function [s1] = mergestruct (s1, s2)

	% Merges two structures. if there are same-named 
	% fields in s1 and s2 the value in s2 prevails
	% 
	% mergestruct crashes if the parameters
	% are not structures.
	
    fns = fieldnames(s2);
  % struct2numfields = numfields(s2);
    szfns=size(fns);
    struct2numfields = szfns(1);
    for i = 1:struct2numfields  
        fn = char(fns(i));
        
        fv = getfield(s2, fn);
        s1 = setfield(s1, fn, fv);
    end
end
