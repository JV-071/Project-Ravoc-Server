# Build diagnostics
This server was split from https://github.com/flp159/Project-Ravoc, preserving its folder history and original license.
Windows Debug and RelWithDebInfo use existing Ninja presets; production optimizations remain unchanged.
Separate persistent caches cover dependency packages, downloads and compiler objects. Each stage records exit status, elapsed seconds and full output.
Diagnostics include runner/compiler versions, CMake configuration, compiler cache statistics and CTest JUnit. Unit tests fail when none are discovered.
Server database integration tests require a separately configured database and are not executed by the Windows unit-test job.
Cold and warm runs must pass before improvements are considered measured. Legacy workflows are retained with .reference suffixes; automatic release publication is disabled.
