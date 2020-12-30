This is the MATLAB interface for liblsl.

## Download & Install

### Official Release

First try getting the latest release for your platform and Matlab version from [the release page](https://github.com/labstreaminglayer/liblsl-Matlab/releases). Unfortunately, Matlab is very strict about using the exact right versions of binaries, and there is no easy way to automate Matlab releases ([see #17](https://github.com/labstreaminglayer/liblsl-Matlab/issues/17)), so it is very much a matter of luck as to whether or not we happen to have a release that will work for you.

### From Source

Instead, you can download the source, the dependencies, and build yourself. This may sound intimidating but we've tried to automate some of the work for you. If you're lucky then it might be easier than you think.

1. Clone or download a zip of this repository from https://github.com/labstreaminglayer/liblsl-Matlab
    * If you downloaded the zip, extract it somewhere convenient.
2. Add an up-to-date build of the liblsl binary to the `liblsl-Matlab/bin/` directory.
    * Option 1: Do nothing and it will download automatically when first required.
        * This might fail, or even if it succeeds in downloading the file, you might still get errors trying to load the library. Try Option 2 next.
    * Option 2: Download precompiled libraries from the [liblsl release page](https://github.com/sccn/liblsl/releases)
        * See [here](https://labstreaminglayer.readthedocs.io/info/faqs.html#binaries) for more information about which library you need.
        * This doesn't always work, unfortunately. Try option 3.
    * Option 3: Build it yourself.
        * [See here](https://labstreaminglayer.readthedocs.io/dev/lib_dev.html) for instructions.
3. Build the mex files.
    * In Matlab: Change Matlab's working directory to this repository's root (i.e., liblsl-Matlab) and run `build_mex`.
    * From the command line: `matlab -nodesktop -nosplash -r 'build_mex'`
    * You may need to install a compiler. [See here for supported compilers](https://www.mathworks.com/support/requirements/supported-compilers.html). For Windows users, this usually means installing [Visual Studio](https://visualstudio.microsoft.com/downloads/).

## How to Use

1. Add the liblsl-Matlab folder to your MATLAB path recursively
    * Using the MATLAB GUI, use File/Set Path...
    * Alternatively, in a script, use `addpath(genpath('path/to/liblsl-Matlab'));`
2. Load the library then call a function.
    * `lib = lsl_loadlib(); version = lsl_library_version(lib)`
3. See the example files in the examples/ directory for more examples of how to use this interface in a MATLAB program.

### Simulink

[See here](https://bitbucket.org/neatlabs/simbsi/wiki/LSL%20signal%20acquisition%20example).

### Troubleshooting

If you get an error similar to `lsl_loadlib_ undefined`, then try following the "From Source" directions above.

On MacOS, you may still get an error similar to `Invalid MEX-file [...] lsl_loadlib_.mexmaci64; Reason: image not found.`. To fix this run the following command in a Terminal window from within the liblsl-Matlab directory: `install_name_tool -add_rpath "@loader_path/" bin/lsl_loadlib_.mexmaci64`

If you still can't get it to work then open an issue here and hopefully someone who has the same platform and Matlab version as you can build and upload a release for you.
