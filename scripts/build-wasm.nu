#!/usr/bin/env nu

# Build emf2svg as WebAssembly using Emscripten
# Prerequisites: Emscripten SDK must be activated (emsdk_env.sh sourced)

let project_root = $env.FILE_PWD | path dirname
let dist_dir = $project_root | path join 'wasm-dist'
let build_dir = $project_root | path join 'build-wasm'

print $'Project root: ($project_root)'
print $'Build directory: ($build_dir)'
print $'Dist directory: ($dist_dir)'

# Verify emcmake is available
let emcmake_path = which emcmake
if ($emcmake_path | is-empty) {
    print -e 'Error: emcmake not found. Please activate Emscripten SDK first.'
    exit 1
}

# Clean and create build directory
if ($build_dir | path exists) {
    rm -r $build_dir
}
mkdir $build_dir

# Configure with emcmake
print 'Configuring with emcmake cmake...'
(emcmake cmake
    -B $build_dir
    -S $project_root
    -DCMAKE_BUILD_TYPE=Release)

# Build
print 'Building...'
cmake --build $build_dir --config Release

# Create dist directory and copy artifacts
if ($dist_dir | path exists) {
    rm -r $dist_dir
}
mkdir $dist_dir

let mjs_file = $build_dir | path join 'emf2svg.mjs'
let wasm_file = $build_dir | path join 'emf2svg.wasm'

if (not ($wasm_file | path exists)) or (not ($mjs_file | path exists)) {
    print -e 'Error: WASM build artifacts not found.'
    ls ($build_dir | path join 'emf2svg*')
    exit 1
}

cp $mjs_file $dist_dir
cp $wasm_file $dist_dir

# Optimize WASM with wasm-opt (bundled in Emscripten SDK)
let dist_wasm = $dist_dir | path join 'emf2svg.wasm'
let opt_wasm = $dist_dir | path join 'emf2svg.opt.wasm'
let wasm_opt_bin = $env.EMSDK | path join 'upstream' 'bin' 'wasm-opt'
print $'Optimizing WASM with ($wasm_opt_bin)...'
let before_size = (ls $dist_wasm | get size | first)
^$wasm_opt_bin -O3 --all-features $dist_wasm -o $opt_wasm
let after_size = (ls $opt_wasm | get size | first)
print $'WASM optimized: ($before_size) -> ($after_size)'

print $'Build complete! Artifacts in ($dist_dir):'
ls $dist_dir
