function [isOK, mixtureA, tdata] = doclassify (fqfnAudioIn, fqfnTrainIn, tdata, kpstruct) 
	% Invokes the C++ classifier (which is confusingly called cpptranscribe (executable is transcribe.exe)
	% as it was intended to and may eventually do the whole transcription job)
	
	prevtime=gettime();
	tempdir = getenv('TEMP');
	
	% 1. Create unique temporary filename for returned data and ensure it does not already exist
	fqfnCppOutput =  fullfile(tempdir, ['cppgain' , num2str( mygetpid()) , '.bin']);
	if exist(fqfnCppOutput,'file'); delete (fqfnCppOutput); end; 
	
	% 2. Create file for passing merged tdata and kpstruct to cpptranscribe
	fqfnQqqq = fullfile(tempdir,['qqqq' , num2str( mygetpid()) , '.bin']);
    saveQqqq(fqfnQqqq, tdata, kpstruct);
	
	% 3. Run cpptranscribe
	cpptranscribeBinary = fullfile(getenv('APPDATA'), 'HOS', 'cpptranscribe-binaries', 'transcribe.exe');
	if (isoctave()) % undo_string_escapes
        cmd = sprintf('\"%s\" -audio:\"%s\" -train:\"%s\" -tdata:\"%s\" -out:\"%s\" -quiet:\"%d\" t', ...
	          cpptranscribeBinary, ...
	          undo_string_escapes(strtrim(fqfnAudioIn)), ...
	          undo_string_escapes(strtrim(fqfnTrainIn)), ...
	          undo_string_escapes(strtrim(fqfnQqqq)),...
	          undo_string_escapes(strtrim(fqfnCppOutput)),...
			  kpstruct.quiet);
		      overlaps='overlaps'; %bypass a mobfuscation limitation
              cmd = strrep(cmd,'\\','\',overlaps,false); % Remove double \ which created problems for \\servername\...
    else    
        cmd = sprintf('\"%s\" -audio:\"%s\" -train:\"%s\" -tdata:\"%s\" -out:\"%s\" -quiet:2 t', ...
	          cpptranscribeBinary, ...
	          strtrim(fqfnAudioIn), ...
	          strtrim(fqfnTrainIn), ...
	          strtrim(fqfnKpstruct),...
	          strtrim(fqfnCppOutput));
    end
	system(cmd);
	if ~exist(fqfnCppOutput,'file')
	    fprintf('transcribe.exe failed to produce any output\n');
        mixtureA = [];
	    isOK = 0;
	    return;
	end
    
    % 4. Clean up temp files and get results into correct variables
	load('-mat', fqfnCppOutput); % Creates variables: TouchFile, TouchRMSdB, TouchdB, bells, duration
    td=tdata;
    load(fqfnTrainIn); clear allbasis ccurve;  % Obtain tdata from Train file. Change cpptranscribe to avoid!!!!!!!!!!
    tdata= mergestruct(tdata,td);
	delete (fqfnCppOutput);
	delete (fqfnQqqq);
	
	% 5. Move info from the temporary file into appropriate variables for passing on
    fTouch = dir(fqfnAudioIn);
	tdata.TouchTime        = fTouch.datenum;
	tdata.TouchdB          = TouchdB;
	tdata.CompressionLevel = 0;  % Why ??
	tdata.GainProcTime     = gettime()-prevtime;
	tdata.duration         = duration;
	mixtureA               = bells; % Avoid by changing cpptranscribe !!!!!!!!!!!!!!!!!!!!!!!!
	clear bells;
	
	isOK = 1;
end

    function saveQqqq(fqfnQqqq, tdata, kpstruct)% Merge tdata and kpstruct for cpptranscribe
		% Add fields from kpstruct
        tdata.FreqHigh       = kpstruct.FreqHigh;
        tdata.FreqLow        = kpstruct.FreqLow;
        tdata.nBells         = length(tdata.BellsRinging);
        % for debugging reasons check the other tdata fields exist
        tdata.BellsAvailable   ;         
        tdata.BellsRinging     ;       
        tdata.HopSizeSecs      ;     
        tdata.WinSizeSecs      ;     
        tdata.bellset          ; 
        tdata.tower            ;
	    save('-mat', fqfnQqqq, 'tdata');
    end
