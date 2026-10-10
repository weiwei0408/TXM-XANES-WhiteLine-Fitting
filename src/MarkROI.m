function MarkROI(hObject, eventdata, handles)

global hImgOriginal;
hAxis = findobj(gcf,'Type','Axes');
point = get(hAxis,'CurrentPoint');    %获取鼠标点在坐标轴上的点
point = round(point(1,[2,1]));%鼠标点取整 
% size(point)
hROIButton=findobj(gcf,'Tag','ROIButton');
if isempty(get(hROIButton,'UserData'))
    set(hROIButton,'UserData',point);
else
    set(hROIButton,'UserData',[get(hROIButton,'UserData');point]);
end
imgshown=get(hImgOriginal,'CData');
line_length=min(round(size(imgshown)/100));
line([point(2),point(2)],[point(1)+line_length,point(1)-line_length],'Color','yellow','LineWidth',2);
line([point(2)+line_length,point(2)-line_length],[point(1),point(1)],'Color','yellow','LineWidth',2);

hCacheROI=findobj(gcf,'Tag','CacheROI');
set(hCacheROI,'Enable','on');