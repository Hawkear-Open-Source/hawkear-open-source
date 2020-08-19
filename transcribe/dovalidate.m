function [isOK, tdata] = dovalidate(fqfnAudioIn, fqfnTrainIn, kpstruct)
% THIS IS ALL A BODGE AT PRESENT
	% 1. This principle is that kpstruct should ONLY be the keyword parameters and tdata should be validated data used for communication forward between the subphases of transcribe. To make this work Transcribe needs an initial validation step which takes the audio file and the keyword parameters and creates the initial version of tdata containing:
	
	% 1. These should be created as part of the build process (I think!)
	tdata.transcribedby = 'hawkear-open-source';
	tdata.transcribedfor = 'HOS Development';

	% 2. These should be obtained by processing kpstruct
	tdata.gainparams='';
	tdata.onsetparams='';
	tdata.writeparams='';
	tdata.analparams='';
	
	% 3. These should be obtained directly from kpstruct. 
	tdata.Ringingdatetime='';                    
	tdata.Ringingname='';
	tdata.bellset='';
	tdata.Ringers='';
	
	% 4. These should be obtained from the Audio file using audioinfo(), if not found from kpstruct. 
	tdata.Ringingdatetime = '20200101-0000';                    
	tdata.Ringingname     = 'Touch 1';
	tdata.bellset         = 's8t8'; 
	tdata.Ringers         = 'ian,martin,paul,Leigh';
	
	
	% 5. These should be loaded directly from training data.  MOVE TO CLASSIFY??
    tdata.BellsAvailable = ones(1,8);  
    tdata.HopSizeSecs    =  .01;     
    tdata.WinSizeSecs    =  .05;     
    tdata.tower          =  'asd';
    tdata.TowerPhrase    =  'asd st qwe';
	tdata.trainparams    = '';

	% 6. These should be obtained by validation of the bellset against the training data.   MOVE TO CLASSIFY??
	tdata.Rungon=''; % The friendly name of the bellset
	tdata.Tenor=8;  % Why is this here! Can't remember
	tdata.BellsRinging = (1:8)'; 
    tdata.nBells=length(tdata.BellsRinging);

    isOK=1;
end