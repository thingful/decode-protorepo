#!/usr/bin/env bash

set -euo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR="$DIR/build"

# Enter the directory and start the build process for service stubs.
function buildDir {
  currentDir="$1"

  pushd "$currentDir" > /dev/null

  target=$(basename "$currentDir")

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
          retool do protoc --proto_path=. --twirp_out="$build_dir" --go_out="$build_dir" ./*.proto
          ;;

        ruby)
          retool do protoc --proto_path=. --ruby_out="$build_dir" --twirp_ruby_out="$build_dir" ./*.proto
          ;;

        node)
          retool do protoc --twirp_out="$build_dir" --twirp_js_out="$build_dir" --js_out="import_style=commonjs,binary:$build_dir" ./*.proto
          ;;

        *)
          print "Unknown language - currently supported languages are: go, ruby, js"
          exit 1
      esac

      sed -e "s|ARG_REPO_NAME|$repo|g" \
          -e "s|ARG_LANG|$lang|g" \
          -e "s|ARG_TARGET|$target|g" \
          "$DIR/.README.template" > "$build_dir/README.md"

      cp -f "$DIR/LICENSE" "$build_dir/LICENSE"

      if [ "$2" = true ]; then
        commitAndPush "$build_dir"
      fi

    done < .protolangs
  fi

  popd > /dev/null
}

# Finds all directories and builds proto buffer definitions
function buildAll {
  print "Building protocol buffer stubs"

  clean

  find "$DIR" -type d -not -path '*/\.*' | while read d; do
    buildDir "$d" "${1:-false}"
  done
}

# Cleans our build directories
function clean {
  print "Cleaning build directories"

  echo $BUILD_DIR
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
