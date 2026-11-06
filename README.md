# Protean CV Builder

Build a PDF resume from YAML content in a variety of different LaTeX formats, with custom color 
configurations for select formats. 

## Dependencies

Local builds require the following Ubuntu/Debian packages:

| Package | Purpose |
| --- | --- |
| `texlive-luatex` | LuaLaTeX engine and Lua integration packages |
| `texlive-latex-extra` | Additional LaTeX packages; also installs base/recommended packages and TikZ |
| `texlive-fonts-recommended` | Fonts used by the resume, including Helvetica |
| `tex-gyre` | Pagella, Heros, and Termes fonts for the alternative formats |
| `lua5.3`, `liblua5.3-dev` | Lua interpreter and development headers |
| `luarocks` | Installs the Lua YAML module |
| `libyaml-dev`, `build-essential` | YAML library headers and tools to compile the module |
| `inkscape` | SVG-to-PDF conversion for SVG graphics |

The Lua module `lyaml` is also required. For local builds, install the dependencies:

```sh
sudo apt update
sudo apt install \
  texlive-luatex texlive-latex-extra   texlive-fonts-recommended tex-gyre \
  lua5.3 liblua5.3-dev luarocks libyaml-dev build-essential inkscape
sudo luarocks --lua-version=5.3 install lyaml
```

## Customize

Replace the content of `resources/resume_content.yaml` with your own, preserving
the existing YAML structure.

Copy the default configuration and edit its color definitions and theme mappings
to define your own color configuration.

Set `profile.image` in the YAML to select the sidebar portrait, for example
`image: profile_picture.jpeg`. Relative paths are resolved from the YAML file's
directory.

## Build

All resume formats use the same YAML content:

| Argument | Format |
| --- | --- |
| No argument, `config-default`, or `resources/config-a` through `resources/config-h` | Original modern layout, themed section backgrounds and right-margin labels |
| `traditional` | Classic LaTeX serif, horizontal headings, black and white |
| `editorial` | Pagella serif body, Heros sans-serif headings, muted teal accents |
| `technical` | Heros sans-serif, compact spacing, blue accents, muted dates |
| `classic` | Termes serif, small-cap headings, restrained black-and-white styling |
| `sidebar` | Themed photo/contact/skills sidebar on page one; full-width continuation pages |

From the repository root, pass an argument from the table to either build script
(configuration names may omit `.tex`):

```sh
sh build.sh editorial
# Or use Docker instead of local LaTeX dependencies:
./sandbox_build.sh editorial
```

Color configurations apply to the original modern layout and the sidebar format.
For a themed sidebar, use `./sandbox_build.sh resources/config-h sidebar`
(or the same arguments with `sh build.sh`). The shorthand `sidebar` uses
`config-default`. All formats write
`build/resume.pdf`; local builds also leave LaTeX intermediate files in `build/`.

## Docker sandbox (optional)

Follow this instruction if you do not want to install required dependencies on 
your machine.

Install Docker and ensure your user can run Docker commands. You do not need
to install the LaTeX dependencies on your host.

Run the sandbox script with your configuration name (omit `.tex`):

```sh
./sandbox_build.sh resources/config-a
```

With no argument, the script uses `config-default`:

```sh
./sandbox_build.sh
```

The first run creates an Ubuntu 24.04 container named `resume-sandbox-build`
and installs the dependencies inside it. Subsequent runs reuse those installed
dependencies. After editing your content or configuration, run the same command
again; you can choose a different configuration on each run.

Each build copies the latest source into a fresh directory in the container,
excluding previous build and SVG conversion output. The repository is mounted
read-only, except for the host's `build/` directory, where the resulting
`resume.pdf` is copied. The script runs non-interactively and stops the container
when finished, retaining its dependencies for the next run.
