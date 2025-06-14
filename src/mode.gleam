pub type Mode {
  Debug
  Release
}

pub fn mode2string(mode: Mode) -> String {
  case mode {
    Debug -> "debug"
    Release -> "release"
  }
}
