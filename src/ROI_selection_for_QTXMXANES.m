function varargout = ROI_selection_for_QTXMXANES(varargin)
% ROI_SELECTION_FOR_QTXMXANES MATLAB code for ROI_selection_for_QTXMXANES.fig
%      ROI_SELECTION_FOR_QTXMXANES, by itself, creates a new ROI_SELECTION_FOR_QTXMXANES or raises the existing
%      singleton*.
%
%      H = ROI_SELECTION_FOR_QTXMXANES returns the handle to a new ROI_SELECTION_FOR_QTXMXANES or the handle to
%      the existing singleton*.
%
%      ROI_SELECTION_FOR_QTXMXANES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROI_SELECTION_FOR_QTXMXANES.M with the given input arguments.
%
%      ROI_SELECTION_FOR_QTXMXANES('Property','Value',...) creates a new ROI_SELECTION_FOR_QTXMXANES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ROI_selection_for_QTXMXANES_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ROI_selection_for_QTXMXANES_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ROI_selection_for_QTXMXANES

% Last Modified by GUIDE v2.5 02-Jun-2026 13:48:01

% Begin initialization code - DO NOT EDIT初始化代码
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ROI_selection_for_QTXMXANES_OpeningFcn, ...
    'gui_OutputFcn',  @ROI_selection_for_QTXMXANES_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT



% --- Executes just before ROI_selection_for_QTXMXANES is made visible.
% function ROI_selection_for_QTXMXANES_OpeningFcn(hObject, ~, handles, varargin)
% % This function has no output args, see OutputFcn.
% % hObject    handle to figure
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% % varargin   command line arguments to ROI_selection_for_QTXMXANES (see VARARGIN)
%
% % Choose default command line output for ROI_selection_for_QTXMXANES
% handles.output = hObject;
%
% % Update handles structure
% guidata(hObject, handles);
%
% global himg_in_ROIselectionforQTXMXANES;%全局保存当前图像句柄
% DiffImg=varargin{1};
% himg_in_ROIselectionforQTXMXANES=imshow(DiffImg,[],'Parent',handles.imgarea);
% set(handles.imgarea,'UserData',DiffImg);%imgarea显示差值图像，保存到UserData
% set(handles.min,'String',num2str(min(DiffImg(:))));
% set(handles.Threshold_Value,'String',num2str(min(DiffImg(:))));
% set(handles.max,'String',num2str(max(DiffImg(:))));
% set(handles.max,'UserData',(max(DiffImg(:))));
% set(handles.min,'UserData',(min(DiffImg(:))));
% set(handles.Realmax,'String',num2str(max(DiffImg(:))));
% set(handles.Realmin,'String',num2str(min(DiffImg(:))));%初始化输入框中的最大最小值，用于显示范围和阈值
% figure(handles.figure1); % 20250405修改，将当前 GUI 窗口置于最前端
% uiwait(handles.figure1); % 20250405修改，暂停并等待用户操作 ;
%
% % UIWAIT makes ROI_selection_for_QTXMXANES wait for user response (see UIRESUME)
% % uiwait(handles.figure1);
function ROI_selection_for_QTXMXANES_OpeningFcn(hObject, ~, handles, varargin)
% 处理输入参数
DiffImg = varargin{1};  % 获取第一个参数: 图像
savepath = varargin{2};  % 获取第二个参数: 保存路径（假设保存路径是第二个参数）

% 选择默认命令行输出
handles.output = hObject;

% 初始化图像
global himg_in_ROIselectionforQTXMXANES;
himg_in_ROIselectionforQTXMXANES = imshow(DiffImg, [], 'Parent', handles.imgarea);

% 更新 UserData
set(handles.imgarea, 'UserData', DiffImg);
set(handles.min, 'String', num2str(min(DiffImg(:))));
set(handles.Threshold_Value, 'String', num2str(min(DiffImg(:))));
set(handles.max, 'String', num2str(max(DiffImg(:))));
set(handles.max, 'UserData', (max(DiffImg(:))));
set(handles.min, 'UserData', (min(DiffImg(:))));
set(handles.Realmax, 'String', num2str(max(DiffImg(:))));
set(handles.Realmin, 'String', num2str(min(DiffImg(:))));  % 初始化输入框中的最大最小值

