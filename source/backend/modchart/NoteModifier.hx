// @author Nebula_Zorua

package source.backend.modchart;

import source.backend.modchart.Modifier.ModifierType;

class NoteModifier extends source.backend.modchart.Modifier {
	override function getModType()
		return NOTE_MOD; // tells the mod manager to call this modifier when updating receptors/notes

}