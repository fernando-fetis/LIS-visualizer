function check_contorno_click(hObject,~,~)
global XXX YYY ZZZ VXXX VYYY VZZZ;
global z_slider z_streamslice;
%Reiniciar curvas de nivel:
set(z_streamslice,'visible','off');
z_streamslice = streamslice(XXX,YYY,ZZZ,VXXX,VYYY,VZZZ,[],[],z_slider);
set(z_streamslice,'LineWidth',0.1,'LineStyle','-','Color','y','visible','off');
%Visible/oculto:
check_value = get(hObject,'Value');
if check_value == 1
    set(z_streamslice,'visible','on');
else
    set(z_streamslice,'visible','off');
end
end
