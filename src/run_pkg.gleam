import build_pkg
import gleam/io
import gleam/result
import mode
import package
import shellout
import simplifile

pub fn run_from_directory(mode: mode.Mode, path: String) -> Result(Nil, String) {
  let mode_name = mode.mode2string(mode)
  let abs_path =
    simplifile.current_directory() |> result.unwrap(".") <> "/" <> path
  use pkg <- result.try(package.from_file(abs_path <> "/Tailor.toml"))

  case pkg.pkg_type {
    package.Bin -> {
      use _ <- result.try(build_pkg.run_from_directory(mode, path))

      use _ <- result.try(
        shellout.command(
          run: "build/" <> mode_name <> "/" <> pkg.name,
          in: abs_path,
          opt: [],
          with: [],
        )
        |> result.map(with: fn(output) { io.print(output) })
        |> result.replace_error("Failed to run package"),
      )

      Ok(Nil)
    }
    package.Lib -> Error("Running libraries is not supported")
  }
}

pub fn run(mode: mode.Mode) -> Result(Nil, String) {
  run_from_directory(mode, ".")
}
