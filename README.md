# Usage

    monoworkflow build [<runtime>] [-r | -d] [--f=<folder>] [-s]
    monoworkflow build_all [-r | -d] [--f=<folder>] [-s]

# Json File Explanation

- dotnet - represents the path to your dotnet exe, if it's in your path just use the command that's set
- build_folder - is the build folder that you're publishing your dotnet application to
- self_contained - adds a '--self-contained' command to the dotnet command
- build_all - is the default RID's that it'll build in your release/debug folder.

Pretty simple stuff. 