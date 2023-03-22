function mouse_coord (~,~)
global text_coord;
coord = get (gca, 'CurrentPoint');
set(text_coord(1),'String',round(coord(1),2));
set(text_coord(2),'String',round(coord(2),2));
end