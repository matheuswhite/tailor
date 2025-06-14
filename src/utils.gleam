pub fn bool2result(b: Bool, err: value) -> Result(Nil, value) {
  case b {
    True -> Ok(Nil)
    False -> Error(err)
  }
}
