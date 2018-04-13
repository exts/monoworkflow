import os
import tables
import strutils
import flowsettings

proc get(settings: SettingsTable, key: string): string =
  if settings.hasKey(key):
    let val = settings[key]
    if val.kind == sString:
      return val.strVal
    else:
      return ""
  return ""

proc getSeq(settings: SettingsTable, key: string): seq[string] =
  if settings.hasKey(key):
    let val = settings[key]
    if val.kind == sSeqString:
      return val.seqVal
    else:
      return @[]
  return @[]

proc build_command(runtime: string, settings: SettingsTable): string =

  let mode = get(settings, "mode")
  let dotnet = get(settings, "dotnet")
  let build_folder = get(settings, "build_folder")
  let self_contained = get(settings, "self_contained")

  let c_folder = if not isNilOrEmpty(build_folder): build_folder & "/" & mode & "/" & runtime else: ""
  let current_folder = if not isNilOrEmpty(c_folder): "-o " & c_folder & " " & self_contained else: "" & self_contained

  return dotnet & " publish -c " & mode & " -r " & runtime & " " & current_folder

proc build_default(settings: SettingsTable) =
  let runtime = get(settings, "runtime")
  discard execShellCmd(build_command(runtime, settings))
  # echo build_command(runtime, settings)

proc build_all(settings: SettingsTable) =
  let runtimes = getSeq(settings, "runtimes")
  for runtime in runtimes:
    discard execShellCmd(build_command(runtime, settings))
    # echo build_command(runtime, settings)

proc build*(args: Table) =

  # lets setup everything and grab the data
  var data = flowsettings.load(args)

  # handle build types
  if args["build_all"]:
    build_all(data)
  elif args["build"]:
    build_default(data)