package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class GameOverSubstate extends MusicBeatSubstate
{
	public var boyfriend:Boyfriend;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;

	var stageSuffix:String = "";

	public static var characterName:String = 'bf';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';
	public static var thomasfala:String = 'huecat/banho1';
	public static var thomasrandom:Int;
	
	public static var mineGameOver:Bool = false;
	var redEfeito:FlxSprite;

	public static var instance:GameOverSubstate;

	public static function resetVariables() {
		characterName = 'bf';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
		mineGameOver = false;
	}

	override function create()
	{
		instance = this;
		PlayState.instance.callOnLuas('onGameOverStart', []);
		
		new FlxTimer().start(2, function(tmr:FlxTimer) {
			thomasrandom = FlxG.random.int( 1, 6);
		});

		super.create();
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float)
	{
		super();
		
		redEfeito = new FlxSprite(0, 0).loadGraphic(Paths.image('huecat/hehehehe'));
		redEfeito.scrollFactor.set();
		redEfeito.updateHitbox();
		redEfeito.visible = false;
		redEfeito.antialiasing = ClientPrefs.globalAntialiasing;
		//redEfeito.color = 0xFF7f22e3;
		add(redEfeito);
		
		PlayState.instance.setOnLuas('inGameOver', true);

		Conductor.songPosition = 0;

		if(!mineGameOver)
		{
			boyfriend = new Boyfriend(x, y, characterName);
			boyfriend.x += boyfriend.positionArray[0];
			boyfriend.y += boyfriend.positionArray[1];
		}
		else
		{
			boyfriend = new Boyfriend(-100, 0, characterName);
			boyfriend.scrollFactor.set();
			redEfeito.visible = true;
		}
		add(boyfriend);

		camFollow = new FlxPoint(boyfriend.getGraphicMidpoint().x, boyfriend.getGraphicMidpoint().y);

		FlxG.camera.flash(FlxColor.RED, 0.6);
		FlxTween.tween(FlxG.camera, {zoom: 1.1}, 0.6, {ease:FlxEase.expoOut});
		FlxG.sound.play(Paths.sound(deathSoundName));
		new FlxTimer().start(0.2, function(tmr:FlxTimer) {
			//FlxG.sound.play(Paths.sound(thomasfala));
			FlxG.sound.play(Paths.soundRandom('huecat/banho', 1, 6));
		});
		Conductor.changeBPM(140);
		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		boyfriend.playAnim('firstDeath');

		var exclude:Array<Int> = [];

		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		add(camFollowPos);
	}

	var isFollowingAlready:Bool = false;
	override function update(elapsed:Float)
	{
		/*
		if (thomasrandom == 1) {
			thomasfala = 'huecat/banho1';
		} else if (thomasrandom == 2) {
			thomasfala = 'huecat/banho2';
		} else if (thomasrandom == 3) {
			thomasfala = 'huecat/banho3';
		} else if (thomasrandom == 4) {
			thomasfala = 'huecat/banho4';
		} else if (thomasrandom == 5) {
			thomasfala = 'huecat/banho5';
		} else if (thomasrandom == 6) {
			thomasfala = 'huecat/banho6';
		}
		
		switch(thomasrandom)
		{
			case 1:
				thomasfala = 'huecat/banho1';
			case 2:
				thomasfala = 'huecat/banho2';
			case 3:
				thomasfala = 'huecat/banho3';
			case 4:
				thomasfala = 'huecat/banho4';
			case 5:
				thomasfala = 'huecat/banho5';
			case 6:
				thomasfala = 'huecat/banho6';
		}
		*/
	
		super.update(elapsed);

		PlayState.instance.callOnLuas('onUpdate', [elapsed]);
		if(updateCamera) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;

			if (PlayState.isStoryMode)
				MusicBeatState.switchState(new StoryMenuState());
			else
				MusicBeatState.switchState(new FreeplayState());

			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			PlayState.instance.callOnLuas('onGameOverConfirm', [false]);
		}

		if (boyfriend.animation.curAnim.name == 'firstDeath')
		{
			if(boyfriend.animation.curAnim.curFrame >= 12 && !isFollowingAlready)
			{
				FlxG.camera.follow(camFollowPos, LOCKON, 1);
				updateCamera = true;
				isFollowingAlready = true;
			}

			if (boyfriend.animation.curAnim.finished)
			{
				coolStartDeath();
				boyfriend.startedDeath = true;
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		PlayState.instance.callOnLuas('onUpdatePost', [elapsed]);
	}

	override function beatHit()
	{
		super.beatHit();

		//FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			boyfriend.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(endSoundName));
			FlxG.camera.flash(FlxColor.WHITE, 0.6);
			FlxTween.tween(FlxG.camera, {zoom: 0.9}, 0.6, {ease:FlxEase.expoOut});
			FlxTween.tween(redEfeito.scale, {x: 2, y: 2}, 0.6, {ease:FlxEase.expoOut});
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					MusicBeatState.resetState();
				});
			});
			PlayState.instance.callOnLuas('onGameOverConfirm', [true]);
		}
	}
}
