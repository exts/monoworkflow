import docopt
import monobuild

let doc = """
Usage:
  monoworkflow build [<runtime>] [-r | -d] [--f=<folder>] [-s]
  monoworkflow build_all [-r | -d] [--f=<folder>] [-s]

Options:
  -h, --help
  -test
"""

# setup argument parser
let args = docopt(doc)

# run application
monobuild.build(args)