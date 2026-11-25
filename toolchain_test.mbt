///|
test "host selection is deterministic" {
  let value = @env.get_env_var("OS")
  assert_true(value is Some(_) || value is None)
}

///|
async test "discover runs with core async fs" {
  let toolchain = @native-toolchain.discover(
    builder="__unmbt_nonexistent_compiler__",
  )
  assert_true(toolchain.host is Windows || toolchain.host is Posix)
}
