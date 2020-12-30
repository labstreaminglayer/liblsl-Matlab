function [lsl_fname, lsl_include_dir] = lsl_get_dll(binarypath, debugging)
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

script_dir = fileparts(mfilename('fullpath'));
if ~exist('binarypath','var') || isempty(binarypath)
    binarypath = fullfile(script_dir, 'bin');
end
if ~exist('debugging','var') || isempty(debugging)
    debugging = false;
end

if ispc
    prefix = '';
    ext = '.dll';
elseif ismac
    prefix = 'lib';
    ext = '.dylib';
elseif isunix
    prefix = 'lib';
    ext = '.so';
else
    error('Operating system not recognized. Cannot identify liblsl binaries.');
end

if debugging
    debug = '-debug';
else
    debug = '';
end

so_fname = sprintf('%slsl%s%s', prefix, debug, ext);

% First check ./bin/ for the shared object.
% Then check the sister liblsl/build/install/bin folder.
% Finally, check other platform-dependent locations.
lsl_fname = fullfile(binarypath, so_fname);
lsl_include_dir = fullfile(binarypath, 'include');
if ~exist(lsl_fname, 'file') || ~exist(lsl_include_dir, 'dir')
    if exist(fullfile(script_dir, '..', 'liblsl', 'build', 'install', 'bin', so_fname), 'file')
        lsl_fname = fullfile(script_dir, '..', 'liblsl', 'build', 'install', 'bin', so_fname);
        lsl_include_dir = fullfile(script_dir, '..', 'liblsl', 'build', 'install', 'include');
    elseif ispc
        % TODO: Anywhere else to check on PC?
    elseif ismac
        % TODO: After liblsl gets a homebrew distribution, check there.
    elseif exist(fullfile('/usr/lib', so_fname), 'file')
        % Linux: Check /usr/lib
        lsl_fname = fullfile('/usr/lib', so_fname);
        lsl_include_dir = '/usr/include';
    end
end %if

% If liblsl (with headers) could not be found in the default paths,
%  then attempt to download it. On Unix, this will have to be installed
%  manually. On PC and Mac, this will be extracted then cleaned up.
if ~exist(lsl_fname,'file') || ~exist(lsl_include_dir, 'dir')
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
        % Check (xenial vs) bionic vs focal
        filetext = fileread('/etc/lsb-release');
        expr = '[^\n]*DISTRIB_CODENAME=(?<code>\w+)[^\n]*';
        res = regexp(filetext,expr,'names');
        liblsl_url_fname = ['liblsl-' LIBLSL_VER '-' res.code '_amd64.deb'];
    end
    try
        websave(fullfile(binarypath, liblsl_url_fname),...
            [liblsl_url liblsl_url_fname]);
    catch ME
        disp(['Unable to download ' liblsl_url liblsl_url_fname]);
        if isunix
            extra_step = 'install it';
        else
            extra_step = ['extract it to ' fullfile(binarypath, 'liblsl_archive')];
        end
        disp(['You will have to manually download a liblsl release from https://github.com/sccn/liblsl/releases and ' extra_step ...
            ' or build liblsl yourself, before reattempting to build the mex files.']);
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
        error(['Reattempt build after manual installation of liblsl debian package:', ...
            ' sudo dpkg -i ' fullfile(binarypath, liblsl_url_fname)]);
    end
    % Grab include_dir and Cleanup no-longer-needed downloaded files.
    if ispc || ismac
        copyfile(fullfile(binarypath, 'liblsl_archive', 'include'), lsl_include_dir);
        rmdir(fullfile(binarypath, 'liblsl_archive'), 's');
        delete(fullfile(binarypath, liblsl_url_fname));
    end
end
