// script by subpurr [[discord: subpurrowo]]
// please do not use without credit.
// no explicit permission needed to use :3

final IGNORE_LIST:Bool = true; // if the list is outright ignored (default: true)
final BLACKLIST:Bool = false; // if the list acts as blacklist (default: false, only works when IGNORE_LIST is false)
final KAPI_LIST:StringMap<Array<String>> = [ // character variable names and possible characters they can be as a whitelist for kapi held
    'boyfriend' => ['KAPI', 'KAPI_ANGRY', 'yellow'],
    'dad' => ['KAPI', 'KAPI_ANGRY', 'yellow']
];

final IGNORE_TYPES:Bool = false; // if the note type is outright ignored (default: false)
final NOTE_TYPES:Array<String> = ['']; // accepted note types

function onCreatePost() {
    for (daNote in game.unspawnNotes) {
        daNote.extraData.set('kapiHeld', true); 
    }
    return;
}

function opponentNoteHitPre(note) {
    noteHitPre(note, 'dad');
    return;
}

function goodNoteHitPre(note) {
    noteHitPre(note, 'boyfriend');
    return;
}

function noteHitPre(note, char) {
    var character = note.gfNote ? game.gf : Reflect.getProperty(game, char);

    var curSection = PlayState.SONG.notes[curSection];
    var altAnim:String = (curSection != null &&
        curSection.altAnim && !curSection.gfSection) ? note.animSuffix : '-alt';

    var holdAnim:String = game.singAnimations[Std.int(Math.abs(Math.min(game.singAnimations.length-1, note.noteData)))] + altAnim + '-hold';

    // sightreadable, totally
    if (note.isSustainNote && !character.animation.exists(holdAnim) &&
        note.extraData.get('kapiHeld') && (IGNORE_TYPES || NOTE_TYPES.contains(note.noteType)) &&
        (IGNORE_LIST || BLACKLIST != KAPI_LIST.get(char).contains(character.curCharacter))) {
            note.noAnimation = true;
            character.holdTimer = 0;
    }
}