function button_z_stop_click(~,~)
global ax;
global check_proy;
global button_z button_z_stop;
set(button_z_stop,'enable','off');
set(button_z,'enable','on');
set(check_proy,'enable','off');
set(check_proy,'value',0);
%Cleaning y redibujo:
cla(ax);
ax_default();
end
