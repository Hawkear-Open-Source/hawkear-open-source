function [ret] = dotranqual(kpstruct, fqfnOnset, fqfnWriteTQ)

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%
	% Transcription Quality Display tool
	%
	% Measures and reports the transcription quality of each bell at
	% hand and back.
	%   This is measured by comparing the average of 60 seconds-worth of
	%   samples before each onset with the average of the maxima of the
	%   same set of onsets. 60 hops (.6 seconds) before is used on the
	%   basis that the bell itself will not be resonating significantly
	%   from previous blow after that point
	%
	% Supplied with the name of the onset result file
	% and the name of the file for results
	%
	% Copyright (C) 2008-2011 Ian McCallion (ian.mccallion.gmail.com)
	% This file is part of Hawkear
	%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	fid(1) = 1; % always output to stdout
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% add specified file to list of fids to receive the output
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	fid(2) = fopen(fqfnWriteTQ,'w');
	if fid(2) <=0
		fprintf('Cannot open output file %s\n',fqfnWriteTQ)
		ret = 0;
		return
	end
	
	load('-mat', fqfnOnset)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% mixtureB contains the gain curves (normalized)
	% mixtureE contains the smoothed gain curves
	% allys contains zeros except for the peaks of smoothed gain curves
	% allzs contains zeros except for the onsets
	% OnsetCt contains the onset counts for each bell
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	ret=1;
	if exist('OnsetCt','var') && max(OnsetCt)<1
        return
    end
	nBefore  = 60;
	nAfter   = 10;
	nIgnoredBefore = 1;
	nIgnoredAfter  = 1;
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Report Transcription quality of bells
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	myp(fid,'       Transcription Difficulty Analysis\n')
	myp(fid,'         Bell Handstroke Backstroke\n');
	tot=0;
	for b = 1:tdata.nBells
		[iBitsBeforeHs, iBitsBeforeBs] = bitsnear(allzs(:,b), nIgnoredBefore, nBefore,'Before');
		[iBitsAfterHs,  iBitsAfterBs ] = bitsnear(allzs(:,b), nIgnoredAfter,  nAfter, 'After' );
		
		hsmb = mean(mixtureB(iBitsBeforeHs, b));
		hsma = mean(mixtureB(iBitsAfterHs,  b));
		bsmb = mean(mixtureB(iBitsBeforeBs, b));
		bsma = mean(mixtureB(iBitsAfterBs,  b));
		myp(fid, sprintf('          %2d     %2.2f        %2.2f\n',b,100*hsmb/hsma, 100*bsmb/bsma))
		tot = tot+(100*hsmb/hsma + 100*bsmb/bsma);
	end
	myp(fid,sprintf('         Overall Transcription Difficulty       %2.2f\n', tot/tdata.nBells/2))
	
	dobadblows(allzs, mixtureB, fid);
	if length(fid)>1
		fclose(fid(2));
	end
	end
	
	% Returns the positions on the handstroke and backstroke time samples before 
	% each identified hanstroke & backstroke onset
	function [hsb,bsb]= bitsnear(a,n1,n2, sAfter) % n1 is gap, n2 is length
	n1=abs(n1);
	n2=abs(n2);
	ix = find(a);
	lix = length(ix);
	if mod(lix,2)~=0
		ix=ix(1:lix-1);
	end
	lhix = length(ix)/2;
	ixr = reshape(ix,2,lhix);
	
	qzz1 = n1+(1:n2)';
	qzz2 = -n1+(-n2:-1)';
	if strcmpi(sAfter, 'after')
        auxmat=(repmat(ixr(1,:),n2,1)+repmat(qzz1,1,lhix));
		indhs = auxmat(:);
		indhs = indhs(indhs<=length(a));
        auxmat=(repmat(ixr(2,:),n2,1)+repmat(qzz1,1,lhix));
		indbs = auxmat(:)';
		indbs = indbs(indbs<=length(a));
    else
        auxmat=(repmat(ixr(1,:),n2,1)+repmat(qzz2,1,lhix));
		indhs=auxmat(:);
		indhs = indhs(indhs> 0);
        auxmat=(repmat(ixr(2,:),n2,1)+repmat(qzz2,1,lhix));
		indbs=auxmat(:)';
		indbs = indbs(indbs> 0);
    end
    bsb=repmat(false,1,length(a));
    hsb=bsb;
	hsb(indhs) = 1;
	bsb(indbs) = 1;
	end

