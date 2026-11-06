#!/usr/bin/env sh
set -e

cd "$(dirname "$0")"
mkdir -p build

config_file="${1:-config-default}"
format="${2:-modern}"
container_name=resume-sandbox-build

if ! docker container inspect "$container_name" >/dev/null 2>&1; then
  docker create --init -i --name "$container_name" \
    -v "$PWD:/src:ro" \
    -v "$PWD/build:/output" \
    ubuntu:24.04
fi

docker start "$container_name" >/dev/null
trap 'docker stop "$container_name" >/dev/null' EXIT

docker exec "$container_name" sh -ec '
      if [ ! -f /dependencies-installed ]; then
        apt-get update
        apt-get install -y --no-install-recommends \
          texlive-luatex texlive-latex-extra texlive-fonts-recommended \
          lua5.3 liblua5.3-dev luarocks libyaml-dev build-essential inkscape
        luarocks --lua-version=5.3 install lyaml
        touch /dependencies-installed
      fi
      if ! kpsewhich tgpagella.sty >/dev/null || ! kpsewhich tgheros.sty >/dev/null || ! kpsewhich tgtermes.sty >/dev/null; then
        apt-get update
        apt-get install -y --no-install-recommends tex-gyre
      fi

      work=$(mktemp -d)
      tar -C /src \
        --exclude=./.git --exclude=./build --exclude=./svg-inkscape \
        -cf - . | tar -C "$work" -xf -

      cd "$work"
      sh build.sh "$1" "$2" </dev/null
      test -s build/resume.pdf
      cp build/resume.pdf /output/resume.pdf
      echo "PASS: PDF saved to build/resume.pdf"
    ' sh "$config_file" "$format"
