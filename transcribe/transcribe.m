function [varargout] = transcribe(varargin)
	
	% Sample a HOS command written in Octave
	
	% 1. Get parameters into a uniform cell structure
    if length(varargin) == 0 % No paramaeters
        winargs = {};
    elseif length(varargin) == 1 && varargin{1}(1) == '.' % Called  with parameters from windows cmdline
        winargs = cmd2cellarray(varargin{1});
    else
        winargs = varargin; % Called with parameters from an Octave environment
    end
	
	% 2. Define the positional parameters accepted by the transcribe command
	pplen = 3; % Positional parameters: fqfnAudio, fqfnTrain, fqfnLowndes
			   
	% 3. Define the keyword parameters accepted by the transcribe command. The parameters supplied
	%    are validated default values supplied, and a cell structure containing a complete
	%    decoded set of keyword parameters is created for passing to dotranscribe.m

    % keyword       type   field name          def value  meaning
    % train                                             
    %keywords.ft  = {'yn' , 'fasttrain',         'y'};     %     
    %keywords.ws  = {'num', 'WinSizeSecs',       0.05};    %    
    %keywords.hs  = {'num', 'HopSizeSecs',       0.01};    %    
    %keywords.co  = {'num', 'compression',       0.9};     %    
    %keywords.sw  = {'num', 'swin',              40};      %    
    %keywords.ts  = {'str', 'trainsuffix',       ''};      %    
    
    % gain 
    keywords.fg  = {'yn' , 'cppgain',           'y'};     %     
    keywords.fl  = {'num', 'FreqLow',           200};     %    
    keywords.fh  = {'num', 'FreqHigh',          6000};    %    
    keywords.tp  = {'num', 'TotalProcesses',    nproc()}; %  for matlab use feature('numcores')    
    keywords.bs  = {'num', 'BatchSize',         5000};    %    
    
    % onset
    keywords.mb  = {'num', 'MaxBack',           80};      %    
    keywords.mf  = {'num', 'MaxFwd',            10};      %    
    keywords.ng  = {'num', 'NoiseGate',         .3};      %    
    keywords.oo  = {'num', 'OnsetOptim',        0};       %    
    
    % onset debugging 
    keywords.ob  = {'num', 'onsetprobebell',    0};       %    
    keywords.or  = {'num', 'onsetproberow',     0};       %    
    keywords.ov  = {'num', 'onsetverbose',      'n'};     %    
    
    % write    
    keywords.hb  = {'yn' , 'hb',                'y'};     % Create lowndes files w/wo hand/back indicator
    
    % analyser  
    keywords.au  = {'yn' , 'audiolink',         'n'};     % Create audio file of touch in analysis folder
    keywords.xp  = {'yn' , 'experiment',        'n'};     % experiment option for tuning transcription
    keywords.hsg = {'num', 'hsg',               -1};      % HSG to be used by models if required
    
    % Workflow  
    keywords.gt  = {'yn' , 'gentranscription', 'y'};      % stop after train
    keywords.ga  = {'yn' , 'genanal',          'y'};      % Generate Analysis
    keywords.gw  = {'yn' , 'genwebpages',      'y'};      % Generate web pages (implemented by analyser)
    keywords.gi  = {'yn' , 'genindex',         'y'};      % Generate the index page after analysis
    keywords.li  = {'yn' , 'launchindex',      'y'};      % Launch index
    keywords.ll  = {'yn' , 'launchlatest',     'n'};      % Launch latest analysis (Overrides launch index)
    keywords.sg  = {'yn' , 'suppressgraphs',   'n'};      % Suppress graphs (use in tower to speed analysis)
    keywords.qt  = {'num', 'quiet',            2};        % 2. Very little optput. 1. Ringing relevant. 1 Lots
    keywords.fo  = {'yn' , 'forcetr',          'n'};      % (y=> force transcription (Product only)
    
    % Dev only 
    keywords.wt  = {'yn' ,  'genWebtemp',       'y'};     % Create webtemp file for testing with tw.m
     	
	% 4. Parse positional and keyword parameters
	[isOK, pp, kp, msg] = parsep(pplen, keywords, winargs);
	varargout = cell (nargout, 1);
    if ~isOK
		fprintf('\n   !!! %s\n\n', msg)
		if nargout
			varargout{1} = 0;
        end
        return
	end
    
	% 5. Do the work and return whatever the doxxx function returned
	[varargout{:}] = dotranscribe(pp{:}, kp);

end