% 关于加载外部ROI_Mask
% 新增：用于外部Mask配准的字段
handles.useExtMask = false;      % 是否使用外部加载的Mask模式
handles.extMaskOriginal = [];    % 加载的原始Mask（未经平移）
handles.extMaskCurrent = [];     % 当前显示的Mask（经过平移）
handles.extMaskOffset = [0,0];   % 平移偏移量 [dx, dy]
handles.extMaskAxesClickEnabled = false;  % 标记是否启用了点击配准
handles.currentImg = DiffImg;

% 存储保存路径
handles.savepath = savepath;  % 存储路径到 handles 中

% 更新 handles 结构
guidata(hObject, handles);

% 将当前 GUI 窗口置于最前端
figure(handles.figure1);
uiwait(handles.figure1);  % 暂停并等待用户操作

% --- Outputs from this function are returned to the command line.
function varargout = ROI_selection_for_QTXMXANES_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
global ROImapOut;
varargout{1} = ROImapOut;%全局变量输出到命令行或者调用环境

% --- Executes on slider movement.
function Threshold_Callback(hObject, eventdata, handles)
% hObject    handle to Threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
realmax=get(handles.max,'UserData');
realmin=get(handles.min,'UserData');
CurThresholdValue=get(hObject,'Value');
CurThresholdValue=realmin+(realmax-realmin)*CurThresholdValue;
set(handles.Threshold_Value,'String',num2str(CurThresholdValue));
setappdata(0, 'CurThresholdValue', CurThresholdValue);
disp_img_in_ROIselectionforQTXMXANES(handles);%滑块的0-1值线性映射到真实阈值范围


% --- Executes during object creation, after setting all properties.
function Threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in Reset.
function Reset_Callback(~, eventdata, handles)
% hObject    handle to Reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles, 'useExtMask') && handles.useExtMask
    % 清除鼠标回调
    set(handles.figure1, 'WindowButtonDownFcn', '');
    set(handles.figure1, 'WindowButtonMotionFcn', '');
    set(handles.figure1, 'WindowButtonUpFcn', '');
    handles.useExtMask = false;
    handles.extMaskOriginal = [];
    handles.extMaskCurrent = [];
    handles.extMaskOffset = [0,0];
    handles.isDragging = false;
    % 重新启用阈值控件
    set(handles.Threshold, 'Enable', 'on');
    set(handles.Threshold_Value, 'Enable', 'on');
    set(handles.meadianfiltering_on_BinMap, 'Enable', 'on');
    set(handles.medianfiltering_value, 'Enable', 'on');
    set(handles.min, 'Enable', 'on');
    set(handles.max, 'Enable', 'on');
    % 刷新显示（恢复阈值模式）
    disp_img_in_ROIselectionforQTXMXANES(handles);
    guidata(gcbo, handles);
    return;
end
% 原有的Reset功能（阈值范围重置）
realmax = get(handles.max,'UserData');
realmin = get(handles.min,'UserData');
set(handles.min,'String',num2str(realmin));
set(handles.max,'String',num2str(realmax));
set(handles.Threshold_Value,'String',num2str(realmin));
set(handles.Threshold,'Value',0);
disp_img_in_ROIselectionforQTXMXANES(handles);

% --- Executes on button press in Submit.
function Submit_Callback(hObject, eventdata, handles)
% hObject    handle to Submit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global ROImapOut;

% 优先处理外部Mask模式
if isfield(handles, 'useExtMask') && handles.useExtMask
    BWmap = handles.extMaskCurrent;
    if isempty(BWmap)
        errordlg('当前没有有效的Mask，请重新加载或使用阈值模式。');
        return;
    end
    ROImapOut = BWmap;
    % 清理回调
    set(handles.figure1, 'WindowButtonDownFcn', '');
    set(handles.figure1, 'WindowButtonMotionFcn', '');
    set(handles.figure1, 'WindowButtonUpFcn', '');
    % 先恢复执行，再关闭窗口
    uiresume(handles.figure1);
    close(handles.figure1);
    return;
