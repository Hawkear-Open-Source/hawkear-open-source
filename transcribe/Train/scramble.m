function [ about ] = scramble (abin,yn,state)

	% scrambling currently is done by modifying allbasis in training step
	% and descrambling in dogainloop
	%
	% Eventual aim is to scramble only for products - during build:
	% - modify trainingdata
	% - modify dogainloop and to descramble by editing the scrambling code into
	%   dogainloop

    if (isoctave())
        %% Mimic octave 4.2.2 and earlier when using Octave 4.4.0
        %% Is not correct for -ve states but this should never happen
        if state == Inf
            rand('state',0);
        else
            rand('state',floor(state));
        end
        rvec=rand(size(abin));
    else
        %% Horrible code to minimic the Octave RNG initialization
        mt=octave_twister_seed(state);
        ss=RandStream('mt19937ar');
        ss.set('State', mt);
        rvec=ss.rand(size(abin));
    end
    
    
    q=.05;
	if yn == 'y'
		about = abin.*(rvec*(1/q-q)+q);
	else
		about = abin./(rvec*(1/q-q)+q);
	end
end
