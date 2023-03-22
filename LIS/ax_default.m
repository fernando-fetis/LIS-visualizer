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
