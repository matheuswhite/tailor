import gleeunit
import new_pkg
import simplifile

pub fn main() -> Nil {
  gleeunit.main()
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
