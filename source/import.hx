
#if !macro

//Discord API
#if DISCORD_ALLOWED
import backend.Discord;
#end

#if desktop
import sys.thread.Thread;
#end

//Psych
#if LUA_ALLOWED
import llua.*;
import llua.Lua;
#end

#if ACHIEVEMENTS_ALLOWED
import backend.Achievements;
#end

#if sys
import sys.*;
import sys.io.*;
#elseif js
import js.html.*;
#end

import backend.Mods;
import backend.Paths;
import backend.Controls;
import backend.CoolUtil;
import backend.Conductor;
import backend.BaseStage;
import backend.Difficulty;
import backend.AudioThing;
import backend.ClientPrefs;
import backend.MusicBeatState;
import backend.MusicBeatSubstate;
import backend.CustomFadeTransition;
import backend.TransitionState;
import backend.ArtemisIntegration;
import backend.Language;

import backend.util.ColorUtil; //Thanks, Jack Bass. Very Cool
import backend.ui.*; //Psych-UI
import backend.*; //Everything Else


import objects.Note;
import objects.Alphabet;
import objects.BGSprite;
import objects.StrumNote;
import objects.HealthIcon;
import objects.NoteObject;

import states.PlayState;
import states.LoadingState;

#if flxanimate
import flxanimate.*;
import flxanimate.PsychFlxAnimate as FlxAnimate;
#end


import shaders.ColorSwap;

import backend.math.Vector3;

import backend.util.MemoryUtil;
import backend.Cursor;

//Window Stuff
import backend.window.Window;
import backend.window.WindowUtil;
import backend.window.WindowUtils;

//Flixel
import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.transition.FlxTransitionableState;

//Modcharting stuff
import objects.playfields.*;
import backend.modchart.*;
import backend.modchartalt.*;
import backend.modchartalt.modcharting.*;

import shop.*;

// import backend.modules.MathSolver;
import backend.modules.MathSolver2;
import backend.modules.ArrayToMapConverter;
import backend.modules.SoundLayer;
// import backend.modules.SoundGroup;
import backend.modules.Variable;
using HoldableVariable;
using DataStorage;
using backend.FNFC;
using backend.modules.EventFunc;
using backend.modules.Number;

using StringTools;
using backend.ChanceSelector;
using options.Toggle;
using IterSingle;

#if test
// import backend.TestState;
#end
// using BoolConcepts; WIP

#end