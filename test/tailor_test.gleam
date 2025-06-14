import build_pkg
import dependency
import gleam/result
import gleam/string
import gleeunit
import mode
import new_pkg
import package
import run_pkg
import simplifile

pub fn main() -> Nil {
  let assert Ok(_) =
    simplifile.delete_all([
      "test_build_bin", "test_build_lib", "test_bin", "dir1", "dir3",
      "test_run_bin", "test_run_lib",
    ])
  gleeunit.main()
}

pub fn from_file_basic_test() {
  let expected_package =
    package.Package(
      name: "basic",
      version: "0.1.0",
      dependencies: [],
      pkg_type: package.Bin,
      sources: ["src/*.c"],
      includes: ["include/"],
    )

  let package = package.from_file("res/basic/Tailor.toml")

  assert package == Ok(expected_package)
}

pub fn from_file_deps_test() {
  let expected_package =
    package.Package(
      name: "deps",
      version: "0.1.0",
      dependencies: [
        dependency.Registy(name: "backpack", version: "0.3.0"),
        dependency.Registy(name: "hello", version: "0.1.0"),
        dependency.Git(
          name: "lua",
          revision: "main",
          url: "https://github.com/lua/lua.git",
        ),
        dependency.Local(name: "zephyr", path: "../zephyr/"),
      ],
      pkg_type: package.Bin,
      sources: ["src/*.c"],
      includes: ["include/"],
    )

  let package = package.from_file("res/deps/Tailor.toml")

  assert package == Ok(expected_package)
}

pub fn from_file_lib_test() {
  let expected_package =
    package.Package(
      name: "lib",
      version: "0.1.0",
      dependencies: [],
      pkg_type: package.Lib,
      sources: ["src/*.c"],
      includes: ["include/"],
    )

  let package = package.from_file("res/lib/Tailor.toml")

  assert package == Ok(expected_package)
}

pub fn from_file_content_test() {
  let expected_package =
    package.Package(
      name: "content",
      version: "0.1.0",
      dependencies: [],
      pkg_type: package.Bin,
      sources: ["src/main.c"],
      includes: ["."],
    )

  let package = package.from_file("res/content/Tailor.toml")

  assert package == Ok(expected_package)
}

