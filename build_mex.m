% Build mex bindings
% For Octave on Linux, you need the package liboctave-dev installed
% You also need the liblsl64 binary in the bin folder and a configured
% C compiler (mex -setup)
binarypath = fullfile(fileparts(mfilename('fullpath')), 'bin');
if ispc
    if exist(fullfile(binarypath, 'liblsl64.lib'), 'file')
        libs = {'-llsl64'};
    elseif exist(fullfile(binarypath, 'lsl.lib'), 'file')
        libs = {'-llsl'};
    else
        error('Neither liblsl64.lib nor lsl.lib found in bin/');
    end
elseif ismac
    if exist(fullfile(binarypath, 'liblsl64.dylib'), 'file')
        libs = {'-llsl64'};
    elseif exist(fullfile(binarypath, 'liblsl.dylib'), 'file')
        libs = {'-llsl'};
    end    
elseif isunix
	libs = {'-llsl64','-ldl'};
else
    libs = {'-llsl64'};
end

ext = ['.' mexext];

files = dir('mex/*.c');

orig_path = pwd();
disp('Building mex files. This may take a few minutes.');
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
