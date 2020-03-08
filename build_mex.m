% Build mex bindings
% For Octave on Linux, you need the package liboctave-dev installed
% You also need the liblsl64 binary in the bin folder and a configured
% C compiler (mex -setup)
libs = {};
lsl_fname = lsl_get_dll();
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

ext = ['.' mexext];

files = dir('mex/*.c');

orig_path = pwd();
disp('Building mex files. This may take a few minutes.');
binarypath = fullfile(fileparts(mfilename('fullpath')), 'bin');
cd(binarypath);
for i = 1:length(files)
    f = files(i);
	[~, base, ~] = fileparts(f.name);
	targetstats = dir([base, ext]);
	if isempty(targetstats) || f.datenum > targetstats.datenum
		mex('-I../../liblsl/include','-L.', libs{:}, ['../mex/', f.name]);
	else
		disp([base, ext, ' up to date']);
	end
end
if ismac
    system('install_name_tool -add_rpath "@loader_path/" lsl_loadlib_.mexmaci64')
end
cd(orig_path);
