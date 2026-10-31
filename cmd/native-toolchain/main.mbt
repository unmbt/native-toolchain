///|
async fn main {
  let args = @env.args()
  let builder = match args {
    [_, "discover", .. rest] => if rest is [name, ..] { name } else { "auto" }
    _ => "auto"
  }
  let result = @toolchain.discover(builder~)
  let compiler = result.compiler.map(tool => tool.path).unwrap_or("")
  let linker = result.linker.map(tool => tool.path).unwrap_or("")
  let archiver = result.archiver.map(tool => tool.path).unwrap_or("")
  let symbol_tool = result.symbol_tool.map(tool => tool.path).unwrap_or("")
  let sdk = result.sdk.unwrap_or("")
  println(
    "{\"usable\":\{Json(result.is_usable()).stringify()},\"compiler\":\{Json(compiler).stringify()},\"linker\":\{Json(linker).stringify()},\"archiver\":\{Json(archiver).stringify()},\"symbol_tool\":\{Json(symbol_tool).stringify()},\"sdk\":\{Json(sdk).stringify()},\"diagnostics\":\{Json(result.diagnostics).stringify()}}",
  )
  if !result.is_usable() {
    fail("native toolchain is incomplete")
  }
}