end

% 原有的阈值模式代码（保持不变）
BWmap = disp_img_in_ROIselectionforQTXMXANES(handles);
if isempty(BWmap)
    errordlg('未生成有效的Mask，请调整阈值后重试。');
    return;
end
handles.ROImapOut = BWmap;
handles.ThresholdValueStr = get(handles.Threshold_Value, 'String');
handles.Edit7Str = get(handles.medianfiltering_value, 'String');
guidata(hObject, handles);
set(handles.Submit,'UserData',BWmap);
ROImapOut = get(handles.Submit,'UserData');
uiresume(handles.figure1);
close(handles.figure1);
disp(['Submit时 Mask尺寸: ', num2str(size(handles.extMaskCurrent))]);
disp(['Submit时 Mask中1的个数: ', num2str(sum(handles.extMaskCurrent(:)))]);


function Threshold_Value_Callback(hObject, eventdata, handles)
% hObject    handle to Threshold_Value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Threshold_Value as text
%        str2double(get(hObject,'String')) returns contents of Threshold_Value as a double
realmin=get(handles.min,'UserData');
realmax=get(handles.max,'UserData');
CurThresholdValue=str2double(get(hObject,'String'));
if isnan(CurThresholdValue) || CurThresholdValue<realmin || CurThresholdValue>realmax
    CurThresholdValue=realmin;
end
set(hObject,'String',num2str(CurThresholdValue));
set(handles.Threshold,'Value',(CurThresholdValue-realmin)/(realmax-realmin));
disp(handles);
% setappdata(0, 'Threshold_Value', Threshold_Value);
disp_img_in_ROIselectionforQTXMXANES(handles);

% --- Executes during object creation, after setting all properties.
function Threshold_Value_CreateFcn(hObject, ~, ~)
% hObject    handle to Threshold_Value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function min_Callback(~, ~, handles)
% hObject    handle to min (see GCBO)disp_img_in_ROIselectionforQTXMXANES
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of min as text
%        str2double(get(hObject,'String')) returns contents of min as a double
shownMax=str2double(get(handles.max,'String'));
shownMin=str2double(get(handles.min,'String'));
realmin=get(handles.min,'UserData');
% realmax=get(handles.max,'UserData');
if isnan(shownMin) || shownMin<realmin || shownMin>=shownMax
    shownMin=realmin;
end
set(handles.min,'String',num2str(shownMin));
disp_img_in_ROIselectionforQTXMXANES(handles);



% --- Executes during object creation, after setting all properties.
function min_CreateFcn(hObject, ~, ~)
% hObject    handle to min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function max_Callback(hObject, eventdata, handles)
% hObject    handle to max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of max as text
%        str2double(get(hObject,'String')) returns contents of max as a double
shownMax=str2double(get(handles.max,'String'));
shownMin=str2double(get(handles.min,'String'));
% realmin=get(handles.min,'UserData');
realmax=get(handles.max,'UserData');
if isnan(shownMax) || shownMax>realmax || shownMax<=shownMin
    shownMax=realmax;
end
set(handles.max,'String',num2str(shownMax));
disp_img_in_ROIselectionforQTXMXANES(handles);

% --- Executes during object creation, after setting all properties.
function max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Realmin_Callback(hObject, eventdata, handles)
% hObject    handle to Realmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Realmin as text
%        str2double(get(hObject,'String')) returns contents of Realmin as a double


% --- Executes during object creation, after setting all properties.
function Realmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Realmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Realmax_Callback(hObject, eventdata, handles)
% hObject    handle to Realmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Realmax as text
%        str2double(get(hObject,'String')) returns contents of Realmax as a double


% --- Executes during object creation, after setting all properties.
function Realmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Realmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function meadianfiltering_on_BinMap_Callback(hObject, eventdata, handles)
% hObject    handle to meadianfiltering_on_BinMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

CurmedianfilteringValue = get(hObject,'Value');
set(handles.medianfiltering_value, 'String', num2str(CurmedianfilteringValue));
setappdata(0, 'CurmedianfilteringValue', CurmedianfilteringValue);
% 调用显示更新函数
disp_img_in_ROIselectionforQTXMXANES(handles);


