# !! ARCHIVED  !!  
# This repository merged into PSPSDK

<br><br><br>
# PSP Dynamic Libraries

Dynamic PRX libraries for PSP.

## Usage

Include whichever PRX a homebrew application needs and link the application
against the corresponding stub library, for example `libpng_stub` rather than
the static implementation. The PRX can then be loaded with the PSP module
loading APIs or, on supported custom firmware, through the utility-module
loading mechanism.

Dynamic libraries allow code to be loaded and unloaded on demand, shared by
multiple applications, and updated independently of applications that consume
their stable stub interfaces.

## Build model

CMake is the only supported build path for this repository. The former root and
per-component Makefiles were removed so the release build cannot diverge from
the CMake build.

The project consumes CFW headers and stub libraries from the installed PSPSDK.
It does not fetch or download a separate `psp-cfw-sdk` tree. Install the CFW
portion of [StochasticEagle/pspsdk](https://github.com/StochasticEagle/pspsdk/tree/dev/fork)
before configuring this repository.

CI pins that PSPSDK dependency to commit
`9702264002efcbaef95e2e72a7e5ea3699165a85` and then builds its integrated
CFW support with `build-cfw-and-install.sh`. Updating that dependency is an
explicit repository change rather than a floating `main` or `latest`
dependency.

The source-built PRXs also require these PSP packages:

- `bzip2`
- `liblzma`
- `libpng`
- `libpspav`
- `libpspftp`
- `unarr`
- `zlib`

They can be installed with `psp-pacman`.

## Building

With `$PSPDEV` set and the required PSPSDK/CFW interfaces installed:

```sh
cmake -S . -B build -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE="$PSPDEV/psp/share/pspdev.cmake" \
  -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
```

The complete release set is staged in:

```text
build/dist/LIBS/
```

CMake builds all source components, including `LibPNG` and `Unarchiver`,
which previously existed only in the Make build path. The release set contains
ten source-built PRXs and five explicitly versioned pre-built PRXs.

## Pre-built PRX policy

The files under `pre-built/` remain versioned binary inputs because this
repository does not currently contain complete, verified reproduction recipes
for them. They are explicitly enumerated by CMake; the build does not glob the
directory.

Their current Git blob identities and reproduction status are documented in
[`pre-built/README.md`](pre-built/README.md). A pre-built PRX should be
replaced by a source build only after its source provenance, toolchain inputs,
and output compatibility can be reproduced and verified. Until then, changing
one of those binaries is an intentional versioned repository change.
