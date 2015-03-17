package 
{
	import flash.globalization.DateTimeFormatter;
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
	import org.flixel.*;
	
	import com.newgrounds.API;
	/**
	 * ...
	 * @author zillix
	 */
	public class NPC extends HittableSprite 
	{
		[Embed(source = "data/npcSmall.png")]	public var SmallNpcSprite:Class;
		[Embed(source = "data/npcDie.mp3")]	public var NPCDieSound:Class;
		[Embed(source = "data/solaceOrbSound.mp3")]	public var SolaceOrbSound:Class;
		[Embed(source = "data/gameRestarted.mp3")]	public var MadeSolaceableSound:Class;
		[Embed(source = "data/advanceQuest2.mp3")]	public var AdvanceQuestSound:Class;
		
		
			
		public static const MAX_HEALTH:int = 3;
		
		public var gameStateTime:Number = 0;
		
		public static var IDLE:int = 0;
		public static var WALK:int = 1;
		public static var HIDE:int = 3;
		public static var COWER:int = 4;
		public static var ESCAPE:int = 5;
		public static var END:int = 6;
		public static var DEAD:int = 7;
		public static var TALKING:int = 8;
		public var gameState:int = IDLE;
		
		
		public var DEST_DIST:Number = 5
		
		public var WALK_SPEED:Number = 30;
		public var RUN_SPEED:Number = 50;
		public var SPEED_VARIANCE:Number = 10;
		
		public var target:FlxObject;
		
		public var id:int = 0;
		
		public var DEAD_FADE_RATE:Number = .4;
		public var FADE_RATE:Number = 1;
		
		public var usesDefaultAnimations:Boolean = true;
		
		private var _lastExamineTextLength:int = 0;
		
		public var timesTalkedToday:int = 0;
		public var solaceable:Boolean = false;
		
		
		public function NPC(X:Number, Y:Number, state:int)
		{
			super(X, Y, state);
			enemyHitsToDamage = 15;
			loadGraphic(SmallNpcSprite, true, true, 20, 29);
			scale.x = scale.y = 2;
			if (isLight)
			{
				offset.y = height * 3 / 2;
			}
			else {
				offset.y = -height / 2;
			}
			addAnimation("lightStand", [0]);
			addAnimation("lightWalk", [0,1,2,3,4,5,6,7,8,9], 16);
			addAnimation("darkStand", [10]);
			addAnimation("darkWalk", [10, 11, 12, 14, 15, 16, 16, 17, 18, 19], 16);
			addAnimation("lightDead", [20]);
			addAnimation("darkDead", [21]);
			
			if (state == World.LIGHT)
			{
				play("lightStand");
				
			}
			else
			{
				play("darkStand");
			}
			
			facing = Math.random() < .5 ? LEFT : RIGHT;
			
			health = MAX_HEALTH;
		}
		
		override public function update() : void
		{
			super.update();
			
			if (health > 0 && usesDefaultAnimations)
			{
				if (velocity.x > 0)
				{
					facing = isLight ? RIGHT : LEFT;
					play(isLight ? "lightWalk" : "darkWalk");
				}
				else if (velocity.x < 0)
				{
					facing = isLight ? LEFT : RIGHT;
					play(isLight ? "lightWalk" : "darkWalk");
				}
				else
				{
					play(isLight ? "lightStand" : "darkStand");
				}
			}
			
			if (health > 0)
			{
				runGameState(gameState);
			}
			else
			{
				velocity.x = 0;
				target = null;
			}
		}
		
		override public function damage(enemy:GameSprite) : void
		{
			if (health <= 0)
			{
				return;
			}
			
			health--;
			emitParticle(enemy.x, enemy.y, 10, true, 0xffff0000, 2, 0, 0, 1, 3);
			if (health <= 0)
			{
				setGameState(DEAD);
				FlxG.play(NPCDieSound, PlayState.SFX_VOLUME);
			}
		}
		
		public function exitGameState(oldGameState:int) : void
		{
			switch (oldGameState)
			{
				case COWER:
					if (target is LampPost)
					{
						LampPost(target).hideUnlock(this);
						target = null;
					}
					break;
			}
		}
		
		public function setGameState(newGameState:int):void
		{
			exitGameState(gameState);
			
			switch (newGameState)
			{
				case TALKING:
					velocity.x = 0;
					gameStateTime = 2 * _lastExamineTextLength;
					break;
				case IDLE:
					gameStateTime = Math.random() * 1.5 + .5;
					velocity.x = 0;
					break;
					
				case WALK:
					target = getRandomTarget();
					break;
					
				case HIDE:
					target = findHideTarget();
					break;
					
				case ESCAPE:
					target = new FlxObject(PlayState.instance.world.x + World.ESCAPE_DISTANCE * 1.2, y);
					break;
					
				case COWER:
					velocity.x = 0;
					gameStateTime = 3;
					break;
					
				case END:
					velocity.x = 0;
					velocity.y = 0;
					target = null;
					break;
					
				case DEAD:
					velocity.x = 0;
					target = null;
					if (state == World.LIGHT)
					{
						play("lightDead");
					}
					else
					{
						play("darkDead");
					}
					break;
			}
			
			gameState = newGameState;
		}
		
		protected function getRandomTarget() : FlxObject
		{
			return new FlxObject(Math.random() * (World.MAX_DISTANCE - 10) * 2 - (World.MAX_DISTANCE - 10) + PlayState.instance.world.x, 0);
		}
		
		protected function findHideTarget() : FlxObject
		{
			if (!isDark)
			{
				return null;
			}
			
			var bestHideSpot:OrbHolderHideSpot;
			var bestDistance:Number = Number.MAX_VALUE;
			for each (var orbHolder:OrbHolder in PlayState.instance.darkOrbHolders.members)
			{
				var hideSpot:OrbHolderHideSpot = orbHolder as OrbHolderHideSpot;
				if (hideSpot != null && hideSpot.orbs.length > 0)
				{
					if (hideSpot.hidingNpcs.length > 0)
					{
						continue;
					}
					
					var distance:Number = Math.abs(hideSpot.x - x);
					if (distance < bestDistance)
					{
						bestHideSpot = hideSpot;
						bestDistance = distance;
					}
				}
			}
			
			if (bestHideSpot != null)
			{
				bestHideSpot.hideLock(this);
				return bestHideSpot;
			}
			
			return getRandomTarget();
		}
		
		public function runGameState(currentGameState:int):void
		{
			gameStateTime -= FlxG.elapsed;
			
			switch (currentGameState)
			{
				case TALKING:
					if (gameStateTime <= 0)
					{
						setGameState(WALK);
					}
					break;
				case HIDE:
					if (target != null)
					{
						if (target.x > x)
						{
							setVelocity(RUN_SPEED);
						}
						else
						{
							setVelocity(-RUN_SPEED);
						}
						if (FlxU.getDistance(new FlxPoint(x, y), new FlxPoint(target.x, y)) < DEST_DIST)
						{
							setGameState(COWER);
						}
					}	
				break;
				
				case ESCAPE:
					if (target != null)
					{
						if (target.x > x)
						{
							setVelocity(RUN_SPEED);
						}
						else
						{
							setVelocity(-RUN_SPEED);
						}
						if (FlxU.getDistance(new FlxPoint(x, y), new FlxPoint(target.x, y)) < DEST_DIST)
						{
							setGameState(END);
						}
					}	
				break;
				
				case COWER:
					if (gameStateTime <= 0)
					{
						setGameState(IDLE);
					}
				break;
				
				case WALK:
					if (target != null)
					{
						if (target.x > x)
						{
							setVelocity(WALK_SPEED);
						}
						else
						{
							setVelocity(-WALK_SPEED);
						}
						if (FlxU.getDistance(new FlxPoint(x, y), new FlxPoint(target.x, y)) < DEST_DIST)
						{
							setGameState(IDLE);
						}
					}	
				break;
				
			case IDLE:
				if (gameStateTime <= 0)
				{
					if (Math.random() < .4)
					{
						setGameState(WALK);
					}
					else
					{
						setGameState(IDLE);
					}
				}
				break;
				
			case DEAD:
				alpha -= FlxG.elapsed * DEAD_FADE_RATE;
				break;
				
			case END:
				alpha -= FlxG.elapsed * FADE_RATE;
				break;
				
			}
			
			
		}
		
		override public function getExamineText() : Vector.<PlayText>
		{
			var text:Vector.<PlayText> = new Vector.<PlayText>();
			var orbCount:int = PlayState.instance.getOrbCount(state);
			var day:int = PlayState.instance.day;
			var quips:Vector.<PlayText> = new Vector.<PlayText>();
			var plants:int = PlayState.instance.plants.members.length;
			var maxPlantGrowth:int = PlayState.instance.getMaxPlantGrowth();
			var deviceCharge:int = PlayState.instance.getMachine(state).charge;
			var blockQuips:Boolean = false;
			var progressQuest:Boolean = false;
			var player:Player = PlayState.instance.getMyPlayer(PlayState.instance.state);
			var isInverted:Boolean = PlayState.instance.save.data.inverted;
			var list:Vector.<PlayText>;
			if (isLight)
			{
				if (day == 0)
				{
					list = (PlayState.instance.countEndings == 0 || timesTalkedToday == 0) ? text : quips;
					if (!isInverted)
					{
						addText(list, "the " + Orb.ORB_NAME_PLURAL + " can power the " + Machine.MACHINE_NAME + " overnight");
						addText(list, "hold DOWN to rest for the night");
					}
					else
					{
						addText(list, "something feels different... but I can't tell why");
						addText(list, "everything seems wrong somehow");
					}
					
					if (PlayState.instance.countEndings == 0)
					{
						blockQuips = true;
					}
				}
				else
				{
					addText(quips, "the " + Orb.ORB_NAME_PLURAL + " can power the " + Machine.MACHINE_NAME + " overnight");
					addText(quips, "the falling rocks will soon destroy the " + Machine.MACHINE_NAME);
					if (PlayState.instance.getOrbCount(World.DARK) > 0)
					{
						addText(quips, "where are the " + Orb.ORB_NAME_PLURAL + " disappearing to?");
					}
				}
				
				if (plants > 0)
				{
					switch (maxPlantGrowth)
					{
						case 0:
							break;
						case 1:
							if (!hasEnding(PlayState.END_CATALYZE)
								|| !hasEnding(PlayState.END_TEND))
							{
							addText(quips, "I wonder what that sapling will grow into...", 4);
							}
							break;
							
						case 2:
						case 3:
							if (!hasEnding(PlayState.END_CATALYZE))
							{	
								addText(quips, "I wish I could bring a sample of that tree with me", 4);
							}
							break;
						case 4:
							if (!hasEnding(PlayState.END_CATALYZE))
							{
								addText(quips, "I wonder how the tree's fruit would fare in the desert?", 4);
							}
							break;
					}
				}
					
				
				if (!hasEnding(PlayState.END_WORSHIP))
				{
					addText(quips,  "we have better uses for the orbs, but that tree calls to me...");
				}
				if (!hasEnding(PlayState.END_RESIGN))
				{
					addText(quips,  "if all of the antennae on the " + Machine.MACHINE_NAME + " break, we'll be trapped");
				}
				if (!hasEnding(PlayState.END_TEND))
				{
					addText(quips, "this wouldn't be so bad with a garden to care for");
				}
				if (!hasEnding(PlayState.END_SQUANDER))
				{
					addText(quips, "what would we do if we ran out of orbs?");
				}
				if (!hasEnding(PlayState.END_JUXTAPOSE))
				{
					addText(quips, "what does that hanging lamp do?");
				}
			}
			else
			{
				if (day == 0)
				{
					list = (PlayState.instance.countEndings == 0 || timesTalkedToday == 0) ? text : quips;
						
					if (!isInverted)
					{
						addText(text, "they will come again tonight");
						addText(text, "only the light keeps them at bay");
						blockQuips = true;
					}
					else
					{
						addText(list, "I sense a strange power");
						addText(list, "they fear the light, but now so do I");
					}
				}
				
				
				addText(quips, "we need to get out of here");
				
				if (health == 1)
				{
					addText(quips, "I don't expect to make it through the night");
				}
				else if (health < MAX_HEALTH)
				{
					addText(quips, "the attacks are taking their toll");
				}
				
				if (PlayState.instance.getOrbCount(World.LIGHT) > 0)
				{
					addText(quips, "where do the orbs go at night?");
				}
				
				if (plants > 0)
				{
					switch (maxPlantGrowth)
					{
						case 1:
							addText(quips, "where did these vines come from?");
							break;
						case 2:
						case 3:
							addText(quips, "if the vines can survive this, maybe so can we");
							break;
						case 4:
							addText(quips, "even in this hell, the vines managed to flourish");
							break;
					}
				}
				
				
				if (!hasEnding(PlayState.END_MOURN))
				{
					addText(quips,  "if I don't make it through the night, you'll be all alone");
				}
			}
			
			switch (deviceCharge)
			{
				case 0:
				break;
				
				case 1:
					addText(quips, "we need the " + Machine.MACHINE_NAME + " to charge faster...");
					break;
				case Machine.MAX_LIGHTS - 1:
					addText(quips, "the " + Machine.MACHINE_NAME + " is nearly charged");
			}
			
			if (PlayState.instance.countEndings > 4)
			{
				addText(quips, "this seems... familiar somehow. have I been here before?");
			}
			
			addText(quips, "how did I get here?");
			addText(quips, "who are you? why won't you speak?");
			addText(quips, "this is a lonely place...");
			
			
			
			/*if (!hasEnding(PlayState.END_SECRET))
			{
				if (PlayState.instance.plants.members.length > 0)
				{
					addText(quips, "the flora here is fascinating. we should try to take a sample when we leave");
					addText(quips, "if only we could see the fully-grown flora before we depart");
				}
			}*/
			
			
				
			// SolaceQuest stuff
			if (timesTalkedToday == 1)
			{
				progressQuest = false;
				text.length = 0;
				blockQuips = true;
				
				progressQuest = addSolaceText(text);
						
				if (progressQuest)
				{
					PlayState.instance.progressSolaceQuest();
				}
			}
			if (PlayState.instance.solaceQuestProgress == PlayState.SOLACE_COLOR_ORB
				&& PlayState.instance.state == PlayState.instance.solaceQuestStartState)
			{
				if (playerHoldingSolaceColoredOrb)
				{
					text.length = 0;
					blockQuips = true;
					PlayState.instance.progressSolaceQuest();
					addText(text, "I won't forget her", -1, 
						function() : void {
							FlxG.play(SolaceOrbSound, PlayState.SFX_VOLUME);
							FlxG.flash(PlayState.instance.SOLACE_COLOR, 1, function() : void {
									player.carriedOrb.makeSolaceColored();
								}
							);
						},
						PlayState.instance.SOLACE_COLOR
					);
					
				}
				
			}
			
			if (PlayState.instance.solaceQuestProgress == PlayState.SOLACE_PRESENT_ORB
				&& PlayState.instance.state != PlayState.instance.solaceQuestStartState)
			{
				if (playerHoldingSolaceColoredOrb)
				{
					text.length = 0;
					blockQuips = true;
					PlayState.instance.progressSolaceQuest();
					addText(text, "where did you get that orb?", -1, null, PlayState.instance.SOLACE_COLOR);
					addText(text, "she knew it was my favorite color...", -1, null, PlayState.instance.SOLACE_COLOR);
					addText(text, "I choose to believe we'll someday be reunited", -1, 
						function () : void
						{
							API.logCustomEvent("solace_quest_" + PlayState.instance.solaceQuestProgress);
				
							makeSolaceable();
						},
						PlayState.instance.SOLACE_COLOR
					);
				}
			}
			
				
			
			if (!blockQuips 
				&& quips.length > 0
				&& (text.length == 0 || Math.random() > .5))
			{
				text.push(quips[int(Math.random() * quips.length)]);
			}
			
			_lastExamineTextLength = text.length;
			setGameState(TALKING);
			
			// Hacky monkey patch
			if (text.length > 0)
			{
				var firstText:PlayText = text[0];
				var onFirstText:Function = function() : void
				{
					timesTalkedToday++;
					API.logCustomEvent("npc_talked");
					
					if (state == World.LIGHT)
					{
						PlayState.instance.logIncrementalStat(timesTalkedToday, "npc_light_talked_today", [1, 2, 3]);
					}
					else
					{	
						PlayState.instance.logIncrementalStat(timesTalkedToday, "npc_dark_talked_today", [1, 2, 3]);
					}
				}
				
				if (firstText.callback == null)
				{
					firstText.callback = onFirstText;
				}
				else
				{
					var cachedCallback:Function = firstText.callback;
					firstText.callback = function() : void
					{
						onFirstText();
						cachedCallback();
					}
				}
				
				
			}
			else
			{
				trace("Failed to generate text!");
			}
			
			
			return text;
		}
		
		private function makeSolaceable() : void
		{
			solaceable = true;
			FlxG.play(MadeSolaceableSound, PlayState.SFX_VOLUME);
		}
		
		private function addSolaceText(text:Vector.<PlayText>) : Boolean
		{
			var progressQuest:Boolean = false;
			var solaceStartState:int = PlayState.instance.solaceQuestStartState;
			var currentState:int = PlayState.instance.state;
			switch (PlayState.instance.solaceQuestProgress)
			{
				case 0:
					// Dude 1
					addText(text, "we traveled here together...", -1, null, PlayState.instance.SOLACE_COLOR );
					addText(text, "where is she now? she should be here...", -1, null, PlayState.instance.SOLACE_COLOR);
					progressQuest = true;
					PlayState.instance.solaceQuestStartState = PlayState.instance.state;
					break;
				case 1:
					// Dude 2
					if (solaceStartState != currentState)
					{
						addText(text, "she said we would both make it here", -1, null, PlayState.instance.SOLACE_COLOR);
						addText(text, "I wish I knew if she was still alive", -1, null, PlayState.instance.SOLACE_COLOR);
						progressQuest = true;
					}
					else // Dude 1
					{
						addText(text, "where did she go...?");
					}
					
					break;
				case 2:
					// Dude 1
					if (solaceStartState != currentState)
					{
						addText(text, "I wish I knew if she was still alive");	
					}
					else // Dude 2
					{
						addText(text, "these orbs remind me of her", 1.5, null, PlayState.instance.SOLACE_COLOR);
						addText(text, "I wish I could see one closer...", 2, null, PlayState.instance.SOLACE_COLOR);
						addText(text, "I could create something to remember her by", 2, null, PlayState.instance.SOLACE_COLOR);
						FlxG.play(AdvanceQuestSound, PlayState.SFX_VOLUME);
					}
					break;
				case 3:
					// Dude 2
					if (solaceStartState != currentState)
					{
						addText(text, "these orbs remind me of her", 1.5);
					}
					else // Dude 1
					{
						addText(text, "she always loved that color...");
					}
					break;
			}
			
			return progressQuest;
			
		}
		
		
	
		public function setVelocity(vel:Number) : void
		{
			velocity.x = Math.random() * SPEED_VARIANCE - SPEED_VARIANCE / 2 + vel;
		}
		
		override public function onStateChanged(newState:int) : void
		{
			super.onStateChanged(newState);
			if (state == World.DARK && newState == World.LIGHT)
			{
				setGameState(HIDE);
			}
		
			timesTalkedToday = 0;
		}
		
		override public function get canExamine() : Boolean
		{
			return super.canExamine || (PlayState.instance.isEligibleForMournEnd && health == 0)
			|| solaceable;
		}
		
		override public function examine() : void
		{
			if (PlayState.instance.isEligibleForMournEnd && health == 0)
			{
				PlayState.instance.onMourn();
			}
			else if (solaceable)
			{
				PlayState.instance.onSolace();
			}
			else
			{
				super.examine();
			}
		}
		
		override public function get examineString() : String
		{
			if (PlayState.instance.isEligibleForMournEnd && health == 0)
			{
				return PlayState.MOURN_TEXT;
			}
			if (solaceable)
			{
				return PlayState.SOLACE_TEXT;
			}
			if (playerHoldingSolaceColoredOrb)
			{
				return "show";
			}
			
			
			return "talk";
		}
		
		public function hasEnding(ending:int) : Boolean
		{
			return PlayState.instance.endings[ending];
		}
		
		public function get playerHoldingSolaceColoredOrb() : Boolean
		{
			var player:Player = PlayState.instance.getMyPlayer(PlayState.instance.state);
			return player.carriedOrb != null
					&& ((player.carriedOrb.solaceColored
							&& PlayState.instance.solaceQuestStartState != PlayState.instance.state)
						|| (!player.carriedOrb.solaceColored
							&& PlayState.instance.solaceQuestStartState == PlayState.instance.state));
		}
		
	}
	
}