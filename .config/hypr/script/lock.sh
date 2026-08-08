#!/usr/bin/env bash
# hyprlock via zink (GL-over-Vulkan/ RADV) to bypass the radeonsi+LLVM
# heap-corruption crash on this AMD Krackan (GFX1201) iGPU.
# Move hyprlock to radeonsi again by removing the MESA_LOADER_DRIVER_OVERRIDE line.
exec env MESA_LOADER_DRIVER_OVERRIDE=zink hyprlock --immediate-render "$@"