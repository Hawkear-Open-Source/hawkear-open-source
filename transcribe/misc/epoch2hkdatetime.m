function [ str ] = epoch2hkdatetime( t )
%epoch2hkdatetime Convert epoch time, as returned by gettime() to the HawkEar string datetime format
	
if (isoctave())
    str=strftime('%Y%m%d-%H%M',localtime(t));
else

% convert epoch time (Date requires milliseconds)
   jdate = java.util.Date(t*1000);

% format text and convert to cell array
sdf = java.text.SimpleDateFormat('yyyyMMdd-HHmm');
date_str = sdf.format(jdate);
str = char(cell(date_str));
end

end

