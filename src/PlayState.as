package
{
	import adobe.utils.CustomActions;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.ui.ContextMenuClipboardItems;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	import flash.display.StageDisplayState;
	import org.flixel.*;
	import flash.utils.ByteArray;
	import org.flixel.system.FlxTile;
	
	import com.newgrounds.API;

	public class PlayState extends FlxState
	{
		[Embed(source="/data/HACHEA__.ttf", fontFamily="HACHEA", embedAsCFF="false")] 	public	var	HACHEA:String;
		[Embed(source = "data/placemap20.png")]	public var PlaceMap20:Class;
		[Embed(source = "data/worldmask.png")]	public var WorldMaskSprite:Class;
		[Embed(source = "data/ending.png")]	public var EndingSprite:Class;
		[Embed(source = "data/worldOverlaySmall.png")]	public var WorldOverlaySprite:Class;
		[Embed(source = "data/trickyMask.png")]	public var TrickyMaskSprite:Class;
		[Embed(source = "data/arrowKeys.png")]	public var ArrowKeysSprite:Class;
		
		
		[Embed(source = "data/activateDoor.mp3")]	public var ActivateDoorSound:Class;
		[Embed(source = "data/plantLand.mp3")]	public var PlantLandSound:Class;
		[Embed(source = "data/rotate.mp3")]	public var RotateSound:Class;
		[Embed(source = "data/screenFlash.mp3")]	public var ScreenFlashSound:Class;
		[Embed(source = "data/npcDie.mp3")]	public var NPCDieSound:Class;
		[Embed(source = "data/endingComplete.mp3")]	public var EndingCompleteSound:Class;
		[Embed(source = "data/gameRestarted.mp3")]	public var GameRestartedSound:Class;
		[Embed(source = "data/advanceQuest2.mp3")]	public var AdvanceQuestSound:Class;
		
		
		[Embed(source = "data/DayTheme-long.mp3")]	public var DayThemeLong:Class;
		[Embed(source = "data/NightTheme-long.mp3")]	public var NightThemeLong:Class;
		[Embed(source = "data/DayTheme-longslow.mp3")]	public var DayThemeLongSlow:Class;
		[Embed(source = "data/NightTheme-longslow.mp3")]	public var NightThemeLongSlow:Class;
		
		public var version:String = "v1.16n";
		
		public var DARKNESS_COLOR:uint = 0xff888888;
		
		public var DEBUG:Boolean = false;
		
		public var PLACEMAP_SCALE:int = 20;
		
		public static var instance:PlayState;
		
		private var lightPlayer:LightPlayer;
		private var darkPlayer:DarkPlayer;
		
		private var lightText:GameText;
		private var darkText:GameText;
		
		public var world:World;
		public var darkness:Darkness;
		public var darkCover:FlxSprite;
		
	public var CLEAN_FREQ:int = 1;
		public var cleanTime:Number = 0;
		
		public var startPoint:FlxPoint;

		
		public var cameraPoint:FlxSprite;
		
		public var cameraOffset:FlxPoint;
		
		public var camera:FlxCamera;
		
		public var tower:Tower;
		
		public var orbGlows:FlxGroup;
		public var invertGlows:FlxGroup;
		public var backgroundOrbs:FlxGroup;
		public var foregroundOrbs:FlxGroup;
		public var lightOrbHolders:FlxGroup
		public var darkOrbHolders:FlxGroup;
		public var players:FlxGroup;
		public var npcs:FlxGroup;
		public var objects:FlxGroup;
		public var fiends:FlxGroup;
		public var plants:FlxGroup;
		public var emitters:FlxGroup;
		public var gameSprites:FlxGroup;
		public var textFields:FlxGroup;
		public var endingTextFields:FlxGroup;
		public var finalInvertGlowLayer:FlxGroup;
		public var orbBeams:FlxGroup;
		public var superSecretEnding:FlxGroup;
		
		public var textPlayer:TextPlayer;
		
		public var seedLocations:Vector.<FlxPoint> = new Vector.<FlxPoint>();
		public var finalBeamLocations:Vector.<FlxPoint> = new Vector.<FlxPoint>();
		
		public var day:int = 0;
		
		public var endingGame:Boolean = false;
		public var finalEndingSequence:Boolean = false;
		public var finishedEndRotating:Boolean = false;
		public var endingState:int = 0;
		
		public static const END_ABANDON:int = 0;	// light activation
		public static const END_FLEE:int = 1;		// dark activation
		public static const END_MOURN:int = 2;	
		public static const END_EMBARK:int = 3;
		public static const END_TEND:int = 4;
		public static const END_WORSHIP:int = 5;
		public static const END_RESIGN:int = 6;
		//public static const END_SECRET:int = 7;
		public static const END_JUXTAPOSE:int = 7;
		public static const END_SQUANDER:int = 8;
		public static const END_CATALYZE:int = 9;
		public static const END_SOLACE:int = 10;
		public static const END_SOL:int = 11;
		public static const END_NYX:int = 12;
		
		public static const MAX_ENDINGS:int = 13;
		
		public var endingImage:FlxSprite;
		
		public var endings:Dictionary = new Dictionary();
		public var save:FlxSave;
		
		
		public var giveUpDarkness:FlxSprite;
		public var giveUpDarknessMaxAlpha:Number = 0;
		public var GIVE_UP_DARKNESS_ALPHA_INCREMENT:Number = .4;
		public var GIVE_UP_DARKNESS_ALPHA_FADE_RATE:Number = .5;
		
		public static var playedOnce:Boolean = false;
		
		public var feederTree:FeederTree;
		public var secretPedestal:SecretPedestal;
		
		public var endingSprites:FlxGroup;
		
		public var lastEndingUnlocked:int = -1;
		public var lastEndingColor:uint = ABANDON_COLOR;
		
		public var _shouldShowEndings:Boolean = false;
		public var readyToRestart:Boolean = false;
		
		public var waitingForSecret:Boolean = false;
		public var triggeredSecret:Boolean = false;
		public var startedEndingFade:Boolean = false;
		
		public var worldOverlay:FlxSprite;
		
		public var trickyMask:FlxSprite;
		
		public static var SFX_VOLUME:Number = .5;
		public static var MUSIC_VOLUME:Number = .5; 
		
		public var useAlternateMusic:Boolean = false;
		public var timeMHeld:Number = 0;
		
		public var titleText:GameText;
		public var zillixText:GameText;
		public var completeText:GameText;
		public var versionText:GameText;
		public var versionTimer:Number = 0;
		public var VERSION_TIME:Number = 5;
		
		public var hasStartedGame:Boolean = false;
		public var STARTING_ALPHA:Number = .85;
		public var controlsSprite:FlxSprite;
		
		public var invertFilter:FlxSprite;
		
		public var solaceQuestProgress:int = 0;
		public var solaceQuestStartState:int = -1;
		public static const SOLACE_COLOR_ORB:int = 2;
		public static const SOLACE_PRESENT_ORB:int = 3;
		
		public var nyxBeam:OrbBeam;
		public var solBeam:OrbBeam;
		
		public static var loggedInThisSession:Boolean = false;
		
		public static var escapedThisSession:Boolean = false;
		
		public static var consecutiveEndings:int = 0;
		
		public static const DEFAULT_TEXT_COLOR:uint = 0xffffffff;
		
		override public function create():void
		{
			instance = this;
			FlxG.bgColor = 0xff000000;
			
			// handles fullscreen
			var zKeyboard:ZKeyboard = new ZKeyboard();
			zKeyboard.fullscreenCallback = goFullScreen;
			zKeyboard.fullscreenName = "F";
			FlxG.keys = zKeyboard;
			
			
			super.create();
			
			API.logCustomEvent("game_load");
			
			
			giveUpDarknessMaxAlpha = STARTING_ALPHA;
			
			textPlayer = new TextPlayer();
			
			backgroundOrbs = new FlxGroup();
			foregroundOrbs = new FlxGroup();
			darkOrbHolders = new FlxGroup();
			lightOrbHolders = new FlxGroup();
			players = new FlxGroup();
			orbGlows = new FlxGroup();
			npcs = new FlxGroup();
			objects = new FlxGroup();
			fiends = new FlxGroup();
			plants = new FlxGroup();
			emitters = new FlxGroup();
			gameSprites = new FlxGroup();
			textFields = new FlxGroup();
			endingTextFields = new FlxGroup();
			endingSprites = new FlxGroup();
			invertGlows = new FlxGroup();
			finalInvertGlowLayer = new FlxGroup();
			orbBeams = new FlxGroup();
			superSecretEnding = new FlxGroup();
			
			FlxG.playMusic(useAlternateMusic ? DayThemeLong : DayThemeLongSlow, MUSIC_VOLUME);
			
			save = new FlxSave();
			var loaded:Boolean = save.bind("ZLD30");
			if (save.data.endings != null)
			{
				for (var ending:String in save.data.endings)
				{
					endings[ending] = true;
				}
			}
			if (save.data.inverted == true)
			{
				setupInvertFilter();
			}
			if (!loggedInThisSession)
			{
				loggedInThisSession = true;
				if (save.data.logins == null)
				{
					save.data.logins = 1;
				}
				else
				{
					save.data.logins = save.data.logins + 1;
				}
				
				var logins:int = save.data.logins;
				logIncrementalStat(logins, "login", [1,2,3,5,10]);
			}
			
			if (save.data.game_starts == null)
			{
				save.data.game_starts = 1;
			}
			else
			{
				save.data.game_starts = save.data.game_starts + 1;
			}
			var gameStarts:int = save.data.game_starts;
			logIncrementalStat(gameStarts, "game_start", [1,2,3,5,10]);
			
			world = new World(FlxG.width / 2, FlxG.height / 2);
			add(world);
			
			worldOverlay = new FlxSprite(FlxG.width / 2, FlxG.height / 2, WorldOverlaySprite);
			worldOverlay.scale.x = worldOverlay.scale.y = 2;
			worldOverlay.offset.x = worldOverlay.width / 2;
			worldOverlay.offset.y = worldOverlay.height / 2;
			add(worldOverlay);
			
			darkness = new Darkness(FlxG.width / 2, FlxG.height / 2);
			
			tower = new Tower(0, 0);
			add(darkOrbHolders);
			add(lightOrbHolders);
			lightOrbHolders.add(tower);
			darkOrbHolders.add(tower);
			
			add(orbGlows);
			add(backgroundOrbs);
			add(objects);
			add(gameSprites);
			add(plants);
		
			add(npcs);
			
			
			lightPlayer = new LightPlayer(FlxG.width / 2, FlxG.height / 2);
			add(lightPlayer);
			players.add(lightPlayer);
			
			darkPlayer = new DarkPlayer(FlxG.width / 2, FlxG.height / 2);
			add(darkPlayer);
			players.add(darkPlayer);
			
			trickyMask = new FlxSprite(World.MAX_DISTANCE + world.x + 8, world.y, TrickyMaskSprite);
			trickyMask.offset.y = trickyMask.height / 2;
			trickyMask.visible = false;
			add(trickyMask);
			
			cameraOffset = new FlxPoint(world.width / 2, world.height / 2);
			
			cameraPoint = new FlxSprite(FlxG.width / 2, FlxG.height / 2);
			cameraPoint.makeGraphic(2, 2, 0xffff0000);
			//add(cameraPoint);
			
			add(foregroundOrbs);
			add(emitters);
			
			add(fiends);
			
			add(orbBeams);
			
			add(invertGlows);
			
			add(finalInvertGlowLayer);
			
			
			add(darkness);
			
			endingImage = new FlxSprite(0, 0, EndingSprite);
			add(endingImage);
			endingImage.visible = false;
			
			
			darkCover = new FlxSprite(FlxG.width / 2, FlxG.height / 2, WorldMaskSprite);
			darkCover.offset.x = darkCover.width / 2;
			darkCover.offset.y = darkCover.height / 2;
			
			add(darkCover);
			
			
			add(superSecretEnding)
			
			// UI
			
			lightText = new GameText(World.LIGHT, world.x, 40, FlxG.width, "light", true);
			lightText.offset.x = lightText.width / 2;
			lightText.offset.y = lightText.height / 2;
			lightText.setFormat("HACHEA", 16, 0xffffffff, "center");
			lightText.shadow = 0xff888888;
			
			darkText = new GameText(World.DARK, world.x, FlxG.height - 20, FlxG.width, "here is some test dark text that is pretty long and just keeps going to see what it looks like");
			darkText.setFormat("HACHEA", 16, 0xffffffff, "center");
			darkText.shadow = 0xff888888;
			darkText.alpha = 0;
			
			textFields.add(darkText);
			textFields.add(lightText);
			add(textFields);
			
			giveUpDarkness = new FlxSprite(0, 0);
			giveUpDarkness.makeGraphic(FlxG.width, FlxG.height, 0xff000000);
			
			/*if (PlayState.playedOnce)
			{
				giveUpDarkness.alpha = 1;
			}
			else
			{
				giveUpDarkness.alpha = 0;
			}*/
			add(giveUpDarkness);
			
			add(endingSprites);
			add(endingTextFields);
			
			createEndingSprites();
			
			
			readMap(PLACEMAP_SCALE);
			
			PlayState.playedOnce = true;
			
			titleText = new GameText(World.BOTH, FlxG.width / 2, FlxG.height / 2 - 60, 400, "juxtapose", true);
			titleText.setFormat("HACHEA", 40, 0xffffff, "center");
			titleText.offset.x = titleText.width / 2;
			titleText.shadow = 0xff888888;
			add(titleText);
			
			if (countEndings >= MAX_ENDINGS)
			{
				completeText = new GameText(World.BOTH, FlxG.width / 2, 120, 400, "*complete*", true);
				completeText.setFormat("HACHEA", 10, 0xffffff, "center");
				completeText.offset.x = completeText.width / 2;
				completeText.shadow = 0xff888888;
				add(completeText);
			}
			
			
			zillixText = new GameText(World.BOTH, FlxG.width / 2, FlxG.height - 160, 100, "made by zillix", true);
			zillixText.setFormat("HACHEA", 16, 0xffffff, "center");
			zillixText.offset.x = zillixText.width / 2;
			zillixText.shadow = 0xff888888;
			add(zillixText);
			
			versionText = new GameText(World.BOTH, FlxG.width / 2, FlxG.height - 100, 100, version, true);
			versionText.setFormat("HACHEA", 10, 0xffffff, "center");
			versionText.offset.x = versionText.width / 2;
			versionText.shadow = 0xff888888;
			add(versionText);
			versionText.alpha = 0;
			
			controlsSprite = new FlxSprite(FlxG.width / 2, FlxG.height / 2 + 70, ArrowKeysSprite);
			controlsSprite.offset.x = controlsSprite.width / 2;
			controlsSprite.offset.y = controlsSprite.height / 2;
			controlsSprite.scale.x = controlsSprite.scale.y = 4;
			add(controlsSprite)
			
			//add(finalInvertGlowLayer);
			
			
			
		}
		
		public const ABANDON_COLOR:uint = 0xff160C62;
		public const FLEE_COLOR:uint = 0xffCDDA70;
		public const EMBARK_COLOR:uint = 0xff87CEEB;
		public const SECRET_COLOR:uint = 0xffDA5302;
		
		public static const ABANDON_TEXT:String = "abandon";
		public static const FLEE_TEXT:String = "flee";
		public static const MOURN_TEXT:String = "mourn";
		public static const EMBARK_TEXT:String = "embark";
		public static const TEND_TEXT:String = "tend";
		public static const WORSHIP_TEXT:String = "worship";
		public static const RESIGN_TEXT:String = "resign";
		public static const SQUANDER_TEXT:String = "squander";
		public static const CATALYZE_TEXT:String = "catalyze";
		public static const JUXTAPOSE_TEXT:String = "juxtapose";
		public static const SOLACE_TEXT:String = "solace";
		public static const NYX_TEXT:String = "shroud";
		public static const SOL_TEXT:String = "scorch";
		public function createEndingSprites() : void
		{
			var sprite:EndSprite;
			var endingCount:int = 13; //8;
			var angleFrac:Number = 360 / endingCount;
			var endingDist:Number = world.width / 2 + 60;
			sprite = new EndSprite(angleFrac * 0 - 90, endingDist, JUXTAPOSE_COLOR, JUXTAPOSE_TEXT,END_JUXTAPOSE, world);
			endingSprites.add(sprite);
			sprite = new EndSprite(angleFrac * 1 - 90, endingDist, ABANDON_COLOR, ABANDON_TEXT, END_ABANDON, world);
			endingSprites.add(sprite);
			sprite = new EndSprite(angleFrac * 2 - 90, endingDist, EMBARK_COLOR, EMBARK_TEXT, END_EMBARK, world);
			endingSprites.add(sprite);
			sprite = new EndSprite(angleFrac * 3 - 90, endingDist, FLEE_COLOR, FLEE_TEXT, END_FLEE, world);
			endingSprites.add(sprite);
			sprite = new EndSprite(angleFrac * 4 - 90, endingDist, MOURN_COLOR, MOURN_TEXT, END_MOURN, world);
			endingSprites.add(sprite);
			sprite = new EndSprite(angleFrac * 5 - 90, endingDist, RESIGN_COLOR, RESIGN_TEXT, END_RESIGN, world);
			endingSprites.add(sprite);
			sprite = new EndSprite(angleFrac * 6 - 90, endingDist, SQUANDER_COLOR, SQUANDER_TEXT, END_SQUANDER, world);
			endingSprites.add(sprite);
			sprite = new EndSprite(angleFrac * 7 - 90, endingDist, SECRET_COLOR, CATALYZE_TEXT, END_CATALYZE, world);
			endingSprites.add(sprite);
			sprite = new EndSprite(angleFrac * 8 - 90, endingDist, WORSHIP_COLOR, WORSHIP_TEXT, END_WORSHIP, world);
			endingSprites.add(sprite);
			sprite = new EndSprite(angleFrac * 9 - 90, endingDist, TEND_COLOR, TEND_TEXT, END_TEND, world);
			endingSprites.add(sprite);
			sprite = new EndSprite(angleFrac * 10 - 90, endingDist, SOLACE_COLOR, SOLACE_TEXT, END_SOLACE, world);
			endingSprites.add(sprite);
			sprite = new EndSprite(angleFrac * 11 - 90, endingDist, SOL_COLOR, SOL_TEXT, END_SOL, world);
			endingSprites.add(sprite);
			sprite = new EndSprite(angleFrac * 12 - 90, endingDist, NYX_COLOR, NYX_TEXT, END_NYX, world);
			endingSprites.add(sprite);
			
			
		}
		
		public static function toRadians(ang:Number):Number
		{
			return Math.PI * ang / 180.0;
		}
		
		public static function getDistance(X:Number, Y:Number, A:Number, B:Number):Number
		{
			return Math.sqrt(Math.pow(X - A, 2) + Math.pow(Y - B, 2));
		}
		
		public function killGroup(gr:FlxGroup):void 
		{
			if (gr != null && gr.members.length > 0)
			for each(var obj:FlxObject in gr.members)
			{
				obj.kill();
				obj.exists = false;
			}
		}
		
		public function cleanGroup(gr:FlxGroup):void 
		{
			if (gr != null && gr.members.length > 0)
			for (var i:int = gr.members.length - 1; i >= 0; i--)
			{
				var obj:FlxObject = gr.members[i] as FlxObject;
				if (obj && !obj.alive)
				gr.members.splice(i,1);
			}
		}
		
		public function runCamera() : void
		{
			/*var offsetAngle:Number = FlxU.getAngle(new FlxPoint(), cameraOffset);
			offsetAngle += player.angle;
			var offsetDist:Number = Math.sqrt(Math.pow(cameraOffset.x, 2) + Math.pow(cameraOffset.y, 2));
			var newPoint:FlxPoint = new FlxPoint(player.x + offsetDist * Math.cos(toRadians(90+offsetAngle)), player.y + offsetDist * Math.sin(toRadians(90+offsetAngle)));
			
			cameraPoint.x = newPoint.x;
			cameraPoint.y = newPoint.y;*/
			
			cameraPoint.x = world.x;
			cameraPoint.y = world.y;
			
			FlxG.camera.follow(cameraPoint);
			FlxG.camera.angle = world.worldAngle;
		}
		
		public function get state() : int
		{
			if (world != null)
			{
				return world.state;
			}
			
			return World.LIGHT;
		}
		
		override public function update():void
		{
			super.update();	
			
			runCamera();
			
			checkHolderOverlap(darkPlayer, darkOrbHolders);
			checkHolderOverlap(lightPlayer, lightOrbHolders);
			checkNPCOverlap(players, npcs);
			checkPlantOverlap(players, plants);
			checkBeamOverlap(players, orbBeams);
			
			textPlayer.update();
			lightText.text = textPlayer.currentText;
			darkText.text = textPlayer.currentText;
			lightText.color = textPlayer.currentColor;
			darkText.color = textPlayer.currentColor;
			if (textPlayer.currentText == "")
			{
				lightText.alpha = 0;
				darkText.alpha = 0;
			}
			
			updateEnd();
			
			if (FlxG.keys.M)
			{
				timeMHeld += FlxG.elapsed;
			}
			if (timeMHeld > 2)
			{
				useAlternateMusic = true;
			}
			
			if (!hasStartedGame)
			{
				if (FlxG.keys.any())
				{
					hasStartedGame = true;
					giveUpDarknessMaxAlpha = 0;
				}
			}
			
			
			if (hasStartedGame)
			{
				zillixText.alpha -= FlxG.elapsed;
				titleText.alpha -= FlxG.elapsed;
				controlsSprite.alpha -= FlxG.elapsed;
				versionText.alpha -= FlxG.elapsed;
				if (completeText != null)
				{
					completeText.alpha -= FlxG.elapsed;
				}
			}
			else
			{
				versionTimer += FlxG.elapsed;
				if (versionTimer >= VERSION_TIME)
				{
					versionText.alpha += FlxG.elapsed;
				}
				//titleText.angle = -world.worldAngle;
			}
			
			if (DEBUG)
			{
				if (FlxG.keys.justPressed("B"))
				{
					restartGame();
				}
				if (FlxG.keys.justPressed("U"))
				{
					onMachineActivated(World.LIGHT);
				}
				if (FlxG.keys.justPressed("I"))
				{
					onMachineActivated(World.DARK);
				}
				if (FlxG.keys.justPressed("P"))
				{
					onMachineActivated(World.BOTH);
				}
				if (FlxG.keys.justPressed("Y"))
				{
					onMourn();
				}
				if (FlxG.keys.justPressed("H"))
				{
					onTend();
				}
				if (FlxG.keys.justPressed("G"))
				{
					onWorship();
				}
				if (FlxG.keys.justPressed("V"))
				{
					onMachineActivated(World.DARK);
				}
				if (FlxG.keys.justPressed("W"))
				{
					world.setTargetEnding(getEnding(END_TEND));
				}
				if (FlxG.keys.justPressed("D"))
				{
					save.erase();
				}
				if (FlxG.keys.justPressed("A"))
				{
					unlockEnding(END_ABANDON);
					unlockEnding(END_FLEE);
					unlockEnding(END_MOURN);
					unlockEnding(END_EMBARK);
					unlockEnding(END_TEND);
					unlockEnding(END_WORSHIP);
					unlockEnding(END_RESIGN);
					unlockEnding(END_CATALYZE);
					unlockEnding(END_JUXTAPOSE);
					unlockEnding(END_SQUANDER);
					unlockEnding(END_SOL);
					unlockEnding(END_NYX);
				}
				if (FlxG.keys.justPressed("Q"))
				{
					spawnSeed(0);
				}
				if (FlxG.keys.justPressed("S"))
				{
					for each (var plant:Plant in plants.members)
					{
						plant.grow();
					}
				}
				if (FlxG.keys.justPressed("E"))
				{
					triggerNyxEnding();
				}
			}
			
			if (FlxG.keys.any() && readyToRestart)
			{
				restartGame();
			}
			
			/*if (FlxG.keys.justPressed("F"))
			{
				if (FlxG.stage.displayState == StageDisplayState.NORMAL)
				{
					goFullScreen();
				}
				/*else
				{
					goNormalScreen();
				}*/
			//}
			
			if (FlxG.keys.pressed("R"))
			{
				giveUpDarkness.alpha += .5 * FlxG.elapsed;
				if (giveUpDarkness.alpha >= 1 && !endingGame)
				{
					endingGame = true;
					giveUpDarknessMaxAlpha = 1;
					
					API.unlockMedal("restart");
				}
			}
			
			/*if (finishedEndRotating && state == World.BOTH)
			{
				giveUpDarknessMaxAlpha = 1;
			}*/
			var play:Player = getMyPlayer(state);
	
			if (play.fading && play.alpha == 0 && state == play.state && finishedEndRotating)
			{
				world.nextState();
			}
			
			if (giveUpDarkness.alpha < giveUpDarknessMaxAlpha && giveUpDarkness.alpha < 1)
			{
				giveUpDarkness.alpha = Math.min(giveUpDarknessMaxAlpha, giveUpDarkness.alpha + FlxG.elapsed * GIVE_UP_DARKNESS_ALPHA_FADE_RATE);
			}
			if (giveUpDarkness.alpha == 1 && endingGame && !startedEndingFade)
			{
				startedEndingFade = true;
				FlxG.camera.fade(0xff000000, 2, onEndingFade);
			}
			
			if (giveUpDarkness.alpha > giveUpDarknessMaxAlpha && !FlxG.keys.R)
			{
				giveUpDarkness.alpha = Math.max(giveUpDarknessMaxAlpha, giveUpDarkness.alpha - FlxG.elapsed * GIVE_UP_DARKNESS_ALPHA_FADE_RATE);
			}
			
			var machine:Machine = getMachine(World.LIGHT);
			if (machine)
			{
				trickyMask.alpha = machine.alpha;
			}
			
			tickClean();
		}
		
		private function goFullScreen() : void
		{
			API.unlockMedal("full_screen");
			FlxG.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			FlxG.stage.fullScreenSourceRect = new Rectangle(0,0,FlxG.width,FlxG.height); 
    	}
		
		private function goNormalScreen() : void
		{
			FlxG.stage.displayState = StageDisplayState.NORMAL;
			//FlxG.camera.getContainerSprite().x = 0;
		}
		
		private function updateEnd() : void
		{
			if (endingGame && !finalEndingSequence)
			{
				var waiting:Boolean = false;
				for each (var npc:NPC in npcs.members)
				{
					if (npc.state == endingState || endingState == World.BOTH)
					{
						if (npc.gameState != NPC.END && npc.health > 0)
						{
							waiting = true;
							break;
						}
					}
				}
				
				/*if (!getMyPlayer(endingState).fading)
				{
					waiting = true;
				}
				if (endingState == World.BOTH && !getMyPlayer((endingState + 1) % 2).fading)
				{
					waiting = true;
				}*/
				
				if (!waiting && waitingForSecret && !triggeredSecret)
				{
					triggerSecret();
					triggeredSecret = true;
				
				}
				
				if (!waiting && !waitingForSecret)
				{
					finalEndingSequence = true;
					FlxG.camera.shake(0.05, 2, onEndingShakeComplete);
				}
			}
		}
		
		private function onEndingShakeComplete() : void
		{
			getMachine(World.LIGHT).onEnding();
			getMachine(World.DARK).onEnding();
			FlxG.camera.shake(0.01, 3);
			FlxG.camera.flash(0xff000000, 3, onEndingFlashComplete);
			FlxG.play(ScreenFlashSound, SFX_VOLUME);
		}
		
		private function onEndingFlashComplete() : void
		{
			var machine:Machine = getMachine(endingState);
			machine.kill();
			
			for each (var npc:NPC in npcs.members)
				{
					if (npc.state == endingState && npc.health > 0)
					{
						npc.kill();
					}
				}
				
			FlxG.play(RotateSound, SFX_VOLUME);	
			world.startEndSpin();
		}
		
		private function checkPlantOverlap(players:FlxGroup, plants:FlxGroup) : void
		{
			for each (var player:Player in players.members)
			{
				for each (var plant:Plant in plants.members)
				{
					if (player.simpleOverlapCheck(plant))
					{
						player.touchedPlant = plant;
					}
				}
			}
		}
		
		private function checkNPCOverlap(players:FlxGroup, npcs:FlxGroup) : void
		{
			for each (var player:Player in players.members)
			{
				for each (var npc:NPC in npcs.members)
				{
					if (player.simpleOverlapCheck(npc))
					{
						player.touchedNPC = npc;
					}
				}
			}
		}
		
		private function checkHolderOverlap(player:Player, group:FlxGroup) : void
		{
			for each (var holder:OrbHolder in group.members)
			{
				if (player.simpleOverlapCheck(holder))
				{
					player.touchedOrbHolder = holder;
				}
			}
		}
		
		private function checkBeamOverlap(players:FlxGroup, group:FlxGroup) : void
		{
			for each (var player:Player in players.members)
			{
				for each (var beam:OrbBeam in group.members)
				{
					if (player.simpleOverlapCheck(beam) && !beam.disappear)
					{
						player.touchedBeam = beam;
					}
				}
			}
		}
		
		private function tickClean() : void
		{
			cleanTime -= FlxG.elapsed;
			if (cleanTime < 0)
			{
				cleanTime = CLEAN_FREQ;
				
				// Clean anything that could lose members
				cleanGroup(fiends);
				cleanGroup(objects);
				cleanGroup(emitters);
				cleanGroup(darkOrbHolders);
				cleanGroup(lightOrbHolders);
				cleanGroup(invertGlows);
				cleanGroup(orbBeams);
			}
		}
		
		override public function draw():void 
		{
			// TODO(alex): fix this to use a better asset
		   darkness.reDarken();
			//darkness.stamp(darkness2);
			//darkness.fill(DARKNESS_COLOR);
		   super.draw();
		 }
		
		public function readMap(scale:int) : void
		{
			var MapClass:Class;
			switch (scale)
			{
				case 20:
					MapClass = PlaceMap20
					break;
					
			}
			
			if (MapClass == null)
			{
				trace("BAD PLACEMAP SCALE!");
				return;
			}
			
			var bitmapData:BitmapData = (new MapClass).bitmapData;
			if (bitmapData != null)
			{
				var column:uint;
				var pixel:uint;
				var bitmapWidth:uint = bitmapData.width;
				var bitmapHeight:uint = bitmapData.height;
			
				var endIndex:int = bitmapHeight;
				var row:uint = 0;
				
				while(row < endIndex)
				{
					column = 0;
					while(column < bitmapWidth)
					{
						//Decide if this pixel/tile is solid (1) or not (0)
						pixel = bitmapData.getPixel(column, row);
				
						processMapPixel(pixel, column, row, scale, bitmapWidth, bitmapHeight);
						
						column++;
					}
					if (row == endIndex)
					{
						break;
					}
					else
					{
						row++;
					}
				
				}
			}
		}
		
		private static const TOWER_LOCATION:uint = 0x1F5717;
		private static const NPC_LOCATION:uint = 0x02DA88;
		private static const LAMPPOST:uint = 0xE8FD4D;
		private static const MACHINE:uint = 0x1B02DA;
		private static const FEEDER_TREE:uint = 0xDA02A7;
		private static const PLAYER_LOCATION:uint = 0x4D2122;
		private static const SEED_LOCATION:uint = 0x994344;
		private static const CRUSH_PLANT:uint = 0x02DA37;
		private static const SECRET_PEDESTAL:uint = 0x7F8582;
		private static const FINAL_BEAM:uint = 0xFEBAEE;
		private function processMapPixel(color:uint, column:int, row:int, scale:int, bitmapWidth:int, bitmapHeight:int) : void
		{
			// if it's in the light half, we want to bottom-justify it
			var state:int = World.DARK;
			if (row < bitmapHeight / 2)
			{
				state = World.LIGHT;
				row++;
			}
			
			var worldX:Number = world.x + (column - bitmapWidth / 2) * scale;
			var worldY:Number = world.y + (row - bitmapHeight / 2) * scale
			var group:FlxGroup;
			switch (color)
			{
				case TOWER_LOCATION:
					tower.x = worldX;
					tower.y = worldY;
					tower.initialize();
					break;
					
				case NPC_LOCATION:
					addNpc(worldX, worldY, state);
					break;
				case LAMPPOST:
					var lamppost:LampPost = new LampPost(worldX, worldY, state);
					group = state == World.LIGHT ? lightOrbHolders : darkOrbHolders;
					group.add(lamppost);
					break;
					
				case MACHINE:
					var machine:Machine = new Machine(worldX, worldY, state);
					group = state == World.LIGHT ? lightOrbHolders : darkOrbHolders;
					group.add(machine);
					break;
					
				case FEEDER_TREE:
					feederTree = new FeederTree(worldX, worldY);
					lightOrbHolders.add(feederTree);
					break;
					
				case PLAYER_LOCATION:
					if (state == World.LIGHT)
					{
						lightPlayer.x = worldX + 10;
					}
					else
					{
						darkPlayer.x = worldX + 10;
					}
					break;
				case SEED_LOCATION:
					if (Math.random() < .5)
					{
						seedLocations.splice(0, 0, new FlxPoint(worldX, worldY));
					}
					else
					{
						seedLocations.push(new FlxPoint(worldX, worldY));
					}
					break;
					
				case CRUSH_PLANT:
					var crushPlant:CrushPlant = new CrushPlant(worldX, worldY);
					//gameSprites.add(crushPlant);
					break;
				case SECRET_PEDESTAL:
					secretPedestal = new SecretPedestal(worldX, worldY);
					lightOrbHolders.add(secretPedestal);
					break;
				case FINAL_BEAM:
					finalBeamLocations.push(new FlxPoint(worldX, worldY));
					break;
			}
			
		}
		
		public var npcCounts:Dictionary = new Dictionary();
		public function addNpc(X:Number, Y:Number, state:int) : void
		{
			var npc:NPC = new NPC(X, Y, state);
			if (!npcCounts[state])
			{
				npcCounts[state] = 0;
			}
			npc.id = npcCounts[state];
			npcCounts[state]++;
			
			npcs.add(npc);
			
		}
		
		public function onStateChanged(newState:int) : void
		{
			if (newState == World.LIGHT)
			{
				API.logCustomEvent("state_entered_light");
			}
			else
			{
				API.logCustomEvent("state_entered_dark");
			}
			if (newState == World.LIGHT)
			{
				logIncrementalStat(day, "day_completed", [1,2,3,4]);
			
				day++;
				FlxG.playMusicAtPosition(useAlternateMusic ? DayThemeLong : DayThemeLongSlow, MUSIC_VOLUME, FlxG.music.channel.position);
			}
			else if (newState == World.DARK)
			{
				FlxG.playMusicAtPosition(useAlternateMusic ? NightThemeLong : NightThemeLongSlow, MUSIC_VOLUME, FlxG.music.channel.position);
			}
			
			if (finishedEndRotating && newState == World.BOTH)
			{
				giveUpDarknessMaxAlpha = 1;
				endingGame = true;
			}
			
			var obj:GameSprite;
			for each (obj in lightOrbHolders.members)
			{
				obj.onStateChanged(newState);
			}
			
			for each (obj in darkOrbHolders.members)
			{
				obj.onStateChanged(newState);
			}
			
			for each (obj in plants.members)
			{
				obj.onStateChanged(newState);
			}
			
			for each (obj in gameSprites.members)
			{
				obj.onStateChanged(newState);
			}
			
			for each (obj in players.members)
			{
				obj.onStateChanged(newState);
			}
			
			for each (obj in npcs.members)
			{
				obj.onStateChanged(newState);
			}
		}
		
		public function spawnSeed(index:int) : void
		{
			if (seedLocations.length <= index)
			{
				trace("TRIED TO SPAWN INVALID SEED INDEX", index);
				return;
			}
			
			var spawnPoint:FlxPoint = seedLocations[index ];
			var seed:Seed = new Seed(spawnPoint.x, spawnPoint.y);
			objects.add(seed);
		}
		
		public function spawnPlant(X:Number, Y:Number) : void
		{
			var plant:Plant = new Plant(X, world.y);
			plants.add(plant);
			FlxG.play(PlantLandSound, SFX_VOLUME);
			
			if (isInverted)
			{
				var beam:OrbBeam = new OrbBeam(plant.x - 5, plant.y, World.LIGHT);
				orbBeams.add(beam);
				
				solBeam = new OrbBeam(plant.x - 5, plant.y, World.LIGHT, false);
				solBeam.charges = true;
				orbBeams.add(solBeam);
				
				API.logCustomEvent("plant_orb_beam");
			}
		}
		
		public function onMachineActivated(endState:int) : void
		{
			if (endingGame)
			{
				return;
			}
			FlxG.play(ActivateDoorSound, SFX_VOLUME);
			
			trickyMask.visible = true;
			
			var machine:Machine;
			
			endingState = endState; // == World.LIGHT ? END_LIGHT_ESCAPE : END_DARK_ESCAPE;
			
			var isPlantGrownToMax:Boolean = getMaxPlantGrowth() == Plant.MAX_GROWTH;
			
			if (endState == World.BOTH)
			{
				world.setHalfState();
				
				machine = getMachine(World.DARK)
				if (machine)
				{
					machine.open();
				}
				machine = getMachine(World.LIGHT)
				if (machine)
				{
					machine.open();
				}
				
				if (isPlantGrownToMax)
				{
					waitingForSecret = true;
					unlockEnding(END_CATALYZE);
					giveUpDarkness.fill(SECRET_COLOR);
				}
				else
				{
					unlockEnding(END_EMBARK);
					giveUpDarkness.fill(EMBARK_COLOR);
				
				}
				//lastEndingColor = EMBARK_COLOR;
			}
			else
			{
				machine = getMachine(endState)
				if (machine)
				{
					machine.open();
				}
				
				if (isPlantGrownToMax && endState == World.LIGHT)
				{
					waitingForSecret = true;
					unlockEnding(END_CATALYZE);
					giveUpDarkness.fill(SECRET_COLOR);
				}
				else
				{
					unlockEnding(endState == World.LIGHT ? END_ABANDON : END_FLEE);
					//lastEndingColor = endState == World.LIGHT ? ABANDON_COLOR : FLEE_COLOR;
					giveUpDarkness.fill(endState == World.LIGHT ? ABANDON_COLOR : FLEE_COLOR);
				}
			}
			
			endingGame = true;
			for each (var npc:NPC in npcs.members)
			{
				if (npc.state == endState || endState == World.BOTH)
				{
					npc.setGameState(NPC.ESCAPE);
				}
			}
			
			if (endState == World.BOTH)
			{
				PlayState.instance.getMyPlayer(World.LIGHT).startEscape();
				PlayState.instance.getMyPlayer(World.DARK).startEscape()
			}
			else
			{
				PlayState.instance.getMyPlayer(endState).startEscape()
			}
		}
		
		public function crushLightMachine() : void
		{
			if (getMachine(World.LIGHT))
			{
				getMachine(World.LIGHT).crush();
			}
		}
		
		public function getMachine(state:int) : Machine
		{
			var group:FlxGroup = state == World.LIGHT ? lightOrbHolders : darkOrbHolders;
			for each (var holder:OrbHolder in group.members)
			{
				if (holder is Machine)
				{
					return holder as Machine;
				}
			}
			
			return null;
		}
		
		public function getMyPlayer(state:int) : Player
		{
			if (state == World.LIGHT)
			{
				return lightPlayer;
			}
			return darkPlayer;
		}
		
		public function queueText(text:Vector.<PlayText>) : void
		{
			if (text && text.length > 0)
			{
				textPlayer.queue(text);
			}
		}
		
		public function getOrbCount(State:int) : int
		{
			var count:int = 0;
			
			if (State == state)
			{
				count += tower.orbs.length;
			}
			
			var player:Player = getMyPlayer(State);
			if (player && player.carriedOrb != null)
			{
				count++;
			}
			
			var group:FlxGroup = State == World.LIGHT ? PlayState.instance.lightOrbHolders : PlayState.instance.darkOrbHolders;
			for each (var holder:OrbHolder in group.members)
			{
				if (holder.canTakeOrb && !(holder is Tower))
				{
					count += holder.orbs.length;
				}
			}
			
			return count;
		}
		
		public function countLivingNpcs(state:int) : int
		{
			var count:int = 0;
			for each(var npc:NPC in npcs.members)
			{
				if (npc.state == state)
				{
					if (npc.health > 0)
					{
						count++;
					}
				}
			}
			
			return count;
		}
		
		public function get isTextPlayerBusy() : Boolean
		{
			return textPlayer.isBusy;
		}
		
		public function getMaxPlantGrowth() : int
		{
			var max:int = 0;
			for each (var plant:Plant in plants.members)
			{
				if (plant.growth > max)
				{
					max = plant.growth;
				}
			}
			
			return max;
		}
		
		public const SQUANDER_COLOR:uint = 0xff888888;
		public function onSquander() : void
		{
			lastEndingColor = SQUANDER_COLOR;
			giveUpDarknessMaxAlpha = 1;
			endingGame = true;
			makePlayersKneel();
			unlockEnding(END_SQUANDER);
			FlxG.play(NPCDieSound, SFX_VOLUME);
		}
		
		public function onGiveUp() : void
		{
			lastEndingColor = SQUANDER_COLOR;
			giveUpDarknessMaxAlpha = 1;
			endingGame = true;
			makePlayersKneel();
			FlxG.play(NPCDieSound, SFX_VOLUME);
			API.logCustomEvent("give_up");
		}
		
		public const RESIGN_COLOR:uint = 0xff1E1757;//0xff888888;
		public function onResign() : void
		{
			lastEndingColor = RESIGN_COLOR;
			giveUpDarkness.fill(RESIGN_COLOR);
			giveUpDarknessMaxAlpha = 1;
			unlockEnding(END_RESIGN);
			endingGame = true;
			makePlayersKneel();
			//world.setTargetEnding(getEnding(END_RESIGN));
		}
		
		public const SOLACE_COLOR:uint = 0xffA302DA;//0xffFEBAD4;//0xff888888;
		public function onSolace() : void
		{
			lastEndingColor = SOLACE_COLOR;
			giveUpDarkness.fill(SOLACE_COLOR);
			giveUpDarknessMaxAlpha = 1;
			unlockEnding(END_SOLACE);
			endingGame = true;
			makePlayersKneel();
			FlxG.play(NPCDieSound, SFX_VOLUME);
			//world.setTargetEnding(getEnding(END_RESIGN));
		}
		
		public function onEndingFade() : void
		{
			
			giveUpDarkness.fill(0xff000000);
			giveUpDarknessMaxAlpha = 0;
			giveUpDarkness.alpha = .4;
			FlxG.camera.stopFX();
			world.setTargetEnding(getEnding(lastEndingUnlocked));
			_shouldShowEndings = true;
			
			if (lastEndingUnlocked > -1)
			{
				unlockEndingMedal(lastEndingUnlocked);
			}
			//FlxG.switchState(new PlayState);
			
			if ((countEndings == MAX_ENDINGS - 1
				&& !endings[END_CATALYZE])
				|| (countEndings == MAX_ENDINGS))
			{
				API.unlockMedal("resolve");
			}
		}
		
		private function unlockEndingMedal(ending:int) : void
		{
			switch (ending)
			{
				case END_TEND:
					API.unlockMedal("tend");
					break;
				case END_RESIGN:
					API.unlockMedal("resign");
					break;
				case END_EMBARK:
					API.unlockMedal("embark");
					break;
				case END_CATALYZE:
					API.unlockMedal("catalyze");
					break;
				case END_FLEE:
					API.unlockMedal("flee");
					break;
				case END_JUXTAPOSE:
					API.unlockMedal("juxtapose");
					break;
				case END_WORSHIP:
					API.unlockMedal("worship");
					break;
				case END_SQUANDER:
					API.unlockMedal("squander");
					break;
				case END_MOURN:
					API.unlockMedal("mourn");
					break;
				case END_ABANDON:
					API.unlockMedal("abandon");
					break;
				case END_SOL:
					API.unlockMedal("scorch");
					break;
				case END_NYX:
					API.unlockMedal("shroud");
					break;
				case END_SOLACE:
					API.unlockMedal("solace");
					break;
			}
		}
		
		public const TEND_COLOR:uint = 0xff016D44;
		public function onTend() : void
		{
			lastEndingColor = RESIGN_COLOR;
			giveUpDarkness.fill(TEND_COLOR);
			giveUpDarknessMaxAlpha = 1;	
			unlockEnding(END_TEND);
			endingGame = true;
			makePlayersKneel();
			//world.setTargetEnding(getEnding(END_TEND));
		}
		
		public function makePlayersKneel() : void
		{
			for each (var player:Player in players.members)
			{
				if (!player.kneeling)
				{
					player.kneel();
					player.play("kneel");
					player.kneeling = true;
				}
				
				player.forceKneeling = true;
			}
		}
		
		public function get isEligibleForTendEnd() : Boolean
		{
			return getMaxPlantGrowth() == Plant.MAX_GROWTH
		}
		
		public function get isEligibleForBothEnd() : Boolean
		{
			return getMachine(World.LIGHT) &&
			getMachine(World.LIGHT).charge >= Machine.MAX_LIGHTS &&
			getMachine(World.DARK) &&
			getMachine(World.DARK).charge >= Machine.MAX_LIGHTS;
			
		}
		
		public function get isEligibleForSquanderEnd() : Boolean
		{
			return PlayState.instance.getOrbCount(World.LIGHT) + PlayState.instance.getOrbCount(World.DARK) == 0;
		}
		
		public function get isEligibleForResignEnd() : Boolean
		{
			return state == World.LIGHT && getMachine(World.LIGHT) && getMachine(World.LIGHT).crushed;
		}
		
		public function get isEligibleForWorshipEnd() : Boolean
		{
			return state == World.LIGHT && feederTree && feederTree.orbsEaten == Tower.STARTING_ORBS;
		}
		
		public function get isEligibleForMournEnd() : Boolean
		{
			return state == World.DARK && countLivingNpcs(World.DARK) == 0;
		}
		
		public function get isEligibleForSolaceEnd() : Boolean
		{
			for each(var npc:NPC in npcs.members)
			{
				if (npc.state == state)
				{
					if (npc.solaceable)
					{
						return true;
					}
				}
			}
			
			return false;
		}
		
		public function get isEligibleForJuxtaposeEnd() : Boolean
		{
			return state == World.LIGHT && secretPedestal.canActivate;
		}
		
		public function get isEligibleForNyxEnd() : Boolean
		{
			return nyxBeam != null;
		}
		
		public function get isEligibleForSolEnd() : Boolean
		{
			return solBeam != null && solBeam.isFullyCharged;
		}
		
		private function setupInvertFilter() : void
		{
			finalInvertGlowLayer.clear();
			
			invertFilter = new FlxSprite(0, 0);
			invertFilter.makeGraphic(FlxG.width, FlxG.height);
			invertFilter.blend = "invert";
			finalInvertGlowLayer.add(invertFilter);
		}
		
		public const JUXTAPOSE_COLOR:uint = 0xffffffff;
		public function onJuxtapose() : void
		{
			save.data.inverted = !save.data.inverted;
			setupInvertFilter();
			
			var flickerTime:Number = 2;
			invertFilter.flicker(flickerTime, 5);
			
			FlxG.shake(.004, flickerTime, function():void {
				if (!save.data.inverted)
				{
					finalInvertGlowLayer.visible = false;
				}
				giveUpDarkness.fill(JUXTAPOSE_COLOR);
				giveUpDarknessMaxAlpha = 1;
				endingGame = true;
				unlockEnding(END_JUXTAPOSE);
				
				makePlayersKneel();
				});
		}
		
		public const WORSHIP_COLOR:uint = 0xffECC85E;
		public function onWorship() : void
		{
			giveUpDarkness.fill(WORSHIP_COLOR);
			giveUpDarknessMaxAlpha = 1;
			endingGame = true;
			unlockEnding(END_WORSHIP);
			makePlayersKneel();
			
			//world.setTargetEnding(getEnding(END_WORSHIP));
		}
		
		public const MOURN_COLOR:uint = 0xff000282;
		public function onMourn() : void
		{
			giveUpDarkness.fill(MOURN_COLOR);
			giveUpDarknessMaxAlpha = 1;
			endingGame = true;
			unlockEnding(END_MOURN);
			makePlayersKneel();
			
			//world.setTargetEnding(getEnding(END_MOURN));
		}
		
		public function get pendingEndingBlocksSleeping() : Boolean
		{
			return PlayState.instance.isEligibleForWorshipEnd ||
			PlayState.instance.isEligibleForMournEnd ||
			isEligibleForResignEnd ||
			isEligibleForJuxtaposeEnd ||
			isEligibleForSolaceEnd;
		}
		
		public function get hasPendingEnding() : Boolean
		{
			return PlayState.instance.isEligibleForBothEnd ||
			PlayState.instance.isEligibleForTendEnd ||
			PlayState.instance.isEligibleForWorshipEnd ||
			PlayState.instance.isEligibleForMournEnd ||
			isEligibleForResignEnd ||
			isEligibleForJuxtaposeEnd ||
			isEligibleForSolaceEnd;
		}
		
		public function triggerNyxBeam() : void
		{
			if (nyxBeam != null)
			{
				return;
			}
			
			var nyxPoint:FlxPoint = null;
			for each (var point:FlxPoint in finalBeamLocations)
			{
				if (point.y >= FlxG.height / 2)
				{
					nyxPoint = point;
					break;
				}
			}
			
			if (nyxPoint != null)
			{
				nyxBeam = new OrbBeam(nyxPoint.x, FlxG.height / 2, World.DARK, false);
				orbBeams.add(nyxBeam)
				
				API.logCustomEvent("nyx_beam_created");
			}
		}
		
		public function triggerNyxEnding() : void
		{
			var ending:SuperSecretEndSprite = new SuperSecretEndSprite(World.DARK);
			superSecretEnding.add(ending);
		}
		
		public const NYX_COLOR:uint = 0xff222222;
		public function onNyxEnd() : void
		{
			giveUpDarkness.fill(NYX_COLOR);
			giveUpDarknessMaxAlpha = 1;
			endingGame = true;
			unlockEnding(END_NYX);
			makePlayersKneel();
		}
		
		public function triggerSolEnding() : void
		{
			var ending:SuperSecretEndSprite = new SuperSecretEndSprite(World.LIGHT);
			superSecretEnding.add(ending);
		}
		
		public const SOL_COLOR:uint = 0xffCCCCCC;
		public function onSolEnd() : void
		{
			giveUpDarkness.fill(SOL_COLOR);
			giveUpDarknessMaxAlpha = 1;
			endingGame = true;
			unlockEnding(END_SOL);
			makePlayersKneel();
		}
		
		public function unlockEnding(ending:int) : void
		{
			if (!endings[ending] && !save.data.escapedOnce)
			{
				switch (ending)
				{
					case END_ABANDON:
					case END_FLEE:
					case END_EMBARK:
					case END_CATALYZE:
						save.data.escapedOnce = true;
						PlayState.escapedThisSession = true;
						break;
				}
			}
			
			consecutiveEndings++;
			logIncrementalStat(consecutiveEndings, "consecutive_endings", [1,2,3,5,10,15]);
			
			logIncrementalStat(countEndings, "endings", [1,2,3,5,10,13]);
			
			API.logCustomEvent("ending_completed");
			if (isInverted)
			{
				API.logCustomEvent("ending_completed_inverted");
			}
			
			switch (ending)
			{
				case END_ABANDON:
					API.logCustomEvent("end_abandon");
					break;
				case END_SOL:
					API.logCustomEvent("end_scorch");
					break;
				case END_NYX:
					API.logCustomEvent("end_shroud");
					break;
				case END_CATALYZE:
					API.logCustomEvent("end_catalyze");
					break;
				case END_FLEE:
					API.logCustomEvent("end_flee");
					break;
				case END_EMBARK:
					API.logCustomEvent("end_embark");
					break;
				case END_JUXTAPOSE:
					API.logCustomEvent("end_juxtapose");
					break;
				case END_SOLACE:
					API.logCustomEvent("end_solace");
					break;
				case END_WORSHIP:
					API.logCustomEvent("end_worship");
					break;
				case END_RESIGN:
					API.logCustomEvent("end_resign");
					break;
				case END_MOURN:
					API.logCustomEvent("end_mourn");
					break;
				case END_TEND:
					API.logCustomEvent("end_tend");
					break;
				case END_SQUANDER:
					API.logCustomEvent("end_squander");
					break;
			}
			
			
			endings[ending] = true;
			lastEndingUnlocked = ending;
			if (save.data.endings == null)
			{
				save.data.endings = { };
			}
			save.data.endings[ending] = true;
		}
		
		public function getEnding(ending:int) : EndSprite
		{
			for each (var sprite:EndSprite in endingSprites.members)
			{
				if (sprite.end == ending)
				{
					return sprite;
				}
			}
			
			return endingSprites.members[0];
		}
		
		public function onRotatedToTargetEnding() : void
		{
			readyToRestart = true;
			FlxG.play(EndingCompleteSound, SFX_VOLUME);
		}
		
		/*public function get shouldShowEndings() : Boolean
		{
			return false;
		}*/
		
		public function get shouldShowEndings() : Boolean
		{
			return _shouldShowEndings || !hasStartedGame;
		}
		
		public function isEndingUnlocked(end:int) : Boolean
		{
			return endings[end];
		}
		
		
		
		public function get countEndings() : int
		{
			var count:int = 0;
			for (var key:String in endings)
			{
				if (endings[key])
				{
					count++;
				}
			}
			
			return count;
		}
		
		public function restartGame() : void
		{
			readyToRestart = false;
			FlxG.play(GameRestartedSound, SFX_VOLUME);
			FlxG.fade(0xff000000, 1, restartEverything);
		}
		
		public function restartEverything() : void 
		{
			FlxG.switchState(new PlayState);
		}
		
		public function triggerSecret() : void
		{
			for each (var plant:Plant in plants.members)
			{
				if (plant.growth >= Plant.MAX_GROWTH)
				{
					plant.spawnSecretSeed();
					return;
				}
			}
		}
		
		public function spawnSecret(X:Number, Y:Number) : void
		{
			var secret:Secret = new Secret(X, world.y);
			npcs.add(secret);
			FlxG.play(PlantLandSound, SFX_VOLUME);
		}
		
		public function onFinishKneeling() : void
		{
			var play:Player = getMyPlayer(state);
	
			if (isEligibleForSquanderEnd)
			{
				onSquander();
			}
			else if (play.isHopeless)
			{
				onGiveUp();
			}
			else
			{
				if (world.canAdvanceState)
				{
					FlxG.play(RotateSound, PlayState.SFX_VOLUME);
					world.nextState();
					
				}
			}
		}
		
		public function get isInverted() : Boolean
		{
			return save.data.inverted;
		}
		
		public function get escapedOnce() : Boolean
		{
			return save.data.escapedOnce;
		}
		
		public function logIncrementalStat(statValue:int, statName:String, milestones:Array) : void
		{
			var suffix:String = null;
			for (var i:int = 0; i < milestones.length; i++)
			{
				if (i == milestones.length - 1
					&& statValue >= milestones[i])
				{
					suffix = "" + milestones[i] + "_plus";
					break;
				}
				
				if (statValue <= milestones[i])
				{
					if (i == 0
						|| (milestones[i] - milestones[i - 1] == 1))
					{
						suffix = "" + milestones[i];
					}
					else
					{
						suffix = "" + milestones[i - 1] + "-" + milestones[i];
					}
					break;
				}
			}
			
			if (suffix != null)
			{
				API.logCustomEvent(statName + "_" + suffix);
			}
		}
		
		public function progressSolaceQuest() : void
		{
			solaceQuestProgress++;
			FlxG.play(AdvanceQuestSound, SFX_VOLUME);
			API.logCustomEvent("solace_quest_" + PlayState.instance.solaceQuestProgress);
		}
	}
}