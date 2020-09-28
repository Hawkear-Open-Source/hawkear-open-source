function [isOK] = dotrain(fqdnTrainIn, fqfnTrainOut, Towerid, TowerPhrase, kpstruct)
    if kpstruct.quiet == 0 % 0 ==> Noisy. 1 ==> Ringing info only. 2 ==> Silent.
		display 'In dotrain'
	end
	addpath ('transcribe/train')
	addpath ('transcribe/misc')
	prevtime = gettime();
    setenv('OPENBLAS_NUM_THREADS','1'); 
	tempdir = getenv('TEMP');
	
	% 1. Work out number of bells in tower from directory contents
    bellfns = simpleglob([fqdnTrainIn, filesep,'*t.wav']);
   	nBellsInTower = length(bellfns);
	if nBellsInTower > 0
		fprintf('       Assuming %d bells\n',nBellsInTower)
	else
		fprintf('   !!! No Training data for Tower\n\n')
		isOK=0;
		return
    end
	
    % 2. Compute number of processes to use
	TotalProcesses = min(nBellsInTower, kpstruct.TotalProcesses);
    fprintf('       Using %d processes\n',TotalProcesses);
   
    % 3. Allocate bells to processors
    BaseNoBells = floor(nBellsInTower/TotalProcesses);  
    ExtraBells = (nBellsInTower - TotalProcesses*BaseNoBells); %will be the number of processes doing one more.
    if BaseNoBells == 0
       TotalProcesses = ExtraBells;
       p = ones(1,ExtraBells);
    elseif ExtraBells == 0
       p = ones(1,TotalProcesses)*BaseNoBells;
    else
       p1 = ones(1,TotalProcesses)*BaseNoBells;
       p2 = ones(1,ExtraBells);
       p2(TotalProcesses) = 0;
       p=p1+p2;
    end
    
    % 4. Launch the processes
    LastBellDone = 0;
	kpstruct.SampleRate=NaN;
    for i = 1 : TotalProcesses;
        BellsToDo = LastBellDone+1:LastBellDone+p(i);
        LastBellDone=LastBellDone+p(i);
        temp=sprintf('%d,',BellsToDo);
        sBells = ['[',temp(1:end-1),']'];
        pfqfnTrainOut = fullfile(tempdir,sprintf('on%d',i));
        cmd = 'addpath(''transcribe/misc:transcribe/train'');';
		cmd(cmd == ':') = pathsep;
        cmd = [cmd, sprintf('%s(''%s'', %d, %f, %f, ''%s'', %s);', ... 
		       'dofasttrainloop', fqdnTrainIn, kpstruct.SampleRate, kpstruct.WinSizeSecs,...
               kpstruct.HopSizeSecs, pfqfnTrainOut, sBells)];
        pid(i) = mstart(cmd);         
    end

    % 5. Wait for instances of dotrainloop to complete and accumulate results
    LastBellDone = 0;
    for i = 1:TotalProcesses
        BellsToDo = LastBellDone+1:LastBellDone+p(i);
        LastBellDone = LastBellDone+ p(i);
        err=mwait(pid(i)); 
        if (~isempty(err))
            fprintf('Error in train process: %s', err);
            isOK=0;
            return;
        end
        pfqfnTrainOut = fullfile(tempdir,sprintf('on%d',i));
        load ('-mat', pfqfnTrainOut) % Sets somebasis and tpdata
        delete(pfqfnTrainOut);
		allbasis(:,BellsToDo) = somebasis;
		tdata.TraindB(BellsToDo) = tpdata.TraindB(BellsToDo);
    end
	
    % 6. Normalize spectra
    allbasis=allbasis./repmat(sum(allbasis,1),size(allbasis,1),1); % This line was inherited from the Finnish
	                                                               % group but may not be necessary as makes
															       % no difference to output.
	
    % 7. Stuff that should be moved into classify as no need to lock the emphasis into the trainfile
    hv = sum(allbasis,2).^.5;                      % representation of the overall frequency content of the bells. Added the .^.5
												   % on 23 July 2018. This seemed to significantly improve transcriptions
												   % based on lincoln 6brum, sheffield team3, and gsmcambridge contest pieces
												   % I don't know why it helps when it seems to be the same thing as
												   % compression. 11/2018. I'm still having trouble with BristolSMR and
												   % removing this did not significantly change transcription quality
												   % Really need a new theory of how pregain works and code to match!!!!
    fil=filter(hammingwindow(kpstruct.swin),1,hv); % fil is a smoothed but convolved representation
	qqq=round(kpstruct.swin/2);                    % Shift amount to remove convolution
    bfc=shift(fil,-qqq);               			   % Shift so that filtered and unfiltered data align
    bfc(end-qqq:end)=0;                			   % Zero the looped-round values
    ccurve = (1./bfc).^kpstruct.compression;       % Invert bfc and apply compression to give vector to multiply
                                                   % train data and mixture data by prior to classification
    allbasis=scramble(allbasis,'y',ccurve(1));     % Scramble code that should be removed
	
	% 8. Complete tdata with all the fields transcribe is expecting
	for i = 1:length(bellfns)
        f=dir(bellfns{i});
        timestamp(i) = f.statinfo.mtime;
	end
	tdata.TrainDataRecordedOn = strftime('%Y%m%d-%H%M',localtime(min(timestamp)));
    tdata.TraindB             = round(tdata.TraindB*100)/100;
	tdata.TrainedOn           = epoch2hkdatetime(gettime());
    tdata.BellsAvailable      = sum(allbasis)~=0; % boolean vector
	tdata.WinSizeSecs         = kpstruct.WinSizeSecs;
	tdata.HopSizeSecs         = kpstruct.HopSizeSecs;
	tdata.Towerid             = kpstruct.Towerid;
	tdata.TowerPhrase         = kpstruct.TowerPhrase;
	tdata.DefaultBells        = kpstruct.DefaultBells;
	tdata.trainparams         = kpstruct.trainparams;
	tdata.TrainProcTime = sprintf('%.3fsecs',gettime()-prevtime);
    % 9. Save the binary trainfile
    save ('-mat', fqfnTrainOut, 'allbasis', 'tdata', 'ccurve');
    clear time; 
    fprintf ('       Total time for train processing: %s\n\n\n', tdata.TrainProcTime);
    isOK=1;
end
