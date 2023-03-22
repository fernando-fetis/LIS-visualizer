function control_slider_z(~, eventdata)
global XXX YYY ZZZ rapidez;
global z_slider plano_nivel z_streamslice;
global text_coord;
global z_transparencia;
set(z_streamslice,'color','b');
z_slider = get(eventdata.AffectedObject, 'Value');
%Actualización coord. y plano:
set(text_coord(3),'String',round(z_slider,2));
set(plano_nivel,'Visible','off');
plano_nivel = slice(XXX,YYY,ZZZ,rapidez,[],[],z_slider);
set(plano_nivel,'FaceColor','interp','EdgeColor','none','FaceAlpha',1-z_transparencia);
end
