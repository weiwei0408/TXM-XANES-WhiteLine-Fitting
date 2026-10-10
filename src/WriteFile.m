%% function WriteFile()
%  Version 2011-02-11;
%  by F. Meirer, Y. Liu, P.A. Williams
%  This software was developed at SSRL as part of the package to process TXM
%  data; this software is freeware 
%  Please report bugs to:
%  liuyijin@slac.stanford.edu
%  fmeirer@slac.stanford.edu
%% Documentation
%  this function writes image data (and metadata if desired) to different file types 
%  flag = WriteFile(img,fn,varargin)
%% INPUT
%  'img' [double]: image data as 2D array of double
%  'fn' [string]: path and filename of file to be written
%  'varargin' [struct]: if provided varargin = struct containing metadata:
%  metadata for .bin and .bim files:
%  metadata.width = image width; class uint32
%  metadata.height = image height; class uint32
%  metadata.angles = list of angles for each image; in radians!; class single
%  metadata.pixelsize = image pixelsize; class single
%  metadata.HBin = horizontal binning; class uint32
%  metadata.VBin = vertical binning; class uint32
%  metadata.energy= incident beam energy; class double
%  metadata.MotPos= motor positions; array of class single
%  metadata.AxisNames= names of axis; array of char
%  .bim files only:
%  metadata.ExpTimes= exposure times; array of single
%  metadata.ImagesTaken= number of images taken; uint32
%  metadata.datatype = class of image dmatrix 10 =>single or 5 =>uint16
%  metadata.date = date
%  metadata.caps = ??
%  
%  the suffix of the filename 'fn' determines the file type to be written:
%  'jpg','bmp','tif','prj','slice','sino','binprj','binslice','binsino':
%      image written as 2D array of double; no metadata written;
%  'bin', 'bim':    image written as 2D array of double; metadata = struct (see above);
%% OUTPUT
%  'flag' = 1 if ok; =0 if error occurred
%% DEPENDENCIES
%  writeBIN, writeBINfile, writeBIMfile   
%%
function flag = WriteFile(img,fn,varargin)

flag = 1;
optargin = length(varargin);
if optargin==1
    metadata=varargin{1};
else
    metadata = [];
end

dotindx=find(fn=='.');
if isempty(dotindx)
    errordlg('Invalid output file format!');
    flag =0;
    return;
else
    extname=fn((dotindx(end)+1):end);
end

img(isnan(img))=0;

switch lower(extname)
    case {'jpg','bmp','png'}
        imwrite(mat2gray(img),fn);
    case {'tif'}
        img=single(img);
        t = Tiff(fn, 'w');
        tagstruct.ImageLength = size(img, 1);
        tagstruct.ImageWidth = size(img, 2);
        tagstruct.Compression = Tiff.Compression.None;
        tagstruct.SampleFormat = Tiff.SampleFormat.IEEEFP;
        tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample = 32;   
        tagstruct.SamplesPerPixel = 1;  
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        t.setTag(tagstruct);
        t.write(img);
        t.close();
    case {'prj','slice','sino'}
        dlmwrite(fn,img);
    case {'binprj','binslice','binsino'}
        % 需要 writeBIN.m
        flag = writeBIN(img,fn);
    case {'bin'}
        % 需要 writeBINfile.m
        if isempty(metadata)
            errordlg('No metadata provided or wrong metadata for .bin! Please select correct output file format!');
            flag = 0;
            return;
        else
            flag = writeBINfile(metadata, img,fn);
        end
    % 删除了 'bim', 'hdf5', 'h5' 分支
    otherwise
        errordlg('Invalid output file format!');
        flag =0;
end
