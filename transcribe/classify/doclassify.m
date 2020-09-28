function [isOK, mixtureA, tdata] = doclassify (fqfnAudioIn, fqfnTrainIn, tdata, kpstruct) 
	% Invokes the C++ classifier (which is confusingly called cpptranscribe and executable is called transcribe.exe!
    
    % Update tdata from trainfile
    td = tdata;
    load(fqfnTrainIn); clear allbasis ccurve;  % Obtain tdata from Train file. Change cpptranscribe to avoid!!!!!!!!!!
    tdata = mergestruct(tdata, td);
    clear td;
   
    % these assignments to tdata are a bodge.  should obtain these from the recording
    % and also should allow them to be overridden on the transcribe API
	tdata.Ringingdatetime = '20200101-0000';                    
	tdata.Ringingname     = 'Touch 1';
	tdata.bellset         = 's8t8'; 
	tdata.Ringers         = 'ian,martin,paul,Leigh';
    
	tdata.BellsRinging    = (1:8)'; 
	tdata.Rungon          = ''; % The friendly name of the bellset
	tdata.Tenor           = 8;  % Why is this here! Can't remember
    tdata.nBells          = length(tdata.BellsRinging);
	
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
        cmd = sprintf('\"%s\" -audio:\"%s\" -train:\"%s\" -tdata:\"%s\" -out:\"%s\" -quiet:\"%d\" t', ...
	          cpptranscribeBinary, ...
	          strtrim(fqfnAudioIn), ...
	          strtrim(fqfnTrainIn), ...
	          strtrim(fqfnKpstruct),...
	          strtrim(fqfnCppOutput),...
			  kpstruct.quiet);
    end
	system(cmd);
	if ~exist(fqfnCppOutput,'file')
	    fprintf('transcribe.exe failed to produce any output\n');
        mixtureA = [];
	    isOK = 0;
	    return;
	end
	load('-mat', fqfnCppOutput); % Creates variables: TouchFile, TouchRMSdB, TouchdB, bells, duration
    
    % 4. Clean up temp files
	delete (fqfnCppOutput);
	delete (fqfnQqqq);
	
	% 5. Move info from cpptranscribe into appropriate variables for passing on
    fTouch = dir(fqfnAudioIn);
	tdata.TouchTime        = fTouch.datenum;
	tdata.TouchdB          = TouchdB;
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
	    save('-mat', fqfnQqqq, 'tdata');
    end
