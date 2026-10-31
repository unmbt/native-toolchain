///|
pub(all) enum Host {
  Windows
  Posix
} derive(Debug, Eq)

///|
pub struct Tool {
  pub name : String
  pub path : String
} derive(Debug, Eq)

///|
pub struct Toolchain {
  pub host : Host
  pub compiler : Tool?
  pub linker : Tool?
  pub archiver : Tool?
  pub symbol_tool : Tool?
  pub sdk : String?
  pub diagnostics : Array[String]
} derive(Debug)

///|
/// Resolve the native tools used by HTTP and Node-API builds.
///
/// Explicit MOON_CC, MOON_CXX, MOON_AR, and MOON_NM values are
/// authoritative. An explicit path that does not exist is reported as an
/// error rather than silently replaced by another compiler.
pub async fn discover(builder~ : String = "auto") -> Toolchain {
  let host = if @env.get_env_var("OS") == Some("Windows_NT") {
    Windows
  } else {
    Posix
  }
  let diagnostics : Array[String] = []
  let compiler_name = if builder == "auto" {
    if host is Windows {
      "cl"
    } else {
      "cc"
    }
  } else {
    builder
  }
  let compiler = select_tool("MOON_CC", compiler_name, host, diagnostics)
  let linker = select_tool(
    "MOON_LINK",
    if host is Windows {
      "link"
    } else {
      compiler_name
    },
    host,
    diagnostics,
  )
  let archiver = select_tool(
    "MOON_AR",
    if host is Windows {
      "lib"
    } else {
      "ar"
    },
    host,
    diagnostics,
  )
  let symbol_tool = select_tool(
    "MOON_NM",
    if host is Windows {
      "dumpbin"
    } else {
      "nm"
    },
    host,
    diagnostics,
  )
  let sdk = match host {
    Windows => @env.get_env_var("WindowsSdkDir")
    Posix => @env.get_env_var("SDKROOT")
  }
  { host, compiler, linker, archiver, symbol_tool, sdk, diagnostics, }
}

///|
async fn select_tool(
  variable : String,
  default_name : String,
  host : Host,
  diagnostics : Array[String],
) -> Tool? {
  match @env.get_env_var(variable) {
    Some(explicit) =>
      if !safe_exists(explicit) {
        diagnostics.push(
          variable + " points to a missing executable: " + explicit,
        )
        None
      } else {
        Some({ name: default_name, path: explicit, })
      }
    None => {
      let suffixes = if host is Windows { [".exe", ""] } else { [""] }
      let separator = if host is Windows { ";" } else { ":" }
      let path_value = @env.get_env_var("PATH").unwrap_or("")
      for directory in path_value.split(separator) {
        for suffix in suffixes {
          let candidate = directory.to_owned() + "/" + default_name + suffix
          if safe_exists(candidate) {
            return Some({ name: default_name, path: safe_realpath(candidate), })
          }
        }
      }
      diagnostics.push("tool not found on PATH: " + default_name)
      None
    }
  }
}

///|
async fn safe_exists(path : String) -> Bool {
  @fs.exists(path) catch {
    _ => false
  }
}

///|
async fn safe_realpath(path : String) -> String {
  @fs.realpath(path) catch {
    _ => path
  }
}

///|
pub fn Toolchain::is_usable(self : Toolchain) -> Bool {
  self.diagnostics.is_empty() &&
  self.compiler is Some(_) &&
  self.linker is Some(_)
}
