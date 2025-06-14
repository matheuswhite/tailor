import dependency
import gleam/dict
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile
import tom

pub type PackageType {
  Bin
  Lib
}

pub type Package {
  Package(
    name: String,
    version: String,
    dependencies: List(dependency.Dependency),
    pkg_type: PackageType,
    sources: List(String),
    includes: List(String),
  )
}

pub fn from_file(filepath: String) -> Result(Package, String) {
  use content <- result.try(
    simplifile.read(from: filepath)
    |> result.replace_error("[package:29] File " <> filepath <> " not found"),
  )

  from_content(content)
}

pub fn from_content(content: String) -> Result(Package, String) {
  use parsed <- result.try(
    tom.parse(content) |> result.replace_error("Fail to parse TOML"),
  )

  use name <- result.try(
    parsed
    |> tom.get_string(["name"])
    |> result.replace_error("Fail to get package name"),
  )
  use version <- result.try(
    parsed
    |> tom.get_string(["version"])
    |> result.replace_error("Fail to get package version"),
  )
  let dependencies =
    parsed
    |> tom.get_table(["dependencies"])
    |> result.map(fn(dependencies) {
      dependencies
      |> dict.map_values(fn(name, dep) { dependency.from_content(name, dep) })
      |> dict.values
      |> list.filter_map(fn(x) { x })
    })
    |> result.unwrap([])

  let pkg_type = parsed |> tom.get_string(["type"]) |> result.unwrap("bin")
  use pkg_type <- result.try(case pkg_type {
    "bin" -> Ok(Bin)
    "lib" -> Ok(Lib)
    _ -> Error("Invalid package type")
  })

  let sources =
    parsed
    |> tom.get_array(["src"])
    |> result.map(fn(sources) {
      sources
      |> list.map(fn(src) {
        src
        |> tom.as_string
        |> result.map_error(fn(err) {
          io.println("Invalid src")
          err
        })
        |> result.unwrap("")
      })
      |> list.filter(fn(src) { !string.is_empty(src) })
    })
    |> result.unwrap(["src/*.c"])

  let includes =
    parsed
    |> tom.get_array(["include"])
    |> result.map(fn(includes) {
      includes
      |> list.map(fn(inc) { inc |> tom.as_string |> result.unwrap("") })
      |> list.filter(fn(inc) { !string.is_empty(inc) })
    })
    |> result.unwrap(["include/"])

  Package(name:, version:, dependencies:, pkg_type:, sources:, includes:) |> Ok
}
