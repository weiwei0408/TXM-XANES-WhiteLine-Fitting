
function disp_img_in_ImgViewer(handles)
   img = handles.img;
    % 检查图像是否有效
    if isempty(img)
        errordlg('没有找到任何图像数据！', '错误');
        return;
    end    
  
    % 检查图像维度（允许单通道灰度图像或 RGB 图像）
%     if ~ismatrix(img) && (ndims(img) ~= 3 || size(img, 3) ~= 3)
%         error('传入的图像必须是二维灰度图像或 RGB 图像（三个通道）。');
%     end
   % 检查图像维度（允许二维灰度图像或 RGB 三通道图像）
   if ismatrix(img)
       % 二维灰度图像，直接使用
       is_rgb = false;
   elseif ndims(img) == 3 && size(img, 3) == 3
       % RGB 三通道图像
       is_rgb = true;
   else
       error('传入的图像必须是二维灰度图像或 RGB 图像（三个通道）。当前维度: %d，大小: %s', ...
           ndims(img), mat2str(size(img)));
   end
    

    % 从 UI 控件读取阈值
    Tlow = str2double(get(handles.Threshold_low, 'String')); % 读取低阈值
    Thigh = str2double(get(handles.Threshold_high, 'String')); % 读取高阈值
%     set(handles.ShowndataWindow_low, 'String',num2str(Tlow));
%     set(handles.ShowndataWindow_high, 'String', num2str(Thigh));

    % 在阈值范围内进行处理
    img(img < Tlow) = Tlow; 
    img(img > Thigh) = Thigh;
    
    % 读取显示需要的参数
    ShowLow = str2double(get(handles.ShowndataWindow_low, 'String'));
    ShowHigh = str2double(get(handles.ShowndataWindow_high, 'String')); 
    
    % 设置坐标轴
    axes(handles.imgarea);  % 设置当前坐标轴为 imgarea
    imshow(img, [ShowLow, ShowHigh], 'Parent', handles.imgarea); 
   
%     caxis([ShowLow, ShowHigh]);
    % 获取并设置色表
    colormapp = get(handles.ColorMaps, 'String'); 
    colormapp = colormapp{get(handles.ColorMaps, 'Value')};
    colormap(colormapp); 
    set(gca, 'Color', 'k');  % NaN区域显示为黑色
    hold(handles.imgarea, 'on'); % 保持坐标轴，确保后续绘制在上方

%     % 处理 POI 交互
%     hMainFig = findobj('Type', 'figure', 'Name', 'QuickTXMXANES'); 
%     mainHandles = guidata(hMainFig); 
% 
%     if get(mainHandles.PlotforPOI, 'Value') == 1 % 激活 PlotforPOI 按钮
%         set(hImgarea, 'ButtonDownFcn', @Start_to_markPOI_in_ImgViewer_peak); % 设置点击回调
%     else
%         set(hImgarea, 'ButtonDownFcn', []); % 取消POI事件
%     end
% 
%     % POI 绘制逻辑
%     hMarkPOI = findobj(hMainFig, 'Tag', 'MarkPOI'); % 找到标记 POI 的控件  
%     POI = get(hMarkPOI, 'UserData'); % 从 UserData 中读取兴趣点坐标
% 
%     lineLen = round(max(size(img)) / 100); % 增加十字光标
%     dataForListBox = {}; % 创建列表框字符串的 Cell 数组
% 
%     % 绘制 POI 十字光标并更新列表框内容
%     for ii = 1:size(POI, 1)
%         y = POI(ii, 1);
%         x = POI(ii, 2);
%         
%         % 设置颜色
%         color_str = getColorString(ii); % 获取颜色
% 
%         % 绘制十字光标
%         line([x - lineLen, x + lineLen], [y, y], 'Color', color_str, 'LineWidth', 2); 
%         line([x, x], [y - lineLen, y + lineLen], 'Color', color_str, 'LineWidth', 2); % 绘制像素点
% 
%         % 获取图像值
%         if ndims(img) == 3  % RGB 图像
%             val = img(y, x, 1); % 假设从 RGB 图像的红色通道获取值
%         else  % 灰度图像
%             val = img(y, x);
%         end
% 
%         % 从 diffimg 提取灰度值
%         if ismatrix(diffimg) || (ndims(diffimg) == 3 && size(diffimg, 3) == 1)
%             val_diff = diffimg(y, x); % 跳高值
%         else
%             val_diff = diffimg(y, x, 1);  
%         end
% 
%         % 拼接数据以供列表框使用
%         entry = sprintf('(%d, %d) - Peak: %.2f, Jump: %.2f', x, y, val, val_diff);
%         dataForListBox{end + 1} = entry; % Append to the cell array
%     end
% 
%     % 设置或更新列表框内容
%     set(handles.listbox2, 'String', dataForListBox); % 更新列表框内容
end

