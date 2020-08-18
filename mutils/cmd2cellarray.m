function [myargs] = cmd2cellarray(p)
    % Recovers the windows commandline parameters from the string passed to the hkpxxx functions.
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Solves the problem that the commandline the user types in passes through two parsers before reaching
	% octave variables which means a trick is needed in order to pass parameters to HawkEar code containing
	% quotes and doublequotes, e.g. 
	%   -xl:"It's a Link to my own pdf:mypdf.pdf"
	% Uses the windows command processor ability to substitute data in variables using the syntax:
	%    set modified=%original:from=to%
    % to delete { and } from the commandline, replace " with { and ' with }. The exact statements needed 
	% in xxx.cmd are: 
	%    @set P=.%*			Copies all parameters into a %P% preceded by a .
	%    @set P=%P:{=%		Remove {
	%    @set P=%P:"={%		Replace " with {
	%    @set P=%P:}=%		Remove }
	%    @set P=%P:'=}%		Replace ' with {
	% %P% is then passed (1) into octave (2) into hoscommandname.m (3) into cmd2cellarray.m which recovers 
	% the original parameters and returns them in a cell array.
	% The " character is used in windows commandline commands to enclose parameters containing blanks, hence
	% if the first and last characters of a parameter are " these are stripped off, and also any "" in the string
	% is replaced by ".
	%
	% Note. There may be a better choices than { and } as the substitution characters but I did not find them
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
    sq='}';
    dq='{';
    myargs={};
    thisarg='';
    inarg=false;
    indq=false;
    insq=false;
    lastwasblank=false;
    for i = 2:length(p)
        if p(i) == ' ' && lastwasblank % ignore repeated blanks
        elseif p(i) == ' ' && ~indq && ~insq  % marks parameter boundary
            myargs{end+1}=thisarg;
            thisarg='';
            lastwasblank=true;
        elseif p(i) == sq || p(i) == "'"
            insq=~insq;
            thisarg(end+1)="'";
            lastwasblank=false;
        elseif p(i) == dq || p(i) == '"'
            indq=~indq;
            thisarg(end+1)='"';
            lastwasblank=false;
        else
            thisarg(end+1)=p(i);
            lastwasblank=false;
        end
    end
	if ~isempty(thisarg)
        if thisarg(1)=='"' && thisarg(end)=='"'
	        thisarg=thisarg(2:end-1);
		    thisarg=strrep(thisarg,'""','"');
	    end
        myargs(end+1)=thisarg;
    end
end