% --- Executes during object creation, after setting all properties.
function meadianfiltering_on_BinMap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to meadianfiltering_on_BinMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function medianfilering_value_Callback(hObject, eventdata, handles)
% hObject    handle to medianfilering_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 提取最小值和最大值
realmin = get(handles.min,'UserData');  % 最小值
realmax = get(handles.max,'UserData');  % 最大值
CurmedianfilteringValue = str2double(get(hObject,'String'));
if isnan(CurmedianfilteringValue) || CurmedianfilteringValue<realmin || CurmedianfilteringValue>realmax
    CurmedianfilteringValue=realmin;
end
set(hObject, 'String', num2str(CurmedianfilteringValue)); % 更新滑块的值
set(handles.meadianfiltering_on_BinMap,'Value',(CurmedianfilteringValue-realmin)/(realmax-realmin));
handles.CurmedianfilteringValue = CurmedianfilteringValue;
guidata(hObject, handles);  % 更新 handles 结构
disp(handles);
disp_img_in_ROIselectionforQTXMXANES(handles);



% --- Executes during object creation, after setting all properties.
function medianfilering_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to medianfilering_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in medianfiltering_value.
function medianfiltering_value_Callback(hObject, eventdata, handles)
% hObject    handle to medianfiltering_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 从 handles 获取滑块控件句柄
sliderHandle = handles.meadianfiltering_on_BinMap;

% 检查滑块的 Min 和 Max 属性
minValue = get(sliderHandle, 'Min');
maxValue = get(sliderHandle, 'Max');

% 获取用户输入并将其转换为数字
CurmedianfilteringValue = str2double(strtrim(get(hObject, 'String'))); % 去掉空格


% 验证用户输入的有效性
if isnan(CurmedianfilteringValue) || CurmedianfilteringValue < minValue || CurmedianfilteringValue > maxValue
    % 用户输入无效，重置为最小值
    CurmedianfilteringValue = minValue;
    set(hObject, 'String', num2str(CurmedianfilteringValue));  % 更新文本框以反映有效值
    disp('输入的值不在范围内，重置为最小值。');
end

% 设置滑块的值
set(sliderHandle, 'Value', CurmedianfilteringValue);
% 存储当前中值滤波值到 handles


% 刷新显示图像
disp_img_in_ROIselectionforQTXMXANES(handles);


% --- Executes during object creation, after setting all properties.
function medianfiltering_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to medianfiltering_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function load_parameters_Callback(hObject, eventdata, handles)
[filename, pathname] = uigetfile('*.txt', '选择参数文件');
if isequal(filename, 0) || isequal(pathname, 0)
    return;
end
fullpath = fullfile(pathname, filename);

fileID = fopen(fullpath, 'r');
if fileID == -1
    errordlg('无法打开txt文件读取！');
    return;
end

params = struct();
while ~feof(fileID)
    line = fgetl(fileID);
    disp(['读取到一行: ', line]);
    if contains(line, 'CurThresholdValue')
        value = extract_number(line);
        disp(['匹配CurThresholdValue, 提取到: ', num2str(value)]);
        params.CurThresholdValue = value;
    elseif contains(line, 'CurmedianfilteringValue')
        value = extract_number(line);
        disp(['匹配CurmedianfilteringValue, 提取到: ', num2str(value)]);
        params.CurmedianfilteringValue = value;
    end
end
fclose(fileID);

% 阈值滑块部分
if isfield(params, 'CurThresholdValue') && isscalar(params.CurThresholdValue)
    slider_min = get(handles.Threshold, 'Min');
    slider_max = get(handles.Threshold, 'Max');
    value = params.CurThresholdValue;
    disp('-------- [DEBUG] 阈值参数赋值 --------');
    disp(['slider_min = ', num2str(slider_min)]);
    disp(['slider_max = ', num2str(slider_max)]);
    disp(['txt参数 value_orig = ', num2str(value)]);

    value = max(slider_min, min(slider_max, value));
    disp(['实际赋值（裁剪后）value = ', num2str(value)]);
    set(handles.Threshold_Value, 'String', num2str(value));
    sliderValue = (value - slider_min) / (slider_max - slider_min);
    disp(['归一化后 sliderValue = ', num2str(sliderValue)]);
    sliderValue = max(0, min(1, sliderValue));
    set(handles.Threshold, 'Value', sliderValue);
