import build_pkg
import gleam/io
import gleam/result
import mode
import package
import shellout

pub fn run(mode: mode.Mode) -> Result(Nil, String) {
  use pkg <- result.try(package.from_file("Tailor.toml"))

  case pkg.pkg_type {
    package.Bin -> run_binary(mode)
    package.Lib -> Error("Running libraries is not supported")
  }
}

fn run_binary(mode: mode.Mode) -> Result(Nil, String) {
  use _ <- result.try(build_pkg.run(mode))

  let mode_name = mode.mode2string(mode)

  use pkg <- result.try(package.from_file("Tailor.toml"))

  use _ <- result.try(
    shellout.command(
      run: "build/" <> mode_name <> "/" <> pkg.name,
      in: ".",
      opt: [],
      with: [],
    )
    |> result.map(with: fn(output) { io.print(output) })
    |> result.replace_error("Failed to run package"),
  )

  Ok(Nil)
}
