% ImgViewer_peak - GUI for TXM-XANES white-line peak fitting
% Companion code for [Efficient Chemical State Imaging of Ni90 Cathodes by In Situ TXM-XANES White-Line Peak Fitting ]
% Tested on MATLAB R2022a
% Requires: skewgauss.m, disp_img_in_ImgViewer.m, ROI_selection_for_QTXMXANES.m, WriteFile.m
% gui初始化主流程
function varargout = ImgViewer_peak(varargin)
% IMGVIEWER MATLAB code for ImgViewer_peak.fig
%      IMGVIEWER, by itself, creates a new IMGVIEWER or raises the existing
%      singleton*.
%
%      H = IMGVIEWER returns the handle to a new IMGVIEWER or the handle to
%      the existing singleton*.
%
%      IMGVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMGVIEWER.M with the given input arguments.
%
%      IMGVIEWER('Property','Value',...) creates a new IMGVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ImgViewer_peak_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ImgViewer_peak_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%个
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ImgViewer_peak

% Last Modified by GUIDE v2.5 21-Sep-2026 16:11:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;%初始化流程,只能打开一个实例
%设置gui的文件名、单例、初始化函数、退出执行的函数、布局和通用回调
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ImgViewer_peak_OpeningFcn, ...
    'gui_OutputFcn',  @ImgViewer_peak_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout%内置gui函数
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});%有输出的调用方式
else
    gui_mainfcn(gui_State, varargin{:});%无输出的调用方式
end
% End initialization code - DO NOT EDIT

%%==============================窗口创建时,读取初始输入参数,初始化相关控件值和状态=========================================
% -- Executes just before ImgViewer_peak is made visible.
% -- Executes just before ImgViewer_peak is made visible.
function ImgViewer_peak_OpeningFcn(hObject, ~, handles, varargin)
handles.output = hObject;
set(hObject, 'Name', 'ImgViewer_peak');   % 设置新的窗口标题栏文本
stack = [];
POI = [];

% Initialize selectedROIImage
handles.selectedROIImage = []; % 确保初始化为一个空数组

if ~isempty(varargin)
    stack = varargin{1};  % 第一个参数:堆栈
    if length(varargin) > 1
        path = varargin{2};  % 第二个参数:路径
        set(handles.Path, 'String', path);
    end
    if length(varargin) > 2
        fn = varargin{3};  % 第三个参数:文件名标识
        set(handles.Path, 'UserData', fn);
    end
    if length(varargin) > 3
        handles.MarkPOI = varargin{4};  % 第四个参数:标记POI
    end
    if length(varargin) > 4
        handles.Es_white = varargin{5};  % 第五个参数:赋值给Es_white
    end
    if length(varargin) > 5
        handles.E_whiteline = varargin{6};       % 第六个参数:赋值给E_white
    end
    if length(varargin) > 6
        handles.data_source = varargin{7};  % 第七个参数:赋值给handles中data_source
    end
    if length(varargin) > 7
        handles.diffimg = varargin{8};  % 第七个参数:赋值给handles中data_source
    end
    guidata(hObject, handles);  % 更新handles
end

% 用POI覆盖而不是只初始化空
handles.POI = POI;
guidata(hObject, handles);

% 将图像保存在handles中,而不立即显示
if ~isempty(stack)
    set(handles.Browse, 'UserData', stack);
    handles.stack = stack;  % 将图像存储到handles中,以后使用

    % 打印handles.stack和POI的值
    disp('Value of handles.stack:');
    disp(handles.stack);  % 打印handles.stack的值
    disp(['Value of POI: ', num2str(POI)]);  % 打印POI值
end

% 初始化参考谱存储结构(标量结构体)
handles.ref_spectra = struct();
handles.ref_spectra.name = {'Ref1', 'Ref2', 'Ref3', 'Ref4', 'Ref5','Ref6','Ref7','Ref8'};
handles.ref_spectra.data = cell(1,8);

% 初始化列表控件(假设 listbox 的 Tag 为 'ref_listbox')
set(handles.ref_listbox, 'String', {'Ref1 (empty)', 'Ref2 (empty)', 'Ref3 (empty)', ...
    'Ref4 (empty)', 'Ref5 (empty)', 'Ref6 (empty)', 'Ref7 (empty)', 'Ref8 (empty)'}, ...
    'Value', 1);
% 将 ref_listbox 设置为支持多选模式
set(handles.ref_listbox, 'Max', 2, 'Min', 0);  % 启用多选
% 更新handles
guidata(hObject, handles);




%% ===================单独的函数====================================================
function displayImage(handles)
if isfield(handles, 'img') && ~isempty(handles.img)
    stack = handles.img;  % 读取存储的图像

    if size(stack, 3) > 1
        % 处理多通道图像
        set(handles.ColorMaps, 'Enable', 'off');
        set(handles.ShowThresholdMask, 'Enable', 'off');
        set(handles.Threshold_low, 'Enable', 'off');
        set(handles.Threshold_high, 'Enable', 'off');
        set(handles.ShowndataWindow_low, 'Enable', 'off');
        set(handles.ShowndataWindow_high, 'Enable', 'off');
        set(handles.RawdataWindow_low, 'Enable', 'off')
        set(handles.RawdataWindow_high, 'Enable', 'off')
        imshow(mat2gray(stack), 'Parent', handles.imgarea);
    else
        % 处理单通道图像
        set(handles.ColorMaps, 'Enable', 'on');
        set(handles.ShowThresholdMask, 'Enable', 'on');
        set(handles.Threshold_low, 'Enable', 'on');
        set(handles.Threshold_high, 'Enable', 'on');
        set(handles.ShowndataWindow_low, 'Enable', 'on');
        set(handles.ShowndataWindow_high, 'Enable', 'on');
        set(handles.RawdataWindow_low, 'Enable', 'on')
        set(handles.RawdataWindow_high, 'Enable', 'on')
        imshow(stack, [], 'Parent', handles.imgarea);
    end
end





% --- 新增:绘制原始谱线的通用函数 ---
function plot_original_spectrum(handles, Es, spectrum, ii, jj)
axes(handles.pixel_axes3);
cla(handles.pixel_axes3);
plot(Es, spectrum, 'bo-', 'LineWidth', 1.2, 'DisplayName', 'Original Spectrum');
xlabel('Energy (eV)');
ylabel('Normalized Intensity');
title(sprintf('Pixel (%d, %d) Original Spectrum', ii, jj));
legend show;
grid on;
drawnow;

