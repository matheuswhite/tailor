import gleam/dict
import gleam/io
import gleam/list
import gleam/result
import tom

pub type Dependency {
  Registy(name: String, version: String)
  Git(name: String, revision: String, url: String)
  Local(name: String, path: String)
}

pub fn from_content(
  name: String,
  content: tom.Toml,
) -> Result(Dependency, String) {
  [
    parse_registry_string_dependency,
    parse_registry_dependency,
    parse_git_dependency,
    parse_local_dependency,
  ]
  |> list.filter_map(fn(parser) { parser(name, content) })
  |> list.first
  |> result.map_error(fn(_) {
    let err = "Invalid dependency"
    io.println(err)
    err
  })
}

fn parse_registry_string_dependency(
  name: String,
  content: tom.Toml,
) -> Result(Dependency, tom.GetError) {
  content
  |> tom.as_string
  |> result.map(fn(version) { Registy(name:, version:) })
}

fn parse_registry_dependency(
  name: String,
  content: tom.Toml,
) -> Result(Dependency, tom.GetError) {
  content
  |> tom.as_table
  |> result.unwrap(dict.from_list([#("", tom.String(""))]))
  |> tom.get_string(["version"])
  |> result.map(fn(version) { Registy(name:, version:) })
}

fn parse_git_dependency(
  name: String,
  content: tom.Toml,
) -> Result(Dependency, tom.GetError) {
  let content =
    content
    |> tom.as_table
    |> result.unwrap(dict.from_list([#("", tom.String(""))]))

  let revision =
    content
    |> tom.get_string(["revision"])

  let url =
    content
    |> tom.get_string(["url"])

  revision
  |> result.map(fn(revision) {
    url
    |> result.map(fn(url) { Git(name:, revision:, url:) })
  })
  |> result.flatten
}

fn parse_local_dependency(
  name: String,
  content: tom.Toml,
) -> Result(Dependency, tom.GetError) {
  content
  |> tom.as_table
  |> result.unwrap(dict.from_list([#("", tom.String(""))]))
  |> tom.get_string(["path"])
  |> result.map(fn(path) { Local(name:, path:) })
}
