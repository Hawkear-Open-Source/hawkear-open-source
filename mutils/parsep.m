function[isOK, pp, kpstruct, msg] = parsep(pplen, keywords, winargs)
	% 1. Manage the quiet option. kpstruct will have the "quiet" field and the user can specify the "-qt:value" parameter
	%    whether or not "qt" is listed in the keywords table. Meaning of "qt":
	%      - 0 ==> Noisy. 
	%      - 1 ==> Ringing info only. 
	%      - 2 ==> Silent.
	%    Here we set the default value -qt:0. This is an attempt to ensure standardisation across components.

    % 2. Initialise rest of kpstruct from the keywords table
    kpstruct = {};
	fieldns= fieldnames(keywords);
        for i = 1:length(fieldns)
			try
				qq=getfield(keywords, fieldns{i});
				putp('', qq{3}, qq{1});
			catch % Bug in keywords table
				error ('\n   INTERNAL ERROR: Unknown problem with row %d of keyword table.',i)
			end
		    if ~isfield(kpstruct,qq{2}) % if field does not already exist we are OK
		    	kpstruct = setfield(kpstruct,qq{2}, qq{3});
			else 
				error('\n   INTERNAL ERROR: Problem with row %d of keyword table. Cannot specify the -qt: option, or duplicate value in column 2\n', i);
		    end
	    end
	keywords.qt    = {'num', 'quiet'    , NaN      , ''}; 
	keywords.quiet = {'num', 'quiet'    , NaN      , ''}; 
	keywords.h     = {'none', 'help'    , NaN      , ''}; 
	keywords.help  = {'none', 'help'    , NaN      , ''}; 
    kpstruct.quiet = 1;
    kpstruct.help  = 0;

	% 3. Initialise positional parameters, pp, to empty cell structure of correct size.
	pp=repmat({[]},1,pplen);
	
	% 4. Complete pp and kpstruct from parameters on the API request
	iskpstarted=false;
    for i = 1:length(winargs)
        if isempty(winargs{i})
            continue
        end
        if winargs{i}(1) ~= '-'
			if iskpstarted
				msg = sprintf('ERROR. Invalid parameter "%s"', winargs{i});
				isOK=0;
				return
			else
				pp{i}=winargs{i};
				continue
			end
		else 
			iskpstarted = true;
		end
		[k,v]= splitkp(winargs{i});
		if isfield(keywords, lower(k))
		    qq = getfield(keywords,lower(k));
			if     strcmp(qq{1}, 'num')
                kpstruct = setfield(kpstruct, qq{2}, getnum(v));
            elseif strcmp(qq{1},'yn')
			    kpstruct = setfield(kpstruct, qq{2}, getyn(v));
            elseif strcmp(qq{1},'str')	    	 	
                kpstruct = setfield(kpstruct, qq{2}, v);
            elseif strcmp(qq{1},'none')	    	 	
                kpstruct = setfield(kpstruct, qq{2}, 1);
		    else
			    error('INTERNAL ERROR. Invalid keyword table entry "%s".\n\n', disp(qq));
			end
		else
			msg = sprintf('ERROR. Invalid keyword parameter: "%s"', winargs{i});
			isOK=0;
            return
        end
    end
    
    if kpstruct.help
		error('Help for valid keyword options: %s\n', disp(fieldns));
    end
	rmfield(kpstruct,'help');
    
	% 5. Add the group parameter strings. These become metadata included in the component's output data and presented in the
	%    technical information of an eventual analysis, for example "trainparams" for the parameters used to create the train file
	fieldns = fieldnames(keywords);
	for i = 1:length(fieldns)
		kw = fieldns{i}; % e.g. "qt" 
		qq = getfield(keywords, kw); % e.g. {'num', 'quiet'    , 2      , 'train'}
        if isempty(qq{4})
            continue;
        end
		type = qq{1}; % eg "num"
		kpname = qq{2}; % e.g. "quiet"
		v  = getfield(kpstruct, kpname); % get the operational value of e.g. kpstruct.quiet
		sv = putp(kw, v, type); % string version of the kpstruct field e.g. "-qt:n"
		group  = [qq{4},'params'];    % e.g. "trainparams"
		if isfield(kpstruct, group)
			cv = getfield(kpstruct, group);
			kpstruct = setfield(kpstruct, group, [cv, ' ', sv]);
		else
			kpstruct = setfield(kpstruct, group, sv);
		end		
	end

	if length(pp) > pplen
		msg = sprintf('ERROR. unwanted positional parameters');
        pp = pp(1:pplen);
		isOK=0;
		return
	end
    msg='';
    isOK=1;
end	

function [k,v] = splitkp (p) % Split a '-keyword:value' parameter into keyword and value
    i=find(p==':');
    if length(i)
        v=strtrim(p(i(1)+1:end));
        k=p(2:i(1)-1);
		if length(v)>1 && v(1) == '"' && v(end) == '"'
			v=v(2:end-1);
		end
    else
        k=p(2:end);
        v='';
    end
    k=lower(k);
end

function [yn] = getyn (v) % Convert string to boolean
	% Value = 'y' or 'Y' results in true. anything else results in false
    yn = strcmpi(strtrim(v),'y');
end

function [num] = getnum (v) % Convert string to numeric. 
	% String must be in one of the following formats where
    % a and b are real numbers and the complex unit is 'i' or 'j':
    %    a + bi
    %    a + b*i
    %    a + i*b
    %    bi + a
    %    b*i + a
    %    i*b + a
    % If present, a and/or b are of the form [+-]d[,.]d[[eE][+-]d] where the brackets indicate 
    % optional arguments and 'd' indicates zero or more digits. The special input values Inf, 
    % NaN, and NA are also accepted.
	num=real(str2double(v));
	if isnan(num)|| isna(num); % Silently treat NaN and NA as zero
    	num=0;
	end
end

function [sv] = putp(kp, v, type) % Recreate the commandline parameter
    if strcmp(type,'num')
        sv = sprintf('%d',v);
    elseif strcmp(type,'yn')
        sv = 'ny'(v+1);
    else % "str". put value in quotes if there is anything weird in the parameter
        svoriginal = sv = strtrim(v);
        sv(sv=="\n")='';
        sv(sv=="\t")='';
        if any(sv==' ') || ~strcmp(svoriginal,sv)
            sv=["\"",sv,"\""];
        end
    end
    sv = sprintf('-%s:%s',kp,sv);
end
