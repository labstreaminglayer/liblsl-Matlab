function hlib = lsl_loadlib(binarypath,debugging,keep_persistent)
% Load the lab streaming layer library.
% [LibHandle] = lsl_loadlib(BinaryPath,DebugVersion)
%
% This operation loads the library, after which its functions (starting with lsl_) can be used.
%
% In:
%   BinaryPath : Optionally the path to the locations of the liblsl bin folder (default: relative
%                to this .m file).
%
%   DebugVersion : Optionally load the debug version of the library (default: false)
%
%   Persistent : keep the library handle around until shutdown (default: true)
%
% Out:
%   Handle : handle to the library
%            when the handle is deleted, the library will be unloaded
%
% Notes:
%   Do not delete this handle while you still have LSL objects (streaminfos, inlets, outlets)
%   alive.
%
%                                Christian Kothe, Swartz Center for Computational Neuroscience, UCSD
%                                2012-03-05

if ~exist('binarypath','var') || isempty(binarypath)
    binarypath = [];
end
if ~exist('debugging','var') || isempty(debugging)
    debugging = false; 
end
if ~exist('keep_persistent','var') || isempty(keep_persistent)
    keep_persistent = true; 
end
    
persistent lib;
if keep_persistent && ~isempty(lib)
    hlib = lib;
else   
    dllpath = lsl_get_dll(binarypath, debugging);

    % open the library and make sure that it gets auto-deleted when the handle is erased
    try
        hlib = lsl_loadlib_(dllpath);
    catch e
        disp('See https://github.com/labstreaminglayer/liblsl-Matlab/#troubleshooting for further troubleshooting tips');
        error(['Error loading the liblsl library: ', e.message,...
            ' Make sure liblsl-Matlab/bin is added to path and try running build_mex.m']);
    end

    hlib.on_cleanup = onCleanup(@()lsl_freelib_(hlib));
    
    if keep_persistent
        lib = hlib; end
end
