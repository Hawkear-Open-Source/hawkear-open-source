function [varargout] = printp(varargin)
	
	% Sample a HOS command written in Octave
	
	% 1. Get parameters into a uniform cell structure
    if length(varargin) == 0 % No paramaeters
        winargs = {};
    elseif length(varargin) == 1 && varargin{1}(1) == '.' % Called  with parameters from windows cmdline
        winargs = cmd2cellarray(varargin{1});
    else
        winargs = varargin; % Called with parameters from an Octave environment
    end
	
	% 2. Define the positional parameters accepted by the printp command
	pplen = 2; % Maximum number of positional parameters. Will generate error if more
	           % supplied. Will provide empty parameters to doprintp if less.
			   % Could do more validation here but probably not worth it.
			   
	% 3. Define the keyword parameters accepted by the printp command. The parameters supplied
	%    are validated default values supplied, and a cell structure containing a complete
	%    decodes set of keyword parameters is created for passing to doprintp.m
    keywords.year={'num', 'birthyear', 2020     };
	keywords.month={'str', 'birthmonth', 'Jaunary'};
	keywords.day={'num', 'birthday', '1'};
	keywords.wasweekend={'yn',  'bornatweekend', 1     };
	
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
	[varargout{:}] = doprintp(pp{:}, kp);

end

