function [ processid ] = mygetpid( )
	%PID returns the current process id
	%   Detailed explanation goes here
	% Note renamed from pid.m to mygetpid.m to avoid conflict with the pid function in signal package
	if isoctave()
		processid=getpid();
	else
		processid=feature('getpid');
	end
end