pub fn new_pkg_bin_test() {
  let pkg_name = "test_bin"
  assert Ok(Nil) == new_pkg.run(pkg_name, "--bin")

  assert Ok(True) == simplifile.is_file(pkg_name <> "/src/main.c")
  assert Ok(
      "#include <stdio.h>

int main() {
  printf(\"Hello, World!\\n\");

  return 0;
}
",
    )
    == simplifile.read(pkg_name <> "/src/main.c")

  assert Ok(True) == simplifile.is_file(pkg_name <> "/Tailor.toml")
  assert Ok(
      "name = \"test_bin\"
version = \"0.1.0\"

[dependencies]
",
    )
    == simplifile.read(pkg_name <> "/Tailor.toml")

  simplifile.delete("test_bin")
}

pub fn new_pkg_lib_test() {
  let pkg_name = "test_lib"
  assert Ok(Nil) == new_pkg.run(pkg_name, "--lib")

  assert Ok(True) == simplifile.is_file(pkg_name <> "/src/test_lib.c")
  assert Ok(
      "#include \"test_lib/test_lib.h\"
#include <stdio.h>

void test_lib() {
  printf(\"Hello from the test_lib library!\\n\");
}
",
    )
    == simplifile.read(pkg_name <> "/src/test_lib.c")

  assert Ok(True)
    == simplifile.is_file(pkg_name <> "/include/test_lib/test_lib.h")
  assert Ok(
      "#ifndef TEST_LIB_H
#define TEST_LIB_H

void test_lib();

#endif /* TEST_LIB_H */
",
    )
    == simplifile.read(pkg_name <> "/include/test_lib/test_lib.h")

  assert Ok(True) == simplifile.is_file(pkg_name <> "/Tailor.toml")
  assert Ok(
      "name = \"test_lib\"
version = \"0.1.0\"
type = \"lib\"

[dependencies]
",
    )
    == simplifile.read(pkg_name <> "/Tailor.toml")

  let _ = simplifile.delete("test_lib")
}

pub fn new_pkg_bin_path_test() {
  let pkg_path = "dir1/dir2/test_bin"
  assert Ok(Nil) == new_pkg.run(pkg_path, "--bin")

  assert Ok(True) == simplifile.is_file(pkg_path <> "/src/main.c")
  assert Ok(
      "#include <stdio.h>

int main() {
  printf(\"Hello, World!\\n\");

  return 0;
}
",
    )
    == simplifile.read(pkg_path <> "/src/main.c")

  assert Ok(True) == simplifile.is_file(pkg_path <> "/Tailor.toml")
  assert Ok(
      "name = \"test_bin\"
version = \"0.1.0\"

[dependencies]
",
    )
    == simplifile.read(pkg_path <> "/Tailor.toml")

  simplifile.delete("dir1")
}

pub fn new_pkg_lib_path_test() {
  let pkg_path = "dir3/dir4/test_lib"
  assert Ok(Nil) == new_pkg.run(pkg_path, "--lib")

  assert Ok(True) == simplifile.is_file(pkg_path <> "/src/test_lib.c")
  assert Ok(
      "#include \"test_lib/test_lib.h\"
#include <stdio.h>

void test_lib() {
  printf(\"Hello from the test_lib library!\\n\");
}
",
    )
    == simplifile.read(pkg_path <> "/src/test_lib.c")

  assert Ok(True)
    == simplifile.is_file(pkg_path <> "/include/test_lib/test_lib.h")
  assert Ok(
      "#ifndef TEST_LIB_H
#define TEST_LIB_H

void test_lib();

#endif /* TEST_LIB_H */
",
    )
    == simplifile.read(pkg_path <> "/include/test_lib/test_lib.h")

  assert Ok(True) == simplifile.is_file(pkg_path <> "/Tailor.toml")
  assert Ok(
      "name = \"test_lib\"
version = \"0.1.0\"
type = \"lib\"

[dependencies]
",
    )
    == simplifile.read(pkg_path <> "/Tailor.toml")

  let _ = simplifile.delete("dir3")
}

pub fn build_pkg_bin_test() {
  let pkg_name = "test_build_bin"
  assert Ok(Nil) == new_pkg.run(pkg_name, "--bin")

  assert Ok(Nil) == build_pkg.run_from_directory(mode.Debug, "test_build_bin")
  assert Ok(True)
    == simplifile.is_file(pkg_name <> "/build/debug/CMakeLists.txt")
  assert Ok(
      "cmake_minimum_required(VERSION 3.10)
project(test_build_bin C)
set(CMAKE_C_STANDARD 99)
file(GLOB src_files $path/test_build_bin/src/*.c)
add_executable(test_build_bin ${src_files})
target_include_directories(test_build_bin PRIVATE $path/test_build_bin/include/)
if (CMAKE_BUILD_TYPE STREQUAL \"Debug\")
  target_compile_definitions(test_build_bin PRIVATE DEBUG)
else()
  target_compile_definitions(test_build_bin PRIVATE RELEASE)
endif()
"
      |> string.replace(
        each: "$path",
        with: simplifile.current_directory() |> result.unwrap("."),
      ),
    )
    == simplifile.read(pkg_name <> "/build/debug/CMakeLists.txt")
  assert Ok(True)
    == simplifile.is_file(pkg_name <> "/build/debug/test_build_bin")

  assert Ok(Nil) == build_pkg.run_from_directory(mode.Release, "test_build_bin")
  assert Ok(True)
    == simplifile.is_file(pkg_name <> "/build/release/CMakeLists.txt")
  assert Ok(
      "cmake_minimum_required(VERSION 3.10)
project(test_build_bin C)
set(CMAKE_C_STANDARD 99)
file(GLOB src_files $path/test_build_bin/src/*.c)
add_executable(test_build_bin ${src_files})
target_include_directories(test_build_bin PRIVATE $path/test_build_bin/include/)
if (CMAKE_BUILD_TYPE STREQUAL \"Debug\")
  target_compile_definitions(test_build_bin PRIVATE DEBUG)
else()
  target_compile_definitions(test_build_bin PRIVATE RELEASE)
endif()
"
      |> string.replace(
        "$path",
        simplifile.current_directory() |> result.unwrap("."),
      ),
    )
    == simplifile.read(pkg_name <> "/build/release/CMakeLists.txt")
  assert Ok(True)
    == simplifile.is_file(pkg_name <> "/build/release/test_build_bin")

  simplifile.delete(pkg_name)
}

pub fn build_pkg_lib_test() {
  let pkg_name = "test_build_lib"
  assert Ok(Nil) == new_pkg.run(pkg_name, "--lib")

  assert Ok(Nil) == build_pkg.run_from_directory(mode.Debug, "test_build_lib")
  assert Ok(True)
    == simplifile.is_file(pkg_name <> "/build/debug/CMakeLists.txt")
  assert Ok(
      "cmake_minimum_required(VERSION 3.10)
project(test_build_lib C)
set(CMAKE_C_STANDARD 99)
file(GLOB src_files $path/test_build_lib/src/*.c)
add_library(test_build_lib STATIC ${src_files})
target_include_directories(test_build_lib PRIVATE $path/test_build_lib/include/)
if (CMAKE_BUILD_TYPE STREQUAL \"Debug\")
  target_compile_definitions(test_build_lib PRIVATE DEBUG)
else()
  target_compile_definitions(test_build_lib PRIVATE RELEASE)
endif()
"
      |> string.replace(
        each: "$path",
        with: simplifile.current_directory() |> result.unwrap("."),
      ),
    )
    == simplifile.read(pkg_name <> "/build/debug/CMakeLists.txt")
  assert Ok(True)
    == simplifile.is_file(pkg_name <> "/build/debug/libtest_build_lib.a")

  assert Ok(Nil) == build_pkg.run_from_directory(mode.Release, "test_build_lib")
  assert Ok(True)
    == simplifile.is_file(pkg_name <> "/build/release/CMakeLists.txt")
  assert Ok(
      "cmake_minimum_required(VERSION 3.10)
project(test_build_lib C)
set(CMAKE_C_STANDARD 99)
file(GLOB src_files $path/test_build_lib/src/*.c)
add_library(test_build_lib STATIC ${src_files})
target_include_directories(test_build_lib PRIVATE $path/test_build_lib/include/)
if (CMAKE_BUILD_TYPE STREQUAL \"Debug\")
  target_compile_definitions(test_build_lib PRIVATE DEBUG)
else()
  target_compile_definitions(test_build_lib PRIVATE RELEASE)
endif()
"
      |> string.replace(
        each: "$path",
        with: simplifile.current_directory() |> result.unwrap("."),
      ),
    )
    == simplifile.read(pkg_name <> "/build/release/CMakeLists.txt")
  assert Ok(True)
    == simplifile.is_file(pkg_name <> "/build/release/libtest_build_lib.a")

  simplifile.delete(pkg_name)
}

pub fn run_pkg_bin_test() {
  let pkg_name = "test_run_bin"
  assert Ok(Nil) == new_pkg.run(pkg_name, "--bin")

  assert Ok(Nil) == run_pkg.run_from_directory(mode.Debug, pkg_name)
  assert Ok(True)
    == simplifile.is_file(pkg_name <> "/build/debug/CMakeLists.txt")
  assert Ok(True) == simplifile.is_file(pkg_name <> "/build/debug/" <> pkg_name)

  assert Ok(Nil) == run_pkg.run_from_directory(mode.Release, pkg_name)
  assert Ok(True)
    == simplifile.is_file(pkg_name <> "/build/release/CMakeLists.txt")
  assert Ok(True)
    == simplifile.is_file(pkg_name <> "/build/release/" <> pkg_name)

  simplifile.delete(pkg_name)
}

pub fn run_pkg_lib_test() {
  let pkg_name = "test_run_lib"
  assert Ok(Nil) == new_pkg.run(pkg_name, "--lib")

  assert Error("Running libraries is not supported")
    == run_pkg.run_from_directory(mode.Debug, pkg_name)
  assert Error("Running libraries is not supported")
    == run_pkg.run_from_directory(mode.Release, pkg_name)

  simplifile.delete(pkg_name)
}
