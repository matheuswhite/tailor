import dependency
import gleeunit
import package

pub fn main() -> Nil {
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
