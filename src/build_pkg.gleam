import gleam/bool
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import mode
import package
import shellout
import simplifile
import utils

pub fn run(mode: mode.Mode) -> Result(Nil, String) {
  let mode_name = mode.mode2string(mode)
  use pkg <- result.try(package.from_file("Tailor.toml"))

  let pkg = case pkg.pkg_type {
    package.Bin -> create_binary_cmake_lists(mode_name)
    package.Lib -> create_library_cmake_lists(mode_name)
  }

  use pkg <- result.try(pkg)

  io.println(
    "Building package `" <> pkg.name <> "` in " <> mode_name <> " mode",
  )

  use _ <- result.try(
    shellout.command(
      run: "cmake",
      with: ["-S", "build/" <> mode_name, "-B", "build/" <> mode_name],
      in: ".",
      opt: [],
    )
    |> result.map(with: fn(output) { io.print(output) })
    |> result.map_error(fn(err) {
      io.print(err.1)
      "Failed to run CMake command"
    }),
  )

  use _ <- result.try(
    shellout.command(
      run: "cmake",
      with: ["--build", "build/" <> mode_name],
      in: ".",
      opt: [],
    )
    |> result.map(with: fn(output) { io.print(output) })
    |> result.replace_error("Failed to build package"),
  )

  Ok(Nil)
}

const bin_cmake_lists = "cmake_minimum_required(VERSION 3.10)
project($pkg_name C)
set(CMAKE_C_STANDARD 99)
file(GLOB src_files $sources)
add_executable($pkg_name ${src_files})
target_include_directories($pkg_name PRIVATE $include)
if (CMAKE_BUILD_TYPE STREQUAL \"Debug\")
  target_compile_definitions($pkg_name PRIVATE DEBUG)
else()
  target_compile_definitions($pkg_name PRIVATE RELEASE)
endif()
"

fn create_binary_cmake_lists(
  mode_name: String,
) -> Result(package.Package, String) {
  use _ <- result.try(
    simplifile.is_file("Tailor.toml")
    |> result.unwrap(False)
    |> utils.bool2result("Tailor.toml file not found"),
  )

  use pkg <- result.try(package.from_file("Tailor.toml"))
  let sources =
    pkg.sources
    |> list.map(fn(src) {
      simplifile.current_directory() |> result.unwrap(".") <> "/" <> src
    })
    |> string.join("\n")
  let includes =
    pkg.includes
    |> list.map(fn(inc) {
      simplifile.current_directory() |> result.unwrap(".") <> "/" <> inc
    })
    |> string.join("\n")

  let _ = {
    use _ <- result.try(
      simplifile.is_file("build/" <> mode_name <> "/CMakeLists.txt")
      |> result.unwrap(False)
      |> bool.negate
      |> utils.bool2result(
        "CMakeLists.txt file already exists in build/" <> mode_name,
      ),
    )

    use _ <- result.try(
      simplifile.create_directory_all("build/" <> mode_name)
      |> result.replace_error("Failed to create build directory"),
    )

    use _ <- result.try(
      simplifile.write(
        to: "build/" <> mode_name <> "/CMakeLists.txt",
        contents: bin_cmake_lists
          |> string.replace(each: "$include", with: includes)
          |> string.replace(each: "$sources", with: sources)
          |> string.replace(each: "$pkg_name", with: pkg.name),
      )
      |> result.replace_error("Failed to write Tailor.toml file"),
    )

    Ok(Nil)
  }

  Ok(pkg)
}

const lib_cmake_lists = "cmake_minimum_required(VERSION 3.10)
project($pkg_name C)
set(CMAKE_C_STANDARD 99)
file(GLOB src_files $sources)
add_library($pkg_name STATIC ${src_files})
target_include_directories($pkg_name PRIVATE $include)
if (CMAKE_BUILD_TYPE STREQUAL \"Debug\")
  target_compile_definitions($pkg_name PRIVATE DEBUG)
else()
  target_compile_definitions($pkg_name PRIVATE RELEASE)
endif()
"

fn create_library_cmake_lists(
  mode_name: String,
) -> Result(package.Package, String) {
  use _ <- result.try(
    simplifile.is_file("Tailor.toml")
    |> result.unwrap(False)
    |> utils.bool2result("Tailor.toml file not found"),
  )

  use pkg <- result.try(package.from_file("Tailor.toml"))
  let sources =
    pkg.sources
    |> list.map(fn(src) {
      simplifile.current_directory() |> result.unwrap(".") <> "/" <> src
    })
    |> string.join("\n")
  let includes =
    pkg.includes
    |> list.map(fn(inc) {
      simplifile.current_directory() |> result.unwrap(".") <> "/" <> inc
    })
    |> string.join("\n")

  let _ = {
    use _ <- result.try(
      simplifile.is_file("build/" <> mode_name <> "/CMakeLists.txt")
      |> result.unwrap(False)
      |> bool.negate
      |> utils.bool2result(
        "CMakeLists.txt file already exists in build/" <> mode_name,
      ),
    )

    use _ <- result.try(
      simplifile.create_directory_all("build/" <> mode_name)
      |> result.replace_error("Failed to create build directory"),
    )

    use _ <- result.try(
      simplifile.write(
        to: "build/" <> mode_name <> "/CMakeLists.txt",
        contents: lib_cmake_lists
          |> string.replace(each: "$include", with: includes)
          |> string.replace(each: "$sources", with: sources)
          |> string.replace(each: "$pkg_name", with: pkg.name),
      )
      |> result.replace_error("Failed to write Tailor.toml file"),
    )

    Ok(Nil)
  }

  Ok(pkg)
}
