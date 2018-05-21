#!/usr/bin/env bash

set -euo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR="$DIR/build"

# Enter the directory and start the build process for service stubs.
function buildDir {
  currentDir="$1"

  pushd "$currentDir" > /dev/null

  target=$(basename $currentDir)

  if [ -f .protolangs ]; then
    print "Building directory: '$currentDir'"

    while read lang; do
      repo="twirp-$target-$lang"
      build_dir="$BUILD_DIR/$repo"

      rm -rf "$build_dir"
      print "Cloning repo: git@github.com:thingful/$repo.git"
      git clone "git@github.com:thingful/$repo.git" "$build_dir"

      case "$lang" in
        go)
          protoc --proto_path=. --twirp_out="$build_dir" --go_out="$build_dir" *.proto
          ;;

        ruby)
          protoc --proto_path=. --ruby_out="$build_dir" --twirp_ruby_out="$build_dir" *.proto
          ;;

        node)
          protoc --twirp_out="$build_dir" --twirp_js_out="$build_dir" --js_out="import_style=commonjs,binary:$build_dir" *.proto
          ;;

        *)
          echo "--> Unknown language - currently supported languages are: go, ruby, js"
          exit 1
      esac

      commitAndPush "$build_dir"

    done < .protolangs
  fi

  popd > /dev/null
}

# Finds all directories and builds proto buffer definitions
function buildAll {
  print "Building protocol buffer stubs"

  clean

  find "$DIR" -type d -not -path '*/\.*' | while read d; do
    buildDir "$d"
  done
}

# Cleans our build directories
function clean {
  print "Cleaning build directories"

  rm -rf "$BUILD_DIR"
}

function commitAndPush {
  print "Committing and pushing from $1"

  pushd "$1" > /dev/null

  git add -N .

  if ! git diff --exit-code > /dev/null; then
    print "Changes detected"
    git add .
    git commit -m "Automatic rebuild of Twirp stubs"
    git push origin HEAD
  else
    print "No changes detected for $1"
  fi

  popd > /dev/null
}

function print {
  echo "--> $1"
}

"$@"
