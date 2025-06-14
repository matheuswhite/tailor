import build_pkg
import gleam/result
import gleam/string
import gleeunit
import mode
import new_pkg
import simplifile

pub fn main() -> Nil {
  gleeunit.main()
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
