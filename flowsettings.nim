import json
import docopt
import tables
import strutils
import typetraits

# getto fucking union types...
type
  SettingKind* = enum
    sString,
    sSeqString
  Setting* = ref object
    case kind*: SettingKind
      of sString: strVal*: string
      of sSeqString: seqVal*: seq[string]

type SettingsTable* = Table[string, Setting]

# default values loaded from settings file
var dotnet = "dotnet"
var build_folder = ""
var self_contained = false
var build_all_runtines = @[
  "osx-x64",
  "win-x64",
  "linux-x64",
]

# default values
let settings_file = "monoflow.json"
let default_release_type = "Debug"
let default_runtime = "win-x64"
let supported_runtime_ids = @[
  "osx-x64",
  "win-x64",
  "linux-x64",
  "centos-x64",
  "debian-x64",
  "fedora-x64",
  "ubuntu-x64",
  "opensuse-x64",
]

# process folder path
proc get_folder_path(args: Table, folder: string, mode: string, runtime: string): string =
  let c_mode = capitalizeAscii(toLowerAscii(mode))
  let c_runtime = toLowerAscii(runtime)

  # get folder
  let c_folder = if $args["--f"] == "nil": folder else: $args["--f"]

  return c_folder & "/" & c_mode & "/" & c_runtime

# load settings if available
proc load_settings(file: string, args: Table) =
  try:
    let data = json.parseFile(file)

    if data.hasKey("build_folder"):
      build_folder = data["build_folder"].getStr()

    if $args["--f"] != "nil":
      build_folder = $args["--f"]
    
    if data.hasKey("self_contained"):
      self_contained = data["self_contained"].getBool()

    if data.hasKey("dotnet"):
      dotnet = data["dotnet"].getStr()

    # override self contained
    if args["-s"] == true:
      self_contained = true

    # get build all data to override
    if data.hasKey("build_all") and data["build_all"].kind == JArray:
      var runtimes = data["build_all"].getElems()
      if runtimes.len > 0:
        build_all_runtines = @[]
        for rt in runtimes:
          build_all_runtines.add(rt.getStr())
  except:
    discard

# Get the release type of the dotnet release 
proc get_release_type(args: Table): string =
  if args["-d"] == true:
    "Debug"
  elif args["-r"] == true:
    "Release"
  else:
    default_release_type

# Get available runtime if available
proc get_runtime(args: Table): string =
  if args["<runtime>"] and $args["<runtime>"] == "nil":
    return default_runtime

  var runtime = args["<runtime>"]

  # check if runtime exists
  for rt in supported_runtime_ids:
    if rt == $runtime:
      return rt

  default_runtime

proc load*(args: Table): SettingsTable =

  load_settings(settings_file, args)

  let mode = get_release_type(args)
  let runtime = get_runtime(args)

  var settings = initTable[string, Setting]()
  settings.add("mode", Setting(kind: sString, strVal: mode))
  settings.add("dotnet", Setting(kind: sString, strVal: dotnet))
  settings.add("folder", Setting(kind: sString, strVal: get_folder_path(args, build_folder, mode, runtime)))
  settings.add("build_folder", Setting(kind: sString, strVal: build_folder))
  settings.add("runtime", Setting(kind: sString, strVal: runtime))
  settings.add("runtimes", Setting(kind: sSeqString, seqVal: build_all_runtines))
  settings.add("self_contained", Setting(kind: sString, strVal: if self_contained: "--self-contained" else: ""))

  return settings