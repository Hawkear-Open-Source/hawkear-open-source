function [rc] = dotranscribe(fqfnAudioIn, fqfnTrainIn, fqfnLowndesOut, kpstruct)
	addpath ('transcribe/validate')
	addpath ('transcribe/classify')
	addpath ('transcribe/onset')
	addpath ('transcribe/write')
	addpath ('transcribe/misc')
	addpath ('transcribe/train')
	
	% 1. dovalidate
	%[isOK, tdata] = dovalidate(fqfnAudioIn, fqfnTrainIn, kpstruct);
	%if ~isOK
	%	rc = 2021; % Indicate validation problem
	%	return
	%end
    
    % 1. Init tdata
	tdata.transcribedby = 'hawkear-open-source';
	tdata.transcribedfor = 'HOS Development';
	
	% 2. Classify (these assignments to tdata are a bodge that doclassify should be fixed to avoid the need for)
	tdata.Ringingdatetime = '20200101-0000';                    
	tdata.Ringingname     = 'Touch 1';
	tdata.bellset         = 's8t8'; 
	tdata.Ringers         = 'ian,martin,paul,Leigh';
    tdata.BellsAvailable  = ones(1,8);  
    tdata.HopSizeSecs     =  .01;     
    tdata.WinSizeSecs     =  .05;     
    tdata.tower           =  'asd';
    tdata.TowerPhrase     =  'asd st qwe';
	tdata.trainparams     = '';
	tdata.Rungon          = ''; % The friendly name of the bellset
	tdata.Tenor           = 8;  % Why is this here! Can't remember
	tdata.BellsRinging    = (1:8)'; 
    tdata.nBells          = length(tdata.BellsRinging);
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

