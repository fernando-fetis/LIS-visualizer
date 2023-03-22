function button_z_click(~,~)
global XXX YYY ZZZ VXXX VYYY VZZZ;
global ax;
global z_slider plano_nivel;
global label_pozos z_corriente;
global button_z button_z_stop;
global n_entorno;
global check_proy;
global z_curvas z_transparencia;
global cuadros_animacion;
set(button_z,'enable','off');
set(button_z_stop,'enable','on');
set(check_proy,'enable','on');
rot = get(ax, 'View');
%Animacion vista XY:
for i=0:1/cuadros_animacion:1 %comb. convexa.
    view([(1-i)*rot(1) 90*i + (1-i)*rot(2)]); %vista plana: view(0,90).
    pause(0.005)
end
set(label_pozos,'color','w');
set(plano_nivel,'FaceColor','interp','EdgeColor',[0,0.2,0.8],'FaceAlpha',1,'LineWidth',0.1);
%Lectura de coordenadas:
[click_x,click_y] = ginput(1);
rotate3d on
set (gcf, 'WindowButtonMotionFcn', @mouse_coord);
z_PX = linspace(click_x-n_entorno(1,1),click_x+n_entorno(1,1),n_entorno(2,1));
z_PY = linspace(click_y-n_entorno(1,2),click_y+n_entorno(1,2),n_entorno(2,2));
global z_px z_py z_pz;
[z_px,z_py,z_pz]=meshgrid(z_PX,z_PY,z_slider);
%Lineas de campo:
z_curvas = stream3(XXX,YYY,ZZZ,VXXX,VYYY,VZZZ,z_px,z_py,z_pz);
z_corriente = streamline(z_curvas);
set(z_corriente,'LineWidth',0.1,'LineStyle','-','Color','w');
%Animacion vista anterior:
set(plano_nivel,'FaceColor','interp','EdgeColor','none','FaceAlpha',1-z_transparencia);
for i=0:1/cuadros_animacion:1
    view([rot(1)*i rot(2)*i + (1-i)*90]);
    pause(0.005)
end
set(label_pozos,'color','k');
%Simulación:
z_curvas_vel = interpstreamspeed(XXX,YYY,ZZZ,VXXX,VYYY,VZZZ, z_curvas, 0.001);
streamparticles(z_curvas_vel,50,'Animate',10^6,'ParticleAlignment','on','MarkerFaceColor',[0.8,0.3,0.1]);
end
