function [varargout] = train(varargin)
	% This file adapted from Boilerplate for HOS commands. 
	
	%%%%%%%%%%%%%%Change this section for different APIs%%%%%%%%%%%%%%%
	api = @dotrain;
	
	% 1. Positional parameters accepted by the train command:
	%     fqdnTrainIn, fqfnTrainOut, Towerid, TowerPhrase
	%    All we need here is the number.
	pplen = 4; 
	
	% 2. Keyword parameters accepted by the train command. The parameters supplied
	%    are validated default values supplied, and a cell structure containing a complete
	%    decoded set of keyword parameters is created for passing to dotrain.m
    % Keyword       Type   kpstruct.Fieldname  Default   Groupname       Meaning
    %keywords.qta= {'yn', 'rubbish',               'q',    ''};        % causes error in keyword table because 'q' should be 0 or 1
    keywords.qt  = {'num', 'quiet',              2,      ''};          % 2. Very little output. 1. Ringing relevant. 1 Lots
    keywords.ws  = {'num', 'WinSizeSecs',        0.05    'train'};     %    
    keywords.hs  = {'num', 'HopSizeSecs',        0.01    'train'};     %    
    keywords.co  = {'num', 'compression',        0.9     'train'};     %    
    keywords.sw  = {'num', 'swin',               40      'train'};     %    
    keywords.ts  = {'str', 'trainsuffix',        ''      'train'};     %    
    keywords.tp  = {'num', 'TotalProcesses',     nproc() 'train'};     %  for matlab use feature('numcores')    
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	%%%%%%%%%%%%%%%Do not change this section%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% 3. Get parameters into a uniform cell structure
    if length(varargin) == 0 % No paramaeters
        winargs = {};
    elseif length(varargin) == 1 && varargin{1}(1) == '.' % Called  with parameters from windows cmdline
        winargs = cmd2cellarray(varargin{1});
    else
        winargs = varargin; % Called with parameters from an Octave environment
    end
        	
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
	[varargout{:}] = api(pp{:}, kp);

end

