var spriteBreaker:ProxyField;
function onCreatePost()
{
    game.dadField.noteField.alpha = 0;
	game.dadField.noteField.scrollFactor.set(1, 1);
    
    spriteBreaker = new ProxyField(game.dadField.noteField);
	spriteBreaker.cameras = [game.camGame];
	spriteBreaker.scrollFactor.set(1,1);
    addBehindGF(spriteBreaker);
}