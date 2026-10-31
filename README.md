# unmbt/native-toolchain

Deterministic native compiler and linker discovery for MoonBit build tools.

The package centralizes the host and environment handling shared by native
CLI, HTTP, and Node-API build scripts. It discovers the compiler, linker,
archiver, symbol tool, and SDK while keeping explicit `MOON_CC`, `MOON_LINK`,
`MOON_AR`, and `MOON_NM` overrides authoritative. Missing explicit tools are
reported as diagnostics instead of silently falling back to another tool.

## Install

```bash
moon add unmbt/native-toolchain
```

Then import the package from MoonBit:

```moonbit
import "unmbt/native-toolchain"
```

## Example

```moonbit
let toolchain = @native_toolchain.discover()
match toolchain.compiler {
  Some(tool) => println("native compiler: " + tool.path)
  None => for diagnostic in toolchain.diagnostics { println(diagnostic) }
}
```

`discover(builder~="auto")` selects `cl`/`link`/`lib`/`dumpbin` on Windows
and `cc`/`ar`/`nm` on POSIX hosts. Set an explicit builder name when a project
uses a non-default compiler. `Toolchain::is_usable` requires a compiler and
linker and no diagnostics; the optional archiver, symbol tool, SDK, and tool
paths remain available to callers that need to construct a native build.

## Supported targets

The package targets native and is intended for host-side build and release
tools. It does not embed a compiler or ship platform binaries.

## License

MIT
