function [isOK] = dowritelowndes (fqfnAudioIn, xxRawPieceByBi, fqfnLowndes, tdata, kpstruct)
    % Creates the lowndes version of the transcription
	
	% 1. Open output file
    fid = fopen(fqfnLowndes,'w');
    if fid <= 0
	    fprintf('\n   !!! HawkEar error. Cannot create output file:\n          %s\n\n', fqfnLowndes)
	    isOK=false;
        return
    end
    
	% 2. Make zero-origin and save firstblowms in structured data because the lowndes file
	%    65536ms rounding would destroy info about the time origin
    firstblowms = xxRawPieceByBi(1,2);
	xxRawPieceByBi(:,2) = xxRawPieceByBi(:,2)-firstblowms; 
	
	% 3. Write Structured Comments based on tdata
	fprintf(fid,'#. Lowndes: Version 2\n');
	fprintf(fid,'#. SourceFilename: %s\n',			fqfnAudioIn);
	fprintf(fid,'#. Tower: %s\n',				  	tdata.TowerPhrase);
	fprintf(fid,'#. RingingName: %s\n',				tdata.Ringingname);
	fprintf(fid,'#. RingingDateTime: %s\n',	  		tdata.Ringingdatetime);
	fprintf(fid,'#. Rungon: %s\n',					tdata.Rungon);
	fprintf(fid,'#. Tenor: %d\n',					tdata.Tenor);
	fprintf(fid,'#. NumBellsRinging: %d\n',			tdata.nBells);
	fprintf(fid,'#. FirstBlowMs: %d\n',				firstblowms);
	% Blank metadata that may be edited by user 
	fprintf(fid,'#. Association:\n');
	fprintf(fid,'#. Calling:\n');
	fprintf(fid,'#. CompositionName:\n');
	fprintf(fid,'#. Method:\n');
	fprintf(fid,'#. Footnotes:\n');
	fprintf(fid,'#. Ringers:\n');
	fprintf(fid,'#. Stage:\n');
	% Technical data about training and transcription
	fprintf(fid,'#. Creator: %s\n',					tdata.transcribedby);
	fprintf(fid,'#. TranscribedFor: %s\n',          tdata.transcribedfor);
	fprintf(fid,'#. TranscriptionDateTime: %s\n',  	epoch2hkdatetime(gettime()));
	fprintf(fid,'#. TouchdB: %d\n',					tdata.TouchdB);
	fprintf(fid,'#. TraindB: %s\n',                 sprintf('%d, ',tdata.TraindB)(1:end-2));
	fprintf(fid,'#. TrainedOn: %s\n',               tdata.TrainedOn);
	fprintf(fid,'#. TrainDataRecordedOn: %s\n',     tdata.TrainDataRecordedOn);
	fprintf(fid,'#. TrainParams: %s\n',				tdata.trainparams);
	fprintf(fid,'#. ClassifyParams: %s\n', 			kpstruct.classifyparams);
	fprintf(fid,'#. OnsetParams: %s\n',				kpstruct.onsetparams);
	fprintf(fid,'#. WriteParams: %s\n',				kpstruct.writeparams);

	% 4. Write Strike Data
	if kpstruct.hb == 'y'    % option to suppress indication of Hand vs Back in the lowndes file which is sometimes useful
		hb = ['H' 'B'];
	else
		hb = ['H' 'H'];
	end
	[isOK, OnsetCt] = writestrikedata(xxRawPieceByBi, hb, fid);
	fclose(fid);
    
end
