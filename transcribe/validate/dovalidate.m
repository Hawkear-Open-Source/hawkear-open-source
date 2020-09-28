function [isOK, Metadata, msg] = dovalidate(fqfnAudio, fqfnTrain, kpstruct)

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Constructs valid metadata values for the required fields passed on by transcribe for later
	% consumption, or returns an error code and an error message.
	%
    % Parameters:
    % - fqfnAudio = Filename of the audio file to be transcribed
    % - fqfnTrain = Filename of the traindata file for the approporate tower
    % - kpstruct  = Structure containing fields for all the transcribe options
	%
    % Returns:
    % - isOK      = 1 if a full set of metadata has been constructed
    %             = 0 Error, and error message is in the msg parameter
    % - msg       = Message if problem
    % - Metadata  = A structure containing Metadata items. see xxx.md
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
 	metadata.Towerphrase       = '';
    metadata.Title             = '';
    metadata.Rungon            = '';
    metadata.Ringers           = '';
    metadata.Notes             = '';
    metadata.Fake              = '';
	metadata.Method)           = '';
    metadata.Datetime          = '';
    metadata.Ident             = '';
    metadata.Towerid           = '';
    metadata.Bellsringing      = '';
    metadata.Towerid2          = '';
    metadata.Bellset           = '';
	isOK = 0;
	msg = '';
  
    ainfo = audioinfo(fqfnAudio);
	metadata.Title = ainfo.Title;
	metadata.Ringers = ainfo.Artist;
	metadata.Notes = ainfo.Comment;
	
    % Split name into parts 
    [fdir,name,ext] = fileparts(fsSource);
	if length(fdir)== 0
		fsSource = fullfile('.',fsSource);
	end
    [fdir, name, ext] = fileparts(fsSource);
	name = name(name!=' ');
	parts=strsplit(name,'.');
    
    %  If simple filename use as Ringingid
	if length(parts) == 1
		fi.Ringingid = name;
		fi.isWellnamed=false;

	% If multipart filename try to find datetime, towerid, bellset, and Ringingid
	else
		nPartsfound=0;
		[sOK, Ringingdatetime,  dtpartused] = finddatetime(parts);
		if isOK
			fi.Ringingdatetime = Ringingdatetime;
			nPartsfound = nPartsfound+1;
		end
		[isOK, Towerid, topartused] = findtower(parts, [dtpartused]);
 		if isOK
			fi.Towerid = Towerid;
			nPartsfound = nPartsfound+1;
		end
		[isOK, Tenor, nBells, bspartused] = findbellset (parts, [dtpartused, topartused]);
		if isOK
			fi.Tenor = Tenor;
			fi.nBells = nBells;
			nPartsfound = nPartsfound+1;
		end
		[isOK, Ringingid, napartused] = findname(parts, [dtpartused, topartused, bspartused]);
		if isOK
			fi.Ringingid = Ringingid;
			nPartsfound = nPartsfound+1;
		end
 	    if nPartsfound != 4
		    fi.isWellnamed=false;
	    end
    end
    % Get time from directory if necessary
    if isempty(fi.Ringingdatetime)
		[isOK, fi.Ringingdatetime] = dtfromdirentry(fsSource);
    end
	
	% fix up Ringingid and RingingName
    if isempty(fi.Ringingid) % No id provided in the name, so use hhmm as ringingid and decorate it for display purposes
		fi.Ringingid = fi.Ringingdatetime(10:13);
		fi.Ringingname = sprintf('At_%s:%s', fi.Ringingid(1:2), fi.Ringingid(3:4));
	elseif ~isnan(base2dec(fi.Ringingid, 10)); % It is a number so assume it intended as the touch number for display purposes
		fi.Ringingname = sprintf('Touch_%s', fi.Ringingid);
	else % assume it the touchname for display purposes
		fi.Ringingname = fi.Ringingid; 
	end	
end

function [isOK, Ringingid, napartused] = findname(parts, partsused)
	tt=true(1,length(parts));
	tt(partsused) = false;
	parts = parts(tt);
    if length(parts)
        isOK = 1;
        Ringingid = parts{1};
        napartused = find(tt)(1);
    else
        isOK = 0;
        Ringingid = '';
        napartused = [];
    end
end

function [isOK, Tenor, nBells, bspartused] = findbellset (parts, partsused)
	tt=true(1,length(parts));
	tt(partsused) = false;
	parts = parts(tt);
    for i=1:length(parts)
        [isOK, nBells, Tenor, msg] = bellset2st(parts{i}, 0); % 0 means no bellset keywords
        if isOK == 1
            bspartused = find(tt)(i);
            return
        end
    end 
    isOK=0;
    Tenor=0;
    nBells=0;
	bspartused = [];
end

function [isOK, dt, i] = finddatetime (parts)
    for i=1:length(parts)
        [isOK, dt] = dtfrompart(parts{i});
        if isOK
            return
        end
    end 
    isOK=0;
    value=0;
    i=[];
end

function [isOK, dt] = dtfrompart(in) 
    % Checks if string is a convincing date-time and returns yyyymmdd-hhmm if so.
	if ~length(in) || in(1)< 48 || in(1)>57 % Quickly return if not possibly valid
		dt='';
		isOK=0;
	else % slower process of checking if a valid date-time
		vec = datetimestr2vec(in);
		if length(vec) 
			dt = vec2hkdatetime(vec); % This function should return [isOK, dt] !!!!!!!!!
			isOK=1;
		else
			dt='';
			isOK=0;
		end
	end
end

function [isOK, to, topartused] = findtower(parts, dtpartused)
    if ~isempty(dtpartused) && dtpartused == 2
        isOK=1;
        to = parts{1};
        topartused=1;
    else
        isOK=0;
        to = '';
        topartused = [];
    end
end
