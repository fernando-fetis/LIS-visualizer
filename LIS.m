global W;
global X Y Z VX VY VZ;
global XXX YYY ZZZ VXXX VYYY VZZZ;
global rapidez;
global z_slider;
global ax;
global coord_pozos;
global z_permeabilidad;
global button_z button_z_stop;
global text_coord;
global n_entorno;
global check_proy;
global z_transparencia;
global cuadros_animacion;
%------------------------ CONSTANTES ------------------------
coord_pozos = [-10  10;... %(Pozo,coordenadas).
                10  10;...
                10 -10;...
               -10 -10;...
                0   0];
z_permeabilidad = [24,54; 26,62; 25,61; 24,54; 25,54]; %(Pozo, [min_z,max_z]).
z_slider = 30; %mean(z_permeabilidad(5,:));
vista_inicial = [-10 25];
n_entorno = [[8,8];[8,8]]; % (radios,cantidad).
cuadros_animacion = 30;
z_transparencia = 0; %opaco < (0,1) < transparente.

%------------------------ DATA ------------------------
W=load('velocidades.out');
X=round(W(:,1));
Y=round(W(:,2));
Z=round(W(:,3));
VX=round(10^9*W(:,4));
VY=round(10^9*W(:,5));
VZ=round(10^9*W(:,6));
XXX=zeros(15,15,10);
YYY=zeros(15,15,10);
ZZZ=zeros(15,15,10);
VXXX=zeros(15,15,10);
VYYY=zeros(15,15,10);
VZZZ=zeros(15,15,10);
%Transf. a mashgrid:
for i=1:10
    I=i:10:2250;
    XX=reshape(X(I),15,15);
    YY=reshape(Y(I),15,15);
    ZZ=reshape(Z(I),15,15);
    XXX(:,:,i)=XX;
    YYY(:,:,i)=YY;
    ZZZ(:,:,i)=ZZ;
    VXX=reshape(VX(I),15,15);
    VYY=reshape(VY(I),15,15);
    VZZ=reshape(VZ(I),15,15);
    VXXX(:,:,i)=VXX;
    VYYY(:,:,i)=VYY;
    VZZZ(:,:,i)=VZZ;    
end
rapidez = sqrt(VXXX.^2 + VYYY.^2 + VZZZ.^2);
%------------------------ GUI ------------------------
f = figure('Units','Normalized','Position',[0.1,0.15,0.8,0.7],'Name','Simulacion');
ax = axes('Units','Normalized','Position',[.25 .1 .7 .8]);
hold on
rotate3d on
view(vista_inicial);
text_titulo = uicontrol('Style','text','Units','Normalized','Position',[0.22,0.92,0.75,0.06]);
set(text_titulo,'String','Simulacion LIS','FontSize',30);
%Visualizacion:
panel_visualizacion = uipanel('Units','Normalized','Position',[0.01,0.7,0.2,0.15],'Title','Visualizacion');
check_pozos = uicontrol(panel_visualizacion,'style','checkbox','Units','Normalized','Position',[0.1,0.6,0.8,0.4]);
set(check_pozos,'String','Mostrar pozos','Callback',{@check_pozos_click},'value',1);
check_contorno = uicontrol(panel_visualizacion,'style','checkbox','Units','Normalized','Position',[0.1,0.3,0.8,0.4]);
set(check_contorno,'String','Fijar curvas de nivel','Callback',{@check_contorno_click});
check_permeabilidad = uicontrol(panel_visualizacion,'style','checkbox','Units','Normalized','Position',[0.1,0,0.8,0.4]);
set(check_permeabilidad,'String','Mostrar zonas de permeabilidad','Callback',{@check_permeabilidad_click},'value',1);
%Simulacion entorno:
panel_z = uipanel('Units','Normalized','Position',[0.01 0.32 0.2 0.35],'Title','Simulacion en un entorno');
button_z = uicontrol(panel_z,'style','pushbutton','Units','Normalized','Position',[0.1,0.75,0.8,0.2]);
set(button_z,'String','Simular entorno','Callback',{@button_z_click});
button_z_stop = uicontrol(panel_z,'style','pushbutton','Units','Normalized','Position',[0.1,0.52,0.8,0.2]);         
set(button_z_stop,'String','Detener simulacion','Callback',{@button_z_stop_click},'enable','off');
check_proy = uicontrol(panel_z,'style','checkbox','Units','Normalized','Position',[0.14,0.4,0.8,0.1]);
set(check_proy,'String','Simulacion plana (proyectada)','Callback',{@check_proy_click},'enable','off');
%Coordenadas:
text_coord = zeros(1,3);
text_coord_fijo = zeros(1,3);
for i=1:3
    text_coord_fijo(i) = uicontrol(panel_z,'Style','text','Units','Normalized','Position',[0.18,0.25-i/10,0.5,0.2]);
    set(text_coord_fijo(i),'String','Coordenada','FontWeight','bold');
    text_coord(i) = uicontrol(panel_z,'Style','text','Units','Normalized','Position',[0.63,0.25-i/10,0.20,0.2],'String','-');                 
