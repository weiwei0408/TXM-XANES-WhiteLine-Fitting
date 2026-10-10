%% function writeBINfile()
%  Version 2011-02-11;
%  by F. Meirer, Y. Liu, P.A. Williams
%  This software was developed at SSRL as part of the package to process TXM
%  data; this software is freeware 
%  Please report bugs to:
%  liuyijin@slac.stanford.edu
%  fmeirer@slac.stanford.edu
%% Documentation
% this function writes .bin files including metadata from .xrm file data using the structure below
% to read these files use readBINfile.m
%  flag = writeBINfile(img,wn)
%% INPUT
%  'img' [double]: image data as 2D array of double
%  'wn' [string]: path and filename of file to be written
%  'metadata' [struct]:
%  metadata.width = image width; class uint32
%  metadata.height = image height; class uint32
%  metadata.angles = list of angles for each image; in radians!; class single
%  metadata.pixelsize = image pixelsize; class single
%  metadata.HBin = horizontal binning; class uint32
%  metadata.VBin = vertical binning; class uint32
%  metadata.energy= incident beam energy; class double
%  metadata.MotPos= motor positions; array of class single
%  metadata.AxisNames= names of axis; array of char
%% OUTPUT
%  'flag' = 1 if ok; =0 if error occurred
%% DEPENDENCIES
%  none   
%%
function flag = writeBINfile(metadata, image,wn)
flag =1;
[fid, message] = fopen(wn,'w');
if isempty(message)
    fwrite(fid,length(metadata.MotPos),'uint32');             
    fclose(fid);
    fid = fopen(wn,'a');
    fwrite(fid,length(metadata.AxisNames),'uint32');
    fwrite(fid,metadata.width,'uint32');   
    fwrite(fid,metadata.height,'uint32');
    fwrite(fid,metadata.angles,'double');
    fwrite(fid,metadata.pixelsize,'single');
    fwrite(fid,metadata.HBin,'uint32');
    fwrite(fid,metadata.VBin,'uint32');
    fwrite(fid,metadata.energy,'double');
    fwrite(fid,metadata.MotPos,'single'); %1x21 array!
    fwrite(fid,metadata.AxisNames,'char');
    fwrite(fid,image,'float32');
    flag = fclose(fid)+1;    
    if flag==0
        message = ferror(fid);
        errordlg(message);
    end
else
    errordlg(message);   
    flag = 0;
end