else
    errordlg('CurThresholdValue参数无效，请确保它是标量');
end

% 中值滤波滑块部分
if isfield(params, 'CurmedianfilteringValue') && isscalar(params.CurmedianfilteringValue)
    % 推荐：用slider自身的Min/Max；如果非标准slider，可用UserData手动维护
    medslider_min = get(handles.meadianfiltering_on_BinMap, 'Min');
    medslider_max = get(handles.meadianfiltering_on_BinMap, 'Max');
    value = params.CurmedianfilteringValue;
    disp('-------- [DEBUG] 中值滤波参数赋值 --------');
    disp(['medslider_min = ', num2str(medslider_min)]);
    disp(['medslider_max = ', num2str(medslider_max)]);
    disp(['txt参数 value_orig = ', num2str(value)]);

    value = max(medslider_min, min(medslider_max, value));
    disp(['实际赋值（裁剪后）value = ', num2str(value)]);
    set(handles.medianfiltering_value, 'String', num2str(value));

    disp(['归一化后 sliderValue = ', num2str(value)]);
    value = max(0, min(1, value));
    set(handles.meadianfiltering_on_BinMap, 'Value', value);
else
    errordlg('CurmedianfilteringValue参数无效，请确保它是标量');
end

% 最后刷新显示和后续操作
disp_img_in_ROIselectionforQTXMXANES(handles);
setappdata(0, 'CurThresholdValue', params.CurThresholdValue);
setappdata(0, 'CurmedianfilteringValue', params.CurmedianfilteringValue);
Threshold_Callback(handles.Threshold, eventdata, handles);
meadianfiltering_on_BinMap_Callback(handles.meadianfiltering_on_BinMap, eventdata, handles);


% --- Executes on button press in Load_ROI_Mask.
function Load_ROI_Mask_Callback(hObject, eventdata, handles)
DiffImg = get(handles.imgarea, 'UserData');
if isempty(DiffImg)
    errordlg('未找到当前图像数据');
    return;
end
[f, p] = uigetfile('*.mat', '选择 ROI_Mask.mat');
if isequal(f,0); return; end
S = load(fullfile(p,f));
if ~isfield(S, 'mask')
    errordlg('文件中无 mask 变量');
    return;
end
loadedMask = S.mask;

% 尺寸调整（只裁剪/补零，不缩放）
imgSize = size(DiffImg);
if ~isequal(size(loadedMask), imgSize)
    loadedMask = resizeMaskByCropOrPad(loadedMask, imgSize);
end

handles.extMaskOriginal = loadedMask;
handles.extMaskCurrent = loadedMask;
handles.extMaskOffset = [0,0];
handles.useExtMask = true;

% 禁用阈值控件
set(handles.Threshold, 'Enable', 'off');
set(handles.Threshold_Value, 'Enable', 'off');
set(handles.meadianfiltering_on_BinMap, 'Enable', 'off');
set(handles.medianfiltering_value, 'Enable', 'off');
set(handles.min, 'Enable', 'off');
set(handles.max, 'Enable', 'off');

% 设置拖动状态
handles.isDragging = false;
handles.dragStartPoint = [0,0];
handles.dragStartOffset = [0,0];
guidata(hObject, handles);

% 设置窗口鼠标按下回调（拖动开始）
set(handles.figure1, 'WindowButtonDownFcn', @(src,evt) dragStartCallback(handles.figure1));

% 刷新显示
disp_img_in_ROIselectionforQTXMXANES(handles);
guidata(hObject, handles);

msgbox('外部Mask已加载。在图像区域内按住鼠标左键拖动即可平移Mask。', '操作说明', 'help');
disp(['原始Mask尺寸: ', num2str(size(loadedMask))]);
disp(['目标图像尺寸: ', num2str(imgSize)]);
loadedMask = resizeMaskByCropOrPad(loadedMask, imgSize);
disp(['调整后Mask尺寸: ', num2str(size(loadedMask))]);

