function [ t ] = gettime( )
%TIME returns current time in seconds since unix epoch
if (isoctave())
    t=time();
else
    t = java.lang.System.currentTimeMillis/1000;
end
end

