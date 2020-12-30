% Build mex bindings
% For Octave on Linux, you need the package liboctave-dev installed
% You also need the liblsl64 binary in the bin folder and a configured
% C compiler (mex -setup)

orig_path = pwd();  % Will change back to this when done.
ext = ['.' mexext];
script_dir = fileparts(mfilename('fullpath'));
files = dir('mex/*.c');

% Find liblsl, possibly downloading it if it can't be found locally.
[lsl_fname, lsl_include_dir] = lsl_get_dll();

% Build cell array of libray dependencies (liblsl and maybe others)
libs = {};
if contains(lsl_fname, '32')
    libs{end+1} = '-llsl32';
elseif contains(lsl_fname, '64')
    libs{end+1} = '-llsl64';
else
    libs{end+1} = '-llsl';
end
if isunix
    libs{end+1} = '-ldl';
end

disp('Building mex files. This may take a few minutes.');
binarypath = fullfile(script_dir, 'bin');
cd(binarypath);
for i = 1:length(files)
    f = files(i);
	[~, base, ~] = fileparts(f.name);
	targetstats = dir([base, ext]);
	if isempty(targetstats) || f.datenum > targetstats.datenum
		mex(['-I', lsl_include_dir], '-L.', libs{:}, ['../mex/', f.name]);
	else
		disp([base, ext, ' up to date']);
	end
end
if ismac
    system('install_name_tool -add_rpath "@loader_path/" lsl_loadlib_.mexmaci64')
end

cd(orig_path);
