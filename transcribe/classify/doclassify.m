function [isOK, mixtureA, tdata] = doclassify (fqfnAudioIn, fqfnTrainIn, kpstruct) 
	% Invokes the C++ classifier (which is called transcribe.exe as it was intended to and may eventually do the whole transcription job)
	prevtime=gettime();
	tempdir = getenv('TEMP');
	transcribeBinary = fullfile(getenv('APPDATA'), 'HOS', 'cpptranscribe-binaries', 'transcribe.exe');
	% 1. Create unique temporary filename for returned data and ensure it does not already exist
	fqfnCppOutput =  fullfile(tempdir, ['cppgain' , num2str( mygetpid()) , '.bin']);
	if exist(fqfnCppOutput,'file'); delete (fqfnCppOutput); end; 
	
	% 2. Save kpstruct as tdata for putting into a file for transcribe.exe
	tdata =  kpstruct; 
	fqfnTdata = fullfile(tempdir,'tdata');
	save('-mat', fqfnTdata, 'tdata');

	% 3. Run transcribe.exe
	if (isoctave()) % undo_string_escapes
        cmd = sprintf('\"%s\" -audio:\"%s\" -train:\"%s\" -tdata:\"%s\" -out:\"%s\" -quiet:2 t', ...
	          transcribeBinary, ...
	          undo_string_escapes(strtrim(fqfnAudioIn)), ...
	          undo_string_escapes(strtrim(fqfnTrainIn)), ...
	          undo_string_escapes(strtrim(fqfnTdata)),...
	          undo_string_escapes(strtrim(fqfnCppOutput)));
		      overlaps='overlaps'; %bypass a mobfuscation limitation
              cmd = strrep(cmd,'\\','\',overlaps,false); % Remove double \ which created problems for \\servername\...
    else    
        cmd = sprintf('\"%s\" -audio:\"%s\" -train:\"%s\" -tdata:\"%s\" -out:\"%s\" -quiet:2 t', ...
	          transcribeBinary, ...
	          strtrim(fqfnAudioIn), ...
	          strtrim(fqfnTrainIn), ...
	          strtrim(fqfnTdata),...
	          strtrim(fqfnCppOutput));
    end
	system(cmd);
	if ~exist(fqfnCppOutput,'file')
	    fprintf('transcribe.exe failed to produce any output\n');
        mixtureA = [];
	    isOK = 0;
	    return;
	end
	
    % 4. Get composite results back and delete the temporary file
	load('-mat', fqfnCppOutput);
	delete (fqfnCppOutput);
	
	% 5. Move info from the temporary file into appropriate variables for passing on
    fTouch = dir(fqfnAudioIn);
	tdata.TouchTime        = fTouch.datenum;
	tdata.TouchdB          = TouchdB;
	tdata.CompressionLevel = 0;  % Why ??
	tdata.GainProcTime     = gettime()-prevtime;
	tdata.duration         = duration;
	mixtureA               = bells; 
	clear bells;
	
	isOK = 1;
end