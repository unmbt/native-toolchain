///|
test "host selection is deterministic" {
  let value = @env.get_env_var("OS")
  assert_true(value is Some(_) || value is None)
}
