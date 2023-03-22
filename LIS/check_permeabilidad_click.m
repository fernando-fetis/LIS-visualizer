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
