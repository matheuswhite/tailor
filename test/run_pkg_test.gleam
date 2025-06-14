import gleeunit
import mode
import new_pkg
import run_pkg
import simplifile

pub fn main() -> Nil {
  gleeunit.main()
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
