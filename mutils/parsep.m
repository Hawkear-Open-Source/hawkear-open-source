function[isOK, pp, kpstruct, msg] = parsep(pplen,keywords, winargs)
    % Initialise kpstruct and pp
	kpstruct={};
	fieldns= fieldnames(keywords);
    for i = 1:length(fieldns)
		qq=getfield(keywords, fieldns{i});
		if ~isfield(kpstruct,qq{2})
			kpstruct = setfield(kpstruct,qq{2}, qq{3});
		end
	end
	pp=repmat({[]},1,pplen);
	
	% Process parameters
	ishelprequested=0;
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
		    qq=getfield(keywords,lower(k));
			if     strcmp(qq{1}, 'num')
                kpstruct = setfield(kpstruct, qq{2}, getnum(v));
            elseif strcmp(qq{1},'yn')
			    kpstruct = setfield(kpstruct, qq{2}, getyn(v));
            elseif strcmp(qq{1},'str')	    	 	
                kpstruct = setfield(kpstruct, qq{2}, v);
		    else
			    msg = sprintf('ERROR. Invalid keyword table entry "%s".\n\n', disp(qq));
				isOK=0;
				return
			end
		elseif any(strcmp({lower(k)}, {'help','h'}))
			ishelprequested=1;
		else
			msg = sprintf('ERROR. Invalid keyword parameter: "%s"', winargs{i});
			isOK=0;
            return
        end
    end
	if ishelprequested
		msg = sprintf('Help for valid keyword options: %s\n', disp(fieldns));
		isOK=0;
		return
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


% Split a '-keyword:value' parameter into keyword and value
function [k,v] = splitkp (p)
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

% Convert to boolean. value = 'y' of 'Y' results in true. anything else results in false
function [yn] = getyn (v)
    yn = strcmpi(strtrim(v),'y');
end

% Convert to numeric. Only the real part is returned for a complex number. Octave:
% The string must be in one of the following formats where a and b are real numbers and the
% complex unit is 'i' or 'j':
% 
% a + bi
% a + b*i
% a + i*b
% bi + a
% b*i + a
% i*b + a
% If present, a and/or b are of the form [+-]d[,.]d[[eE][+-]d] where the brackets indicate 
% optional arguments and 'd' indicates zero or more digits. The special input values Inf, 
% NaN, and NA are also accepted.
function [num] = getnum (v)
	num=real(str2double(v));
end

% Convert number to string with no trailing zeros
function [sx] = decnotrailingzeros (x) 
    z=sprintf('%f',x);
    for i = length(z)-1:-1:2
        if ~strcmp(z(i),'0');break;end
    end
    if strcmp(z(i),'.')
        i = i-1;
    end
    sx=z(1:i);
end
