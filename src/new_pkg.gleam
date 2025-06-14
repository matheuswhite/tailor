import filepath
import gleam/bool
import gleam/io
import gleam/result
import gleam/string
import simplifile
import utils

pub fn run(pkg_name: String, pkg_type: String) -> Result(Nil, String) {
  case pkg_type {
    "--lib" -> new_library_package(pkg_name)
    "--bin" -> new_binary_package(pkg_name)
    _ -> Error("Unknown package type: " <> pkg_type)
  }
}

const bin_main_c = "#include <stdio.h>

int main() {
  printf(\"Hello, World!\\n\");

  return 0;
}
"

const bin_tailor_manifest = "name = \"$pkg_name\"
version = \"0.1.0\"

[dependencies]
"

fn new_binary_package(pkg_path: String) -> Result(Nil, String) {
  use _ <- result.try(
    simplifile.is_directory(pkg_path)
    |> result.unwrap(False)
    |> bool.negate
    |> utils.bool2result("Directory already exists: " <> pkg_path),
  )

  use _ <- result.try(
    simplifile.create_directory_all(pkg_path <> "/src")
    |> result.replace_error("Failed to create src directory"),
  )

  use _ <- result.try(
    simplifile.create_directory_all(pkg_path <> "/include")
    |> result.replace_error("Failed to create include directory"),
  )

  use _ <- result.try(
    simplifile.write(to: pkg_path <> "/src/main.c", contents: bin_main_c)
    |> result.replace_error("Failed to create main.c file"),
  )

  let pkg_name = filepath.base_name(pkg_path)

  let tailor_content =
    bin_tailor_manifest |> string.replace(each: "$pkg_name", with: pkg_name)
  use _ <- result.try(
    simplifile.write(to: pkg_path <> "/Tailor.toml", contents: tailor_content)
    |> result.replace_error("Failed to write Tailor.toml file"),
  )

  io.println("Creating binary (application) package `" <> pkg_name <> "`")

  Ok(Nil)
}

const lib_pkg_source = "#include \"$pkg_name/$pkg_name.h\"
#include <stdio.h>

void $pkg_name() {
  printf(\"Hello from the $pkg_name library!\\n\");
}
"

const lib_pkg_header = "#ifndef $pkg_name_guard
#define $pkg_name_guard

void $pkg_name();

#endif /* $pkg_name_guard */
"

const lib_tailor_manifest = "name = \"$pkg_name\"
version = \"0.1.0\"
type = \"lib\"

[dependencies]
"

fn new_library_package(pkg_path: String) -> Result(Nil, String) {
  use _ <- result.try(
    simplifile.is_directory(pkg_path)
    |> result.unwrap(False)
    |> bool.negate
    |> utils.bool2result("Directory already exists: " <> pkg_path),
  )

  use _ <- result.try(
    simplifile.create_directory_all(pkg_path <> "/src")
    |> result.replace_error("Failed to create src directory"),
  )

  let pkg_name = filepath.base_name(pkg_path)

  use _ <- result.try(
    simplifile.create_directory_all(pkg_path <> "/include/" <> pkg_name)
    |> result.replace_error("Failed to create include directory"),
  )

  let pkg_source =
    lib_pkg_source |> string.replace(each: "$pkg_name", with: pkg_name)

  let pkg_header =
    lib_pkg_header
    |> string.replace(
      each: "$pkg_name_guard",
      with: string.uppercase(pkg_name) <> "_H",
    )
    |> string.replace(each: "$pkg_name", with: pkg_name)

  let tailor_content =
    lib_tailor_manifest |> string.replace(each: "$pkg_name", with: pkg_name)

  use _ <- result.try(
    simplifile.write(
      to: pkg_path <> "/src/" <> pkg_name <> ".c",
      contents: pkg_source,
    )
    |> result.replace_error("Failed to create source file"),
  )

  use _ <- result.try(
    simplifile.write(
      to: pkg_path <> "/include/" <> pkg_name <> "/" <> pkg_name <> ".h",
      contents: pkg_header,
    )
    |> result.replace_error("Failed to create header file"),
  )

  use _ <- result.try(
    simplifile.write(to: pkg_path <> "/Tailor.toml", contents: tailor_content)
    |> result.replace_error("Failed to write Tailor.toml file"),
  )

  io.println("Creating library package `" <> pkg_name <> "`")

  Ok(Nil)
}
