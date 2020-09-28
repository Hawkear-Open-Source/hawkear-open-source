function [rc] = dotranscribe(fqfnAudioIn, fqfnTrainIn, fqfnLowndesOut, kpstruct)
	addpath ('transcribe/validate')
	addpath ('transcribe/classify')
	addpath ('transcribe/onset')
	addpath ('transcribe/write')
	addpath ('transcribe/misc')
	addpath ('transcribe/train')
	
    % 1. Init metadata
	
	[isOK, Metadata, msg] = dovalidate(fqfnAudio, fqfnTrain, kpstruct);
	if ~isOK 
		fprintf(stderr, '%s\n',msg);
		return
	end
	metadata.transcribedby = 'hawkear-open-source';
	metadata.transcribedfor = 'HOS Development';
	
	% 2. Classify 
    [isOK, mixtureA, metadata] = doclassify(fqfnAudioIn, fqfnTrainIn, metadata, kpstruct);
	if ~isOK
		rc = 2022; % Indicate Classification problem
		return
	end
	
	% 3. Detection Onsets
	[isOK, xxRawPieceByBi, metadata] = doonset(mixtureA, metadata, kpstruct);
	if ~isOK
		rc = 2023; % Indicate onset problem
		return
	end
	
	% 4. Write to output file
	[isOK] = dowritelowndes (fqfnAudioIn, xxRawPieceByBi, fqfnLowndesOut, metadata, kpstruct);
	if ~isOK
		rc = 2024; % Indicate write problem
		return
	end
    
	rc = 0; % This gets returned to windows and can be retrieved using %ERRORLEVEL%. By convention in windows zero means OK, and non-zero means an error, with the value possibly being an error code.
end

