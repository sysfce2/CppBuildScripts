# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

CppBuildScripts is a small, self-contained collection of CMake-driver scripts intended to be **vendored as a git submodule at `build/` inside a host C++ project**. It does not build anything on its own — every script is a thin wrapper around `cmake` / `ctest` / `make` / `MSBuild` for the consumer project that sits one directory above this repo.

There is no source code, no test suite, and no package manifest to update here. The artifact is the scripts themselves.

## Layout and execution contract

Three parallel toolchain directories, each with the same numbered step sequence:

- `Unix/` — `*.sh`, generator `Unix Makefiles`, `make -j4`
- `MinGW/` — `*.bat`, generator `MinGW Makefiles`, `mingw32-make -j4`
- `VisualStudio/` — `*.bat`, generator `Visual Studio 17 2022` (x64), `MSBuild` with `Configuration=RelWithDebInfo`

Numbered steps (consistent across all three toolchains):

1. `01-generate` — `cmake` into `../../temp` with `CMAKE_INSTALL_PREFIX=../../temp/install`
2. `02-build` — build the `all` target
3. `03-tests` — `ctest -V` (Unix tolerates failures with `|| true`; MinGW/VS do not)
4. `04-install` — install into `temp/install`
5. `05-doxygen` — clone the host project's `gh-pages` branch into `documents/html`, build the `doxygen` target, commit, and push. Requires `GITHUB_ACTOR` and `GITHUB_TOKEN` in the environment. **Has real side effects on the host project's remote — don't run while iterating.**
6. `06-clean` — delete `temp/` and `documents/html/`
7. `Unix/07-coverage.sh` — Unix-only: reconfigures with `-DCODE_COVERAGE=ON`, runs ctest, then `gcovr` over `../../include/` and `../../source/`, writes `temp/coverage/coverage.html`, and `open`s it.

Top-level wrappers (`unix.sh`, `mingw.bat`, `vs.bat`) chain steps 01→04, plus 05 only when the `doxygen` env var is set.

### Path assumption — critical

Every script does `cd ../..` from its own directory. They will only work when this repo lives at `<host-project>/build/`. If you run a script from a different working directory or relocate this folder, paths break silently (e.g. you'll generate into a sibling of the wrong project).

### Host project assumptions

These scripts implicitly require the parent directory to contain:
- A top-level `CMakeLists.txt` consumed by step 01.
- A `documents/` directory (for step 05).
- For coverage: `include/` and `source/` directories, a `coverage` ctest target, and a build configured with `-DCODE_COVERAGE=ON`.
- For doxygen: a `doxygen` build target in CMake and a `gh-pages` branch on `origin`.

When changing a step, mirror the change across all three toolchain variants unless the difference is intentional (e.g. `07-coverage.sh` is Unix-only by design, and `Unix/03-tests.sh` swallows test failures while the Windows variants do not).

## Common commands

Run from the **host project root** (one level above this directory), not from inside `build/`:

```sh
# Unix full pipeline (generate, build, test, install)
./build/unix.sh
# With doxygen publish step
doxygen=1 ./build/unix.sh

# Windows (MinGW or Visual Studio)
build\mingw.bat
build\vs.bat
```

Run an individual step (from inside the toolchain directory, which is what the `cd ../..` logic expects):

```sh
cd build/Unix && ./01-generate.sh
cd build/Unix && ./07-coverage.sh
```