% function color_str = getColorString(index)
%     % 根据索引返回不同颜色
%     switch index
%         case 1
%             color_str = 'r';
%         case 2
%             color_str = 'g';
%         case 3
%             color_str = 'b';
%         case 4
%             color_str = 'c';
%         case 5
%             color_str = 'm';
%         case 6
%             color_str = 'y';
%         case 7
%             color_str = 'k';
%         otherwise
%             color_str = 'k'; % 默认是黑色
%     end
% end
% function disp_img_in_ImgViewer(~,handles)
%     % 从控件读取图像
%     img = get(handles.Browse, 'UserData'); 
% 
%     % 检查图像是否有效
%     if isempty(img)
%         errordlg('没有找到任何图像数据！', '错误');
%         return;
%     end
% 
%     % 从 handles 获取 diffimg
%     if isfield(handles, 'diffimg')
%         diffimg = handles.diffimg;  % 获取 diffimg
%     else
%         errordlg('Diff image data is not set in handles.', '错误');  % 报错处理
%         return;
%     end
% 
%     % 检查图像维度
%     if ndims(img) ~= 3 || size(img, 3) ~= 3
%         error('传入的图像必须是 RGB 图像（三个通道）。');
%     end
% 
%     % 从 UI 控件读取阈值
%     Tlow = str2double(get(handles.Threshold_low, 'String')); % 读取低阈值
%     Thigh = str2double(get(handles.Threshold_high, 'String')); % 读取高阈值
% 
%     % 在阈值范围内进行处理
%     img(img < Tlow) = Tlow; 
%     img(img > Thigh) = Thigh;
% 
%     % 读取显示需要的参数
%     ShowLow = str2double(get(handles.ShowndataWindow_low, 'String'));
%     ShowHigh = str2double(get(handles.ShowndataWindow_high, 'String')); 
% 
%     % 获取并设置色表
%     colormapp = get(handles.ColorMaps, 'String'); 
%     colormapp = colormapp{get(handles.ColorMaps, 'Value')};
%     colormapp = colormap(colormapp); 
% 
%     % 设置坐标轴
%     axes(handles.imgarea);  % 设置当前坐标轴为 imgarea
%     hImgarea = imshow(img, [ShowLow, ShowHigh], 'Parent', handles.imgarea); 
% 
%     hold(handles.imgarea, 'on'); % 保持坐标轴，确保后续绘制在上方
% 
%     % 处理 POI 交互
%     hMainFig = findobj('Type', 'figure', 'Name', 'QuickTXMXANES'); 
%     mainHandles = guidata(hMainFig); 
% 
%     if get(mainHandles.PlotforPOI, 'Value') == 1 % 激活 PlotforPOI 按钮
%         set(hImgarea, 'ButtonDownFcn', @Start_to_markPOI_in_ImgViewer); % 设置点击回调
%     else
%         set(hImgarea, 'ButtonDownFcn', []); % 取消POI事件
%     end
% 
%     % POI 绘制逻辑
%     hMarkPOI = findobj(hMainFig, 'Tag', 'MarkPOI'); % 找到标记 POI 的控件  
%     POI = get(hMarkPOI, 'UserData'); % 从 UserData 中读取兴趣点坐标
% 
%     lineLen = round(max(size(img)) / 100); % 增加十字光标
%     dataForListBox = {}; % 创建列表框字符串的 Cell 数组
% 
%     % 绘制 POI 十字光标并更新列表框内容
%     for ii = 1:size(POI, 1)
%         y = POI(ii, 1);
%         x = POI(ii, 2);
% 
%         % 设置颜色
%         color_str = getColorString(ii); % 获取颜色
% 
%         % 绘制十字光标
%         line([x - lineLen, x + lineLen], [y, y], 'Color', color_str, 'LineWidth', 2); 
%         line([x, x], [y - lineLen, y + lineLen], 'Color', color_str, 'LineWidth', 2); % 绘制像素点
% 
%         % 获取白线峰值
%         val = img(y, x, 1); % 假设从 RGB 图像的红色通道获取值
% 
%         % 从 diffimg 提取灰度值
%         if ndims(diffimg) == 2 || (ndims(diffimg) == 3 && size(diffimg, 3) == 1)
%             val_diff = diffimg(y, x); % 跳高值
%         else
%             val_diff = diffimg(y, x, 1);  
%         end
% 
%         % 拼接数据以供列表框使用
%         entry = sprintf('(%d, %d) - Peak: %.2f, Jump: %.2f', x, y, val, val_diff);
%         dataForListBox{end + 1} = entry; % Append to the cell array
%     end
% 
%     % 设置或更新列表框内容
%     set(handles.listbox2, 'String', dataForListBox); % 更新列表框内容
% end
% 
% function color_str = getColorString(index)
%     % 根据索引返回不同颜色
%     switch index
%         case 1
%             color_str = 'r';
%         case 2
%             color_str = 'g';
%         case 3
%             color_str = 'b';
%         case 4
%             color_str = 'c';
%         case 5
%             color_str = 'm';
%         case 6
%             color_str = 'y';
%         case 7
%             color_str = 'k';
%         otherwise
%             color_str = 'k'; % 默认是黑色
%     end
% end
