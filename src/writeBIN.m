%% function WriteFile()
%  Version 2011-02-11;
%  by F. Meirer, Y. Liu, P.A. Williams
%  This software was developed at SSRL as part of the package to process TXM
%  data; this software is freeware 
%  Please report bugs to:
%  liuyijin@slac.stanford.edu
%  fmeirer@slac.stanford.edu
%% Documentation
%  this function writes image data (and metadata if desired) as
%  '.binprj','.binslice' or '.binsino' filetype
%  flag = writeBIN(img,wn)
%% INPUT
%  'img' [double]: image data as 2D array of double
%  'wn' [string]: path and filename of file to be written
%% OUTPUT
%  'flag' = 1 if ok; =0 if error occurred
%% DEPENDENCIES
%  none   
%%
function flag = writeBIN(img,wn)
flag =1;
img=double(img);
[fid, message] = fopen(wn,'w');
if isempty(message)
    [size1,size2]=size(img);
    size1=double(size1);
    size2=double(size2);
    fwrite(fid,size1,'float32');
    fwrite(fid,size2,'float32');
    fwrite(fid,img,'float32');
    flag = fclose(fid)+1;
    if flag==0
        message = ferror(fid);
        errordlg(message);
    end
else
    errordlg(message);   
    flag = 0;
end