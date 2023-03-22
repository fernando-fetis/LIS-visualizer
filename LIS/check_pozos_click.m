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