%% --- Outputs from this function are returned to the command line.
function varargout = ImgViewer_peak_OutputFcn(~, ~, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;%handles.output作为函数的第一个输出


function Path_Callback(~, ~, ~)
% hObject    handle to Path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Path as text
%        str2double(get(hObject,'String')) returns contents of Path as a double

%路径按钮的外观
% --- Executes during object creation, after setting all properties.
function Path_CreateFcn(hObject, ~, ~)
% hObject    handle to Path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
    
end
function Path_DeleteFcn(hObject, ~, ~)

%RawdataWindow_low
function RawdataWindow_low_Callback(~, ~, ~)
% hObject    handle to RawdataWindow_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RawdataWindow_low as text
%        str2double(get(hObject,'String')) returns contents of RawdataWindow_low as a double

% --- Executes during object creation, after setting all properties.
function RawdataWindow_low_CreateFcn(hObject, ~, ~)
% hObject    handle to RawdataWindow_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function RawdataWindow_high_Callback(~, ~, ~)
% hObject    handle to RawdataWindow_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RawdataWindow_high as text
%        str2double(get(hObject,'String')) returns contents of RawdataWindow_high as a double

% --- Executes during object creation, after setting all properties.
function RawdataWindow_high_CreateFcn(hObject, ~, ~)
% hObject    handle to RawdataWindow_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%Threshold Window
function Threshold_low_Callback(~, ~, handles)
% hObject    handle to Threshold_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Threshold_low as text
%        str2double(get(hObject,'String')) returns contents of Threshold_low as a double
DataWindowL=str2double(get(handles.RawdataWindow_low,'String'));
DataWindowH=str2double(get(handles.RawdataWindow_high,'String'));
Tlow=str2double(get(handles.Threshold_low,'String'));
Thigh=str2double(get(handles.Threshold_high,'String'));
ShowLow=str2double(get(handles.ShowndataWindow_low,'String'));
ShowHigh=str2double(get(handles.ShowndataWindow_high,'String'));%从控件中获得数值参数
if isnan(Tlow) || Tlow<DataWindowL || Tlow>=Thigh%判断用户输入是否合法,判断区间是否合理,有一个为真值即为真
    set(handles.Threshold_low,'String',num2str(DataWindowL));
end
disp_img_in_ImgViewer(handles);

% --- Executes during object creation, after setting all properties.
function Threshold_low_CreateFcn(hObject, ~, ~)
% hObject    handle to Threshold_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Threshold_high_Callback(~, ~, handles)
% hObject    handle to Threshold_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Threshold_high as text
%        str2double(get(hObject,'String')) returns contents of Threshold_high as a double
DataWindowL=str2double(get(handles.RawdataWindow_low,'String'));
DataWindowH=str2double(get(handles.RawdataWindow_high,'String'));
Tlow=str2double(get(handles.Threshold_low,'String'));
Thigh=str2double(get(handles.Threshold_high,'String'));
ShowLow=str2double(get(handles.ShowndataWindow_low,'String'));
ShowHigh=str2double(get(handles.ShowndataWindow_high,'String'));
if isnan(Thigh) || Thigh>DataWindowH || Tlow>=Thigh
    set(handles.Threshold_high,'String',num2str(DataWindowH));
end
disp_img_in_ImgViewer(handles);

% --- Executes during object creation, after setting all properties.
function Threshold_high_CreateFcn(hObject, ~, ~)
% hObject    handle to Threshold_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ShowndataWindow_low_Callback(~, ~, handles)
% hObject    handle to ShowndataWindow_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ShowndataWindow_low as text
%        str2double(get(hObject,'String')) returns contents of ShowndataWindow_low as a double

DataWindowL=str2double(get(handles.RawdataWindow_low,'String'));
DataWindowH=str2double(get(handles.RawdataWindow_high,'String'));
Tlow=str2double(get(handles.Threshold_low,'String'));
Thigh=str2double(get(handles.Threshold_high,'String'));
ShowLow=str2double(get(handles.ShowndataWindow_low,'String'));
ShowHigh=str2double(get(handles.ShowndataWindow_high,'String'));
if isnan(ShowLow) || ShowLow>=Thigh || ShowLow>=ShowHigh
    set(handles.ShowndataWindow_low,'String',num2str(Tlow));
end

disp_img_in_ImgViewer(handles);

% --- Executes during object creation, after setting all properties.
function ShowndataWindow_low_CreateFcn(hObject, ~, ~)
% hObject    handle to ShowndataWindow_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ShowndataWindow_high_Callback(~, ~, handles)
% hObject    handle to ShowndataWindow_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ShowndataWindow_high as text
%        str2double(get(hObject,'String')) returns contents of ShowndataWindow_high as a double
DataWindowL=str2double(get(handles.RawdataWindow_low,'String'));
DataWindowH=str2double(get(handles.RawdataWindow_high,'String'));
Tlow=str2double(get(handles.Threshold_low,'String'));
Thigh=str2double(get(handles.Threshold_high,'String'));
ShowLow=str2double(get(handles.ShowndataWindow_low,'String'));
ShowHigh=str2double(get(handles.ShowndataWindow_high,'String'));
if isnan(ShowHigh) || ShowHigh<=Tlow || ShowLow>=ShowHigh
    set(handles.ShowndataWindow_high,'String',num2str(Thigh));
end

disp_img_in_ImgViewer(handles);

% --- Executes during object creation, after setting all properties.
function ShowndataWindow_high_CreateFcn(hObject, ~, ~)
% hObject    handle to ShowndataWindow_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in ColorMaps.
function ColorMaps_Callback(~, ~, handles)
% hObject    handle to ColorMaps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ColorMaps contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ColorMaps
disp_img_in_ImgViewer(handles);

% --- Executes during object creation, after setting all properties.
function ColorMaps_CreateFcn(hObject, ~, ~)
% hObject    handle to ColorMaps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in SaveAs.
function SaveAs_Callback(~, ~, handles)
% hObject    handle to SaveAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
path=get(handles.Path,'String');
fn=get(handles.Path,'UserData');
if path(end)~='\' || isempty(fn)
    return;
end
img=get(handles.Browse,'UserData');%获取当前图像数据
Tlow=str2double(get(handles.Threshold_low,'String'));%读取阈值下限
Thigh=str2double(get(handles.Threshold_high,'String'));%读取阈值上限
mask=double(sign(double(img<Tlow)+double(img>Thigh)));%标记阈值范围之外的像素点
mask=find(mask==1);%mask中值为1的元素线性索引提取,用于统计超出阈值范围的像素索引
img(img<Tlow)=Tlow;%所有低于Tlow的都赋值给Tlow
img(img>Thigh)=Thigh;%高于Thigh赋值给Thigh
ShowLow=str2double(get(handles.ShowndataWindow_low,'String'));
ShowHigh=str2double(get(handles.ShowndataWindow_high,'String'));%获取显示区间
colormapp=get(handles.ColorMaps,'String');
colormapp=colormapp{get(handles.ColorMaps,'Value')};
colormapp=colormap(colormapp);%获取色表

if get(handles.ShowThresholdMask,'Value') && ~isempty(mask)%开启显示阈值掩膜的选项
    imgg=repmat(img,[1,1,3]);
    img(mask)=ShowHigh;
    imgg(:,:,2)=img;
    img(mask)=ShowLow;
    imgg(:,:,1)=img;
    imgg(:,:,3)=img;
    img=imgg;
end
img(img<ShowLow)=ShowLow;
img(img>ShowHigh)=ShowHigh;%截断显示范围
if size(img,3)==1
    ext=get(handles.OutputFormat,'String');
    ext=ext{get(handles.OutputFormat,'Value')};
    ext=ext(2:end);
    WriteFile(img,[path,fn,ext]);
else
    finalmap=img;
    save([path,'phasemap.mat'],'finalmap');
end%根据图像通道导出并保存

% --- Executes on selection change in OutputFormat.
function OutputFormat_Callback(~, ~, ~)
% hObject    handle to OutputFormat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns OutputFormat contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OutputFormat

% --- Executes during object creation, after setting all properties.
function OutputFormat_CreateFcn(hObject, ~, ~)
% hObject    handle to OutputFormat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in ShowThresholdMask.
function ShowThresholdMask_Callback(hObject, ~, handles)
% hObject    handle to ShowThresholdMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ShowThresholdMask
if get(hObject,'Value')
    set(handles.ColorMaps,'Value',1);
    set(handles.ColorMaps,'Enable','off');
else
    set(handles.ColorMaps,'Enable','on');
end
disp_img_in_ImgViewer(handles);

% --- Executes on key press with focus on E_whiteline and none of its controls.
function E_whiteline_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to E_whiteline (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)



function Imgstack_size_Callback(hObject, eventdata, handles)
% hObject    handle to Imgstack_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Imgstack_size as text
%        str2double(get(hObject,'String')) returns contents of Imgstack_size as a double


% --- Executes during object creation, after setting all properties.
function Imgstack_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Imgstack_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over E_whiteline.
function E_whiteline_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to E_whiteline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function Energy_Range_Callback(hObject, eventdata, handles)
% hObject    handle to Energy_Range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Energy_Range as text
%        str2double(get(hObject,'String')) returns contents of Energy_Range as a double


% --- Executes during object creation, after setting all properties.
function Energy_Range_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Energy_Range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in Browse.
function Browse_Callback(hObject, eventdata, handles)
% hObject    handle to Browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ========== 选择导入方式 ==========
choice = questdlg('Select data import method:', 'Import Data', ...
    'Import MAT File', 'Import TIF/TIFF Sequence', 'Cancel', 'Import MAT File');

if strcmp(choice, 'Cancel') || isempty(choice)
    return;
end

% 获取初始路径
initpath = get(handles.Path, 'String');

if iscell(initpath)
    initpath = initpath{1};
end

% 检查路径是否有效
if isempty(initpath) || (isempty(find(initpath == '\', 1)) && isempty(find(initpath == '/', 1)))
    startPath = pwd;
else
    slash_idx = max([find(initpath == '\'), find(initpath == '/')]);
    if ~isempty(slash_idx)
        startPath = initpath(1:slash_idx(end));
    else
        startPath = pwd;
    end
end

% 根据选择执行不同导入流程
switch choice
    case 'Import MAT File'
        % ========== 原有MAT文件导入逻辑 ==========
        [filename, pathname] = uigetfile({'*.mat';'*.*'}, ...
            'Select image stack file (.mat)', 'MultiSelect', 'off', startPath);

        if isequal(filename, 0)
            disp('User canceled file selection');
            return;
        end

        fullpath = fullfile(pathname, filename);
        loaded_data = load(fullpath);
        data_source = fullpath;
        loaded_filename = filename;

    case 'Import TIF/TIFF Sequence'
        % ========== 新增TIF批量导入逻辑 ==========
        [filenames, pathname] = uigetfile({'*.tif;*.tiff', 'TIF/TIFF Images (*.tif, *.tiff)'; ...
            '*.*', 'All Files (*.*)'}, ...
            'Select TIF images (Ctrl/Shift for multi-select, order by energy)', ...
            'MultiSelect', 'on', startPath);

        if isequal(filenames, 0)
            disp('User canceled file selection');
            return;
        end

        % 确保filenames是cell数组
        if ~iscell(filenames)
            filenames = {filenames};
        end

        numImages = length(filenames);
        if numImages == 0
            errordlg('No image files selected!', 'Error');
            return;
        end

        % 按文件名排序(确保能量顺序)
        filenames = sort(filenames);

        disp(['Start reading ', num2str(numImages), ' TIF images...']);

        % 读取第一张图像获取尺寸
        firstImagePath = fullfile(pathname, filenames{1});
        firstImage = imread(firstImagePath);
        [height, width] = size(firstImage);

        % 根据图像类型初始化堆栈
        if isa(firstImage, 'uint16')
            Imgstack = zeros(height, width, numImages, 'uint16');
        elseif isa(firstImage, 'uint8')
            Imgstack = zeros(height, width, numImages, 'uint8');
        else
            Imgstack = zeros(height, width, numImages, 'like', firstImage);
        end

        % 初始化能量值数组
        Es = zeros(numImages, 1);

        % 创建进度条
        hWait = waitbar(0, 'Reading TIF images...', 'Name', 'Import Progress');

        % 遍历读取所有图像
        for i = 1:numImages
            % 更新进度条
            waitbar(i/numImages, hWait, sprintf('Reading: %s (%d/%d)', filenames{i}, i, numImages));

            imgPath = fullfile(pathname, filenames{i});
            img = imread(imgPath);

            % 检查尺寸一致性
            if size(img,1) ~= height || size(img,2) ~= width
                close(hWait);
                errordlg(sprintf('Image %s size (%dx%d) does not match the first image (%dx%d)!', ...
                    filenames{i}, size(img,1), size(img,2), height, width), 'Size Error');
                return;
            end
            % 存入堆栈
            Imgstack(:,:,i) = img;
            % 从文件名提取能量值
            [~, namePart] = fileparts(filenames{i});

            % 尝试匹配格式: _7120.00_eV, _7120.0_eV, 7120eV等
            match = regexp(namePart, '[_\-]?(\d{4,5}\.?\d{0,3})[_\-]?eV', 'match', 'ignorecase');

            if ~isempty(match)
                energyStr = match{1};
                energyStr = regexprep(energyStr, '[_\-]?eV$', '', 'ignorecase');
                energyStr = regexprep(energyStr, '^[_\-]', '');
                Es(i) = str2double(energyStr);
            else
                % 尝试匹配纯数字
                match2 = regexp(namePart, '(\d{4,5}\.?\d{0,3})', 'match');
                if ~isempty(match2)
                    Es(i) = str2double(match2{1});
                else
                    warning('Cannot extract energy from filename %s, using index %d instead', filenames{i}, i);
                    Es(i) = i;
                end
            end
        end

        close(hWait);

        % 检查能量值单调性
        if ~all(diff(Es) >= 0)
            warningMsg = 'Warning: Energy values are not monotonically increasing. Sort automatically?';
            sortChoice = questdlg(warningMsg, 'Energy Order', 'Yes', 'No', 'Yes');
            if strcmp(sortChoice, 'Yes')
                [Es, sortIdx] = sort(Es);
                Imgstack = Imgstack(:,:,sortIdx);
                filenames = filenames(sortIdx);
                disp('Re-sorted by energy values');
            end
        end

        % 构建loaded_data结构,兼容原有验证逻辑
        loaded_data.Imgstack = Imgstack;
        loaded_data.Es = Es;

        data_source = pathname;
        loaded_filename = sprintf('%dTIF images', numImages);

        % 询问是否保存为MAT文件
        saveChoice = questdlg('Save TIF sequence as MAT file for faster loading next time?','Save Data', 'Yes', 'No', 'Yes');

        if strcmp(saveChoice, 'Yes')
            defaultName = fullfile(pathname, 'Imgstack.mat');
            [saveName, savePath] = uiputfile('*.mat', 'Save MAT File', defaultName);

            if ~isequal(saveName, 0)
                fullSavePath = fullfile(savePath, saveName);
                save(fullSavePath, 'Imgstack', 'Es', 'filenames');
                disp(['Data saved to: ', fullSavePath]);
                data_source = fullSavePath; % 更新数据源为保存的MAT文件
            end
        end

        disp(['✓ Successfully read ', num2str(numImages), ' TIF images']);
        disp(['  Image Size: ', num2str(height), ' x ', num2str(width)]);
        disp(['  Energy Range: ', num2str(min(Es)), ' - ', num2str(max(Es)), ' eV']);

    otherwise
        return;
end
% ========== 以下复用原有的数据验证和显示逻辑 ==========
try
    % ========== 1. 加载数据(MAT或TIF已统一为loaded_data结构)==========
    disp(['Processing data source: ', loaded_filename]);

    % ========== 2. 检查并获取Imgstack图像堆栈数据 ==========
    if isfield(loaded_data, 'Imgstack')
        Imgstack = loaded_data.Imgstack;
        disp(['✓ ✓ Found image stack data (Imgstack),dimensions: ', num2str(size(Imgstack))]);
    elseif isfield(loaded_data, 'imgstack')
        Imgstack = loaded_data.imgstack;
        disp(['✓ ✓ Found image stack data (imgstack),dimensions: ', num2str(size(Imgstack))]);
    elseif isfield(loaded_data, 'finalmap')
        Imgstack = loaded_data.finalmap;
        disp(['✓ ✓ Found image stack data (finalmap),dimensions: ', num2str(size(Imgstack))]);
    else
        % 尝试查找第一个3D数组作为图像堆栈
        field_names = fieldnames(loaded_data);
        Imgstack = [];
        for i = 1:length(field_names)
            var_data = loaded_data.(field_names{i});
            if isnumeric(var_data) && ndims(var_data) == 3
                Imgstack = var_data;
                disp(['✓ Using variable "', field_names{i}, '" as image stack, dimensions: ', num2str(size(Imgstack))]);
                break;
            end
        end
    end

    % 验证图像堆栈数据
    if isempty(Imgstack)
        errordlg(['No valid 3D image stack data found in file!', ...
            '\n\nPlease ensure the file contains the Imgstack variable (3D array: height x width x energy points).'], 'Data Error');
        return;
    end
    if ndims(Imgstack) ~= 3
        errordlg(['Image stack data must be a 3D array!', ...
            '\nCurrent dimensions: ', num2str(ndims(Imgstack)), 'Dimension'], 'Data Error');
        return;
    end

    % ========== 3. 检查并获取Es能量轴数据 ==========
    Es = [];
    if isfield(loaded_data, 'Es')
        Es = loaded_data.Es;
        disp(['✓ Found energy axis data (Es), length: ', num2str(length(Es))]);
    end

    % 验证能量轴数据
    if isempty(Es)
        errordlg(['No energy axis data found in file!', ...
            '\n\nPlease ensure the file contains the Es variable (1D array, length matching image stack energy dimension).'], 'Data Error');
        return;
    end
    if length(Es) ~= size(Imgstack, 3)
        errordlg(sprintf('Energy axis length (%d) does not match image stack energy dimension (%d)!', ...
            length(Es), size(Imgstack, 3)), 'Data Error');
        return;
    end

    % ========== 4. 检查数据中的能量范围 ==========
    Es_min = min(Es);
    Es_max = max(Es);

    % ========== 5. 显示数据统计信息 ==========
    [height, width, nEnergy] = size(Imgstack);

    % ========== 6. 检查数据质量 ==========
    % 检查是否有NaN或Inf
    if any(isnan(Imgstack(:)))
        warning('Image stack contains NaN values, which may affect analysis.');
    end
    if any(isinf(Imgstack(:)))
        warning('Image stack contains Inf values, which may affect analysis.');
    end

    % 检查是否有全零的像素
    zero_pixels = 0;
    for i = 1:height
        for j = 1:width
            if all(Imgstack(i, j, :) == 0)
                zero_pixels = zero_pixels + 1;
            end
        end
    end
    if zero_pixels > 0
        disp(['Note: Found ', num2str(zero_pixels), ' all-zero pixels (', ...
            num2str(zero_pixels/(height*width)*100, '%.1f'), '%)']);
    end
    % ========== 7. 保存到handles结构体 ==========
    handles.org_stack = Imgstack;         % 保存原始图像堆栈
    handles.Es_white = Es;            % 能量轴数据(用于白线分析)
    handles.Es = Es;                  % 保存原始能量轴数据(通用)
    handles.data_source = data_source;% 数据源路径
    handles.loaded_filename = loaded_filename; % 文件名

    % 更新路径显示
    set(handles.Path, 'String', data_source);

    % ========== 8. 更新GUI显示 ==========
    % 构建文件信息字符串
    info_text = sprintf('%d × %d x %d', height, width, nEnergy);
    % 将文件信息展示在可编辑控件handles.Imgstack_size中
    if isfield(handles, 'Imgstack_size')
        % 设置为多行文本显示
        set(handles.Imgstack_size, 'String', info_text);
        set(handles.Imgstack_size, 'Enable', 'inactive');  % 设置为只读模式
        set(handles.Imgstack_size, 'BackgroundColor', [0.95, 0.95, 0.95]);  % 灰色背景表示只读
    else
        disp('Warning: Imgstack_size control not found');
    end

    info_text_2 = sprintf('%d - %d eV', Es_min, Es_max);
    if isfield(handles, 'Energy_Range')
        % 设置为多行文本显示
        set(handles.Energy_Range, 'String', info_text_2);
        set(handles.Energy_Range, 'Enable', 'inactive');  % 设置为只读模式
        set(handles.Energy_Range, 'BackgroundColor', [0.95, 0.95, 0.95]);  % 灰色背景表示只读
    else
        disp('Warning: Energy_Range control not found');
    end

    % ========== 9. 显示中间能量点的图像 ==========
    axes(handles.imgarea);% 选定坐标区
    cla(handles.imgarea);  % 清空图形

    % 提取中心图像
    org_img = Imgstack(:, :, round(nEnergy/2));  % 显示中间能量点的图像
    org_img(org_img == 0) = NaN;

    % 只选择非 NaN 的值来设置颜色映射范围
    valid_img = org_img(~isnan(org_img));  % 提取非 NaN 值
    valid_img = valid_img(valid_img > 0); % 进一步筛选正值

    if ~isempty(valid_img)  % 确保有效值不为空
        % 将颜色映射范围设置为有效值的最小和最大值
        min_center = min(valid_img(:));
        max_center = max(valid_img(:));
    else
        disp('No valid fitting values available for color mapping!');
        min_center = 0;
        max_center = 1;
    end

    % 设置默认阈值
    set(handles.RawdataWindow_low, 'String', min_center)
    set(handles.RawdataWindow_high, 'String', max_center)
    set(handles.Threshold_low, 'String', min_center);
    set(handles.Threshold_high, 'String', max_center);
    set(handles.ShowndataWindow_low, 'String', min_center);
    set(handles.ShowndataWindow_high, 'String', max_center);

    % 更新结构体
    handles.img = org_img;% 刷新img
    handles.org_stack = Imgstack;% 刷新Imgstack

    % 使用 disp_img_in_ImgViewer 显示拟合结果
    disp_img_in_ImgViewer(handles);

    % 获取handles中的data_source,动态设置标题
    mid_E = Es(round(nEnergy/2));
    title(sprintf('Center Energy Image: %.2f eV', mid_E));

    % 保持图形呈现为正方形
    axis image;

    %plot平均吸收谱
    %     num_Es = numel(handles.Es);
    meanAbsorption = zeros(length(handles.Es));
    % 计算每个像素在所有能量点的总和
    pixel_sum = sum(handles.org_stack, 3, 'omitnan'); % 忽略NaN值
    % 设置阈值 - 根据数据特性调整
    threshold = 0.01 * max(pixel_sum(:));
    mask = pixel_sum > threshold;
    % 获取有效像素索引
    valid_indices = mask;
    % 计算每个能量点的平均吸收谱(仅考虑有效像素)
    for i = 1:length(handles.Es)
        % 获取当前能量点的图像
        currentImage = handles.org_stack(:, :, i);

        % 仅提取有效像素的值
        validPixels = currentImage(valid_indices);

        % 计算有效像素的平均值
        if ~isempty(validPixels)
            meanAbsorption(i) = mean(validPixels);
        else
            meanAbsorption(i) = 0; % 如果没有有效像素
        end
    end

    axes(handles.pixel_axes3);
    plot(handles.Es, meanAbsorption, '-+');
    title('Mean: Absorption');
    xlabel('E/eV');
    ylabel('Absorption');
    grid on;
    % ========== 10. 更新handles ==========
    guidata(hObject, handles);

    disp('Data import complete!');

catch ME
    % 错误处理
    errordlg(sprintf('Failed to load file!\n\nError message: %s\n\nPlease check if the file format is correct.', ME.message), 'Load Error');
    disp(['Error Details: ', ME.message]);
    disp(['Error Location: ', ME.stack(1).name, ' Line ', num2str(ME.stack(1).line)]);
    return;
end

% --- Executes on button press in ROI_selection.
function ROI_selection_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on button press in areaofinterest.

disp(handles);

if strcmp(get(handles.Path,'String'),'Path')
    return;
end
savepath = get(handles.Path, 'String');


if isfield(handles, 'org_stack') || ~isempty(handles.org_stack)
    handles.stack = handles.org_stack;
else
    errordlg('No image stack data loaded!', 'Data Error');
end
imgstack=handles.stack;%读取堆栈

Es=handles.Es;%获得能量区域数组

% 在Es数组中找到距离白线最近的索引
% 交互输入最大最小值
% 获取E_white:优先使用handles中保存的值,否则从控件获取
if isfield(handles, 'E_white')
    % 使用保存的值
    E_white = handles.E_white;
    % 更新控件显示
    if isfield(handles, 'E_whiteline')
        set(handles.E_whiteline, 'String', num2str(E_white, '%.2f'));
    end
    disp(['✓ Using saved white-line energy: ', num2str(E_white, '%.2f'), ' eV']);
else
    % 从控件获取用户输入
    if ~isfield(handles, 'E_whiteline')
        errordlg('E_white input box not found!', 'UI Error');
        return;
    end
    E_white = get(handles.E_whiteline, 'String');
    E_white = str2double(E_white);

    % 验证输入
    if isnan(E_white)
        errordlg('Please enter a valid white-line peak energy value (numeric)!', 'Input Error');
        return;
    end

    if E_white > max(Es) || E_white < min(Es)
        errordlg(sprintf('White-line peak energy %.2f eV exceeds energy range [%.2f, %.2f] eV!', ...
            E_white, min(Es), max(Es)), 'Range Error');
        return;
    end

    % 保存到handles
    handles.E_white= E_white;
    disp(['✓ User input white-line energy: ', num2str(E_white, '%.2f'), ' eV']);
end

E_white=str2double(get(handles.E_whiteline,'String'));

% % 设置默认拟合范围
% default_min = max(min(Es), E_white - 5);
% default_max = min(max(Es), E_white + 5);
%
% % 计算默认范围
%
% set(handles.Fit_min, 'String', num2str(default_min));
% set(handles.Fit_max, 'String', num2str(default_max));

[~, idx] = min(abs(Es - E_white));%在Es数组中找到离白线最近的索引
img_white = imgstack(:,:,idx);%读取白线帧

ROI_Mask = ROI_selection_for_QTXMXANES(img_white, savepath);
% 2. 用ROI掩码筛选img(仅保留阈值筛选后的区域,其余置0)
img_white_filtered = img_white .* (1 - ROI_Mask); % 1-ROI_BW_map:选中区域保留,未选中置0
% (若需要“仅保留阈值内区域,其余为NaN”,替换为:diffimg_filtered(diffimg_raw >= intensitythreshold) = NaN;)

% ========== 关键修复2:更新handles
Mask = ROI_Mask;
[h,w,num_Es] = size(imgstack);
stack_ROI = zeros(h,w,num_Es);
for i = 1:num_Es
    stack_ROI(:,:,i) = imgstack(:,:,i) .* (1 - Mask);
end
handles.stack_ROI = stack_ROI;
handles.img_white = img_white;       % 原始img
handles.img= img_white_filtered;      % 阈值筛选后的img
handles.ROI_Mask = ROI_Mask; % 保存ROI掩码(便于后续调试)
handles.E_white = E_white;
guidata(hObject, handles); % 强制更新handles,确保数据传递
disp_img_in_ImgViewer(handles);

function Save_ROIStack_Callback(hObject, eventdata, handles)
if ~isfield(handles, 'stack_ROI') || isempty(handles.stack_ROI)
    errordlg('ROI processed stack (stack_ROI) not found. Please perform ROI selection first!', 'Data Missing');
    return;
end
if ~isfield(handles, 'Path') || isempty(get(handles.Path, 'String')) || ...
        strcmp(get(handles.Path, 'String'), 'Path')
    errordlg('Invalid image path set, cannot save file.', 'Path Error');
    return;
end
pathStr = get(handles.Path, 'String');
[fileDir, ~, ~] = fileparts(pathStr);
if isempty(fileDir)
    fileDir = pathStr;
end

% 保存 ROI 处理后的堆栈
savefile = fullfile(fileDir, 'ROI_Imgstack.mat');
Imgstack = handles.stack_ROI;
if isfield(handles, 'Es')
    Es = handles.Es;
end
try
    save(savefile, 'Imgstack', 'Es');
    msgbox(sprintf('ROI processed stack saved successfully to:\n%s', savefile), 'Save Success', 'help');
catch ME
    errordlg(sprintf('Error saving stack:\n%s', ME.message), 'Save Failed');
    return;
end

% ========== 新增:保存 ROI_Mask ==========
if isfield(handles, 'ROI_Mask') && ~isempty(handles.ROI_Mask)
    maskSaveFile = fullfile(fileDir, 'ROI_Mask.mat');
    try
        mask = handles.ROI_Mask;
        save(maskSaveFile, 'mask');
        msgbox(sprintf('ROI mask saved to:\n%s', maskSaveFile), 'Mask Save Success', 'help');
    catch ME
        errordlg(sprintf('Error saving ROI mask:\n%s', ME.message), 'Save Failed');
    end
else
    warndlg('Valid ROI_Mask not found in handles, mask not saved.', 'Mask Missing');
end


% --- Executes on button press in Smooth.
function Smooth_Callback(hObject, eventdata, handles)
% hObject    handle to Smooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Smooth


% --- Executes on selection change in Filter.
function Filter_Callback(hObject, eventdata, handles)
% hObject    handle to Filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Filter contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Filter


% --- Executes during object creation, after setting all properties.
function Filter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Smooth_window_Callback(hObject, eventdata, handles)
% hObject    handle to Smooth_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Smooth_window as text
%        str2double(get(hObject,'String')) returns contents of Smooth_window as a double


% --- Executes during object creation, after setting all properties.
function Smooth_window_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Smooth_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Apply_Smooth.
function Apply_Smooth_Callback(hObject, eventdata, handles)
% hObject    handle to Apply_Smooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 获取当前图像堆栈(三维:高×宽×能量通道)
% 检查 img 字段
if isfield(handles, 'stack_ROI') && ~isempty(handles.stack_ROI)
    Imgstack = handles.stack_ROI;
    disp('Filtering stack_ROI');
elseif isfield(handles, 'org_stack') && ~isempty(handles.org_stack)
    Imgstack = handles.org_stack;
    disp('Filtering org_stack');
else
    errordlg('No image stack data loaded!', 'Data Error');
    return;   % 或者做其他错误处理
end
[h, w, nFrames] = size(Imgstack);
Es = handles.Es;  % 能量轴
% 获取滤波方法
filter_methods = get(handles.Filter, 'String');
filter_sel = get(handles.Filter, 'Value');
method = filter_methods{filter_sel};

% 获取窗口大小(能量点数)
win_str = get(handles.Smooth_window, 'String');
win_size = str2double(win_str);
if isnan(win_size) || win_size < 3 || mod(win_size,2) == 0
    warndlg('Window size must be an odd number ≥3, using default 3', 'Filter parameters are incorrect');
    win_size = 3;
end

% 如果是 Savitzky-Golay 滤波,还需要多项式阶数
poly_order = 3;  % 默认值
if strcmp(method, 'Savitzky-Golay')
    if isfield(handles, 'Poly_order') && ishandle(handles.Poly_order)
        order_str = get(handles.Poly_order, 'String');
        poly_order = str2double(order_str);
        if isnan(poly_order) || poly_order < 1 || poly_order >= win_size
            warndlg('Polynomial order must be ≥1 and < window size, using default 3', 'Filter parameters are incorrect');
            poly_order = min(3, win_size-1);
        end
    else
        % 如果没有 Poly_order 控件,使用默认值
        poly_order = min(3, win_size-1);
    end
end

% 初始化滤波后的堆栈
Imgstack_filtered = zeros(size(Imgstack), class(Imgstack));
h_wait = waitbar(0, 'Filtering spectrum for each pixel...');

% 确定滤波方法对应的函数句柄
switch method
    case 'Savitzky-Golay'
        filter_func = @(spec) sgolayfilt(spec, poly_order, win_size);
    case 'Average'
        % 均值滤波:窗口内平均
        filter_func = @(spec) movmean(spec, win_size, 'Endpoints', 'shrink');
    case 'Median'
        % 中值滤波
        filter_func = @(spec) movmedian(spec, win_size, 'Endpoints', 'shrink');
    case 'Gaussian'
        % 一维高斯滤波:使用 imgaussfilt(需要 Image Processing Toolbox)
        % 标准差取窗口大小的 1/6
        sigma = win_size / 6;
        filter_func = @(spec) imgaussfilt(spec, sigma, 'FilterSize', win_size);
    otherwise
        filter_func = @(spec) spec;  % 无滤波
end

% 逐像素滤波
total_pixels = h * w;
processed = 0;
for i = 1:h
    for j = 1:w
        % 提取该像素的能谱(第三维)
        spec = squeeze(Imgstack(i, j, :))';  % 转为行向量

        % 转换为 double 进行计算(避免 sgolayfilt 类型错误)
        spec = double(spec);
        % 应用滤波
        spec_filtered = filter_func(spec);
        % 存回
        Imgstack_filtered(i, j, :) = spec_filtered(:);

        processed = processed + 1;
        if mod(processed, round(total_pixels/100)) == 0
            waitbar(processed/total_pixels, h_wait);
        end
        % 在滤波后,检查最后一个像素的最后一个能量点
        if i==h && j==w
            fprintf('Original spec last 5 points: %g %g %g %g %g\n', spec(end-4:end));
            fprintf('Filtered last 5 points: %g %g %g %g %g\n', spec_filtered(end-4:end));
        end
    end
end
close(h_wait);
disp(['Applied filtering to absorption spectrum of each pixel:', method, ', window size:', num2str(win_size)]);
if strcmp(method, 'Savitzky-Golay')
    disp(['Polynomial order:', num2str(poly_order)]);
end
% 更新堆栈
% 保存到 handles
handles.smoothed_stack = Imgstack_filtered;
handles.Es = Es;
guidata(hObject, handles);
msgbox('Spectrum filtering complete', 'Success', 'help');



function imgarea_CreateFcn(hObject, eventdata, ~)
% hObject    handle to imgarea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate imgarea

% --- Executes during object deletion, before destroying properties.
function imgarea_DeleteFcn(~, eventdata, handles)
% hObject    handle to imgarea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on mouse press over axes background.
function imgarea_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to imgarea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 获取当前点击点
pt = get(hObject, 'CurrentPoint');
x = pt(1,1); y = pt(1,2);  % 注意顺序
if isfield(handles,'POI') && ~isempty(handles.POI)
    handles.POI = [handles.POI; y, x]; % [行,列]
else
    handles.POI = [y, x];
end
guidata(hObject, handles);

% 重画POI(你可以写成函数调用,如drawPOI(handles))
img = get(handles.Browse,'UserData');
axes(handles.imgarea);
imshow(img,[],'Parent',handles.imgarea);
hold(handles.imgarea,'on');
lineLen = round(max(size(img))/100);
for ii = 1:size(handles.POI,1)
    yy = handles.POI(ii,1); xx = handles.POI(ii,2);
    plot(handles.imgarea, [xx-lineLen, xx+lineLen], [yy, yy], 'r-', 'LineWidth', 2);
    plot(handles.imgarea, [xx, xx], [yy-lineLen, yy+lineLen], 'r-', 'LineWidth', 2);
end
hold(handles.imgarea,'off');

%%=================================================================================================
function Estimate_Callback(hObject, eventdata, handles)
% 参数预估(偏高斯,常数基线,b1固定为0)
% 使用用户在GUI中输入的 Fit_min 和 Fit_max 作为预估窗口

%% 1. 获取图像堆栈和能量轴
if get(handles.use_nor,'Value')==1
    if isfield(handles, 'nor_stack') && ~isempty(handles.nor_stack)
        spec_stack = handles.nor_stack;
    else
        errordlg('Normalized stack not loaded!');return;
    end
else
    if get(handles.Smooth, 'Value') == 1
        if isfield(handles, 'smoothed_stack') && ~isempty(handles.smoothed_stack)
            spec_stack = handles.smoothed_stack;
        else
            errordlg('Smoothed stack not loaded!'); return;
        end
    else
        if isfield(handles, 'stack_ROI') && ~isempty(handles.stack_ROI)
            spec_stack = handles.stack_ROI;
        elseif isfield(handles, 'org_stack') && ~isempty(handles.org_stack)
            spec_stack = handles.org_stack;
        else
            errordlg('Stack not loaded!'); return;
        end
    end
end
if ~isfield(handles,'Es') || isempty(handles.Es)
    errordlg('Energy axis not loaded!'); return;
end
Es = handles.Es(:)';

if ~isfield(handles,'E_whiteline') || ~ishandle(handles.E_whiteline)
    errordlg('White-line energy input box not found!'); return;
end
E_white = str2double(get(handles.E_whiteline, 'String'));
if isnan(E_white) || E_white < min(Es) || E_white > max(Es)
    errordlg('Invalid white-line energy!'); return;
end
handles.E_white = E_white;

%% 2. 读取用户自定义预估窗口
fit_min = str2double(get(handles.Fit_min, 'String'));
fit_max = str2double(get(handles.Fit_max, 'String'));
if isnan(fit_min) || isnan(fit_max)
    errordlg('Invalid fit range input (must be numeric)!', 'Input Error'); return;
end
if fit_min >= fit_max
    errordlg('Fit range lower bound must be less than upper bound!', 'Range Error'); return;
end
if fit_min < min(Es) || fit_max > max(Es)
    errordlg(sprintf('Fit range [%.2f, %.2f] eV exceeds energy axis range [%.2f, %.2f] eV!', ...
        fit_min, fit_max, min(Es), max(Es)), 'Range Error'); return;
end

fit_idx = find(Es >= fit_min & Es <= fit_max);
if length(fit_idx) < 5
    errordlg('Less than 5 energy points in fit range, please expand range!', 'Range Error'); return;
end

Es_fit = Es(fit_idx);
stack_fit = spec_stack(:, :, fit_idx);
[h, w, nE] = size(stack_fit);
nPixels = h*w;
stack_2d = reshape(stack_fit, nPixels, nE);
stack_2d = double(stack_2d);

%% 3. 有效像素掩码
valid_mask = all(isfinite(stack_2d),2) & all(stack_2d >= 0,2);
range = max(stack_2d,[],2) - min(stack_2d,[],2);
valid_mask = valid_mask & (range > 1e-6);
valid_pixels = find(valid_mask);
num_valid = length(valid_pixels);
if num_valid == 0
    errordlg('No valid pixels!'); return;
end
fprintf('Valid pixels: %d / %d\n', num_valid, nPixels);

%% 4. 并行池配置
n_cores = feature('numcores');
n_workers = max(1, n_cores - 1);   % 使用核心数-1
pool = gcp('nocreate');
if isempty(pool)
    parpool('local', n_workers);
elseif pool.NumWorkers ~= n_workers
    delete(pool);
    parpool('local', n_workers);
end

%% 5. 分块参数
chunk_size = min(100, max(20, round(num_valid / 20)));
n_chunks = ceil(num_valid / chunk_size);
fprintf('Fit window: [%.2f, %.2f] eV, total %d energy points\n', fit_min, fit_max, length(fit_idx));
fprintf('Split into %d chunks, max %d pixels per chunk\n', n_chunks, chunk_size);

% 预分配结果(6参数,b1恒为0)
A0   = zeros(num_valid,1);
xc0  = zeros(num_valid,1);
w0   = zeros(num_valid,1);
s0   = zeros(num_valid,1);
b0   = zeros(num_valid,1);
b1   = zeros(num_valid,1);  % 恒为0
lb_mat = zeros(num_valid,6);
ub_mat = zeros(num_valid,6);

%% 6. 进度条
h_progress = waitbar(0, 'Parameter estimation started...', 'Name', 'Estimation Progress', ...
    'CreateCancelBtn', 'setappdata(gcbf, ''Cancel'', true)');
setappdata(h_progress, 'Cancel', false);
cleanup = onCleanup(@() delete(h_progress));

Es_local = Es_fit; nE_local = nE;
tStart = tic;

%% 7. 分块循环(并行)
for chunk_idx = 1:n_chunks
    if getappdata(h_progress, 'Cancel')
        fprintf('User canceled estimation.\n'); return;
    end

    idx_start = (chunk_idx-1)*chunk_size + 1;
    idx_end = min(chunk_idx*chunk_size, num_valid);
    idx_range = idx_start:idx_end;
    n_chunk = length(idx_range);

    pixels_chunk = valid_pixels(idx_range);
    spec_chunk = stack_2d(pixels_chunk, :);

    A_chunk   = zeros(n_chunk,1);
    xc_chunk  = zeros(n_chunk,1);
    w_chunk   = zeros(n_chunk,1);
    s_chunk   = zeros(n_chunk,1);
    b0_chunk  = zeros(n_chunk,1);
    b1_chunk  = zeros(n_chunk,1);
    lb_chunk  = zeros(n_chunk,6);
    ub_chunk  = zeros(n_chunk,6);

    parfor i = 1:n_chunk
        spec = spec_chunk(i, :);
        spec_smooth = smooth(spec, 5)';
        if isempty(spec_smooth), spec_smooth = spec; end

  
        % ---- (1) 常数基线:20%分位数 ----
        b0_val = prctile(spec_smooth, 20);
        if isnan(b0_val) || ~isfinite(b0_val)
            b0_val = min(spec_smooth);
        end
        b1_val = 0;   % 强制斜率为0
        spec_corrected = spec_smooth - b0_val;

        % ---- (2) 峰值检测 ----
        [amp, imax] = max(spec_corrected);
        if amp <= 0
            % 降级:使用最小值作为基线
            b0_val = min(spec_smooth);
            spec_corrected = spec_smooth - b0_val;
            [amp, imax] = max(spec_corrected);
            if amp <= 0
                % 极端异常值兜底
                A_chunk(i) = 1;
                xc_chunk(i) = Es_local(round(end/2));
                w_chunk(i) = 1.5;
                s_chunk(i) = 0;
                b0_chunk(i) = 0;
                b1_chunk(i) = 0;
                lb_chunk(i,:) = [0, Es_local(1), 0.01, -1, -Inf, 0];
                ub_chunk(i,:) = [Inf, Es_local(end), Inf, 1, Inf, 0];
                continue;
            end
        end

        % ---- (3) 质心法修正峰位 ----
        half = 3;
        i1 = max(1, imax - half);
        i2 = min(nE_local, imax + half);
        num = sum(Es_local(i1:i2) .* spec_corrected(i1:i2));
        den = sum(spec_corrected(i1:i2));
        if den > 0, xc = num/den; else xc = Es_local(imax); end
        if isnan(xc) || ~isfinite(xc), xc = Es_local(imax); end

        % ---- (4) FWHM估算 ----
        halfmax = amp / 2;
        left = find(spec_corrected(1:imax) < halfmax, 1, 'last');
        right = imax-1 + find(spec_corrected(imax:end) < halfmax, 1, 'first');
        if isempty(left) || left<1, left = max(1, imax-2); end
        if isempty(right) || right>nE_local, right = min(nE_local, imax+2); end
        if right <= left, right = min(nE_local, left+2); end
        fwhm = Es_local(right) - Es_local(left);
        if fwhm <= 0 || isnan(fwhm), fwhm = 1.5; end

        % ---- (5) 存储初值 ----
        A_chunk(i) = max(amp, 0.1);
        xc_chunk(i) = xc;
        w_chunk(i) = fwhm;
        s_chunk(i) = 0;
        b0_chunk(i) = b0_val;
        b1_chunk(i) = 0;

        % ---- (6) 边界(6参数,b1固定为0) ----

        lb_chunk(i,:) = [0,   Es_local(1),  0.01, -1, -Inf, 0];
        ub_chunk(i,:) = [Inf, Es_local(end), Inf,  1,  Inf, 0];
    end

    % 汇总
    A0(idx_range) = A_chunk;
    xc0(idx_range) = xc_chunk;
    w0(idx_range) = w_chunk;
    s0(idx_range) = s_chunk;
    b0(idx_range) = b0_chunk;
    b1(idx_range) = b1_chunk;
    lb_mat(idx_range,:) = lb_chunk;
    ub_mat(idx_range,:) = ub_chunk;

    % 更新进度
    elapsed = toc(tStart);
    pct = idx_end / num_valid;
    remain = elapsed / pct - elapsed;
    msg = sprintf('Processed %d/%d (%.1f%%) | Remaining %.0fs', idx_end, num_valid, pct*100, remain);
    waitbar(pct, h_progress, msg);
    fprintf('%s\n', msg);
end

elapsed_total = toc(tStart);
waitbar(1, h_progress, 'Complete!');
fprintf('Parameter estimation complete, time elapsed %.2f seconds\n', elapsed_total);

%% 8. 映射回原始尺寸(6参数)
A_full = NaN(nPixels,1); xc_full = NaN(nPixels,1);
w_full = NaN(nPixels,1); s_full = NaN(nPixels,1);
b0_full = NaN(nPixels,1); b1_full = NaN(nPixels,1);
lb_full = NaN(nPixels,6); ub_full = NaN(nPixels,6);

A_full(valid_pixels) = A0; xc_full(valid_pixels) = xc0;
w_full(valid_pixels) = w0; s_full(valid_pixels) = s0;
b0_full(valid_pixels) = b0; b1_full(valid_pixels) = b1;
lb_full(valid_pixels,:) = lb_mat; ub_full(valid_pixels,:) = ub_mat;

p0 = struct('A0', reshape(A_full,h,w), 'xc0', reshape(xc_full,h,w), ...
    'w0', reshape(w_full,h,w), 's0', reshape(s_full,h,w), ...
    'b0', reshape(b0_full,h,w), 'b1', reshape(b1_full,h,w));
lb = reshape(lb_full, h,w,6);
ub = reshape(ub_full, h,w,6);
valid_mask_2d = reshape(valid_mask, h,w);

%% 9. 保存到 handles
handles.Es_fit = Es_fit;
handles.spec_stack = spec_stack;
handles.stack_fit = stack_fit;
handles.valid_mask = valid_mask_2d;
handles.p0 = p0;
handles.lb = lb;
handles.ub = ub;
handles.fit_min = fit_min;
handles.fit_max = fit_max;
guidata(hObject, handles);
%
function Gaussian_Fitting_Callback(hObject, eventdata, handles)
% 偏高斯拟合(常数基线,b1固定为0)
% 每个像素使用动态局部窗口拟合,R²和残差基于局部窗口,
% fitted_spec在公共窗口上由最终参数完整计算。
% 结果结构与原版一致,兼容现有显示函数。

%% 1. 提取预估数据
if ~isfield(handles,'p0') || isempty(handles.p0)
    errordlg('Please run parameter estimation first!'); return;
end

if isfield(handles, 'Es') && isfield(handles, 'spec_stack')
    Es_orig = handles.Es(:)';
    stack_full = handles.spec_stack;
elseif isfield(handles, 'Es') && isfield(handles, 'stack_ROI')
    Es_orig = handles.Es(:)';
    stack_full = handles.stack_ROI;
else
    errordlg('Full energy axis and stack not found!'); return;
end

valid_mask = handles.valid_mask;
p0 = handles.p0;

[h, w, nE_orig] = size(stack_full);
nPixels = h*w;
stack_2d_full = reshape(stack_full, nPixels, nE_orig);
stack_2d_full = double(stack_2d_full);
valid_pixels = find(valid_mask);
num_valid = length(valid_pixels);
if num_valid == 0, errordlg('No valid pixels!'); return; end

A0_vec = p0.A0(valid_pixels);
xc0_vec = p0.xc0(valid_pixels);
w0_vec  = p0.w0(valid_pixels);
s0_vec  = p0.s0(valid_pixels);
b0_vec  = p0.b0(valid_pixels);

%% 2. 构建公共窗口(用于存储 fitted_spec 和显示)
half_width_common = 5;   % eV
xc_min_all = min(xc0_vec);
xc_max_all = max(xc0_vec);
common_min = max(Es_orig(1), xc_min_all - half_width_common);
common_max = min(Es_orig(end), xc_max_all + half_width_common);
idx_common = find(Es_orig >= common_min & Es_orig <= common_max);
if length(idx_common) < 5
    idx_common = 1:nE_orig;
    fprintf('Warning: Common window is too narrow, using full energy range.\n');
end
Es_fit = Es_orig(idx_common);
nE_fit = length(idx_common);
fprintf('Common storage window: [%.2f, %.2f] eV, total %d points\n', Es_fit(1), Es_fit(end), nE_fit);

%% 3. 拟合设置
half_width_fit =5;    % 每个像素的局部拟合半宽 (eV)
opts = optimset('Display','off','MaxFunEvals',1e5,'MaxIter',1e5,'TolFun',1e-6);
R2_threshold = 0.7;

%% 4. 并行池
n_workers = max(1, feature('numcores') - 1);
pool = gcp('nocreate');
if isempty(pool)
    parpool('local', n_workers);
end

chunk_size = min(100, max(20, round(num_valid / 20)));
n_chunks = ceil(num_valid / chunk_size);
fprintf('Half-width of fitting window per pixel = %.1f eV\n', half_width_fit);
fprintf('Split into %d chunks, max %d pixels per chunk\n', n_chunks, chunk_size);

%% 5. 预分配
params_all   = zeros(num_valid, 6);
R2_all       = zeros(num_valid, 1);
fail_flags   = false(num_valid, 1);
fitted_all   = NaN(num_valid, nE_fit);
residuals_all= NaN(num_valid, nE_fit);

%% 6. 进度条
h_progress = waitbar(0, 'Gaussian fitting started...', 'Name', 'Fitting Progress', ...
    'CreateCancelBtn', 'setappdata(gcbf, ''Cancel'', true)');
setappdata(h_progress, 'Cancel', false);
cleanup = onCleanup(@() delete(h_progress));

Es_orig_const = parallel.pool.Constant(Es_orig);
Es_fit_const  = parallel.pool.Constant(Es_fit);
stack_const = parallel.pool.Constant(stack_2d_full);
idx_common_const = parallel.pool.Constant(idx_common);
A0_c = A0_vec; xc0_c = xc0_vec; w0_c = w0_vec; s0_c = s0_vec; b0_c = b0_vec;

tStart = tic;

%% 7. 分块并行拟合
for chunk_idx = 1:n_chunks
    if getappdata(h_progress, 'Cancel')
        fprintf('User canceled fitting.\n'); return;
    end

    idx_start = (chunk_idx-1)*chunk_size + 1;
    idx_end   = min(chunk_idx*chunk_size, num_valid);
    idx_range = idx_start:idx_end;
    n_chunk   = length(idx_range);

    params_chunk   = zeros(n_chunk, 6);
    R2_chunk       = zeros(n_chunk, 1);
    fail_chunk     = false(n_chunk, 1);
    fitted_chunk   = NaN(n_chunk, nE_fit);
    resid_chunk    = NaN(n_chunk, nE_fit);

    parfor i = 1:n_chunk
        idx_global = idx_range(i);
        xc_i = xc0_c(idx_global);

        % ---- 构建局部窗口(确保索引在公共窗口内) ----
        idx_local_raw = find(Es_orig_const.Value >= xc_i - half_width_fit & ...
                             Es_orig_const.Value <= xc_i + half_width_fit);
        % 限制在公共窗口内
        idx_local = intersect(idx_local_raw, idx_common_const.Value);
        if length(idx_local) < 5
            % 若局部窗口点数不足,直接使用公共窗口(仍保持局部性)
            idx_local = idx_common_const.Value;
        end
        Es_local = Es_orig_const.Value(idx_local);
        y_local = stack_const.Value(valid_pixels(idx_global), idx_local);

        % ---- 初值 ----
        p_init = [A0_c(idx_global), xc_i, w0_c(idx_global), ...
                  s0_c(idx_global), b0_c(idx_global), 0];

        % ---- 边界约束 ----
        xc_low  = max(Es_local(1), xc_i - 1.5);
        xc_high = min(Es_local(end), xc_i + 1.5);
        lb = [0,               xc_low,  0.01,  -1, -Inf, 0];
        ub = [Inf,             xc_high, Inf,   1,  Inf, 0];
        % 可在此收紧 s 边界,例如 lb(4) = -0.5; ub(4) = 0.5;

        % ---- 拟合 ----
        try
            p_fit = lsqcurvefit(@skewgauss, p_init, Es_local, y_local, lb, ub, opts);
        catch
            p_fit = p_init;
        end

        % ---- 局部拟合值和残差(用于R²) ----
        y_fit_local = skewgauss(p_fit, Es_local);
        res_local = y_local - y_fit_local;

        % ---- R² 基于局部窗口 ----
        SS_res = sum(res_local.^2);
        SS_tot = sum((y_local - mean(y_local)).^2);
        if SS_tot > 0
            R2 = 1 - SS_res / SS_tot;
        else
            R2 = 0;
        end

        if R2 < R2_threshold
            fail_chunk(i) = true;
            p_fit = p_init;
            y_fit_local = skewgauss(p_init, Es_local);
            res_local = y_local - y_fit_local;
        end

        % ---- 公共窗口上的完整拟合曲线 ----
        y_fit_common = skewgauss(p_fit, Es_fit_const.Value);
        fitted_chunk(i, :) = y_fit_common;

        % ---- 将局部残差映射到公共窗口 ----
        [~, loc_common] = ismember(idx_local, idx_common_const.Value);
        % 由于 idx_local 是 idx_common 的子集,loc_common 全为正整数
        resid_vec = NaN(1, nE_fit);
        resid_vec(loc_common) = res_local;
        resid_chunk(i, :) = resid_vec;

        % ---- 存储参数和R2 ----
        params_chunk(i, :) = p_fit;
        R2_chunk(i) = R2;
    end

    % 汇总
    params_all(idx_range, :) = params_chunk;
    R2_all(idx_range) = R2_chunk;
    fail_flags(idx_range) = fail_chunk;
    fitted_all(idx_range, :) = fitted_chunk;
    residuals_all(idx_range, :) = resid_chunk;

    elapsed = toc(tStart);
    pct = idx_end / num_valid;
    remain = elapsed / pct - elapsed;
    msg = sprintf('Processed %d/%d (%.1f%%) | Remaining %.0fs', idx_end, num_valid, pct*100, remain);
    waitbar(pct, h_progress, msg);
    fprintf('%s\n', msg);
end

elapsed_total = toc(tStart);
waitbar(1, h_progress, 'Complete!');
fprintf('Fitting complete, total time %.2f seconds\n', elapsed_total);

%% 8. 映射回原尺寸
params_full = NaN(nPixels, 6);
R2_full     = NaN(nPixels, 1);
fitted_full = NaN(nPixels, nE_fit);
residuals_full = NaN(nPixels, nE_fit);
params_full(valid_pixels, :) = params_all;
R2_full(valid_pixels) = R2_all;
fitted_full(valid_pixels, :) = fitted_all;
residuals_full(valid_pixels, :) = residuals_all;

fail_mask = false(h, w);
fail_mask(valid_pixels(fail_flags)) = true;

%% 9. xc 异常值校正
xc_map = reshape(params_full(:,2), h, w);
xc_corrected = correct_xc_outliers(xc_map, 0.5, 'median');
params_full(:,2) = xc_corrected(:);

%% 10. 构建 fit_result 结构体
% 在构建 fit_result 结构体前,先把原始谱提取出来
org_spec_full = reshape(stack_2d_full, h, w, nE_orig); % 使用最初传入的 stack_full

fit_result = struct(...
    'params',      reshape(params_full, h, w, 6), ...
    'R2',          reshape(R2_full, h, w), ...
    'fail_mask',   fail_mask, ...
    'org_spec',    org_spec_full, ...    % <--- 补充这一行
    'fitted_spec', reshape(fitted_full, h, w, nE_fit), ...
    'Residuals',   reshape(residuals_full, h, w, nE_fit), ...
    'Es_fit',      Es_fit, ...
    'fit_min',     handles.fit_min, ...
    'fit_max',     handles.fit_max ...
);

handles.GS_Result = fit_result;
handles.fit_result = handles.GS_Result;

guidata(hObject, handles);

fprintf('Failed pixels(R²<%.2f): %d (%.1f%%)\n', R2_threshold, sum(fail_flags), 100*sum(fail_flags)/num_valid);

%% 11. 调试输出 s 统计
s_vals = params_full(valid_pixels, 4);
if ~isempty(s_vals)
    fprintf('\n=== Asymmetric parameter s fitting results ===\n');
    fprintf('Number of valid pixels: %d\n', numel(s_vals));
    fprintf('Mean:     %.4f\n', mean(s_vals, 'omitnan'));
    fprintf('Std Dev:   %.4f\n', std(s_vals, 'omitnan'));
    fprintf('Median:   %.4f\n', median(s_vals, 'omitnan'));
    fprintf('Min:   %.4f\n', min(s_vals, [], 'omitnan'));
    fprintf('Max:   %.4f\n', max(s_vals, [], 'omitnan'));
    fprintf('Out of [-0.5,0.5]: %d (%.1f%%)\n', ...
        sum(abs(s_vals) > 0.5), 100*sum(abs(s_vals) > 0.5)/numel(s_vals));
end



% --- Executes during object creation, after setting all properties.
function pixel_axes3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pixel_axes3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate pixel_axes3




function Fit_min_Callback(hObject, eventdata, handles)
% hObject    handle to Fit_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Fit_min as text
%        str2double(get(hObject,'String')) returns contents of Fit_min as a double
% 获取用户输入的拟合范围
fit_min = str2double(get(hObject, 'String'));

% 检查输入的坐标有效性
if isnan(fit_min)  || fit_min < min(handles.Es) || fit_min > max(handles.Es)

    errordlg('Please enter a valid energy!');
    return;
end
guidata(hObject, handles);  % 更新 handles


% --- Executes during object creation, after setting all properties.
function Fit_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Fit_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Fit_max_Callback(hObject, eventdata, handles)
% hObject    handle to Fit_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Fit_max as text
%        str2double(get(hObject,'String')) returns contents of Fit_max as a double
fit_max = str2double(get(hObject, 'String'));

% 检查输入的坐标有效性
if isnan(fit_max)  || fit_max < min(handles.Es) || fit_max > max(handles.Es)

    errordlg('Please enter a valid energy!');
    return;
end
guidata(hObject, handles);  % 更新 handles

% --- Executes during object creation, after setting all properties.
function Fit_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Fit_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function Gaussian_Fitting_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Gaussian_Fitting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in Show_xcmapping.
function Show_xcmapping_Callback(hObject, eventdata, handles)
% hObject    handle to Show_xcmapping (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% = ====在坐标区域imgarea显示拟合结果=-======
fit_params = handles.GS_Result.params;
axes(handles.imgarea);% 选定坐标区
cla(handles.imgarea);  % 清空图形

% 提取拟合参数(以中心位置为例,而不是幅度)
fit_img = squeeze(fit_params(:,:,2));  % 提取中心位置xc参数
% fit_image(isnan(fit_image)) = 0;  % 将 NaN 替换为 0(如果必要)
% 只选择非 NaN 的值来设置颜色映射范围
valid_fit_img = fit_img(~isnan(fit_img));  % 提取非 NaN 值
valid_fit_img = valid_fit_img(valid_fit_img > 0); % 进一步筛选正值
if ~isempty(valid_fit_img)  % 确保有效值不为空
    % 将颜色映射范围设置为有效值的最小和最大值
    min_center = min(valid_fit_img(:));
    max_center = max(valid_fit_img(:));
else
    disp('No valid fitting values available for color mapping!');
end
% 打印出拟合结果(中心位置)范围
disp(['Fitting result center position range (corresponding energy values):', num2str(min_center), ' eV ~ ', num2str(max_center), ' eV']);
% 设置默认阈值
set(handles.RawdataWindow_low, 'String', min(valid_fit_img(:)));
set(handles.RawdataWindow_high, 'String', max(valid_fit_img(:)));

set(handles.Threshold_low,'String',min(valid_fit_img(:)));
set(handles.Threshold_high,'String',max(valid_fit_img(:)));

set(handles.ShowndataWindow_low, 'String',min(valid_fit_img(:)));
set(handles.ShowndataWindow_high, 'String',max(valid_fit_img(:)));

handles.img = fit_img;
% 使用 disp_img_in_ImgViewer 显示拟合结果
disp_img_in_ImgViewer(handles);

% 设置标题
title('Gaussian Fitting xc-mapping');
% 更新结构体
handles.img = fit_img;
handles.fit_result = handles.GS_Result;
guidata(hObject, handles);

% 保持图形呈现为正方形
axis image;

% ========== 新增:在 axes_hist 中绘制像素分布柱状图 ==========
if ~isempty(valid_fit_img)
    % 选定 hist 坐标轴并清空
    axes(handles.axes_hist);
    cla(handles.axes_hist);

    % 绘制直方图(可根据需要调整 bin 数量)
    histogram(valid_fit_img, 'BinWidth', 0.2, ...
        'FaceColor', [0.2 0.4 0.8], 'EdgeColor', 'none');
    xlabel('Center Position (eV)');
    ylabel('Pixel Count');
    title('Pixel Distribution Histogram');
    grid on;

    % 可选:添加均值、中位数等统计信息
    hold on;
    mean_val = mean(valid_fit_img);
    median_val = median(valid_fit_img);
    xline(mean_val, 'r--', 'LineWidth', 1.5);
    xline(median_val, 'g--', 'LineWidth', 1.5);
    legend('Pixel Distribution', ['Mean: ' num2str(mean_val, '%.3f')], ...
        ['Median: ' num2str(median_val, '%.3f')], 'Location', 'best');
    hold off;
else
    % 如果没有有效数据,清空坐标轴并显示提示
    axes(handles.axes_hist);
    cla(handles.axes_hist);
    text(0.5, 0.5, 'No Valid Data', 'HorizontalAlignment', 'center');
    axis off;
end


% --- Executes on button press in Save_Fit_Result.

function Save_Fit_Result_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Fit_Result (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 作用:保存高斯拟合结果到用户选择的文件夹(仅保存为.mat文件)

% ========== 1. 检查数据是否存在 ==========
% 检查高斯拟合结果
if ~isfield(handles, 'GS_Result') || isempty(handles.GS_Result)
    errordlg('Gaussian fitting result (handles.GS_Result) not found! Please run Gaussian fitting first.', 'Data Missing');
    return;
end

% ========== 2. 选择保存路径 ==========
% 弹出文件夹选择对话框
save_path = uigetdir(pwd, 'Select folder to save fitting results');

% 检查用户是否取消了选择
if save_path == 0
    disp('User canceled save operation');
    return;
end

% ========== 3. 准备保存数据 ==========
% 获取当前时间戳,用于文件名
timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');

% 初始化保存结果
saved_files = {};
save_success = true;

% ========== 4. 保存高斯拟合结果 ==========
% 默认文件名
default_gs_name = 'GaussianFittingResult';

% 询问用户是否使用默认文件名
response = questdlg('Save Gaussian fitting result with default filename?', 'Filename Settings', ...
    'Use Default', 'Custom Filename', 'Cancel', 'Use Default');

if strcmp(response, 'Cancel')
    save_success = false;
elseif strcmp(response, 'Custom Filename')
    prompt = {'Enter Gaussian fitting result filename (without extension):'};
    dlg_title = 'Custom Filename';
    num_lines = 1;
    default_input = {default_gs_name};
    user_input = inputdlg(prompt, dlg_title, num_lines, default_input);

    if isempty(user_input)
        save_success = false;
    else
        gs_filename = user_input{1};
        % 去除非法字符
        gs_filename = regexprep(gs_filename, '[<>:"/\\|?*]', '_');
        if isempty(gs_filename)
            gs_filename = default_gs_name;
        end
    end
else
    gs_filename = default_gs_name;
end

if save_success
    % 完整文件路径
    gs_filepath = fullfile(save_path, [gs_filename, '.mat']);

    % 准备保存的数据结构
    gs_data = struct();
    gs_data.GS_Result = handles.GS_Result;
    gs_data.timestamp = timestamp;
    gs_data.save_time = datestr(now);
    gs_data.save_info = 'Gaussian fitting result';

    % 如果存在相关参数,也一并保存
    if isfield(handles, 'GS_fit_params')
        gs_data.GS_fit_params = handles.GS_fit_params;
    end
    if isfield(handles, 'Es_fit')
        gs_data.Es_fit = handles.Es_fit;
    end
    if isfield(handles, 'valid_mask')
        gs_data.valid_mask = handles.valid_mask;
    end

    try
        % 保存文件
        save(gs_filepath, '-struct', 'gs_data');
        saved_files{end+1} = gs_filepath;
        disp(['Gaussian fitting result saved to: ', gs_filepath]);
    catch ME
        errordlg(['Failed to save Gaussian fitting result!\n Error Message: ', ME.message], 'Save Error');
        save_success = false;
    end
end

% ========== 5. 创建信息文件与成功提示 ==========
if save_success && ~isempty(saved_files)
    % 创建简单的README文件,记录保存信息
    readme_content = sprintf('Fitting Result Save Info\n%s\n\n', repmat('=', 50, 1));
    readme_content = [readme_content, sprintf('Save Time: %s\n', datestr(now))];
    readme_content = [readme_content, sprintf('Save Folder: %s\n\n', save_path)];
    readme_content = [readme_content, sprintf('Saved Files:\n')];
    for i = 1:length(saved_files)
        [~, filename, ext] = fileparts(saved_files{i});
        readme_content = [readme_content, sprintf('  %d. %s%s\n', i, filename, ext)];
    end

    readme_content = [readme_content, sprintf('\nFile Description:\n')];
    readme_content = [readme_content, sprintf('  - GaussianFittingResult.mat: Gaussian fitting result\n')];
    readme_content = [readme_content, sprintf('  - Each .mat file contains the complete fitting result structure and related parameters\n')];

    % 保存README文件
    readme_path = fullfile(save_path, 'ReadMe_FittingResults.txt');
    try
        fid = fopen(readme_path, 'w', 'n', 'UTF-8');
        fprintf(fid, '%s', readme_content);
        fclose(fid);
        disp(['Info file saved to: ', readme_path]);
    catch
        warning('Cannot save README file');
    end

    % 显示成功消息
    success_msg = sprintf('Fitting result saved successfully!\n\nLocation: %s\n\nSaved files:\n', save_path);
    for i = 1:length(saved_files)
        [~, name, ext] = fileparts(saved_files{i});
        success_msg = [success_msg, sprintf('  • %s%s\n', name, ext)];
    end

    msgbox(success_msg, 'Save Success', 'help');

    % 可选:询问是否打开文件夹
    response = questdlg('Open save folder?', 'Open Folder', 'Yes', 'No', 'No');
    if strcmp(response, 'Yes')
        try
            if ispc
                winopen(save_path);
            elseif ismac
                system(['open "', save_path, '"']);
            else
                system(['xdg-open "', save_path, '"']);
            end
        catch
            disp(['Cannot automatically open folder: ', save_path]);
        end
    end

elseif ~save_success
    msgbox('Save operation canceled or failed.', 'Save operation canceled', 'warn');
end

% 更新状态栏
if isfield(handles, 'status_text')
    if save_success && ~isempty(saved_files)
        set(handles.status_text, 'String', sprintf('Fitting result saved to: %s', save_path));
    else
        set(handles.status_text, 'String', 'Save operation canceled');
    end
    guidata(hObject, handles);
end

% --- Executes on button press in Load_Fit_Result.
function Load_Fit_Result_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Fit_Result (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 打开文件选择对话框,限定 .mat 文件
[filename, pathname] = uigetfile('*.mat', 'Select Fit Result MAT-file');
if isequal(filename, 0)
    return;  % 用户取消选择
end

fullpath = fullfile(pathname, filename);

try
    % 加载文件中的所有变量
    data = load(fullpath);
catch ME
    errordlg(['Cannot load file:' ME.message], 'Load Error');
    return;
end


fields = fieldnames(data);
for i = 1:length(fields)
    var = data.(fields{i});
    if isstruct(var) && ...
            isfield(var, 'params') && ...
            isfield(var, 'fitted_spec') && ...
            isfield(var, 'Residuals') && ...
            isfield(var, 'Es_fit')
        fit_result = var;
        break;
    end
end

% 检查是否成功获取拟合结果
if isempty(fit_result)
    errordlg('No valid fitting result data in selected file (requires org_spec, fitted_spec, Residuals, Es_fit, etc.).', 'Load Error');
    return;
end

% 将拟合结果存入 handles
handles.fit_result = fit_result;

% 同时提取能量轴,方便其他回调函数使用
if isfield(fit_result, 'Es_fit')
    handles.Es_fit = fit_result.Es_fit;
else
    % 若拟合结果中无能量轴,可尝试从全局或默认值获取(此处仅给出警告)
    warndlg('Es_fit field not found in fitting results, may affect subsequent spectrum plotting.', 'Missing Energy Axis');
end

% 加载成功后,启用拟合谱和残差复选框
set(handles.fitted_spec, 'Enable', 'on');
set(handles.Residuals, 'Enable', 'on');

% 更新 GUIDATA 结构
guidata(hObject, handles);

% 可选:在命令窗口显示成功信息
disp(['Successfully loaded fitting result: ' filename]);
% 可选:弹出消息框提示成功
msgbox(['Loaded fitting result: ' filename], 'Load Success', 'help');


% --- Executes on button press in Show_Load_Result.
function Show_Load_Result_Callback(hObject, eventdata, handles)
% hObject    handle to Show_Load_Result (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% = ====在坐标区域imgarea显示拟合结果=-======
fit_params = handles.fit_result.params;
axes(handles.imgarea);% 选定坐标区
cla(handles.imgarea);  % 清空图形

% 提取拟合参数(以中心位置为例,而不是幅度)
fit_img = squeeze(fit_params(:,:,2));  % 提取中心位置xc参数
% fit_image(isnan(fit_image)) = 0;  % 将 NaN 替换为 0(如果必要)
% 只选择非 NaN 的值来设置颜色映射范围
valid_fit_img = fit_img(~isnan(fit_img));  % 提取非 NaN 值
valid_fit_img = valid_fit_img(valid_fit_img > 0); % 进一步筛选正值
if ~isempty(valid_fit_img)  % 确保有效值不为空
    % 将颜色映射范围设置为有效值的最小和最大值
    min_center = min(valid_fit_img(:));
    max_center = max(valid_fit_img(:));
else
    disp('No valid fitting values available for color mapping!');
end
% 打印出拟合结果(中心位置)范围
disp(['Fitting result center position range (corresponding energy values):', num2str(min_center), ' eV ~ ', num2str(max_center), ' eV']);
% 设置默认阈值
set(handles.RawdataWindow_low, 'String', min(valid_fit_img(:)));
set(handles.RawdataWindow_high, 'String', max(valid_fit_img(:)));

set(handles.Threshold_low,'String',min(valid_fit_img(:)));
set(handles.Threshold_high,"String",max(valid_fit_img(:)));

set(handles.ShowndataWindow_low, 'String',min(valid_fit_img(:)));
set(handles.ShowndataWindow_high, 'String',max(valid_fit_img(:)));

handles.img = fit_img;
% 使用 disp_img_in_ImgViewer 显示拟合结果
disp_img_in_ImgViewer(handles);

% 设置标题
title('xc-mapping');
% 更新结构体
handles.img = fit_img;
% handles.fit_result = handles.GS_Result;
guidata(hObject, handles);

% 保持图形呈现为正方形
axis image;
% ========== 新增:在 axes_hist 中绘制像素分布柱状图 ==========
if ~isempty(valid_fit_img)
    % 选定 hist 坐标轴并清空
    axes(handles.axes_hist);
    cla(handles.axes_hist);

    % 绘制直方图(可根据需要调整 bin 数量)
    histogram(valid_fit_img, 'BinWidth', (max_center - min_center)/50, ...
        'FaceColor', [0.2 0.4 0.8], 'EdgeColor', 'none');
    xlabel('Center Position (eV)');
    ylabel('Pixel Count');
    title('Pixel Distribution Histogram');
    grid on;

    % 可选:添加均值、中位数等统计信息
    hold on;
    mean_val = mean(valid_fit_img);
    median_val = median(valid_fit_img);
    xline(mean_val, 'r--', 'LineWidth', 1.5);
    xline(median_val, 'g--', 'LineWidth', 1.5);
    legend('Pixel Distribution', ['Mean: ' num2str(mean_val, '%.3f')], ...
        ['Median: ' num2str(median_val, '%.3f')], 'Location', 'best');
    hold off;
else
    % 如果没有有效数据,清空坐标轴并显示提示
    axes(handles.axes_hist);
    cla(handles.axes_hist);
    text(0.5, 0.5, 'No Valid Data', 'HorizontalAlignment', 'center');
    axis off;
end
% --- Executes on button press in Remove_Load.
function Remove_Load_Callback(hObject, eventdata, handles)
% hObject    handle to Remove_Load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 1. 清除 handles 中的拟合结果相关字段
if isfield(handles, 'fit_result')
    handles = rmfield(handles, 'fit_result');
end
if isfield(handles, 'Es_fit')
    handles = rmfield(handles, 'Es_fit');
end
if isfield(handles, 'img')
    handles = rmfield(handles, 'img');
end

% 2. 清除图像显示区域 (imgarea)
if isfield(handles, 'imgarea') && ishandle(handles.imgarea)
    axes(handles.imgarea);
    cla(handles.imgarea);
    title('');  % 清空标题
    axis off;   % 可选:关闭坐标轴显示
end

% 3. 清除直方图区域 (axes_hist)
if isfield(handles, 'axes_hist') && ishandle(handles.axes_hist)
    axes(handles.axes_hist);
    cla(handles.axes_hist);
    text(0.5, 0.5, 'No Data Loaded', 'HorizontalAlignment', 'center', 'FontSize', 12);
    axis off;
end

% 4. 重置阈值和窗口显示文本框(可选,设为空字符串或默认值)

if isfield(handles, 'RawdataWindow_low') && ishandle(handles.RawdataWindow_low)
    set(handles.RawdataWindow_low, 'String', '');
end
if isfield(handles, 'RawdataWindow_high') && ishandle(handles.RawdataWindow_high)
    set(handles.RawdataWindow_high, 'String', '');
end

if isfield(handles, 'Threshold_low') && ishandle(handles.Threshold_low)
    set(handles.Threshold_low, 'String', '');
end
if isfield(handles, 'Threshold_high') && ishandle(handles.Threshold_high)
    set(handles.Threshold_high, 'String', '');
end

if isfield(handles, 'ShowndataWindow_low') && ishandle(handles.ShowndataWindow_low)
    set(handles.ShowndataWindow_low, 'String', '');
end
if isfield(handles, 'ShowndataWindow_high') && ishandle(handles.ShowndataWindow_high)
    set(handles.ShowndataWindow_high, 'String', '');
end

% 5. 禁用拟合谱和残差复选框(因为数据已移除)
if isfield(handles, 'fitted_spec') && ishandle(handles.fitted_spec)
    set(handles.fitted_spec, 'Enable', 'off');
end
if isfield(handles, 'Residuals') && ishandle(handles.Residuals)
    set(handles.Residuals, 'Enable', 'off');
end

% 6. 更新 GUIDATA
guidata(hObject, handles);

% 7. 可选:在命令窗口输出提示
disp('Cleared loaded fitting result data and graphics.');

function E_whiteline_Callback(hObject, eventdata, handles)
% hObject    handle to E_whiteline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of E_whiteline as text
%        str2double(get(hObject,'String')) returns contents of E_whiteline as a double


% --- Executes during object creation, after setting all properties.
function E_whiteline_CreateFcn(hObject, eventdata, handles)
% hObject    handle to E_whiteline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over ColorMaps.
function ColorMaps_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to ColorMaps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on ColorMaps and none of its controls.
function ColorMaps_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to ColorMaps (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)



function Mark_POI_Callback(hObject, eventdata, handles)
% 获取当前显示的图像
current_axes = handles.imgarea;
img = getimage(current_axes);
if isempty(img)
    msgbox('No image displayed in axes1.', 'Warning', 'warn');
    return;
end

% 初始化UserData存储结构
if isempty(get(handles.Mark_POI, 'UserData'))
    POI_data = struct(...
        'points', struct('x', {}, 'y', {}, 'color', {}), ...
        'curves', struct('whole_spec',{},'org_spec', {}, 'fitted_spec', {}, 'Residuals', {}) ...
        );
    set(handles.Mark_POI, 'UserData', POI_data);
else
    POI_data = get(handles.Mark_POI, 'UserData');
end

% 定义颜色列表
colors = lines(20);

% 坐标系统设置
H = size(img, 1);
W = size(img, 2);
xlim(current_axes, [0.5, W+0.5]);
ylim(current_axes, [0.5, H+0.5]);

hold(current_axes, 'on');
lineLen = round(max(size(img))/100);

% ==================== 新增代码:获取拟合 xc 参数映射 ====================
has_fit_xc = false;
fit_xc_map = [];
if isfield(handles, 'fit_result') && isfield(handles.fit_result, 'params') && ~isempty(handles.fit_result.params)
    fit_params = handles.fit_result.params;
    if ndims(fit_params) >= 3 && size(fit_params, 3) >= 2
        fit_xc_map = squeeze(fit_params(:, :, 2));  % 尺寸 (y, x)
        has_fit_xc = true;
    else
        disp('Warning: handles.GS_Result.params dimension insufficient, cannot extract xc parameter (3rd dim must be >=2).');
    end
else
    disp('Note: handles.GS_Result.params not found, fitted xc values will not be displayed.');
end
% ==================== 新增代码结束 ====================

% 交互提示
disp('Click on the image to mark points. Press Enter or right-click to finish.');

% 循环获取点,直到用户按回车或右键
while true
    % 获取一个点,同时获取鼠标/键盘信息
    [x, y, button] = ginput(1);

    % 结束条件:按回车(ASCII 13) 或 右键(button=3) 或 按其他结束键
    if isempty(x) || button == 13 || button == 3
        break;
    end

    % 转换坐标并限制范围
    x = round(x);
    y = round(y);
    x = max(1, min(x, W));
    y = max(1, min(y, H));

    % 根据YDir调整显示坐标(用于绘图)
    if strcmp(get(current_axes, 'YDir'), 'reverse')
        y_plot = y;
    else
        y_plot = H - y + 1;
    end

    % 为新点分配颜色
    color_idx = mod(length(POI_data.points), size(colors,1)) + 1;
    color = colors(color_idx, :);

    % 立即绘制十字标记
    plot(current_axes,...
        [x-lineLen, x+lineLen], [y_plot, y_plot],...
        'Color', color, 'LineWidth', 1.5);
    plot(current_axes,...
        [x, x], [y_plot-lineLen, y_plot+lineLen],...
        'Color', color, 'LineWidth', 1.5);

    % ==================== 新增代码:显示 xc 值 ====================
    if has_fit_xc
        % 注意:fit_xc_map 的索引是 (y, x),其中 y 为图像的行坐标(1~H)
        if y >= 1 && y <= size(fit_xc_map, 1) && x >= 1 && x <= size(fit_xc_map, 2)
            xc_val = fit_xc_map(y, x);
            text_str = sprintf(' xc = %.3f', xc_val);
        else
            text_str = ' xc = N/A';
        end
    else
        text_str = '';   % 如果没有拟合数据,不显示任何文本(或可选择显示 x 坐标)
        % 若希望回退显示像素 x 坐标,可改为:text_str = sprintf(' x = %d', x);
    end

    if ~isempty(text_str)
        % 文本位置:十字右侧偏下。根据 YDir 调整垂直对齐方式
        if strcmp(get(current_axes, 'YDir'), 'reverse')
            v_align = 'top';
        else
            v_align = 'bottom';
        end
        text(x, y_plot, text_str, ...
            'HorizontalAlignment', 'left', ...
            'VerticalAlignment', v_align, ...
            'Color', color, 'FontSize', 9, 'FontWeight', 'bold');
    end
    % ==================== 新增代码结束 ====================

    drawnow;  % 强制刷新

    % 保存点信息
    new_point = struct('x', x, 'y', y, 'color', color);
    if isempty(POI_data.points)
        POI_data.points = new_point;
    else
        POI_data.points(end+1) = new_point;
    end
end

hold(current_axes, 'off');

% 更新存储
set(handles.Mark_POI, 'UserData', POI_data);
guidata(hObject, handles);
disp('Point marking finished.');


% --- Executes on button press in Plot_POI.
function Plot_POI_Callback(hObject, eventdata, handles)
% hObject    handle to Plot_POI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 1. 检查是否存在有效的POI数据
if ~isfield(handles, 'Mark_POI') || isempty(get(handles.Mark_POI, 'UserData'))
    disp('No POI data available');
    return;
end

% 获取POI数据
POI_data = get(handles.Mark_POI, 'UserData');
if ~isfield(POI_data, 'points') || isempty(POI_data.points)
    disp('POI data invalid or empty');
    return;
end

% 2. 获取复选框状态
smooth_checked = get(handles.Smooth, 'Value');
nor_checked = get(handles.use_nor, 'Value');
org_checked  = get(handles.org_spec, 'Value');   % 原始谱
fitted_checked = get(handles.fitted_spec, 'Value'); % 拟合谱
res_checked    = get(handles.Residuals, 'Value');   % 残差

% 3. 检查所需数据是否存在
has_org_data = false;
has_fit_data = false;

% ---- 原始谱数据 ----
if org_checked
    % 确定使用哪个堆栈(归一化、平滑或原始)
    if nor_checked && isfield(handles, 'nor_stack') && ~isempty(handles.nor_stack)
        wholestack = handles.nor_stack;
        disp('Use nor_stack');
    elseif smooth_checked && isfield(handles, 'smoothed_stack') && ~isempty(handles.smoothed_stack)
        wholestack = handles.smoothed_stack;
        disp('Use smoothed_stack');
    elseif isfield(handles, 'org_stack') && ~isempty(handles.org_stack)
        wholestack = handles.org_stack;
        disp('Use org_stack');
    else
        warndlg('Original spectrum requires stack data, but org_stack, smoothed_stack or nor_stack not found. Skip original spectrum plotting.', 'Missing Data');
        org_checked = false;
    end

    if org_checked
        if ~isfield(handles, 'Es') || isempty(handles.Es)
            warndlg('Original spectrum requires energy axis Es, but not found. Skip original spectrum plotting.', 'Missing Data');
            org_checked = false;
        else
            has_org_data = true;
        end
    end
end

% ---- 拟合谱/残差数据 ----
if fitted_checked || res_checked
    % 注意:拟合结果现在保存在 handles.GS_Result 中
    if isfield(handles, 'fit_result') && ~isempty(handles.fit_result)
        fit_result = handles.fit_result;  % 结构体包含 params, R2, fitted_spec, Residuals, Es_fit 等
        if ~isfield(fit_result, 'Es_fit') || isempty(fit_result.Es_fit)
            warndlg('Fitting result missing energy axis Es_fit, skip fitting-related plotting.', 'Missing Data');
            fitted_checked = false;
            res_checked = false;
        else
            has_fit_data = true;
        end
    else
        warndlg('Fitting result GS_Result not found, cannot plot fitted spectrum or residuals.', 'Missing Data');
        fitted_checked = false;
        res_checked = false;
    end
end

% 如果所有复选框都未选中或数据不足,直接返回
if ~org_checked && ~fitted_checked && ~res_checked
    disp('Nothing to plot (checkbox not selected or data missing).');
    return;
end

% 4. 提取每个POI点的曲线数据(存储到 POI_data.curves)
num_points = length(POI_data.points);
for i = 1:num_points
    x = POI_data.points(i).x;
    y = POI_data.points(i).y;

    % 初始化当前点的存储结构(若不存在)
    if numel(POI_data.curves) < i
        POI_data.curves(i).whole_spec = [];
        POI_data.curves(i).fitted_spec = [];
        POI_data.curves(i).Residuals = [];
    end

    % 提取原始谱(如果启用且有堆栈)
    if has_org_data
        % wholestack 维度应为 (y, x, energy)
        whole_spec = squeeze(wholestack(y, x, :));
        POI_data.curves(i).whole_spec = whole_spec;
    end

    % 提取拟合相关数据(如果启用且有拟合结果)
    if has_fit_data
        % 检查 POI 是否在有效掩码内(可选)
        % 如果该像素无效,拟合数据可能为 NaN,直接提取即可
        fitted_spec = squeeze(fit_result.fitted_spec(y, x, :));
        residuals = squeeze(fit_result.Residuals(y, x, :));
        POI_data.curves(i).fitted_spec = fitted_spec;
        POI_data.curves(i).Residuals = residuals;
    end
end

% 更新存储的POI数据
set(handles.Mark_POI, 'UserData', POI_data);
guidata(hObject, handles);

% 5. 绘制曲线
axes(handles.pixel_axes3);
cla;
hold on;

% 颜色从POI点中获取
for i = 1:num_points
    color = POI_data.points(i).color;

    % ---- 绘制原始谱(完整能量轴) ----
    if org_checked && has_org_data && isfield(POI_data.curves(i), 'whole_spec') && ~isempty(POI_data.curves(i).whole_spec)
        % 使用完整能量轴 handles.Es
        if isfield(handles, 'Es') && ~isempty(handles.Es)
            Es_full = handles.Es;
            whole = POI_data.curves(i).whole_spec;
            % 确保长度一致(如果长度不一致,截断或警告)
            if length(Es_full) ~= length(whole)
                warning('Original spectrum length inconsistent with energy axis, truncating to minimum length.');
                min_len = min(length(Es_full), length(whole));
                Es_full = Es_full(1:min_len);
                whole = whole(1:min_len);
            end
            plot(Es_full, whole, ...
                'Color', color, 'LineWidth', 1.5, 'LineStyle', '-', ...
                'DisplayName', sprintf('POI%d - org', i));
        else
            warndlg('Full energy axis Es not found, cannot plot original spectrum.', 'Missing Data');
        end
    end

    % ---- 绘制拟合谱(拟合能量轴) ----
    if fitted_checked && has_fit_data && isfield(POI_data.curves(i), 'fitted_spec') && ~isempty(POI_data.curves(i).fitted_spec)
        Es_fit = fit_result.Es_fit;  % 公共局部窗口能量轴
        fitted = POI_data.curves(i).fitted_spec;
        if length(Es_fit) ~= length(fitted)
            warning('Fitted spectrum length inconsistent with fitted energy axis, truncating.');
            min_len = min(length(Es_fit), length(fitted));
            Es_fit = Es_fit(1:min_len);
            fitted = fitted(1:min_len);
        end
        plot(Es_fit, fitted, ...
            'Color', color, 'LineWidth', 1.5, 'LineStyle', ':', ...
            'DisplayName', sprintf('POI%d - Fitting', i));
    end

    % ---- 绘制残差(拟合能量轴) ----
    if res_checked && has_fit_data && isfield(POI_data.curves(i), 'Residuals') && ~isempty(POI_data.curves(i).Residuals)
        Es_fit = fit_result.Es_fit;
        res = POI_data.curves(i).Residuals;
        if length(Es_fit) ~= length(res)
            min_len = min(length(Es_fit), length(res));
            Es_fit = Es_fit(1:min_len);
            res = res(1:min_len);
        end
        plot(Es_fit, res, ...
            'Color', color, 'LineStyle', 'none', 'Marker', '*', 'MarkerSize', 6, ...
            'DisplayName', sprintf('POI%d - Residual', i));
    end
end

hold off;

% 6. 添加图例并放置在坐标轴右侧外部
lgd = legend('Location', 'none', 'AutoUpdate', 'off');
if ~isempty(lgd)
    ax = gca;
    ax.Units = 'normalized';
    axPos = ax.Position;
    legendWidth = 0.1;
    legendHeight = 0.3;
    legendLeft = axPos(1) + axPos(3) + 0.02;
    legendBottom = axPos(2) + (axPos(4) - legendHeight) / 2;
    lgd.Units = 'normalized';
    lgd.Position = [legendLeft, legendBottom, legendWidth, legendHeight];
end

title('POI Spectra');
xlabel('Energy (eV)');
ylabel('μ');
grid on;


% --- Executes on button press in org_spec.
function org_spec_Callback(hObject, eventdata, handles)
% hObject    handle to org_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of org_spec


% --- Executes on button press in fitted_spec.
function fitted_spec_Callback(hObject, eventdata, handles)
% hObject    handle to fitted_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fitted_spec


% --- Executes on button press in Clear_POI.
function Clear_POI_Callback(hObject, eventdata, handles)
% hObject    handle to Clear_POI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 清除 Mark_POI 按钮的 UserData 中的数据
handles.Mark_POI.UserData = [];

% 检查图像区域是否存在且有效
if isfield(handles, 'imgarea') && isgraphics(handles.imgarea) && isvalid(handles.imgarea)
    % 保存当前坐标轴的显示状态(如坐标范围)
    originalXLim = xlim(handles.imgarea);
    originalYLim = ylim(handles.imgarea);

    % 清除图像区域上的覆盖图形(保留底层图像)
    children = get(handles.imgarea, 'Children');
    for i = 1:length(children)
        if ~strcmpi(get(children(i), 'Type'), 'image')
            delete(children(i)); % 只删除非图像对象(如标记点)
        end
    end

    % 如果存在原始图像数据,重新显示它
    if isfield(handles, 'img') && ~isempty(handles.img)
        % 恢复坐标轴范围以保持缩放状态
        xlim(handles.imgarea, originalXLim);
        ylim(handles.imgarea, originalYLim);
    end
end

% 2. 清除axes3中的能量-灰度曲线
if isfield(handles, 'pixel_axes3') && isgraphics(handles.pixel_axes3) && isvalid(handles.pixel_axes3)
    cla(handles.pixel_axes3, 'reset');  % 彻底清除坐标轴内容和设置

    % 重置坐标轴基本属性
    set(handles.pixel_axes3, ...
        'Box', 'on', ...
        'XGrid', 'off', ...
        'YGrid', 'off', ...
        'Visible', 'on');
end

% 提示用户操作成功
disp('POI data cleared, markers removed');

% 更新 handles 结构
guidata(hObject, handles);
% --- Executes on button press in Save_POI.
function Save_POI_Callback(hObject, eventdata, handles)
% hObject    handle to Save_POI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on button press in Save_POI.

% 1. 检查是否存在 POI 数据(点信息)
if ~isfield(handles, 'Mark_POI') || isempty(get(handles.Mark_POI, 'UserData'))
    errordlg('No POI data available, please mark POI points first.', 'Save Failed');
    return;
end

POI_data = get(handles.Mark_POI, 'UserData');
if ~isfield(POI_data, 'points') || isempty(POI_data.points)
    errordlg('POI data invalid or empty, please re-mark POI points.', 'Save Failed');
    return;
end

num_points = length(POI_data.points);

% 2. 检查是否已提取光谱曲线(curves 字段是否存在且非空)
need_extract = false;
if ~isfield(POI_data, 'curves') || length(POI_data.curves) ~= num_points
    need_extract = true;
else
    % 检查每个点的曲线数据是否为空
    for i = 1:num_points
        if ~isfield(POI_data.curves(i), 'whole_spec') || isempty(POI_data.curves(i).whole_spec)
            need_extract = true;
            break;
        end
    end
end

% 若需要提取曲线,则执行提取(复用 Plot_POI 中的逻辑)
if need_extract
    disp('Extracting spectra for POI points...');

    % 获取复选框状态(用于判断需要哪些数据,但保存时尽量全部保存)
    smooth_checked = get(handles.Smooth, 'Value');
    nor_checked    = get(handles.use_nor, 'Value');

    % 确定原始谱使用的堆栈
    has_org_data = false;
    if nor_checked && isfield(handles, 'nor_stack') && ~isempty(handles.nor_stack)
        wholestack = handles.nor_stack;
        has_org_data = true;
    else
        if smooth_checked && isfield(handles, 'smoothed_stack') && ~isempty(handles.smoothed_stack)
            wholestack = handles.smoothed_stack;
            has_org_data = true;
        elseif isfield(handles, 'org_stack') && ~isempty(handles.org_stack)
            wholestack = handles.org_stack;
            has_org_data = true;
        else
            warndlg('Original spectrum stack data (org_stack / smoothed_stack / nor_stack) not found, cannot extract original spectra.', 'Data Missing');
        end
    end

    % 确定是否存在拟合数据
    has_fit_data = false;
    if isfield(handles, 'fit_result') && ~isempty(handles.fit_result)
        fit_result = handles.fit_result;
        if isfield(handles, 'Es_fit') && ~isempty(handles.Es_fit)
            has_fit_data = true;
        else
            warndlg('Fitted energy axis Es_fit not found, cannot extract fitted spectra/residuals.', 'Data Missing');
        end
    end

    % 提取每条曲线的数据
    for i = 1:num_points
        x = POI_data.points(i).x;
        y = POI_data.points(i).y;

        % 初始化 curves 结构
        if numel(POI_data.curves) < i
            POI_data.curves(i).whole_spec   = [];
            POI_data.curves(i).org_spec     = [];
            POI_data.curves(i).fitted_spec  = [];
            POI_data.curves(i).Residuals    = [];
        end

        % 提取原始谱
        if has_org_data
            whole_spec = squeeze(wholestack(y, x, :));
            POI_data.curves(i).whole_spec = whole_spec;
        end

        % 提取拟合相关数据
        if has_fit_data
            org_spec    = squeeze(fit_result.org_spec(y, x, :));
            fitted_spec = squeeze(fit_result.fitted_spec(y, x, :));
            residuals   = squeeze(fit_result.Residuals(y, x, :));
            POI_data.curves(i).org_spec    = org_spec;
            POI_data.curves(i).fitted_spec = fitted_spec;
            POI_data.curves(i).Residuals   = residuals;
        end
    end

    % 更新 GUI 中的 POI_data
    set(handles.Mark_POI, 'UserData', POI_data);
    guidata(hObject, handles);
    disp('Spectrum extraction complete.');
else
    disp('POI curve data already exists, saving directly.');
end

% 3. 准备保存的数据
save_data = struct();
save_data.POI_data = POI_data;

% 保存能量轴(原始谱和拟合谱)
if isfield(handles, 'Es') && ~isempty(handles.Es)
    save_data.Es = handles.Es;
end
if isfield(handles, 'Es_fit') && ~isempty(handles.Es_fit)
    save_data.Es_fit = handles.Es_fit;
end

% 保存完整的拟合结果(可选)
if isfield(handles, 'fit_result') && ~isempty(handles.fit_result)
    save_data.fit_result = handles.fit_result;
end

% 4. 弹出保存对话框
[filename, pathname] = uiputfile('*.mat', 'Save POI Data', 'POI_Data.mat');
if isequal(filename, 0) || isequal(pathname, 0)
    disp('User cancels saving');
    return;
end

fullpath = fullfile(pathname, filename);

% 5. 保存到 .mat 文件
try
    save(fullpath, '-struct', 'save_data');
    msgbox(sprintf('POI data successfully saved to:\n%s', fullpath), 'Save Success', 'help');
    disp(['POI data saved to: ', fullpath]);
catch ME
    errordlg(['Save Failed:', ME.message], 'File write error');
end




% --- Executes on button press in Residuals.
function Residuals_Callback(hObject, eventdata, handles)
% hObject    handle to Residuals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Residuals


% --- Executes on button press in Extract_Ref_Spec.
% --- Executes on button press in Extract_Ref_Spec.
function Extract_Ref_Spec_Callback(hObject, eventdata, handles)
% ========== 1. 检查拟合结果及掩膜参数 ==========
if ~isfield(handles, 'fit_result') || isempty(handles.fit_result)
    errordlg('No fitting result available, please load fitting data first.', 'Error');
    return;
end
img = squeeze(handles.fit_result.params(:, :, 2));

% 获取能量轴(基线校正必需)
if ~isfield(handles, 'Es') || isempty(handles.Es)
    errordlg('Energy axis data does not exist, cannot perform baseline correction.', 'Error');
    return;
end
Es = handles.Es;

try
    Show_Low  = str2double(get(handles.ShowndataWindow_low, 'String'));
    Show_High = str2double(get(handles.ShowndataWindow_high, 'String'));
    Pre_start = str2double(get(handles.Pre_min, 'String'));
    Pre_end   = str2double(get(handles.Pre_max, 'String'));
catch
    errordlg('Please ensure threshold range and baseline interval controls exist and contain valid values.', 'Error');
    return;
end
if isnan(Show_Low) || isnan(Show_High) || Show_Low >= Show_High
    errordlg('Invalid threshold range: lower bound must be less than upper bound and be valid numbers.', 'Error');
    return;
end
% 生成掩膜
Ref_Mask = (img >= Show_Low & img <= Show_High);

% 检查基线区间有效性
idx_pre = (Es >= Pre_start) & (Es <= Pre_end);
if sum(idx_pre) < 1
    errordlg('Not enough points in baseline interval (at least 1 point required for baseline correction).', 'Invalid Interval');
    return;
end

% ========== 2. 检查面积积分数据是否存在 ==========
if ~isfield(handles, 'area_map') || isempty(handles.area_map)
    errordlg('Please perform Area Integral first to calculate the integrated area for each pixel.', 'Data Missing');
    return;
end
area_map = handles.area_map;   % [nx, ny]

% ========== 3. 选择堆栈(原始或滤波) ==========
if get(handles.Smooth, 'Value') == 0
    if ~isfield(handles, 'org_stack') || isempty(handles.org_stack)
        errordlg('Original stack data does not exist.', 'Error');
        return;
    end
    Imgstack = handles.org_stack;
else
    if ~isfield(handles, 'smoothed_stack') || isempty(handles.smoothed_stack)
        errordlg('Smoothed stack data does not exist, please apply smoothing first.', 'Error');
        return;
    end
    Imgstack = handles.smoothed_stack;
end

% 检查尺寸一致性
if any(size(area_map) ~= size(Imgstack(:,:,1)))
    errordlg('Area map size does not match stack spatial size, please recalculate area integral.', 'Size Error');
    return;
end

% ========== 4. 对每个像素的吸收谱进行面积归一化 ==========
tol = 1e-12;
area_map_safe = area_map;
area_map_safe(abs(area_map_safe) < tol) = 1;   % 面积过小的像素不参与平均,但避免除零
Img_norm = Imgstack ./ area_map_safe;   % [nx, ny, nE]

% ========== 5. 提取参考区域归一化谱并求平均 ==========
[~, ~, num_Es] = size(Img_norm);
Mask_3D = repmat(Ref_Mask, [1, 1, num_Es]);

Ref_spectra_stack = Img_norm .* Mask_3D;
Ref_spectrum_sum = squeeze(sum(sum(Ref_spectra_stack, 1), 2));
num_pixels = sum(Ref_Mask(:));
if num_pixels == 0
    errordlg('No valid pixels in reference region, please adjust threshold range.', 'Error');
    return;
end
Ref_spectrum_avg = Ref_spectrum_sum / num_pixels;  % 平均归一化谱

% ========== 基线校正:常数基线) ==========

baseline_val = mean(Ref_spectrum_avg(idx_pre));
Ref_spectrum_avg = Ref_spectrum_avg - baseline_val;

% ========== 6. 初始化/检查 ref_spectra 结构 ==========
if ~isfield(handles, 'ref_spectra') || ~isstruct(handles.ref_spectra) || ...
        ~isfield(handles.ref_spectra, 'data') || ~iscell(handles.ref_spectra.data)
    handles.ref_spectra = struct();
    handles.ref_spectra.name = {'Ref1','Ref2','Ref3','Ref4','Ref5','Ref6','Ref7','Ref8'};
    handles.ref_spectra.data = cell(1,8);
    handles.ref_spectra.range = cell(1,8);
    if isfield(handles, 'ref_listbox') && ishandle(handles.ref_listbox)
        set(handles.ref_listbox, 'String', {'Ref1 (empty)', 'Ref2 (empty)', 'Ref3 (empty)', ...
            'Ref4 (empty)', 'Ref5 (empty)', 'Ref6 (empty)', 'Ref7 (empty)', 'Ref8 (empty)'}, ...
            'Value', 1);
    end
end

% 查找第一个空位
empty_idx = find(cellfun(@isempty, handles.ref_spectra.data), 1);
if isempty(empty_idx)
    errordlg('Reference spectra storage full (max 8)', 'Storage Full');
    return;
end


handles.ref_spectra.data{empty_idx} = Ref_spectrum_avg(:);
handles.ref_spectra.range{empty_idx} = [Show_Low, Show_High];
handles.ref_spectra.name{empty_idx} = sprintf('[%.1f, %.1f] eV ', Show_Low, Show_High);

% ========== 7. 更新列表框显示 ==========
if isfield(handles, 'ref_listbox') && ishandle(handles.ref_listbox)
    list_str = cell(1,8);
    for i = 1:8
        if isempty(handles.ref_spectra.data{i})
            list_str{i} = sprintf('%s (empty)', handles.ref_spectra.name{i});
        else
            r = handles.ref_spectra.range{i};
            range_str = sprintf('[%.1f, %.1f] eV', r(1), r(2));
            list_str{i} = sprintf('%s ', range_str);
        end
    end
    set(handles.ref_listbox, 'String', list_str, 'Value', empty_idx);
end

% ========== 8. 保存辅助数据(可选) ==========
handles.Ref_Mask = Ref_Mask;
handles.Ref_spectrum_avg = Ref_spectrum_avg;   % 基线校正后的平均谱
handles.stack_Ref = Ref_spectra_stack;

% ========== 9. 绘图 ==========
if isfield(handles, 'axes_refs') && ishandle(handles.axes_refs)
    axes(handles.axes_refs); cla;
    if isfield(handles, 'Es') && ~isempty(handles.Es)
        plot(handles.Es, Ref_spectrum_avg, 'b-', 'LineWidth', 1.5);
        xlabel('Energy (eV)'); ylabel('Normalized Intensity');
        title(sprintf('Reference Spectrum (Area-Norm): %s', ...
            handles.ref_spectra.name{empty_idx}));
        grid on;
    end
end

% ========== 10. 更新 GUI 数据 ==========
guidata(hObject, handles);
disp(['Saved baseline-corrected area-normalized reference spectrum to ', handles.ref_spectra.name{empty_idx}]);

% --- Executes on selection change in ref_listbox.
function ref_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to ref_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 获取当前选中的所有索引(支持多选)
selectedIdx = get(handles.ref_listbox, 'Value');
% 存储到 handles 中,供其他控件(如绘图按钮)使用
handles.selected_ref_idx = selectedIdx;
guidata(hObject, handles);
% 不再进行重命名或任何绘图操作

% --- Executes during object creation, after setting all properties.
function ref_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Clear_Refs.
% --- Executes on button press in Clear_Refs.
function Clear_Refs_Callback(hObject, eventdata, handles)
% 获取列表框中当前选中的索引(支持多选)
if ~isfield(handles, 'ref_listbox') || ~ishandle(handles.ref_listbox)
    errordlg('Reference spectra listbox control not found', 'Error');
    return;
end
selectedIdx = get(handles.ref_listbox, 'Value');
if isempty(selectedIdx)
    errordlg('Please select reference spectra to clear (multi-select allowed)', 'No Selection');
    return;
end

% 检查 ref_spectra 结构是否存在
if ~isfield(handles, 'ref_spectra') || ~isstruct(handles.ref_spectra)
    errordlg('No reference spectra data to clear', 'Error');
    return;
end

% 清除选中的参考谱(将 data, name, range 对应位置清空)
for i = 1:length(selectedIdx)
    idx = selectedIdx(i);
    if idx <= length(handles.ref_spectra.data)
        handles.ref_spectra.data{idx} = [];
        if isfield(handles.ref_spectra, 'name') && length(handles.ref_spectra.name) >= idx
            % 重置名称,保留原始编号(Ref1, Ref2...)
            handles.ref_spectra.name{idx} = sprintf('Ref%d', idx);
        end
        if isfield(handles.ref_spectra, 'range') && length(handles.ref_spectra.range) >= idx
            handles.ref_spectra.range{idx} = [];
        end
    end
end

% 更新列表框显示字符串
list_str = cell(1, length(handles.ref_spectra.data));
for i = 1:length(handles.ref_spectra.data)
    if isempty(handles.ref_spectra.data{i})
        list_str{i} = sprintf('%s (empty)', handles.ref_spectra.name{i});
    else
        % 已存储的显示能量范围(若有)
        if isfield(handles.ref_spectra, 'range') && ~isempty(handles.ref_spectra.range{i})
            r = handles.ref_spectra.range{i};
            range_str = sprintf('[%.1f, %.1f] eV', r(1), r(2));
            list_str{i} = sprintf('%s (saved)', range_str);
        else
            list_str{i} = sprintf('%s (saved)', handles.ref_spectra.name{i});
        end
    end
end
set(handles.ref_listbox, 'String', list_str);

% 如果清空后没有任何参考谱,将选中索引设为1；否则选中第一个非空(可选)
if all(cellfun(@isempty, handles.ref_spectra.data))
    set(handles.ref_listbox, 'Value', 1);
else
    % 找到第一个非空索引并选中
    firstNonEmpty = find(~cellfun(@isempty, handles.ref_spectra.data), 1);
    if ~isempty(firstNonEmpty)
        set(handles.ref_listbox, 'Value', firstNonEmpty);
    else
        set(handles.ref_listbox, 'Value', 1);
    end
end

% 清除绘图:如果 axes_refs 中显示的是被清除的谱,则清除坐标区
if isfield(handles, 'axes_refs') && ishandle(handles.axes_refs)
    % 检查当前显示的曲线是否存在,或者直接清除(也可根据选中项是否包括当前显示的谱)
    % 简单处理:清除 axes_refs 并显示空白或提示
    axes(handles.axes_refs); cla;
    xlabel('Energy (eV)'); ylabel('Intensity (a.u.)');
    title('Reference Spectra (none selected)');
end

% 保存数据
guidata(hObject, handles);
disp(['Cleared ', num2str(length(selectedIdx)), ' selected reference spectra']);
% --- Executes on button press in Plot_Refs.
function Plot_Refs_Callback(hObject, eventdata, handles)
% hObject    handle to Plot_Refs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 获取列表框中所有选中的索引
selectedIdx = get(handles.ref_listbox, 'Value');  % 多选时返回向量
if isempty(selectedIdx)
    errordlg('No reference spectra selected', 'No Selection');
    return;
end
% 获取能量轴(假设保存在 handles.Es)
if ~isfield(handles, 'Es') || isempty(handles.Es)
    errordlg('Energy axis data not found', 'Error');
    return;
end
Es = handles.Es;
% 准备绘图
axes(handles.axes_refs);  % 替换为你的坐标区句柄
cla; hold on;
colors = lines(length(selectedIdx));  % 不同颜色
for i = 1:length(selectedIdx)
    idx = selectedIdx(i);
    % 取出参考谱数据(假设为列向量或与 Es 同维度)
    spec = handles.ref_spectra.data{idx};
    if isempty(spec)
        continue;
    end
    % 确保维度一致
    if size(spec,1) == 1, spec = spec(:); end
    name = handles.ref_spectra.name{idx};
    plot(Es, spec, 'Color', colors(i,:), 'DisplayName', name, 'LineWidth', 1.5);
end
hold off;
legend show;
xlabel('Energy (eV)');
ylabel('Intensity (a.u.)');
title('Selected Reference Spectra');
guidata(hObject, handles);

% --- Executes on button press in Save_Ref_Specs.
function Save_Ref_Specs_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Ref_Specs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on button press in Save_Ref_Specs.
% 1. 检查是否存在参考谱数据
if ~isfield(handles, 'ref_spectra') || ~isstruct(handles.ref_spectra) || ...
        ~isfield(handles.ref_spectra, 'data') || ~iscell(handles.ref_spectra.data)
    errordlg('No reference spectra data available, please extract reference spectra first.', 'No Data');
    return;
end

% 2. 检查是否至少有一个已保存的参考谱(非空)
filled_indices = find(~cellfun(@isempty, handles.ref_spectra.data));
if isempty(filled_indices)
    errordlg('No saved reference spectra, please extract reference spectra first.', 'No Data');
    return;
end

% 3. 获取能量轴(用于保存)
if ~isfield(handles, 'Es') || isempty(handles.Es)
    errordlg('Missing energy axis data, cannot save reference spectra.', 'Error');
    return;
end

% 4. 让用户选择保存路径和文件名(默认扩展名为 .txt)
[filename, pathname] = uiputfile('*.txt', 'Save reference spectra as TXT file', 'ref_spectra.txt');
if isequal(filename, 0) || isequal(pathname, 0)
    return; % 用户取消
end
fullpath = fullfile(pathname, filename);

% 5. 获取参考谱总数(假设固定为5个槽位,但动态获取长度)
nRefs = length(handles.ref_spectra.data);
if nRefs < 1
    errordlg('Abnormal number of reference spectra.', 'Error');
    return;
end

% 6. 准备数据矩阵:第一列为能量,后续列为各参考谱(列向量)
E = handles.Es(:);                 % 确保为列向量
nE = length(E);
dataMatrix = zeros(nE, nRefs + 1); % 预分配
dataMatrix(:,1) = E;

% 7. 准备列标题
colHeaders = cell(1, nRefs + 1);
colHeaders{1} = 'Energy';

% 8. 填充每个参考谱的数据和列标题
for i = 1:nRefs
    % 获取参考谱名称(若为空则自动生成)
    if i <= length(handles.ref_spectra.name) && ~isempty(handles.ref_spectra.name{i})
        refName = handles.ref_spectra.name{i};
        % 去除可能导致CSV/TXT问题的特殊字符
        refName = strrep(refName, sprintf('\n'), '');
        refName = strrep(refName, sprintf('\r'), '');
        refName = strrep(refName, '\t', ' ');
    else
        refName = sprintf('Ref_%d', i);
    end
    colHeaders{i+1} = refName;

    % 获取数据(若该槽位为空,则填充NaN)
    if i <= length(handles.ref_spectra.data) && ~isempty(handles.ref_spectra.data{i})
        spec = handles.ref_spectra.data{i}(:); % 确保列向量
        % 检查长度是否匹配
        if length(spec) == nE
            dataMatrix(:, i+1) = spec;
        else
            warning('Length of reference spectrum %d (%d) does not match energy axis length (%d), filling with NaN.', ...
                i, length(spec), nE);
            dataMatrix(:, i+1) = NaN;
        end
    else
        dataMatrix(:, i+1) = NaN;   % 空槽位填充NaN
    end
end

% 9. 写入TXT文件(使用制表符分隔)
try
    % 打开文件
    fid = fopen(fullpath, 'w');
    if fid == -1
        error('Cannot create file, please check path permissions.');
    end

    % 写入列标题(用制表符分隔)
    fprintf(fid, '%s', colHeaders{1});
    for i = 2:length(colHeaders)
        fprintf(fid, '\t%s', colHeaders{i});
    end
    fprintf(fid, '\n');

    % 写入数据(逐行写入,避免大型矩阵的内存问题)
    for row = 1:nE
        fprintf(fid, '%.6f', dataMatrix(row,1));   % 能量,保留6位小数
        for col = 2:nRefs+1
            val = dataMatrix(row, col);
            if isnan(val)
                fprintf(fid, '\tNaN');
            else
                fprintf(fid, '\t%.6f', val);
            end
        end
        fprintf(fid, '\n');
    end

    fclose(fid);
    msgbox(sprintf('Reference spectra saved as TXT file:\n%s\n\nColumn headers: %s', ...
        fullpath, strjoin(colHeaders, ' , ')), 'Save Success', 'help');
    disp(['Reference spectra saved as TXT: ', fullpath]);
catch ME
    if exist('fid', 'var') && fid ~= -1
        fclose(fid);
    end
    errordlg(['Save Failed:', ME.message], 'Save Error');
end

% ============面积归一化函数:使用常数基线==========================
function Area_integral_Callback(hObject, eventdata, handles)
% 1. 检查必要数据

if ~isfield(handles, 'Es') || isempty(handles.Es)
    errordlg('Energy axis data (handles.Es) not found.', 'Data Missing');
    return;
end
if get(handles.Smooth, 'Value') == 0% 未勾选,直接保存并返回
    % 检查 img 字段
    if isfield(handles, 'stack_ROI') && ~isempty(handles.stack_ROI)
        handles.stack = handles.stack_ROI;
    elseif isfield(handles, 'org_stack') && ~isempty(handles.org_stack)
        handles.stack = handles.org_stack;
    else
        errordlg('No image stack data loaded!', 'Data Error');
    end

elseif get(handles.Smooth, 'Value') == 1
    if ~isfield(handles, 'smoothed_stack') || isempty(handles.smoothed_stack)
        errordlg('No image stack data loaded!', 'Data Error');
    else
        handles.stack = handles.smoothed_stack;
    end
end
Imgstack = handles.stack;


Es = handles.Es(:)';                     % 行向量

% 读取 GUI 参数
Pre_start = str2double(get(handles.Pre_min, 'String'));
Pre_end   = str2double(get(handles.Pre_max, 'String'));
E_start   = str2double(get(handles.Integral_min, 'String'));
E_end     = str2double(get(handles.Integral_max, 'String'));

% 确定区间索引
idx_pre     = (Es >= Pre_start) & (Es <= Pre_end);
idx_interval = (Es >= E_start) & (Es <= E_end);

if sum(idx_pre) < 1
    errordlg('Not enough points in baseline interval (at least 1 point required to calculate mean).', 'Invalid Interval');
    return;
end
if sum(idx_interval) < 2
    errordlg('Not enough points in integration interval (at least 2 points required to integrate).', 'Invalid Interval');
    return;
end



% 4. 计算每个像素在基线区间的平均值(作为基线值)
Img_pre = Imgstack(:, :, idx_pre);     % [nx, ny, n_pre]
baseline_val = mean(Img_pre, 3);         % [nx, ny] 每个像素的基线常数

% 6. 对积分区间内的每个能量点减去该像素的基线值(隐式扩展)
Img_baseline_subtracted = Imgstack - baseline_val;

% ========== 计算面积积分 ==========
% 在积分区间内对基线校正后的谱进行积分
Img_int = Img_baseline_subtracted(:, :, idx_interval);
E_int = Es(idx_interval);
area_map = trapz(E_int, Img_int, 3);               % [nx, ny]
% 7. 计算减去基线后的积分面积 (trapz 沿第三维)

% ========== 面积归一化 ==========
% 将每个像素的谱除以该像素的积分面积,得到面积归一化堆栈
tol = 1e-12;
area_map_safe = area_map;
area_map_safe(abs(area_map_safe) < tol) = 1;       % 避免除零
nor_stack = Img_baseline_subtracted ./ area_map_safe; % [nx, ny, nE]

% ========== 保存结果 ==========
handles.area_map  = area_map;      % 积分面积图
handles.nor_stack = nor_stack;     % 基线校正 + 面积归一化后的堆栈

% 可选:如果之前存在 filtered_stack,给出提示
if isfield(handles, 'filtered_stack')
    disp('Note: Baseline-corrected and area-normalized stack saved as handles.nor_stack. If filtering is needed, re-apply smoothing.');
end

guidata(hObject, handles);

% 完成提示
msg = sprintf('Baseline subtraction + area normalization complete.');
msgbox(msg, 'Success', 'help');

% % ============面积归一化函数(线性基线版)==========================
% function Area_integral_Callback(hObject, eventdata, handles)
% % 1. 检查必要数据
% if ~isfield(handles, 'Es') || isempty(handles.Es)
%     errordlg('Energy axis data (handles.Es) not found.', 'Data Missing');
%     return;
% end
% 
% % 选择当前使用的堆栈(ROI、原始或平滑后)
% if get(handles.Smooth, 'Value') == 0  % 未勾选平滑
%     if isfield(handles, 'stack_ROI') && ~isempty(handles.stack_ROI)
%         handles.stack = handles.stack_ROI;
%     elseif isfield(handles, 'org_stack') && ~isempty(handles.org_stack)
%         handles.stack = handles.org_stack;
%     else
%         errordlg('No image stack data loaded!', 'Data Error');
%         return;
%     end
% else  % 勾选平滑
%     if ~isfield(handles, 'smoothed_stack') || isempty(handles.smoothed_stack)
%         errordlg('未找到平滑后的堆栈 (handles.smoothed_stack)。', 'Data Missing');
%         return;
%     else
%         handles.stack = handles.smoothed_stack;
%     end
% end
% Imgstack = handles.stack;
% Es = handles.Es(:)';   % 行向量
% 
% % 读取 GUI 参数
% Pre_start = str2double(get(handles.Pre_min, 'String'));
% Pre_end   = str2double(get(handles.Pre_max, 'String'));
% E_start   = str2double(get(handles.Integral_min, 'String'));
% E_end     = str2double(get(handles.Integral_max, 'String'));
% 
% % 确定区间索引
% idx_pre      = (Es >= Pre_start) & (Es <= Pre_end);
% idx_interval = (Es >= E_start) & (Es <= E_end);
% 
% % 检查点数要求(线性基线至少需要2个点)
% if sum(idx_pre) < 2
%     errordlg('基线区间内点数不足(至少需要2个点才能进行线性拟合)。', 'Invalid Interval');
%     return;
% end
% if sum(idx_interval) < 2
%     errordlg('Not enough points in integration interval (at least 2 points required to integrate).', 'Invalid Interval');
%     return;
% end
% 
% % ========== 对每个像素进行线性基线拟合 ==========
% % 获取基线区间的能量和强度
% Es_pre = Es(idx_pre);                % [1, n_pre]
% Img_pre = Imgstack(:, :, idx_pre);   % [nx, ny, n_pre]
% 
% % 将数据重塑为像素 × 能量点数 矩阵,便于计算
% [nx, ny, ~] = size(Imgstack);
% npixels = nx * ny;
% Img_pre_2d = reshape(Img_pre, npixels, []);   % [npixels, n_pre]
% 
% % 计算线性拟合所需统计量(向量化)
% n_pre = numel(Es_pre);
% sum_E   = sum(Es_pre);
% sum_E2  = sum(Es_pre.^2);
% sum_y   = sum(Img_pre_2d, 2);               % [npixels, 1]
% sum_Ey  = Img_pre_2d * Es_pre(:);           % [npixels, 1]  矩阵乘法
% 
% % 解线性方程组求斜率 a 和截距 b
% denom = n_pre * sum_E2 - sum_E^2;
% % 防止除零(理论上不会,因为 n_pre >= 2 且能量点不全部相同)
% if denom == 0
%     errordlg('基线能量点无法进行线性拟合(能量值可能重复)。', '拟合错误');
%     return;
% end
% a = (n_pre * sum_Ey - sum_E * sum_y) / denom;   % [npixels, 1]
% b = (sum_y - a * sum_E) / n_pre;                % [npixels, 1]
% 
% % 对整个能量轴 Es 计算线性基线值(每个像素的基线直线)
% Es_all = Es;   % [1, nE]
% % 基线矩阵:baseline_linear 为 [npixels, nE]
% baseline_linear = a * Es_all + b;   % 利用广播(a 为列向量,Es_all 为行向量)
% 
% % 重塑为 [nx, ny, nE]
% baseline_linear = reshape(baseline_linear, nx, ny, []);
% 
% % ========== 减去线性基线 ==========
% Img_baseline_subtracted = Imgstack - baseline_linear;
% 
% % ========== 计算面积积分(在积分区间内) ==========
% Img_int = Img_baseline_subtracted(:, :, idx_interval);
% E_int = Es(idx_interval);
% area_map = trapz(E_int, Img_int, 3);   % [nx, ny]
% 
% % ========== 面积归一化 ==========
% tol = 1e-12;
% area_map_safe = area_map;
% area_map_safe(abs(area_map_safe) < tol) = 1;   % 避免除零
% nor_stack = Img_baseline_subtracted ./ area_map_safe;  % [nx, ny, nE]
% 
% % ========== 保存结果 ==========
% handles.area_map  = area_map;      % 积分面积图
% handles.nor_stack = nor_stack;     % 基线校正 + 面积归一化后的堆栈
% 
% % 如果之前存在 filtered_stack,给出提示
% if isfield(handles, 'filtered_stack')
%     disp('提示:基线校正并面积归一化后的堆栈已保存为 handles.nor_stack,如需滤波请重新应用平滑。');
% end
% 
% guidata(hObject, handles);
% 
% % 完成提示
% msg = sprintf('线性Baseline subtraction + area normalization complete.');
% msgbox(msg, 'Success', 'help');



% ================面积归一化area——map显示函数
% --- Executes on button press in Show_Area_map.
function Show_Area_map_Callback(hObject, eventdata, handles)
% hObject    handle to Show_Area_map (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% = ====在坐标区域imgarea显示拟合结果=-======

axes(handles.imgarea);% 选定坐标区
cla(handles.imgarea);  % 清空图形

% 提取拟合参数(以中心位置为例,而不是幅度)

fit_img = handles.area_map;  % 提取area_map
% fit_image(isnan(fit_image)) = 0;  % 将 NaN 替换为 0(如果必要)
% 只选择非 NaN 的值来设置颜色映射范围
valid_fit_img = fit_img(~isnan(fit_img));  % 提取非 NaN 值
valid_fit_img = valid_fit_img(valid_fit_img > 0); % 进一步筛选正值
if ~isempty(valid_fit_img)  % 确保有效值不为空
    % 将颜色映射范围设置为有效值的最小和最大值
    min_center = min(valid_fit_img(:));
    max_center = max(valid_fit_img(:));
else
    disp('No valid fitting values available for color mapping!');
end
% 打印出拟合结果(中心位置)范围
disp(['Fitting result center position range (corresponding energy values):', num2str(min_center), ' eV ~ ', num2str(max_center), ' eV']);
% 设置默认阈值
set(handles.RawdataWindow_low, 'String', min(valid_fit_img(:)));
set(handles.RawdataWindow_high, 'String', max(valid_fit_img(:)));

set(handles.Threshold_low,'String',min(valid_fit_img(:)));
set(handles.Threshold_high,"String",max(valid_fit_img(:)));

set(handles.ShowndataWindow_low, 'String',min(valid_fit_img(:)));
set(handles.ShowndataWindow_high, 'String',max(valid_fit_img(:)));

handles.img = fit_img;

disp_img_in_ImgViewer(handles);
guidata(hObject, handles);
% 保持图形呈现为正方形
% 设置标题
title('Area Integral-mapping');
axis image;
% ========== 新增:在 axes_hist 中绘制像素分布柱状图 ==========
if ~isempty(valid_fit_img)
    % 选定 hist 坐标轴并清空
    axes(handles.axes_hist);
    cla(handles.axes_hist);

    % 绘制直方图(可根据需要调整 bin 数量)
    histogram(valid_fit_img, 'BinWidth', (max_center - min_center)/50, ...
        'FaceColor', [0.2 0.4 0.8], 'EdgeColor', 'none');
    xlabel('Center Position (eV)');
    ylabel('Pixel Count');
    title('Pixel Distribution Histogram');
    grid on;

    % 可选:添加均值、中位数等统计信息
    hold on;
    mean_val = mean(valid_fit_img);
    median_val = median(valid_fit_img);
    xline(mean_val, 'r--', 'LineWidth', 1.5);
    xline(median_val, 'g--', 'LineWidth', 1.5);
    legend('Pixel Distribution', ['Mean: ' num2str(mean_val, '%.3f')], ...
        ['Median: ' num2str(median_val, '%.3f')], 'Location', 'best');
    hold off;
else
    % 如果没有有效数据,清空坐标轴并显示提示
    axes(handles.axes_hist);
    cla(handles.axes_hist);
    text(0.5, 0.5, 'No Valid Data', 'HorizontalAlignment', 'center');
    axis off;
end

% --- Executes on button press in Normalized_checkbox.
function Normalized_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Normalized_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Normalized_checkbox



function Pre_min_Callback(hObject, eventdata, handles)
% hObject    handle to Pre_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Pre_min as text
%        str2double(get(hObject,'String')) returns contents of Pre_min as a double


% --- Executes during object creation, after setting all properties.
function Pre_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Pre_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Pre_max_Callback(hObject, eventdata, handles)
% hObject    handle to Pre_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Pre_max as text
%        str2double(get(hObject,'String')) returns contents of Pre_max as a double


% --- Executes during object creation, after setting all properties.
function Pre_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Pre_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Integral_min_Callback(hObject, eventdata, handles)
% hObject    handle to Integral_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Integral_min as text
%        str2double(get(hObject,'String')) returns contents of Integral_min as a double


% --- Executes during object creation, after setting all properties.
function Integral_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Integral_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Integral_max_Callback(hObject, eventdata, handles)
% hObject    handle to Integral_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Integral_max as text
%        str2double(get(hObject,'String')) returns contents of Integral_max as a double


% --- Executes during object creation, after setting all properties.
function Integral_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Integral_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in use_nor.
function use_nor_Callback(hObject, eventdata, handles)
% hObject    handle to use_nor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of use_nor




% --- Executes on button press in Separate_Particles.
function Separate_Particles_Callback(hObject, eventdata, handles)
% 功能:用户圈画区域,提取所有非零体素(过滤噪声),根据整体包围盒扩展padding像素,
%       裁剪并保存为单个堆栈(扩展区域为0),不区分颗粒编号。

% 1. 获取堆栈数据
if isfield(handles, 'stack_ROI') && ~isempty(handles.stack_ROI)
    stack = handles.stack_ROI;
    disp('Using stack_ROI (ROI processed stack)');
elseif isfield(handles, 'org_stack') && ~isempty(handles.org_stack)
    stack = handles.org_stack;
    disp('Using org_stack (original stack)');
else
    errordlg('No image stack data loaded!', 'Data Error');
    return;
end

% 2. 获取能量数组
if ~isfield(handles, 'Es') || isempty(handles.Es)
    errordlg('The energy array Es was not found and thus cannot be saved.', 'Data Missing');
    return;
end
Es = handles.Es;

% 3. 获取保存路径
if isfield(handles, 'Path') && ~isempty(get(handles.Path, 'String')) && ...
        ~strcmp(get(handles.Path, 'String'), 'Path')
    saveDir = fileparts(get(handles.Path, 'String'));
    if isempty(saveDir); saveDir = pwd; end
else
    saveDir = uigetdir(pwd, 'Select save directory');
    if isequal(saveDir, 0); return; end
end

% 4. 获取 padding(用户输入)
answer = inputdlg('Enter padding margin (pixels, positive integer):', 'Padding Settings', [1 50], {'50'});
if isempty(answer); return; end
padding = round(str2double(answer{1}));
if isnan(padding) || padding < 0; padding = 0; end
fprintf('Using padding = %d pixels\n', padding);

% 5. 显示中心切片供用户圈画区域
[h, w, d] = size(stack);
centerZ = round(d/2);
sliceImg = stack(:, :, centerZ);
figROI = figure('Name', 'Draw region of interest with mouse', 'NumberTitle', 'off', 'MenuBar', 'none');
imshow(sliceImg, [min(sliceImg(:)), max(sliceImg(:))]);
title(sprintf('Center energy slice (Z=%d, E=%.2f eV) - Draw polygon, double click to finish', centerZ, Es(centerZ)));
disp('Draw polygon vertices on the slice, double click or right click to finish.');
mask2D = roipoly;
close(figROI);
if ~any(mask2D(:))
    msgbox('No region drawn, Operation canceled.', 'Cancel');
    return;
end

% 6. 扩展为三维掩膜,结合强度阈值
mask3D = repmat(mask2D, [1, 1, d]);
bw = mask3D & (stack > 0);

% 7. 过滤极小连通域(去除 <10 体素的噪声)
bw = bwareaopen(bw, 10);

if ~any(bw(:))
    errordlg('No valid voxels detected in the region.', 'No Data'); return;
end

% 8. 计算整体非零体素的包围盒
[rowIdx, colIdx, planeIdx] = ind2sub([h, w, d], find(bw));
r_min = min(rowIdx); r_max = max(rowIdx);
c_min = min(colIdx); c_max = max(colIdx);
p_min = min(planeIdx); p_max = max(planeIdx);

% 9. 扩展包围盒,并限制在图像边界内
r_min_ext = max(1, r_min - padding);
r_max_ext = min(h, r_max + padding);
c_min_ext = max(1, c_min - padding);
c_max_ext = min(w, c_max + padding);


% 为简便,我们只裁剪空间维度,保持第三维为 d
newH = r_max_ext - r_min_ext + 1;
newW = c_max_ext - c_min_ext + 1;
newD = d;   % 不裁剪能量层

% 创建裁剪堆栈,填充原强度值(仅保留 bw 中的体素)
extractedStack = zeros(newH, newW, newD, class(stack));
% 将体素坐标转换到裁剪后坐标
r_offset = r_min_ext - 1;
c_offset = c_min_ext - 1;
% 对于所有非零体素,映射到裁剪坐标
newRows = rowIdx - r_offset;
newCols = colIdx - c_offset;
newPlanes = planeIdx;  % 能量层不变
% 使用线性索引赋值
newIdx = sub2ind([newH, newW, newD], newRows, newCols, newPlanes);
extractedStack(newIdx) = stack(sub2ind([h,w,d], rowIdx, colIdx, planeIdx));

% 10. 保存
outDir = fullfile(saveDir, 'extracted_region');
if ~exist(outDir, 'dir'); mkdir(outDir); end
saveFile = fullfile(outDir, 'extractedStack_padded.mat');
save(saveFile, 'extractedStack', 'Es', '-v7.3');
fprintf('Extracted stack saved, size %d×%d×%d, non-zero voxels %d, padding=%d\n', ...
    newH, newW, newD, nnz(extractedStack), padding);

% 保存掩膜和包围盒信息供参考
save(fullfile(outDir, 'user_roi_mask.mat'), 'mask2D', 'centerZ');
save(fullfile(outDir, 'bounding_box_info.mat'), 'r_min', 'r_max', 'c_min', 'c_max', ...
    'r_min_ext', 'r_max_ext', 'c_min_ext', 'c_max_ext', 'padding');

% 11. 提示
msgbox(sprintf('Done! Extracted %d valid voxels, cropped size %d×%d×%d, saved to:\n%s', ...
    nnz(extractedStack), newH, newW, newD, saveFile), 'Extraction Complete', 'help');

% --- Executes on button press in Show_R2_mapping.
function Show_R2_mapping_Callback(hObject, eventdata, handles)
% hObject    handle to Show_R2_mapping (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on button press in Show_Gaussian_Result.

fit_params = handles.GS_Result.R2;
axes(handles.imgarea);% 选定坐标区
cla(handles.imgarea);  % 清空图形

% 提取拟合参数(以中心位置为例,而不是幅度)
fit_img = squeeze(fit_params(:,:));  % 提取中心位置xc参数

% 只选择非 NaN 的值来设置颜色映射范围
valid_fit_img = fit_img(~isnan(fit_img));  % 提取非 NaN 值
valid_fit_img = valid_fit_img(valid_fit_img > 0); % 进一步筛选正值
if ~isempty(valid_fit_img)  % 确保有效值不为空
    % 将颜色映射范围设置为有效值的最小和最大值
    min_center = min(valid_fit_img(:));
    max_center = max(valid_fit_img(:));
else
    disp('No valid fitting values available for color mapping!');
end
% 打印出拟合结果(中心位置)范围
disp(['Fitting result center position range (corresponding energy values):', num2str(min_center), ' eV ~ ', num2str(max_center), ' eV']);
% 设置默认阈值
set(handles.RawdataWindow_low, 'String', min(valid_fit_img(:)));
set(handles.RawdataWindow_high, 'String', max(valid_fit_img(:)));

set(handles.Threshold_low,'String',min(valid_fit_img(:)));
set(handles.Threshold_high,'String',max(valid_fit_img(:)));

set(handles.ShowndataWindow_low, 'String',min(valid_fit_img(:)));
set(handles.ShowndataWindow_high, 'String',max(valid_fit_img(:)));

handles.img = fit_img;
% 使用 disp_img_in_ImgViewer 显示拟合结果
disp_img_in_ImgViewer(handles);

% 设置标题
title('Gaussian Fitting R2-mapping');
% 更新结构体
handles.img = fit_img;
handles.fit_result = handles.GS_Result;
guidata(hObject, handles);

% 保持图形呈现为正方形
axis image;

% ========== 新增:在 axes_hist 中绘制像素分布柱状图 ==========
if ~isempty(valid_fit_img)
    % 选定 hist 坐标轴并清空
    axes(handles.axes_hist);
    cla(handles.axes_hist);

    % 绘制直方图(可根据需要调整 bin 数量)
    histogram(valid_fit_img, 'BinWidth', (max_center - min_center)/50, ...
        'FaceColor', [0.2 0.4 0.8], 'EdgeColor', 'none');
    xlabel('Center Position (eV)');
    ylabel('Pixel Count');
    title('Pixel Distribution Histogram');
    grid on;

    % 可选:添加均值、中位数等统计信息
    hold on;
    mean_val = mean(valid_fit_img);
    median_val = median(valid_fit_img);
    xline(mean_val, 'r--', 'LineWidth', 1.5);
    xline(median_val, 'g--', 'LineWidth', 1.5);
    legend('Pixel Distribution', ['Mean: ' num2str(mean_val, '%.3f')], ...
        ['Median: ' num2str(median_val, '%.3f')], 'Location', 'best');
    hold off;
else
    % 如果没有有效数据,清空坐标轴并显示提示
    axes(handles.axes_hist);
    cla(handles.axes_hist);
    text(0.5, 0.5, 'No Valid Data', 'HorizontalAlignment', 'center');
    axis off;
end


% --- Executes on button press in Params_Select.
function Params_Select_Callback(hObject, eventdata, handles)
% hObject    handle to Params_Select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ========== 1. 读取下拉菜单当前选项 ==========
popupOptions = get(handles.Params_Select, 'String');
if ischar(popupOptions)
    popupOptions = {popupOptions};   % 只有一个选项时保证是cell
end
selectedIdx   = get(handles.Params_Select, 'Value');
selectedParam = strtrim(popupOptions{selectedIdx});

% ========== 2. 根据选项确定要显示的参数与标签 ==========
switch selectedParam
    case 'R2'
        fieldName   = 'R2';
        plotTitle   = 'R2-mapping';
        histTitle   = 'R2 Pixel Distribution Histogram';
        xLabelText  = 'R^2';
        filterPositive = true;    % R2 只取正值
    case 'b0'
        fieldName   = 'b0';
        plotTitle   = 'b0-mapping';
        histTitle   = 'b0 Pixel Distribution Histogram';
        xLabelText  = 'b0';
        filterPositive = false;   % b0 可能为负
    case 's'
        fieldName   = 's';
        plotTitle   = 's-mapping';
        histTitle   = 's Pixel Distribution Histogram';
        xLabelText  = 's';
        filterPositive = false;
    otherwise
        errordlg(['Unknown parameter selection: ' selectedParam], 'Error');
        return;
end

% ========== 3. 检查 fit_result 字段是否存在 ==========
if ~isfield(handles, 'fit_result') || ~isfield(handles.fit_result, fieldName) ...
        || isempty(handles.fit_result.(fieldName))
    errordlg(['Data ' fieldName ' does not exist in fit_result, please run fitting first.'],  'Data Missing');
    return;
end

% ========== 4. 提取参数并显示 ==========
fit_params = handles.fit_result.(fieldName);
fit_img    = squeeze(fit_params);    % 去掉单例维度

% 选定坐标区并清空
axes(handles.imgarea);
cla(handles.imgarea);

% 提取有效值
valid_fit_img = fit_img(~isnan(fit_img));
if filterPositive
    valid_fit_img = valid_fit_img(valid_fit_img > 0);
else
    valid_fit_img = valid_fit_img(valid_fit_img ~= 0);
end

if ~isempty(valid_fit_img)
    min_val = min(valid_fit_img(:));
    max_val = max(valid_fit_img(:));
else
    disp(['No valid ' fieldName ' values available for color mapping!']);
    min_val = 0;
    max_val = 1;
end

% 打印范围
disp([selectedParam 'Range: ', num2str(min_val), ' ~ ', num2str(max_val)]);

% 设置各阈值输入框
set(handles.RawdataWindow_low,   'String', num2str(min_val));
set(handles.RawdataWindow_high,  'String', num2str(max_val));
set(handles.Threshold_low,       'String', num2str(min_val));
set(handles.Threshold_high,      'String', num2str(max_val));
set(handles.ShowndataWindow_low, 'String', num2str(min_val));
set(handles.ShowndataWindow_high,'String', num2str(max_val));

% 存储并显示
handles.img = fit_img;
disp_img_in_ImgViewer(handles);

title(plotTitle);
axis image;

% ========== 5. 绘制直方图 ==========
if ~isempty(valid_fit_img)
    axes(handles.axes_hist);
    cla(handles.axes_hist);

    % 防止 binWidth 为 0
    binWidth = (max_val - min_val) / 50;
    if binWidth <= 0
        binWidth = max(abs(max_val), 1) * 1e-3;
    end

    histogram(valid_fit_img, 'BinWidth', binWidth, ...
        'FaceColor', [0.2 0.4 0.8], 'EdgeColor', 'none');
    xlabel(xLabelText);
    ylabel('Pixel Count');
    title(histTitle);
    grid on;

    % 均值 / 中位数参考线
    hold on;
    mean_val   = mean(valid_fit_img);
    median_val = median(valid_fit_img);
    xline(mean_val,   'r--', 'LineWidth', 1.5);
    xline(median_val, 'g--', 'LineWidth', 1.5);
    legend('Pixel Distribution', ['Mean: ' num2str(mean_val, '%.4f')], ...
        ['Median: ' num2str(median_val, '%.4f')], 'Location', 'best');
    hold off;
else
    axes(handles.axes_hist);
    cla(handles.axes_hist);
    text(0.5, 0.5, 'No Valid Data', 'HorizontalAlignment', 'center');
    axis off;
end

% 更新 handles
guidata(hObject, handles);

%=====异常值校正函数
function xc_corrected = correct_xc_outliers(xc_map, threshold_eV, method)
% 逐像素 3×3 邻域异常值检测与替换
% xc_map : h×w 峰位矩阵 (eV)
% threshold_eV : 判定异常的阈值 (eV)
% method : 'median' 或 'mean'
if nargin < 3, method = 'median'; end
if nargin < 2, threshold_eV = 0.5; end

[h, w] = size(xc_map);
xc_corrected = xc_map;

for i = 2:h-1
    for j = 2:w-1
        neighbors = xc_map(i-1:i+1, j-1:j+1);
        neighbors(2,2) = NaN;   % 移除自身
        valid = neighbors(~isnan(neighbors));
        if isempty(valid), continue; end

        if strcmp(method, 'median')
            stat = median(valid);
        else
            stat = mean(valid);
        end
        stdv = std(valid);

        % 异常判定:偏离统计值超过阈值 或 超过2倍标准差
        if abs(xc_map(i,j) - stat) > threshold_eV || ...
                abs(xc_map(i,j) - stat) > 2*stdv
            xc_corrected(i,j) = stat;
        end
    end
end

% 边界处理(简单复制最近邻)
xc_corrected(1,:) = xc_corrected(2,:);
xc_corrected(end,:) = xc_corrected(end-1,:);
xc_corrected(:,1) = xc_corrected(:,2);
xc_corrected(:,end) = xc_corrected(:,end-1);





% --- Executes on button press in SaveNormStack.
function SaveNormStack_Callback(hObject, eventdata, handles)
% hObject    handle to SaveNormStack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on button press in SaveNormStack.


% 1. 检查是否存在归一化堆栈
if ~isfield(handles, 'nor_stack') || isempty(handles.nor_stack)
    errordlg('Normalized stack data (handles.nor_stack) not found. Please run Area Normalization first.', 'Data Missing');
    return;
end

% 2. 检查能量轴是否存在
if ~isfield(handles, 'Es') || isempty(handles.Es)
    errordlg('Energy axis data (handles.Es) not found.', 'Data Missing');
    return;
end

% 3. 让用户选择保存路径和文件名(默认扩展名为 .mat)
[filename, pathname] = uiputfile('*.mat', 'Save the normalized image stack', 'normalized_stack.mat');
if isequal(filename, 0) || isequal(pathname, 0)
    % 用户取消操作
    return;
end

% 4. 构建完整保存路径
fullpath = fullfile(pathname, filename);

% 5. 准备要保存的变量(按用户要求命名)
Es = handles.Es(:)';        % 能量轴,确保为行向量
Imgstack = handles.nor_stack; % 归一化后的图像堆栈

% 6. 保存为 .mat 文件
save(fullpath, 'Es', 'Imgstack');

% 7. 提示Save Success
msg = sprintf('Normalized stack saved successfully to:\n%s', fullpath);
msgbox(msg, 'Save Success', 'help');
