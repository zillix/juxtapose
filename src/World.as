package 
{
	import flash.events.EventDispatcher;
	import org.flixel.FlxSprite;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class World extends FlxSprite 
	{
		[Embed(source = "data/world2.png")]	public var WorldSprite:Class;
		[Embed(source = "data/swarmSound.mp3")]	public var SwarmSound:Class;
		
		public var worldAngle:Number = 0;
		
		public static const LIGHT:int = 0;
		public static const DARK:int = 1;
		public static const BOTH:int = 2;
		public var state:int = 0;
		
		public const ROTATE_SPEED:Number = 150;
		public const END_ROTATE_SPEED:Number = 400;
		public const SLOW_ROTATE_SPEED:Number = 50;
		public var rotateSpeed:Number = 0;
		public var maxSpeed:Number;
		public const ROTATE_ACCELERATION:Number = 200;
		
		public static const MAX_DISTANCE:int = 150;
		public static const ESCAPE_DISTANCE:int = 170;
		
		public static const SWARM_DURATION:Number = 3;
		public var swarmTimer:Number = 0;
		public static const SWARM_SPAWN_TIME:Number = .01;
		public var swarmSpawnTimer:Number = 0;
		
		public var rotating:Boolean = false;
		public var endSpinning:Boolean = false;
		public var endSpinTime:Number = 0;
		public static const END_SPIN_TIME:Number = 4;
		
		public static const DECELERATION:Number = 100;
		
		
		public static const GRAVITY:int = 100;
		
		public var targetEnding:EndSprite;
		
		public var nextStateRequested:Boolean = false;
		
		public function World(X:Number, Y:Number)
		{
			super(X, Y);
			loadGraphic(WorldSprite);
			offset.x = width / 2;
			offset.y = width / 2;
			maxSpeed = ROTATE_SPEED;
		}
		
		override public function update() : void
		{
			super.update();
			
			
			
			tickSwarm();
			
			if (rotating)
			{
				if (rotateSpeed < maxSpeed)
				{
					rotateSpeed = Math.min(maxSpeed, rotateSpeed + FlxG.elapsed * ROTATE_ACCELERATION);
		
				}
				else if (rotateSpeed > maxSpeed)
				{
					rotateSpeed = Math.max(maxSpeed, rotateSpeed - FlxG.elapsed * DECELERATION);
				}
			}
			
			/*if (!PlayState.instance.hasStartedGame)
			{
				worldAngle = 180;
				//worldAngle += SLOW_ROTATE_SPEED * FlxG.elapsed;
				return;
			}*/
			
			if (targetEnding != null)
			{
				var endingAngle:Number = -targetEnding.worldAngle - 90;
				if (worldAngle > endingAngle)
				{
					worldAngle -= 360;
				}
				if (worldAngle < endingAngle)
				{
					worldAngle += rotateSpeed * FlxG.elapsed;
					if (worldAngle >= endingAngle)
					{
						worldAngle = endingAngle;
						onFinishedRotating();
					}
				}
				return;
			}
			
			
			if (endSpinning)
			{
				worldAngle += rotateSpeed * FlxG.elapsed;
				endSpinTime -= FlxG.elapsed;
				if (endSpinTime <= 0)
				{
					maxSpeed = SLOW_ROTATE_SPEED;
					if (rotateSpeed == maxSpeed)
					{
						endSpinning = false;
						PlayState.instance.finishedEndRotating = true;
						if (state != BOTH)
						{
							state = (PlayState.instance.endingState + 1) % 2;
						}
					}
				
				}
				
				return;
			}
			
			if (state == LIGHT)
			{
				if (worldAngle >= 180)
				{
					worldAngle -= 360;
				}
				if (worldAngle < 0 || worldAngle > 0 && worldAngle < 180)
				{
					worldAngle += rotateSpeed * FlxG.elapsed;
					if (worldAngle >= 0)
					{
						worldAngle = 0;
						onFinishedRotating();
					}
				}
			}
			
			if (state == DARK)
			{
				if (worldAngle > 180)
				{
					worldAngle -= 360;
				}
				if (worldAngle < 180)
				{
					worldAngle += rotateSpeed * FlxG.elapsed;
					if (worldAngle >= 180)
					{
						worldAngle = 180;
						onFinishedRotating();
					}
				}
			}
			
			if (state == BOTH)
			{
				if (worldAngle > -90)
				{
					worldAngle -= 360;
				}
				if (worldAngle < -90)
				{
					worldAngle += rotateSpeed * FlxG.elapsed;
					if (worldAngle >= -90)
					{
						worldAngle = -90;
						onFinishedRotating();
					}
				}
			}
			
			if (nextStateRequested)
			{
				if (canAdvanceState)
				{
					advanceState();
				}
			}
			
		}
		
		public function onFinishedRotating() : void
		{
			rotating = false;
			rotateSpeed = 0;
			
			if (targetEnding)
			{
				PlayState.instance.onRotatedToTargetEnding();
				return;
			}
			
			PlayState.instance.onStateChanged(state);
			
			if (state == DARK)
			{
				
			}
			else if (state == LIGHT)
			{
				FlxG.play(SwarmSound, PlayState.SFX_VOLUME * 1 / 3);
				startFiendSwarm(SWARM_DURATION);
			}
		}
		
		public function startFiendSwarm(duration:int) : void
		{
			swarmTimer = SWARM_DURATION;
		}
		
		public function tickSwarm() : void
		{
			if (swarmTimer > 0)
			{
				swarmTimer -= FlxG.elapsed;
				swarmSpawnTimer -= FlxG.elapsed;
				if (swarmSpawnTimer < 0)
				{
					spawnFiend();
					swarmSpawnTimer = SWARM_SPAWN_TIME;
				}
			}
		}
		
		public function spawnFiend() : void
		{
			var spawnAngle:Number =	 PlayState.toRadians(Math.random() * 180 + 0);
			var spawnDist:Number = this.width / 2;
			var fiend:Fiend = new Fiend(Math.cos(spawnAngle) * spawnDist + x, Math.sin(spawnAngle) * spawnDist + y, World.DARK);
			PlayState.instance.fiends.add(fiend);
		}
		
		public function startEndSpin() : void
		{
			endSpinning = true;
			maxSpeed = END_ROTATE_SPEED;
			rotating = true;
			endSpinTime = END_SPIN_TIME;
		}
		
		public function setHalfState() : void
		{
			state = World.BOTH;
			rotating = true;
		}
		
		public function nextState() : void
		{
			nextStateRequested = true;
		}
		
		public function get canAdvanceState() : Boolean
		{
			if (rotating)
			{
				return false;
			}
			
			if (swarmTimer > 0)
			{
				return false;
			}
			
			return true;
		}
		
		public function advanceState() : void
		{
			if (rotating)
			{
				return;
			}
			state = (state + 1) % 2;
			rotating = true;
			nextStateRequested = false;
			targetEnding = null;
		}
		
		public function clearTargetEnding() : void
		{
			targetEnding = null;
		}
		
		public function setTargetEnding(ending:EndSprite) : void
		{
			targetEnding = ending;
			rotating = true;
			var endingAngle:Number = -targetEnding.worldAngle - 90;
			if (endingAngle <= -180)
			{
				endingAngle += 360;
			}
			if (endingAngle > 180)
			{
				endingAngle -= 360;
			}
			if (worldAngle == endingAngle)
			{
				onFinishedRotating();
			}
		}
		
		
	}
	
}