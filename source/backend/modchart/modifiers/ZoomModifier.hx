package backend.modchart.modifiers;

import objects.playfields.NoteField;

class ZoomModifier extends source.backend.modchart.Modifier {
    override public function getName()return 'mini';

    override public function affectsField()return true; // tells the mod system to call this for playfield zooms

	override public function getFieldZoom(zoom:Float, beat:Float, songPos:Float, player:Int, field:NoteField)
	{
        if(getValue(player)!=0)
            zoom -= (0.5 * getValue(player));
        
        return zoom ;
	}
}