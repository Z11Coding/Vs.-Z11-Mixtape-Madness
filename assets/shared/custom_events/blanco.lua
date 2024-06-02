function onEvent(name, value1, value2)
  if name == 'blanco' then
        setProperty('theSky.visible',false);
        setProperty('theSky2.visible',true);
        setProperty('theGround.visible',true);
        setProperty('theHalfPipe.visible',true);
        setProperty('theHalfPipe2.visible',true);
end
end