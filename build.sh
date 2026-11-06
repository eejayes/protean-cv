#!/usr/bin/env sh
set -e

config_file="${1:-config-default}"
format="${2:-modern}"
case "$config_file" in
  traditional|editorial|technical|classic|sidebar)
    format="$config_file"
    config_file=config-default
    ;;
esac
case "$format" in
  modern) document=resume ;;
  traditional) document=resume-traditional ;;
  editorial) document=resume-editorial ;;
  technical) document=resume-technical ;;
  classic) document=resume-classic ;;
  sidebar) document=resume-sidebar ;;
  *) echo "Unknown format: $format (use modern, traditional, editorial, technical, classic, or sidebar)" >&2; exit 1 ;;
esac

mkdir -p build
for pass in 1 2; do
  lualatex --jobname=resume --output-directory=build --shell-escape "\def\configfile{"$config_file"} \input{$document}"
done
