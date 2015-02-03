package 
{
	import flash.text.TextField;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class Player extends GameSprite 
	{
		[Embed(source = "data/grabOrb2.mp3")]	public var GrabOrbSound:Class;
		
		public static var WALK_SPEED:Number = 70;
		public static var PLAYER_TEXT_OFFSET:int = 150;
		
		public var carriedOrb:Orb;
		
		public var touchedOrbHolder:OrbHolder;
		public var touchedNPC:NPC;
		public var touchedPlant:Plant;
		
		public var textField:GameText;
		public var textFieldAlpha:Number = 1;
		public var TEXT_FIELD_HIDE_ALPHA:Number = -1;
		public var TEXT_FIELD_SHOW_RATE:Number = 2;
		
		public var gaveUp:Boolean = false;
		
		public var fading:Boolean = false;
		public var escaping:Boolean = false;
		
		public var FADE_RATE:Number = 1;
		
		public var carryPoint:FlxPoint;
		public static const HOLD_OFFSET:int = 15;
		
		
		public var kneelTime:Number = 0;
		public static const KNEEL_TIME:Number = 1.7;
		public var kneeling:Boolean = false;
		public var forceKneeling:Boolean = false;
		
		
		public var riseTime:Number = 0;
		public static const RISE_TIME:Number = 1;
		public var rising:Boolean = false;
		
		
		public function Player(X:Number, Y:Number, state:int)
		{
			super(X, Y, state);
			offset.x = width / 2;
			textField = new GameText(state, X, Y + (isLight ? -PLAYER_TEXT_OFFSET : PLAYER_TEXT_OFFSET), 100, "test text", true);
			textField.setFormat("HACHEA", 8, isLight ? 0xff000000 : 0xffffffff, "center");
			textField.offset.x = textField.width / 2;
			textField.fullShadow = state == World.LIGHT ? 0xffffffff : 0xff000000;
			PlayState.instance.textFields.add(textField);
			carryPoint = new FlxPoint(x + (facing == RIGHT ? HOLD_OFFSET : -HOLD_OFFSET), armsY)
		}
		
		override public function update() : void
		{
			super.update();
			
			if (fading && alpha == 0)
			{
				return;
			}
			
			carryPoint.x = x + (facing == RIGHT ? HOLD_OFFSET : -HOLD_OFFSET);
			carryPoint.y = armsY;
			
			if (fading)
			{
				alpha -= FADE_RATE * FlxG.elapsed;
			}
			
			textField.text = getTextFieldText();
			
			textFieldAlpha = Math.min(1, textFieldAlpha + FlxG.elapsed * TEXT_FIELD_SHOW_RATE);
			textField.alpha = textFieldAlpha;
			
			textField.x = x;
			
			if (carriedOrb != null)
			{
				carriedOrb.targetPoint = carryPoint;
			}
			
			if (PlayState.instance.DEBUG)
			{
				if (FlxG.keys.justPressed("F"))
				{
					WALK_SPEED *= 1.5;
				}
			}
			
			if (escaping && !isImmobile)
			{
				var escapeX:Number = PlayState.instance.world.x + World.ESCAPE_DISTANCE * .55;
				if (Math.abs(x - escapeX) < 4)
				{
					
					escaping = false;
					play("kneel");
					kneeling = true;
					forceKneeling = true;
				}
				else if (x < escapeX)
				{
					play("walk");
					velocity.x = WALK_SPEED;
				}
				else if (x >= escapeX)
				{
					velocity.x = -WALK_SPEED;
					play("walk");
				}
			}
			
			if (isImmobile)
			{
				velocity.x = 0;
			}
			if (riseTime > 0)
			{
				riseTime -= FlxG.elapsed;
				if (riseTime <= 0)
				{
					rising = false;
				}
			}
				
			
			if (isActive)
			{
				if (FlxG.keys.justPressed("DOWN"))
				{
					kneeling = true;
					play("kneel");
					
				}
				if (FlxG.keys.DOWN && kneeling && !PlayState.instance.pendingEndingBlocksSleeping)
				{
					kneelTime += FlxG.elapsed;
					
					
					if (kneelTime > KNEEL_TIME)
					{
						kneelTime = 0;
						finishKneeling();
					}
				}
				else if (!forceKneeling)
				{
					kneelTime = 0;
					if (PlayState.instance.state == state)
					{
						if (kneeling)
						{
							kneeling = false;
							rise();
						}
					}
				}
			}
			
			if (state == PlayState.instance.state)
			{
 				if (FlxG.keys.justPressed("SPACE") && !PlayState.instance.giveUpDarknessMaxAlpha && !PlayState.instance.shouldShowEndings )
				{
					if (!(PlayState.instance.endingGame && state == PlayState.instance.endingState))
					{
						if (touchedPlant != null && touchedPlant.growth == Plant.MAX_GROWTH)
						{
							tend();
						}
						else if (isHopeless)
						{
							
							{
								giveUp();
							}
						}
						else
						{
							var didAction:Boolean = true;
							if (touchedOrbHolder != null)
							{
								if (touchedOrbHolder.canActivate)
								{
									touchedOrbHolder.activate();
								}
								else if (!carriedOrb && touchedOrbHolder.canTakeOrb)
								{
									grabOrb(touchedOrbHolder);
									textFieldAlpha = TEXT_FIELD_HIDE_ALPHA;
								}
								else if (carriedOrb && touchedOrbHolder.canPlaceOrb)
								{
									placeOrb(carriedOrb, touchedOrbHolder);
									textFieldAlpha = TEXT_FIELD_HIDE_ALPHA;
								}
								else if (touchedOrbHolder.canExamine && canQueueText)
								{
									touchedOrbHolder.examine();
								}
								else
								{
									didAction = false;
								}
							}
							else
							{
								didAction = false;
							}
							
							if (!didAction && touchedNPC != null && touchedNPC.canExamine && canQueueText)
							{
								touchedNPC.examine();
							}
						}
					}
					
				}
				
				if (!(PlayState.instance.endingGame && state == PlayState.instance.endingState))
				{
					if (leftPressed)
					{
						facing = LEFT;
						velocity.x = -WALK_SPEED;
						x = Math.max(x, PlayState.instance.world.x - World.MAX_DISTANCE);
						play("walk");
					}
					else if (rightPressed)
					{
						facing = RIGHT;
						velocity.x = WALK_SPEED;
						play("walk");
						x = Math.min(x, PlayState.instance.world.x + World.MAX_DISTANCE);
					}
					else
					{
						stand();
					}
				}
			}
			else if (!escaping)
			{
				stand();
			}
			
			touchedOrbHolder = null;
			touchedNPC = null;
			touchedPlant = null;
		}
		
		private function stand() : void
		{
			if (!isImmobile)
			{
				play("stand");
				velocity.x = 0;
			}
		}
		
		private function getTextFieldText() : String
		{
			if (state != PlayState.instance.state)
			{
				return "";
			}
			
			if (gaveUp)
			{
				return "";
			}
			
			
			
			if (PlayState.instance.endingGame && !PlayState.instance.finishedEndRotating)
			{
				if (!PlayState.instance.finalEndingSequence || PlayState.instance.endingState == state)
				{
					return "";
				}
			}
			
			if (touchedPlant != null && touchedPlant.growth == Plant.MAX_GROWTH && PlayState.instance.isEligibleForTendEnd)
			{
				return "tend";
			}
			
			if (isHopeless)
			{	
				return "give up";
			}
			
			if (touchedOrbHolder != null)
			{
				if (touchedOrbHolder.canActivate)
				{
					return touchedOrbHolder.activateString;
				}
				
				if (carriedOrb != null && touchedOrbHolder.canPlaceOrb)
				{
					return "place";
				}
				
				if (carriedOrb == null && touchedOrbHolder.canTakeOrb)
				{
					return "take";
				}
				
				if (touchedOrbHolder.canExamine && canQueueText)
				{
					return touchedOrbHolder.examineString;
				}
				
			}
			
			if (touchedNPC != null && touchedNPC.canExamine &&  canQueueText)
			{
				return touchedNPC.examineString
			}
			
			return "";
		}
		
		private function grabOrb(holder:OrbHolder) : void
		{
			if (holder == null)
			{
				return;
			}
			
			carriedOrb = holder.removeOrb();
			if (carriedOrb != null)
			{
				FlxG.play(GrabOrbSound, PlayState.SFX_VOLUME);
				carriedOrb.carried = true;
			}
		}
		
		private function placeOrb(orb:Orb, holder:OrbHolder) : void
		{
			if (holder == null)
			{
				return;
			}
			
			if (carriedOrb != null)
			{
				var success:Boolean = holder.addOrb(orb);
				
				if (success)
				{
					orb.carried = false;
					carriedOrb = null;
				}
			}
		}
		
		public function get isHopeless() : Boolean
		{
			if (PlayState.instance.hasPendingEnding && !PlayState.instance.endingGame)
			{
				return false;
			}
			
			if (!PlayState.instance.getMachine(state) || PlayState.instance.getMachine(state).crushed)
			{
				return true;
			}
			
			if (PlayState.instance.endingGame && state != PlayState.instance.endingState)
			{
				return true;
			}
			
			if (PlayState.instance.countLivingNpcs(state) == 0)
			{
				return true;
			}
			
			if (PlayState.instance.getOrbCount(World.LIGHT) + PlayState.instance.getOrbCount(World.DARK) > 0)
			{
				return false;
			}
			/*if (PlayState.instance.tower.orbs.length > 0)
			{
				return false;
			}
			
			if (carriedOrb != null)
			{
				return false;
			}
			
			if (PlayState.instance.getMachine(state).crushed)
			{
				return true;
			}
			
			var group:FlxGroup = isLight ? PlayState.instance.lightOrbHolders : PlayState.instance.darkOrbHolders;
			for each (var holder:OrbHolder in group.members)
			{
				if (holder.canTakeOrb)
				{
					return false;
				}
			}*/
			
			return true;
		}
		
		public function kneel() : void
		{
			
		}
		
		public function finishKneeling() : void
		{
			PlayState.instance.onFinishKneeling();
		}
		
		override public function onStateChanged(newState:int) : void
		{
			gaveUp = false;
			if (newState == state)
			{
				rise();
			}
		}
		
		public function tend() : void
		{
			PlayState.instance.onTend();
		}
		
		
		public function giveUp() : void
		{
			gaveUp = true;
			PlayState.instance.onGiveUp();
		}
		
		public function get canQueueText() : Boolean
		{
			return !PlayState.instance.isTextPlayerBusy;
		}
		
		public function get isImmobile() : Boolean
		{
			return kneeling || rising;
		}
		
		public function rise() : void
		{
			kneeling = false;
			//if (kneelTime > KNEEL_TIME * 2 / 3)
			{
				play("rise");
			}
			rising = true;
			riseTime = RISE_TIME;
		}
		
		public function startEscape() : void
		{
			escaping = true;
			if (kneeling)
			{
				rise();
			}
		}
		
		public function get armsY() : Number { return y; }
		
		public function get leftPressed() : Boolean { return false; }
		public function get rightPressed() : Boolean { return false; }
		public function get downPressed() : Boolean { return false; }
		public function get upPressed() : Boolean { return false; }
	}
	
}