function []=myp(fid,s)
	for i=1:length(fid)
		fprintf(fid(i),s);
	end
end

function [rc] = dobadblows(allzs, mixtureB, fid)

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%
	% Transcription Verification
	%
	% [should be] supplied with the name of the onset result file
	% and the name of the file for results
	%
	% Copyright (C) 2008-2011 Ian McCallion (ian.mccallion.gmail.com)
	% This file is part of Hawkear
	%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	myp(fid,sprintf('       Bad Blow Analysis\n'))
	rc=0;
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% mixtureB contains the gain curves
	% mixtureE contains the smoothed gain curves
	% allys contains zeros except for the peaks of smoothed gain curves
	% allzs contains zeros except for the onsets
	% OnsetCt contains the onset counts for each bell
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	% First run hktranqual to display
	nBeforeSamples = 10;
	nIgnoredBefore = 1;
	nAfterSamples  = 10;
	nIgnoredAfter  = 1;
	r=nAfterSamples/nBeforeSamples;
	nBells = size(allzs,2);
	% For each bell
	for bell=1:nBells
		bBeforeSamples = zeros(1,size(mixtureB,1));
		bAfterSamples  = zeros(1,size(mixtureB,1));
		% get a list of the onset positions for the given bell
		onset = find(allzs(:,bell));
		if bell == 1
			risk = zeros(nBells, size(onset,1));
			nBlowsTotal = nBells*size(onset,1);
		end
		% For each onset of each bell
		for i= 1:size(onset,1)
			iBeforeSamples = max(1,onset(i)-nIgnoredBefore-nBeforeSamples) : min(onset(i)-nIgnoredBefore-1, size(mixtureB,1))-1;
			iAfterSamples = max(1,onset(i)+nIgnoredAfter+1) : min(onset(i)+nIgnoredAfter+nAfterSamples-1,size(mixtureB,1));
			
			bBeforeSamples(iBeforeSamples) = 1;
			bAfterSamples (iAfterSamples) = 1;
			riskm = max(mixtureB(iBeforeSamples,bell))*100/max(mixtureB(iAfterSamples,bell));
			if max(mixtureB(iAfterSamples,bell)) == 0
				bell,i
			end
			riska = sum(mixtureB(iBeforeSamples,bell))*100/sum(mixtureB(iAfterSamples,bell));
            if isempty(riska)
                riska=0;
            end
            if isempty(riskm)
                riskm=0;
            end
			risk(bell,i) = max(riskm,riska);
		end
	end
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Display Transcription Verification Report %
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	hknoisethresh=39;		% Consider making this option -nt:
	myp(fid,sprintf('         Reporting threshold = %d\n', hknoisethresh))
	
	toshow = risk>hknoisethresh;
	duffchanges = sum(toshow,1);
	nBadBlows=0;
	if any(duffchanges)
		myp(fid,'         List of blow transcriptions exceeding threshold\n')
		myp(fid,'            ChangeNo  BellNo  metric\n')
		for dc = find(duffchanges)
			for bell = find(toshow(:,dc))'
				myp(fid,sprintf('           %6d     %2d   %6d\n', dc,bell,round(risk(bell,dc))))
				nBadBlows = nBadBlows+1;
			end
		end
	end
	myp(fid,sprintf('         Total blow transcriptions exceeding threshold: %d\n',nBadBlows))
end
