function [rc] = dotranscribe(fqfnAudioIn, fqfnTrainIn, fqfnLowndesOut, kpstruct)
	addpath ('transcribe/classify')
	addpath ('transcribe/onset')
	addpath ('transcribe/write')
	addpath ('transcribe/misc')
	
	% 1. Convert kpstruct from just being keyword parameters to being everything except the operational filenames
	%    that transcribe subphases need.
	kpstruct.fqfnTouch = fqfnAudioIn;
	
	% BODGE!!! Fix kpstruct so that the subcomponents of transcribe don't crash out
	% Should be obtained from train phase which passes them in traindata
	kpstruct.nBells = 8;       % Bells in tower not bellsringing   % F
	kpstruct.BellsAvailable = ones(1,8);                           % F
	kpstruct.WinSizeSecs = .05;                                    % F
	kpstruct.HopSizeSecs = .01;                                    % F
	
	kpstruct.tower = 'Thunston';                                   % A
	kpstruct.TowerPhrase = 'Thunston St Anywhere';                 % A
	kpstruct.TraindB = '10';                                       % A
	kpstruct.TrainedOn = '20200101-0000';                          % A
	kpstruct.TrainDataRecordedOn = '20200101-0000';                % A
	kpstruct.trainparams='';                                       % A
	
	% Should be obtained from transcribe API parameters
	kpstruct.bellset = 's8t8';                                     % A
	kpstruct.Ringingname = '1';                                    % A
	kpstruct.Ringingdatetime = '20200101-0000';                    % A
	
	% Should be computed here 
	kpstruct.BellsRinging = (1:8)'; 
	kpstruct.Rungon=''; % The friendly name of the bellset
	kpstruct.Tenor='';  % Why is this here! Can't remember
	kpstruct.transcribedby = 'hawkear-open-source';
	kpstruct.transcribedfor = 'HOS Development';
	kpstruct.gainparams='';
	kpstruct.onsetparams='';
	kpstruct.writeparams='';
	kpstruct.analparams='';
	
	% 2. Classify
    [isOK, mixtureA, tdata] = doclassify(fqfnAudioIn, fqfnTrainIn, kpstruct);
	if ~isOK
		rc = 2021; % Indicate Classification problem
		return
	end
	
	% 3. Detection Onsets
	[isOK, xxRawPieceByBi, tdata] = doonset(mixtureA, tdata, kpstruct);
	if ~isOK
		rc = 2022; % Indicate onset problem
		return
	end
	
	% 4. Write to output file
	[isOK] = dowritelowndes (xxRawPieceByBi, fqfnLowndesOut, tdata, kpstruct);
	if ~isOK
		rc = 2023; % Indicate write problem
		return
	end
    
	rc = 0; % This gets returned to windows and can be retrieved using %ERRORLEVEL%. By convention in windows zero means OK, and non-zero means an error, with the value possibly being an error code.
end