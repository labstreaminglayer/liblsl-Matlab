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
    binarypath = fullfile(fileparts(mfilename('fullpath')), 'bin');
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

if contains(computer,'64')
    bitness = '64';
else
    bitness = '32';
end

if debugging
    debug = '-debug';
else
    debug = '';
end

so_fname = sprintf('liblsl%s%s%s', bitness, debug, ext);
lsl_fname = fullfile(binarypath, so_fname);

if ~exist(lsl_fname, 'file')
    if ispc
        new_sopath = fullfile(binarypath, 'lsl.dll');
    elseif ismac && exist(fullfile(binarypath, 'liblsl.dylib'), 'file')
        new_sopath = fullfile(binarypath, 'liblsl.dylib');
    elseif exist('/usr/lib/liblsl.so', 'file')
        new_sopath = fullfile('/usr/lib/liblsl.so');
    else
        new_sopath = fullfile('/usr/lib/', so_fname);
    end
    if exist(new_sopath, 'file')
        lsl_fname = new_sopath;
    end %if
end %if

if ~exist(lsl_fname,'file')
    disp(['Could not locate the file "' so_fname '" on your computer. Attempting to download...']);
    LIBLSL_TAG = 'v1.14.0';
    LIBLSL_VER = '1.14.0';
    liblsl_url = ['https://github.com/sccn/liblsl/releases/download/' LIBLSL_TAG '/'];
    if ispc && contains(computer,'64')
        liblsl_url_fname = ['liblsl-' LIBLSL_VER '-Win_amd64.zip'];
    elseif ispc
        liblsl_url_fname = ['liblsl-' LIBLSL_VER '-Win_i386.zip'];
    elseif ismac
        liblsl_url_fname = ['liblsl-' LIBLSL_VER '-OSX_amd64.tar.bz2'];
    elseif isunix
        liblsl_url_fname = ['liblsl-' LIBLSL_VER '-focal_amd64.deb'];
    end
    try
        websave(fullfile(binarypath, liblsl_url_fname),...
            [liblsl_url liblsl_url_fname]);
    catch ME
        disp(['Unable to download ' liblsl_url]);
        rethrow(ME);
    end
    if ispc
        unzip(fullfile(binarypath, liblsl_url_fname),...
            fullfile(binarypath, 'liblsl_archive'));
        lsl_fname = fullfile(binarypath, 'lsl.dll');
        copyfile(fullfile(binarypath, 'liblsl_archive', 'bin', 'lsl.dll'), lsl_fname);
        copyfile(fullfile(binarypath, 'liblsl_archive', 'lib', 'lsl.lib'),...
            fullfile(binarypath, 'lsl.lib'));
    elseif ismac
        % Use system tar because Matlab untar does not preserve symlinks.
        mkdir(fullfile(binarypath, 'liblsl_archive'));
        system(['tar -C ' fullfile(binarypath, 'liblsl_archive') ' -xf ' fullfile(binarypath, liblsl_url_fname)]);
        copyfile(fullfile(binarypath, 'liblsl_archive', 'lib', '*.dylib'), binarypath);
        dylib_list = dir(fullfile(binarypath, '*.dylib'));
        [~, lib_ix] = min(cellfun(@length, {dylib_list.name}));
        lsl_fname = fullfile(dylib_list(lib_ix).folder, dylib_list(lib_ix).name);
    elseif isunix
        error(['liblsl debian package must be installed manually:', ...
            ' sudo dpkg -i ' fullfile(binarypath, liblsl_url_fname)]);
    end
end

end

