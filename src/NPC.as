package 
{
	import flash.globalization.DateTimeFormatter;
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class NPC extends HittableSprite 
	{
		[Embed(source = "data/npcSmall.png")]	public var SmallNpcSprite:Class;
		[Embed(source = "data/npcDie.mp3")]	public var NPCDieSound:Class;
			
		public static const MAX_HEALTH:int = 3;
		
		public var gameStateTime:Number = 0;
		
		public static var IDLE:int = 0;
		public static var WALK:int = 1;
		public static var TALK:int = 2;
		public static var HIDE:int = 3;
		public static var COWER:int = 4;
		public static var ESCAPE:int = 5;
		public static var END:int = 6;
		public static var DEAD:int = 7;
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
			
			var bestLampPost:LampPost;
			var bestDistance:Number = Number.MAX_VALUE;
			for each (var orbHolder:OrbHolder in PlayState.instance.darkOrbHolders.members)
			{
				var lampPost:LampPost = orbHolder as LampPost;
				if (lampPost != null && lampPost.orbs.length > 0)
				{
					if (lampPost.hidingNpcs.length > 0)
					{
						continue;
					}
					
					var distance:Number = Math.abs(lampPost.x - x);
					if (distance < bestDistance)
					{
						bestLampPost = lampPost;
						bestDistance = distance;
					}
				}
			}
			
			if (bestLampPost != null)
			{
				bestLampPost.hideLock(this);
				return bestLampPost;
			}
			
			return getRandomTarget();
		}
		
		public function runGameState(currentGameState:int):void
		{
			gameStateTime -= FlxG.elapsed;
			
			switch (currentGameState)
			{
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
				
			case TALK:
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
			if (isLight)
			{
				if (id == 0)
				{
					if (orbCount == 0)
					{
						addText(quips, "how did it come to this?");
					}
					else
					{
						addText(text, "the " + Orb.ORB_NAME_PLURAL + " can power the " + Machine.MACHINE_NAME + " overnight");
						addText(text, "hold DOWN to rest for the night");
					}
					
					
				}
				else if (id == 1)
				{
					if (day == 0)
					{
						addText(text, "we don't have much time");
						addText(text, "the loose rocks will destroy the " + Machine.MACHINE_NAME + " in a matter of days");
					}
					if (day >= 1)
					{
						addText(quips, "the falling rocks will soon destroy the " + Machine.MACHINE_NAME);
						if (PlayState.instance.getOrbCount(World.DARK) > 0)
						{
							addText(quips, "why are there fewer " + Orb.ORB_NAME_PLURAL + " than yesterday?");
						}
					}
				}
				
				if (plants > 0)
				{
					switch (maxPlantGrowth)
					{
						case 0:
							addText(quips, "why have the sprouts died?   what did we do wrong?", 4);
							break;
						case 1:
							break;
						case 2:
						case 3:
							break;
						case 4:
							break;
					}
				}
			}
			else
			{
				if (id == 0)
				{
					if (orbCount == 0)
					{
						addText(quips, "there is nothing we can do");
					}
					else if (day < 2)
					{
						addText(text, "they will come again tonight");
						addText(text, "they will stay away from the light");
					}
				}
				else if (id == 1)
				{
					addText(text, "they will come again tonight");
					addText(quips, "we need to get out of here");
				}
				
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
						case 0:
							addText(quips, "not even the vines could survive this");
							break;
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
			
			if (!hasEnding(PlayState.END_TEND))
			{
				addText(quips, "this wouldn't be so bad with a garden to care for");
			}
			if (!hasEnding(PlayState.END_RESIGN) && isLight)
			{
				addText(quips,  "if all of the antennae on the " + Machine.MACHINE_NAME + " break, we'll be trapped");
			}
			if (!hasEnding(PlayState.END_MOURN) && isDark)
			{
				addText(quips,  "if we don't make it through the night, you'll be all alone");
			}
			if (!hasEnding(PlayState.END_WORSHIP) && isLight)
			{
				addText(quips,  "we have better uses for the orbs, but that tree calls to me...");
			}
			/*if (!hasEnding(PlayState.END_SECRET))
			{
				if (PlayState.instance.plants.members.length > 0)
				{
					addText(quips, "the flora here is fascinating. we should try to take a sample when we leave");
					addText(quips, "if only we could see the fully-grown flora before we depart");
				}
			}*/
				
			
			if (quips.length > 0 && Math.random() > .5)
			{
				text.push(quips[int(Math.random() * quips.length)]);
			}
			
			
			
			return text;
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
		}
		
		override public function get canExamine() : Boolean
		{
			return super.canExamine || (PlayState.instance.isEligibleForMournEnd && health == 0);
		}
		
		override public function examine() : void
		{
			if (PlayState.instance.isEligibleForMournEnd && health == 0)
			{
				PlayState.instance.onMourn();
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
				return "mourn";
			}
			else
			{
				return "talk";
			}
		}
		
		public function hasEnding(ending:int) : Boolean
		{
			return PlayState.instance.endings[ending];
		}
		
	}
	
}