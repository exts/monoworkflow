import os
import tables
import strutils
import flowsettings

proc get[T](settings: SettingsTable, key: string): T =
  if settings.hasKey(key):
    let val = settings[key]
    
    if (T is string) and val.kind == sString:
      return cast[T](val.strVal)
    elif (T is seq[string]) and val.kind == sSeqString:
      return cast[T](val.seqVal)

  raise newException(IndexError, "Invalid Settings Key")

proc build_command(runtime: string, settings: SettingsTable): string =

  let mode = get[string](settings, "mode")
  let dotnet = get[string](settings, "dotnet")
  let build_folder = get[string](settings, "build_folder")
  let self_contained = get[string](settings, "self_contained")

  let c_folder = if not isNilOrEmpty(build_folder): build_folder & "/" & mode & "/" & runtime else: ""
  let current_folder = if not isNilOrEmpty(c_folder): "-o " & c_folder & " " & self_contained else: "" & self_contained

  return dotnet & " publish -c " & mode & " -r " & runtime & " " & current_folder

proc build_default(settings: SettingsTable) =
  let runtime = get[string](settings, "runtime")
  discard execShellCmd(build_command(runtime, settings))

proc build_all(settings: SettingsTable) =
  let runtimes = get[seq[string]](settings, "runtimes")
  for runtime in runtimes:
    discard execShellCmd(build_command(runtime, settings))

proc build*(args: Table) =

  # lets setup everything and grab the data
  var data = flowsettings.load(args)

  # handle build types
  if args["build_all"]:
    build_all(data)
  elif args["build"]:
    build_default(data)