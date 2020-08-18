function [ names ] = simpleglob( pattern )
	% SIMPLEGLOB Perform a simple glob of files matching a given pattern
	% Does not support full regular expression globbing, only simple DOS
	% style wild cards.
	% Doesn't use dir as doesn't return fully qualified path.
	
	names={}; % {} perhaps??
	if ~isempty(pattern)   
		[stat, struct] = fileattrib(pattern);
		if stat
            [folder,name,ext]=fileparts(struct(1).Name);
           
            % Sadly MATLAB fileattrib can recurse folders which we do not
            % want for simple globbing, so check that all elements are
            % in the same folder. Would like to find a better way
            for i=1:length(struct)
                [f1,n1,e1]=fileparts(struct(i).Name);
                 if (strcmp(f1,folder) && ~struct(i).directory)
                     names{end+1}=struct(i).Name;
                end
            end
		end
	end
end

% copy of same-named octave function which has a bug where if directory contains a file whoes name contains " -" function fails

function [status, msg, msgid] = fileattrib (file = ".")

  if (nargin > 1)
    print_usage ();
  endif

  if (! ischar (file))
    error ("fileattrib: FILE must be a string");
  endif

  status = true;
  msg = "";
  msgid = "";

  files = glob (file);
  if (isempty (files))
    files = {file};
  endif
  nfiles = numel (files);

  for i = [nfiles, 1:nfiles-1]  # first time in loop extends the struct array
    [info, err, msg] = stat (files{i});
    if (! err)
      r(i).Name = canonicalize_file_name (files{i});

      if (isunix ())
        r(i).archive = NaN;
        r(i).system = NaN;
        r(i).hidden = NaN;
      else
        [~, attrib] = dos (sprintf ('attrib "%s"', r(i).Name));
        ## dos never returns error status so have to check it indirectly
        if (! isempty (strfind (attrib, "  -")))
          status = false;
          msgid = "fileattrib";
          break;
        endif
        attrib = regexprep (attrib, '\S+:.*', "");
        r(i).archive = any (attrib == "A");
        r(i).system = any (attrib == "S");
        r(i).hidden = any (attrib == "H");
      endif

      r(i).directory = S_ISDIR (info.mode);

      modestr = info.modestr;
      r(i).UserRead = (modestr(2) == "r");
      r(i).UserWrite = (modestr(3) == "w");
      r(i).UserExecute = (modestr(4) == "x");
      if (isunix ())
        r(i).GroupRead = (modestr(5) == "r");
        r(i).GroupWrite = (modestr(6) == "w");
        r(i).GroupExecute = (modestr(7) == "x");
        r(i).OtherRead = (modestr(8) == "r");
        r(i).OtherWrite = (modestr(9) == "w");
        r(i).OtherExecute = (modestr(10) == "x");
      else
        r(i).GroupRead = NaN;
        r(i).GroupWrite = NaN;
        r(i).GroupExecute = NaN;
        r(i).OtherRead = NaN;
        r(i).OtherWrite = NaN;
        r(i).OtherExecute = NaN;
      endif
    else
      status = false;
      msgid = "fileattrib";
      break;
    endif
  endfor

  if (status)
    if (nargout == 0)
      status = r;
    else
      msg = r;
    endif
  endif

endfunction