end
set(text_coord_fijo(1),'String','Coordenada X:');
set(text_coord_fijo(2),'String','Coordenada Y:');
set(text_coord_fijo(3),'String','Coordenada Z:');
set(text_coord(3),'String',z_slider);
%Slider plano:
slider_contorno = uicontrol('style','slide','units','normalized','position',[0.98,0.1,0.01,0.8]);
set(slider_contorno,'min',min(Z),'max',max(Z),'val',z_slider);
addlistener(slider_contorno ,'Value', 'PostSet', @control_slider_z);
%Slider transparencia:
slider_transparencia = uicontrol('style','slide','units','normalized','position',[0.01,0.25,0.2,0.02]);
set(slider_transparencia,'min',0,'max',100,'val',z_transparencia*100);
addlistener(slider_transparencia ,'Value', 'PostSet', @control_slider_transparencia);
text_transparencia = uicontrol('Style','text','Units','Normalized','Position',[0.01,0.28,0.2,0.03]);
set(text_transparencia,'String','Transparencia');
%Coordenadas actuales:
set (gcf, 'WindowButtonMotionFcn', @mouse_coord);
%Dibujo inicial:
ax_default()

function mouse_coord (~,~)
global text_coord;
coord = get (gca, 'CurrentPoint');
set(text_coord(1),'String',round(coord(1),2));
set(text_coord(2),'String',round(coord(2),2));
end

function check_permeabilidad_click(hObject,~,~)
global recta_permeabilidad;
check_value = get(hObject,'Value');
if check_value == 1
      for i=1:5
           set(recta_permeabilidad(i),'Visible','on');
      end
else
      for i=1:5
        set(recta_permeabilidad(i),'Visible','off');
      end
end
end

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

function check_pozos_click(hObject,~,~)
global label_pozos;
global recta_pozos;
check_value = get(hObject,'Value');
if check_value == 1
      for i=1:5
           set(label_pozos(i),'Visible','on');
           set(recta_pozos(i),'Visible','on');
      end
else
      for i=1:5
        set(label_pozos(i),'Visible','off');
        set(recta_pozos(i),'Visible','off');
      end
end
end

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

function control_slider_transparencia(~, eventdata)
global XXX YYY ZZZ rapidez;
global z_slider plano_nivel z_streamslice;
global text_coord;
global z_transparencia;
set(z_streamslice,'color','b');
z_transparencia = get(eventdata.AffectedObject, 'Value')/100;
%Actualización coord. y plano
set(text_coord(3),'String',round(z_slider,2));
set(plano_nivel,'Visible','off');
plano_nivel = slice(XXX,YYY,ZZZ,rapidez,[],[],z_slider);
set(plano_nivel,'FaceColor','interp','EdgeColor','none','FaceAlpha',1-z_transparencia);
end

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

function ax_default()
global XXX YYY ZZZ VXXX VYYY VZZZ;
global X Y Z;
global z_slider plano_nivel z_streamslice;
global rapidez coord_pozos;
global label_pozos recta_pozos recta_permeabilidad;
global z_permeabilidad z_transparencia;
%Pozos:
label_pozos = zeros(1,5);
recta_pozos = zeros(1,5);
recta_permeabilidad = zeros(1,5);
for i=1:5
    label_pozos(i) = text(coord_pozos(i,1),coord_pozos(i,2),max(Z)+10,strcat('Pozo',int2str(i)));
    set(label_pozos(i),'Color','k','FontWeight','Bold','HorizontalAlignment','Center');
    recta_pozos(i) = stem3(coord_pozos(i,1),coord_pozos(i,2),max(Z)+5);
    set(recta_pozos(i),'LineWidth',3,'LineStyle','-','Color',[0,0.4,0.7]);
    recta_permeabilidad(i) = line([coord_pozos(i,1) coord_pozos(i,1)],[coord_pozos(i,2) coord_pozos(i,2)],z_permeabilidad(i,:));
    set(recta_permeabilidad(i),'Color',[0 0.4 0.7],'LineWidth',6);
end
set(label_pozos(5),'String','Poyo de inyeccion');
set(recta_pozos(5),'Color','y');
set(recta_permeabilidad(5),'Color','y');
%Plano vertical:
plano_nivel = slice(XXX,YYY,ZZZ,rapidez,[],[],z_slider);
set(plano_nivel,'FaceColor','interp','EdgeColor','none','FaceAlpha',1-z_transparencia);
%Cubo exterior:
caja_grafico = slice(XXX,YYY,ZZZ,rapidez,[min(X),max(X)],[min(Y),max(Y)],[min(Z),max(Z)]);
%caja_grafico = slice(XXX,YYY,ZZZ,rapidez,[min(X),max(X)],max(Y),min(Z));
set(caja_grafico,'FaceColor','interp','EdgeColor','none','FaceAlpha',0.1);
%Contorno:
z_streamslice = streamslice(XXX,YYY,ZZZ,VXXX,VYYY,VZZZ,[],[],z_slider);
set(z_streamslice,'LineWidth',0.1,'LineStyle','-','Color','y','visible','off');
end
