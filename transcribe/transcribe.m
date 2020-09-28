function [varargout] = transcribe(varargin)
	% Specify the name of the worker function
	APIWORKER = @dotranscribe;
	
	% Specify positional parameters
	%  - fqfnAudio                                            % Audio and ringer data
	%  - fqfnTrain                                            % Transcribe will use tower info in training data as metadata to be passed on YES!!!!!
	%  - fqfnLowndes                                          % Transcription result
	PPLEN = 3; % Number of lines above
	
	% Specify keyword parameters
    % Keyword           Type   kpstruct.Fieldname  Default   Groupname       Meaning
	% Metadata keyword parameters
	KEYWORDS.Title    = {'str', 'Title',            '',       ''};         % Title that will appear in analysis headers (eg "Touch n" or "Team A")
	KEYWORDS.Rungon   = {'str', 'Rungon',           '',       ''};         % Eg "Front eight"
	KEYWORDS.Ringers  = {'str', 'Ringers',          '',       ''};         % Ordered list of who was ringing. Names comma-separated
	KEYWORDS.Notes    = {'str', 'Notes',            '',       ''};         % Information that can be seen when the analysis is viewed
	KEYWORDS.Method   = {'str', 'Method',           '',       ''};         % Name of method/composition/touch.
	KEYWORDS.DateTime = {'str', 'Date'              '',       ''};         % Date of ringing YYYYMMDD-HHMM
	KEYWORDS.Ident    = {'str', 'Ident'             '',       ''};         % Short name of the ringing (alphanumeric characters only)
    KEYWORDS.Bells    = {'str', 'BellsRinging',     '',       ''};	       % Ordered list of bells ringing. CS-list of training filenames
    % classify
    KEYWORDS.fl  = {'num', 'FreqLow',              200,      'classify'}; %    
    KEYWORDS.fh  = {'num', 'FreqHigh',             6000,     'classify'}; %    
    KEYWORDS.tp  = {'num', 'TotalProcesses',       nproc(),  'classify'}; % for matlab use feature('numcores')    
    KEYWORDS.bs  = {'num', 'BatchSize',            5000,     'classify'}; %    
    % onset                                        
    KEYWORDS.mb  = {'num', 'MaxBack',              80,       'onset'};    %    
    KEYWORDS.mf  = {'num', 'MaxFwd',               10,       'onset'};    %    
    KEYWORDS.ng  = {'num', 'NoiseGate',            .3,       'onset'};    %    
    KEYWORDS.oo  = {'num', 'OnsetOptim',           0,        'onset'};    %    
    % onset debugging                              
    KEYWORDS.ob  = {'num', 'onsetprobebell',       0,        ''};         %    
    KEYWORDS.or  = {'num', 'onsetproberow',        0,        ''};         %    
    KEYWORDS.ov  = {'num', 'onsetverbose',         0,        ''};         %    
    % write                                        
    KEYWORDS.hb  = {'yn' , 'hb',                   1,        'write'};    % Create lowndes files w/wo hand/back indicator
     	
	% Get parameters into a uniform cell structure
    if length(varargin) == 0 % No paramaeters
        winargs = {};
    elseif length(varargin) == 1 && varargin{1}(1) == '.' % Called  with parameters from windows cmdline
        winargs = cmd2cellarray(varargin{1});
    else
        winargs = varargin; % Called with parameters from an Octave environment
    end
	% Parse positional and keyword parameters
	[isOK, pp, kp, msg] = parsep(PPLEN, KEYWORDS, winargs);
	varargout = cell (nargout, 1);
    if ~isOK
		fprintf('\n   !!! %s\n\n', msg)
		if nargout
			varargout{1} = 0;
        end
        return
	end
    
	% 5. Do the work and return whatever the doxxx function returned
	[varargout{:}] = APIWORKER(pp{:}, kp);

end