% --------------------------------------------------------------------
function dragStartCallback(figHandle)
handles = guidata(figHandle);
if ~handles.useExtMask
    return;
end
ax = handles.imgarea;
cp = get(ax, 'CurrentPoint');
x = cp(1,1); y = cp(1,2);
xlims = get(ax, 'XLim'); ylims = get(ax, 'YLim');
if x < xlims(1) || x > xlims(2) || y < ylims(1) || y > ylims(2)
    return;
end
startX = round(x); startY = round(y);
handles.dragStartPoint = [startX, startY];
handles.dragStartOffset = handles.extMaskOffset;
handles.isDragging = true;
guidata(figHandle, handles);

set(figHandle, 'WindowButtonMotionFcn', @(src,evt) dragMotionCallback(figHandle));
set(figHandle, 'WindowButtonUpFcn', @(src,evt) dragEndCallback(figHandle));

% --------------------------------------------------------------------
function dragMotionCallback(figHandle)
handles = guidata(figHandle);
if ~handles.isDragging
    return;
end
ax = handles.imgarea;
cp = get(ax, 'CurrentPoint');
x = cp(1,1); y = cp(1,2);
xlims = get(ax, 'XLim'); ylims = get(ax, 'YLim');
if x < xlims(1) || x > xlims(2) || y < ylims(1) || y > ylims(2)
    return;
end
currentX = round(x); currentY = round(y);
dx = currentX - handles.dragStartPoint(1);
dy = currentY - handles.dragStartPoint(2);
newOffsetX = handles.dragStartOffset(1) + dx;
newOffsetY = handles.dragStartOffset(2) + dy;

% 使用 imtranslate 平移，移出部分填充0，输出尺寸自动与原图像一致
newMask = imtranslate(handles.extMaskOriginal, [newOffsetX, newOffsetY], 'FillValues', 1);
if any(newMask(:))
    handles.extMaskCurrent = newMask;
    handles.extMaskOffset = [newOffsetX, newOffsetY];
    disp_img_in_ROIselectionforQTXMXANES(handles);
    guidata(figHandle, handles);
end


% --------------------------------------------------------------------
function dragEndCallback(figHandle)
handles = guidata(figHandle);
handles.isDragging = false;
guidata(figHandle, handles);
set(figHandle, 'WindowButtonMotionFcn', '');
set(figHandle, 'WindowButtonUpFcn', '');


% --------------------------------------------------------------------
function resizedMask = resizeMaskByCropOrPad(mask, targetSize)
% 中心裁剪或补零，不缩放
[h, w] = size(mask);
targetRows = targetSize(1);
targetCols = targetSize(2);
resizedMask = false(targetRows, targetCols);

targetRowStart = max(1, floor((targetRows - h) / 2) + 1);
targetColStart = max(1, floor((targetCols - w) / 2) + 1);
targetRowEnd = targetRowStart + h - 1;
targetColEnd = targetColStart + w - 1;

srcRowStart = 1; srcRowEnd = h;
srcColStart = 1; srcColEnd = w;

if targetRowStart < 1
    srcRowStart = 1 - targetRowStart + 1;
    targetRowStart = 1;
end
if targetColStart < 1
    srcColStart = 1 - targetColStart + 1;
    targetColStart = 1;
end
if targetRowEnd > targetRows
    srcRowEnd = srcRowEnd - (targetRowEnd - targetRows);
    targetRowEnd = targetRows;
end
if targetColEnd > targetCols
    srcColEnd = srcColEnd - (targetColEnd - targetCols);
    targetColEnd = targetCols;
end

if srcRowStart <= srcRowEnd && srcColStart <= srcColEnd && ...
        targetRowStart <= targetRowEnd && targetColStart <= targetColEnd
    resizedMask(targetRowStart:targetRowEnd, targetColStart:targetColEnd) = ...
        mask(srcRowStart:srcRowEnd, srcColStart:srcColEnd);
end


% 注意：原有的 applyExtMaskTranslation 函数已删除，因为未使用且带边界限制。
% 所有平移逻辑直接由 dragMotionCallback 中的 imtranslate 实现。
