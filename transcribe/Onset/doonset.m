function [isOK, xxRawPieceByBi, tdata] = doonset(mixtureA, tdata, kpstruct)

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% doonset.m - process the output of dogain to identify the onsets
	%
	% This file is part of HawkEar.
	%
	% Copyright (C) 2008-2015 Ian McCallion (ian.mccallion.gmail.com)
	% All rights reserved.
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	prevtime=gettime();
	verbose = kpstruct.onsetverbose == 'y';
	
	% normalise the gains by dividing by the max gain for each bell
	[a,z] = size(mixtureA);
	mixtureB = mixtureA./repmat(max(mixtureA),a,1);
	
	% compress by taking the log of the gain
	mixtureD = log(1+2.0*mixtureB);
	
	% Low pass filter the gain signal with a cut-off selected by analysing the
	% mixture.
	%
	% The /50 here arises from the fact that butter expects the cutoff frequency
	% to be twice (why?) the frequency expressed in cycles per sample.
	% The samples are every hopsize. So with a hopsize of 10ms the
	crh = GetChangeRateHz(mixtureA,tdata.HopSizeSecs)*2*tdata.HopSizeSecs;
	[b, a] = butter(4,crh*1.1);
	mixtureE=filtfilt(b, a, mixtureD);
	clear MixtureD;
	PeakCt=zeros(1,tdata.nBells);
	
	% Find the onsets
	totcounts = zeros(1,8);	% There are currently 8 findonset steps
	for bn = tdata.nBells:-1:1
		mbMax = max(mixtureB(:,bn));
		% clear time; fprintf ('       Processing bell: %d\n', bn);prevtime=time;
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% Find the peaks and set all other values to zero
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		x = mixtureE(:,bn);
		y = x.*(x>circshift(x,-1) & x>=circshift(x,1));
		% clear time; fprintf ('time to find all peaks: %.3f ms\n', time-prevtime);prevtime=time;
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% sort the peaks into ascending order
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		zsort = sort (y);
		zsort(end-4:end) = 0;
		ysort = sort(zsort);
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% find the biggest gap in the set of differences. Where this occurs
		% should be the point at which the correct threshold is found
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		[qqq,i] = max(diff(ysort));
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% Get the upper threshold that has the biggest gap below it
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		thresh = ysort(i+1);
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% Now filter y to eliminate all false peaks
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		y([1,end],1)=0;
		y=y.*(x>=thresh);
		% clear time; fprintf ('time to eliminate false peaks: %.3f ms\n', time-prevtime); prevtime=time;
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% Default values for parameters (now controlled by GetControlParams())
		%  kpstruct.MaxBack = 80;     % this is how far back we look from the peak in the filtered signal
		%  kpstruct.MaxFwd  = 10;
		%  kpstruct.NoiseGate = .3;
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% Now search the unfiltered around each inaccurate onset
		% signal for the probable actual onset
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		z = zeros(1,length(y));
		counts = zeros(1,8);	% There are currently 8 findonset steps
		iii = find(y);
		drilldown = 0;
		for ii=1:size(iii)  % for each blow of this bell
			i=iii(ii);      % i is the approximate time of the blow
			bor = max(i-kpstruct.MaxBack,1);
			tor = min(i+kpstruct.MaxFwd,size(mixtureB,1));
			drilldown = bn == kpstruct.onsetprobebell && ii == kpstruct.onsetproberow;
			[index, step] = findonset(mixtureB(bor:tor,bn)', kpstruct          , drilldown);
			if index ~= 0
				try
					z(index+bor-1) = mbMax; % set this as the onset
				catch
					fprintf('\n       *************************************************************\n');
					fprintf(  '       * ERROR. HAWKEAR IS UNABLE TO TRANSCRIBE YOUR RECORDING!!!  *\n')
					fprintf(  '       * This could be because there is no ringing on it, because  *\n')
					fprintf(  '       * the ringing is too short, or because the recording does   *\n')
					fprintf(  '       * not meet HawkEar technical requirements: silence before   *\n')
					fprintf(  '       * and after, low recording level and mono or if stereo the  *\n')
					fprintf(  '       * left channel must contain ringing as right channel is     *\n')
					fprintf(  '       * ignored.                                                  *\n')
					fprintf(  '       *************************************************************\n\n');
					xxRawPieceByBi = [];
                    isOK = 0;
                    return
				end
			end
			if verbose;
				counts(step)= counts(step)+1;
			end % counts by findonset step
		end
		if verbose;fprintf('       Bell %.2d Counts: %s\n',bn, sprintf('%5d  ',counts)) ;end;
		if verbose; totcounts = totcounts + counts;end;
			
		% Save the onset data for this bell
		allys(:,bn)=y; % allys is location of peaks in the smoothed gain signal
		allzs(:,bn)=z; % allzs is location of doonset's estimate of where onset lies
		%clear time; fprintf ('time to find true onset times: %.3f ms\n', time-prevtime);prevtime=time;
	end
	if verbose;fprintf('\n       Total Counts:   %s\n', sprintf('%5d  ', totcounts)) ;end;
	if verbose;fprintf(  '       Total Onsets estimated: %d (%.2f%%)\n\n', sum(totcounts(6:end)), 100*sum(totcounts(6:end))/sum(totcounts));end;

	% output the onsets to the 'xxRawPieceByBi' array
	hopsize=tdata.HopSizeSecs*1000;
	a = find(allzs');
	t = floor((a-1)/size(allzs,2));
	b = a-t*size(allzs,2);
	t = hopsize*(t+1);
	xxRawPieceByBi=[b,t];
		
	% Save data to onsetdata if requested
	if 0
	    saveonsetdata(outputfn, tdata, xxRawPieceByBi, mixtureB, mixtureE, allys, allzs); % For debugging only
	end
	%clear time; fprintf ('       Total time for onset processing: %.3fsecs\n', tdata.OnsetProcTime);
	isOK = 1;
end	


function [] = saveonsetdata(fn, tdata, xxRawPieceByBi, mixtureB, mixtureE, allys, allzs)
    save('-mat',fn);
end

