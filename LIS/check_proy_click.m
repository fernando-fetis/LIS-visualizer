function check_proy_click(hObject,~,~)
global XXX YYY ZZZ VXXX VYYY VZZZ;
global ax;
global z_slider;
global z_curvas;
check_value = get(hObject,'Value');
%curva auxiliar:
z_curvas_proy = z_curvas;
if check_value == 1
    n_particulas = size(z_curvas_proy);
    %Proyeccion:
    for i=1:n_particulas(2)
    z_curvas_proy{i}(:,3)=z_slider*ones(size(z_curvas_proy{i}(:,3)));
    end
end
cla(ax);
ax_default();
z_corriente = streamline(z_curvas_proy);
set(z_corriente,'LineWidth',0.1,'LineStyle','-','Color','w');
z_curvas_proy_vel = interpstreamspeed(XXX,YYY,ZZZ,VXXX,VYYY,VZZZ, z_curvas_proy, 0.01);
streamparticles(z_curvas_proy_vel,50,'Animate',10^6,'ParticleAlignment','on','MarkerFaceColor',[0.8,0.3,0.1]);
end
