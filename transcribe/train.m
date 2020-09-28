function [varargout] = train(varargin)
	api = @dotrain;
	
	% Creates the train file which contains bell signatures and ancilliary data
	%
	% Positional parameters
	% 1. fqdnTrainIn the name of the directory containing individual bell recordings.
	%    The recordings should normally be named:
	%       B1.wav, B2#.wav, B2.wav, B3.wav, B4.wav, B5.wav, B6b.wav, B6.wav, etc
	%    Train also accepts legacy training data which supports up to 12 bells plus the most
	%    common 3 extra bells, but which is not extensible to more bells.
	%       1t.wav, 2t.wav, etc up to 15t.wav with 13t.wav, 14t.wav, 15t.wav being interpreted
	%       as 6b.wav 2#t.wav, and 1##.wav
	%    The normal and legacy bell naming systems cannot be intermingled.
	% 2. fqfnTrainOut
	pplen = 2; 

	% Keyword parameters
    % Keyword       Type   kpstruct.Fieldname  Default   Groupname
    keywords.ws  = {'num', 'WinSizeSecs',        0.05,   'train'};     %    
    keywords.hs  = {'num', 'HopSizeSecs',        0.01,   'train'};     %    
    keywords.co  = {'num', 'compression',        0.9,    'train'};     %    
    keywords.sw  = {'num', 'swin',               40,     'train'};     %    
    keywords.ts  = {'str', 'trainsuffix',        '',     'train'};     %    
    keywords.tp  = {'num', 'TotalProcesses',     nproc(),'train'};     % for matlab use feature('numcores')
    keywords.tid = {'str', 'Towerid',            '',     'train'};     %    
    keywords.tph = {'str', 'TowerPhrase',        '',     'train'};     %    
	keywords.def = {'str', 'DefaultBells'        ''      'train'};     % eg 'B1, B2, B3, (etc)'. 
	
	%%%%%%%%%%%%%%%Do not change anyhing below this line %%%%%%%%%%%%%
	% Get parameters into a uniform cell structure
    if length(varargin) == 0 % No paramaeters
        winargs = {};
    elseif length(varargin) == 1 && varargin{1}(1) == '.' % Called  with parameters from windows cmdline
        winargs = cmd2cellarray(varargin{1});
    else
        winargs = varargin; % Called with parameters from an Octave environment
    end
        	
	% Parse positional and keyword parameters
	[isOK, pp, kp, msg] = parsep(pplen, keywords, winargs);
	varargout = cell (nargout, 1);
    if ~isOK
		fprintf('\n   !!! %s\n\n', msg)
		if nargout
			varargout{1} = 0;
        end
        return
	end
    
	% call worker function
	[varargout{:}] = api(pp{:}, kp);

end

