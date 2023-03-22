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
n_entorno = [[5,5];[5,5]]; % (radios,cantidad).
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