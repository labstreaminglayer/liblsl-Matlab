function lsl_fname = lsl_get_dll(binarypath, debugging)
% Search for the lsl library
% [lsl_fname] = lsl_get_dll(binarypath, debugging)
%
% In:
%   BinaryPath : Optionally the path to the locations of the liblsl bin folder (default: relative
%                to this .m file).
%
%   DebugVersion : Optionally load the debug version of the library (default: false)
%
% Out:
%   lsl_fname : the filename of the library

if ~exist('binarypath','var') || isempty(binarypath)
    binarypath = [fileparts(mfilename('fullpath')) filesep 'bin'];
end
if ~exist('debugging','var') || isempty(debugging)
    debugging = false;
end

if ispc
    ext = '.dll';
elseif ismac
    ext = '.dylib';
elseif isunix
    ext = '.so';
else
    error('Your operating system is not supported by this version of the lab streaming layer API.');
end

if strfind(computer,'64')
    bitness = '64';
else
    bitness = '32';
end

if debugging
    debug = '-debug';
else
    debug = '';
end

dll_fname = sprintf('liblsl%s%s%s', bitness, debug, ext);
lsl_fname = fullfile(binarypath, dll_fname);

if ~exist(lsl_fname, 'file') && ~ispc
    new_dllpath = fullfile('/usr/lib/', dll_fname);
    if exist(new_dllpath, 'file')
        lsl_fname = new_dllpath;
    end %if
end %if

if ~exist(lsl_fname,'file')
    error(['Apparently the file "' dllpath '" is missing on your computer. Cannot load the lab streaming layer.']);
end

end

