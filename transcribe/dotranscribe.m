function [rc] = dotranscribe(fqfnAudioIn, fqfnTrainIn, fqfnLowndesOut, kpstruct)
	addpath ('transcribe/validate')
	addpath ('transcribe/classify')
	addpath ('transcribe/onset')
	addpath ('transcribe/write')
	addpath ('transcribe/misc')
	addpath ('transcribe/train')
	
	% 1. dovalidate
	[isOK, tdata] = dovalidate(fqfnAudioIn, fqfnTrainIn, kpstruct);
	if ~isOK
		rc = 2021; % Indicate validation problem
		return
	end
	
	% 2. Classify
	tdata.quiet = kpstruct.quiet;
    [isOK, mixtureA, tdata] = doclassify(fqfnAudioIn, fqfnTrainIn, tdata, kpstruct);
	if ~isOK
		rc = 2022; % Indicate Classification problem
		return
	end
	
	% 3. Detection Onsets
	[isOK, xxRawPieceByBi, tdata] = doonset(mixtureA, tdata, kpstruct);
	if ~isOK
		rc = 2023; % Indicate onset problem
		return
	end
	
	% 4. Write to output file
	[isOK] = dowritelowndes (fqfnAudioIn, xxRawPieceByBi, fqfnLowndesOut, tdata, kpstruct);
	if ~isOK
		rc = 2024; % Indicate write problem
		return
	end
    
	rc = 0; % This gets returned to windows and can be retrieved using %ERRORLEVEL%. By convention in windows zero means OK, and non-zero means an error, with the value possibly being an error code.
end

