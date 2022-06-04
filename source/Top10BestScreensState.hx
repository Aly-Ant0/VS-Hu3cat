package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.fxstate
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class Top10BestScreensState extends MusicBeatState
{
  //i love cum
  var bgcum:FlxSprite;
  var text:FlxSprite;
  override function create()
  {
    super.create();
    
    bgcum = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
    bgcum.screenCenter(XY);
    
    // coisas mt xd
    text = new FlxSprite().loadGraphic(Paths.image('text'));
    text.screenCenter(XY);
    
    add(bgcum);
    add(text);
  }
  override function update(elapsed:Float)
  {
    if (controls.ACCEPT) 
    {
      FlxG.sound.play(Paths.sound('confirmManu'));
      MusicBeatState.switchState(new TitleState());
    }
    super.update(elapsed);
  }
}
