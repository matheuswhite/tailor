import argv
import build_pkg
import gleam/io
import mode
import new_pkg
import run_pkg

pub fn main() -> Nil {
  let res = case argv.load().arguments {
    ["new", pkg_name] -> new_pkg.run(pkg_name, "--bin")
    ["new", pkg_type, pkg_name] -> new_pkg.run(pkg_name, pkg_type)
    ["build"] | ["build", "--debug"] -> build_pkg.run(mode.Debug)
    ["build", "--release"] -> build_pkg.run(mode.Release)
    ["run"] | ["run", "--debug"] -> run_pkg.run(mode.Debug)
    ["run", "--release"] -> run_pkg.run(mode.Release)
    _ -> {
      io.println("Usage: tailor new <package_name>")
      Ok(Nil)
    }
  }

  case res {
    Ok(_) -> Nil
    Error(err) -> io.println("Error: " <> err)
  }
}
