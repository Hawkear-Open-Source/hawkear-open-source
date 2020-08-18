function [somebasis, tpdata] = dofasttrainloop2(inputdir, SampleRate, WinSizeSecs, HopSizeSecs, bells)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% DOFASTTRAINLOOP - Train Hawkear on tracks from individual bells
	%    can be called either in a subprocess to share out the work
	%    or in process to put train data directly into allbasis
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	prevtime=gettime();
	sbells = sprintf('%d ',bells);
	ret = 1;

	% Not defined in MATLAB!
	stderr=2;
	
	index = 0;
	for bell = bells
	    index=index+1;
	    
	    %%%%%%%%%%%%%%%%%%
	    % Read the signal
	    %%%%%%%%%%%%%%%%%%
	    
	    fn = fullfile(inputdir,[num2str(bell),'t.wav']);
	    if exist(fn,'file')
	        prevtime=gettime();
	        %fprintf(stderr,'       Processing bell: %d\n',bell);
	        [sig,trainfs]=audioread(fn);
            sig = sig(:,1);           
			params.win_size_s     = round(WinSizeSecs*trainfs);
			% Use an even real FFT length
			params.win_size_s     = fix(params.win_size_s/2)*2;
			params.hop_size_s     = round(HopSizeSecs*trainfs);
			params.fft_length     = params.win_size_s;
	        
	        tpdata.TraindB(bell)     = ratio2db(max(abs(sig)));
	        
	        %%%%%%%%%%%%%%%%%%%%%%%%
	        % calculate spectrogram X(f,t)
	        %%%%%%%%%%%%%%%%%%%%%%%%
	        X=abs(spectrogram(sig,...
	            hammingwindow(params.win_size_s), ...
	            params.win_size_s-params.hop_size_s,...
	            params.fft_length));
	        
	        fprintf (stderr,'       Time to compute spectrum of bell %d: %.3fsecs\n', bell, gettime()-prevtime);
	        %%%%%%%%%%%%
	        % factorize --- one source KL factorization has a closed analytic form
	        %%%%%%%%%%%%
	        prevtime=gettime();
	        
	        % Sum over time
	        norms = sum(X,2);
	        
	        % Compute the analytical optimum
	        S= norms/ sum(norms);
	        
	        fprintf (stderr,'       Time to factorise bell %d: %.3fsecs\n', bell, gettime()-prevtime);
	        
	        %%%%%%%%%%%%%%%%%%%%%%%%%
	        % accumulate the spectra
	        %%%%%%%%%%%%%%%%%%%%%%%%%
	        
	        somebasis(:,index)=S;
	    else
	        break
	    end
	end
end
	
