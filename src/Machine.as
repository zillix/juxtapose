package 
{
	import mx.core.FlexApplicationBootstrap;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class Machine extends OrbHolderHideSpot 
	{
		[Embed(source = "data/machineSmall.png")]	public var MachineSprite:Class;
		[Embed(source = "data/machineLightBW.png")]	public var MachineLightSprite:Class;
		[Embed(source = "data/antenna.png")]	public var AntennaSprite:Class;
		[Embed(source = "data/damage.mp3")]	public var DamageSound:Class;
		[Embed(source = "data/deviceBroken.mp3")]	public var DeviceBrokenSound:Class;
		[Embed(source = "data/orbCharge.mp3")]	public var OrbChargeSound:Class;
			
		public static const MACHINE_NAME:String = "device";
		
		public var ORB_OFFSET:int = 17;
		
		protected static const LIGHT_Y:int = 42;
		protected static const LIGHT_SPACE_Y:int = 10;
		
		public static const MAX_LIGHTS:int = 4;
		protected var lights:Vector.<FlxSprite>;
		
		public var charge:int = 0;
		
		public var crushed:Boolean = false;
		
		public var isEnding:Boolean = false;
		public static const FADE_RATE:Number = .5;
		
		public var damage:int = 0;
		
		public var antennae:Vector.<FlxSprite> = new Vector.<FlxSprite>();
		
		public static const NUM_ANTENNAE:int = 4;
		
		public var damagedThisDay:Boolean = false;
		
		public var spawningRocks:Number = 0;
		public const ROCK_SPAWN_DURATION:Number = 1;
		
		public var nextRock:Number = 0;
		public const NEXT_ROCK:Number = .3;
		
		public function Machine(X:Number, Y:Number, S:int)
		{
			super(X, Y, S, 2, 68);
			//loadGraphic(MachineSprite, true, false, 15, 27);
			
			//scale.x = 4;
			//scale.y = 4;
			loadGraphic(MachineSprite, true, false, 30, 54);
			scale.x = 2;
			scale.y = 2;
			offset.x = width / 2;
			if (state == World.LIGHT)
			{
				offset.y = height * 3/2;
			}
			else
			{
				offset.y = -height / 2;
			}
			
			if (isLight)
			{
				for (i = 0; i < NUM_ANTENNAE; i++)
				{
					var antenna:FlxSprite = new FlxSprite(x - 19 + 10 * i, y - 98);
					antenna.loadGraphic(AntennaSprite, true, true, 9, 14);
					antenna.addAnimation("whole", [0]);
					antenna.addAnimation("broke1", [1]);
					antenna.addAnimation("broke2", [2]);
					antenna.play("whole");
					antenna.scale.x = antenna.scale.y = 2;
					antennae.push(antenna);
					PlayState.instance.objects.add(antenna);
					
				}
			}
			
			addAnimation("light", [0]);
			addAnimation("lightOpen", [1, 2, 3, 4, 5, 6], 6, false);
			addAnimation("lightBroken", [7, 8], .5, true);
			addAnimation("dark", [9]);
			addAnimation("darkOpen", [10, 11, 12, 13, 14, 15], 6, false);
			
			
			if (state == World.LIGHT)
			{
				play("light");
			}
			else
			{
				play("dark");
			}
			
			lights = new Vector.<FlxSprite>();
			for (var i:int = 0; i < MAX_LIGHTS; i++)
			{
				var light:FlxSprite = new FlxSprite(x, y + (state == World.LIGHT ? -LIGHT_Y : LIGHT_Y) + i * (isLight ? LIGHT_SPACE_Y : -LIGHT_SPACE_Y));
				light.loadGraphic(MachineLightSprite, true, false, 4, 4);
				light.addAnimation("off", [0]);
				light.addAnimation("on", [1]);
				light.play("off");
				light.offset.x = light.width / 2;
				light.offset.y = light.height / 2;
				PlayState.instance.objects.add(light);
				lights.push(light);
			}
			
		}
		
		override protected function arrangeOrbs() : void
		{
			for (var i:int = 0; i < orbs.length; i++)
			{
				var realOrb:Orb = orbs[i];
				var orb:FlxPoint = orbPoints[i];
				orb.x = x +( i == 0 ? -ORB_OFFSET : ORB_OFFSET);
				orb.y = y + (state == World.LIGHT ? -orbHeight : orbHeight);
				
				realOrb.targetPoint = orb;
			}
		}
		
		override public function update() : void
		{
			super.update();
			
			if (isEnding)
			{
				alpha -= FADE_RATE * FlxG.elapsed;
			}
		
			
			for (var i:int = 0; i < lights.length; i++)
			{
				if (charge > i)
				{
					lights[i].play("on");
				}
				else
				{
					lights[i].play("off");
				}
				
				lights[i].alpha = alpha;
			}
			
			for each (var orb:Orb in orbs)
			{
				orb.alpha = alpha;
				if (orb.glow != null)
				{
					orb.glow.alpha = alpha;
				}
			}
			
			for each (var antenna:FlxSprite in antennae)
			{
				antenna.alpha = alpha;
			}
			
			spawnRocks();
		}
		
		override public function onStateChanged(newState:int) : void
		{
			if (!visible || alpha == 0)
			{
				return;
			}
			
			damagedThisDay = false;
			
			if (state == newState && state == World.LIGHT)
			{
				spawningRocks = ROCK_SPAWN_DURATION;
			}
			
			if (newState == state)
			{
				return;
			}
			
			if (charge >= MAX_LIGHTS)
			{
				return;
			}
			
			charge += orbs.length;
			if (charge >= MAX_LIGHTS)
			{
				// do nothing
			}
		}
		
		override public function get canTakeOrb() : Boolean
		{
			return super.canTakeOrb && !crushed && alpha == 1;
		}
		
		override public function get canPlaceOrb() : Boolean
		{
			return super.canPlaceOrb && !crushed;
		}
		
		override public function addOrb(orb:Orb) : Boolean
		{
			if (!canPlaceOrb)
			{
				return false;
			}
			
			var bool:Boolean = super.addOrb(orb);
			orb.inMachine = true;
			return bool;
		}
		
		override public function removeOrb() : Orb
		{
			var orb:Orb = super.removeOrb();
			if (orb != null)
			{
				orb.inMachine = false;
			}
			
			return orb;
		}
		
		public function damageMachine() : void
		{
			if (damagedThisDay  || crushed)
			{
				return;
			}
			
			FlxG.play(DamageSound, PlayState.SFX_VOLUME);
			
			damagedThisDay = true;
			
			antennae[damage].play("broke" + (Math.random() < .5 ? 1 : 2));
			if (damage < NUM_ANTENNAE - 1)
			{
				damage++
			}
			else
			{
				crush();
			}
			
		}
		
		public function spawnRocks() : void
		{
			if (spawningRocks > 0)
			{
				spawningRocks -= FlxG.elapsed;
				nextRock += FlxG.elapsed;
				if (nextRock > NEXT_ROCK)
				{
					var rock:FallingRock = new FallingRock(x + Math.random() * 50 - 30, y - 180);
					PlayState.instance.objects.add(rock);
					nextRock = 0;
				}
			}
		}
		
		public function crush() : void
		{
			play("lightBroken");
			FlxG.play(DeviceBrokenSound, PlayState.SFX_VOLUME);
			
			for each (var orb:Orb in orbs)
			{
				orb.consume();
			}
			
			for each (var light:FlxSprite in lights)
			{
				light.visible = false;
			}
			
			crushed = true;
		}
		
		override public function playPlacementSound() : void
		{
			FlxG.play(OrbChargeSound, PlayState.SFX_VOLUME);
		}
		
		override public function getExamineText() : Vector.<PlayText>
		{
			var text:Vector.<PlayText> = new Vector.<PlayText>();
			var orbCount:int = PlayState.instance.getOrbCount(state);
			var day:int = PlayState.instance.day;
			
			addText(text, "a " + MACHINE_NAME);
			var chargeText:String = "";
			switch (charge)
			{
				case 0:
					chargeText = "it is not charged";
					break;
				
				case 1: 
				case 2:
					chargeText = "it is partially charged";
					break;
					
				case 3:
					chargeText = "it is nearly charged";
					break;
			}
			if (crushed)
			{
				chargeText = "it has been crushed by vines"
			}
			
			if (chargeText)
			{
				addText(text, chargeText);
			}
			if (crushed)
			{
				return text;
			}
			
			switch(orbs.length)
			{
				case 0:
					addText(text, "it has no orbs powering it");
					break;
				case 1:
					addText(text, "the orb powering it will charge it overnight");
					break;
					
				case 2:
				case 3:
					addText(text, "the orbs powering it will charge it overnight");
					break;
					
					
			}
			
			return text;
		}
		override public function get canActivate() : Boolean 
		{ return (charge >= MAX_LIGHTS && !PlayState.instance.endingGame) || (crushed && PlayState.instance.isEligibleForResignEnd); }
		override public function activate() : void
		{
			if (PlayState.instance.isEligibleForResignEnd)
			{
				PlayState.instance.onResign();
			}
			else if (PlayState.instance.isEligibleForBothEnd)
			{
				PlayState.instance.onMachineActivated(World.BOTH);
			}
			else
			{
				PlayState.instance.onMachineActivated(this.state);
			}
		}
		
		public function open() : void
		{
			if (isLight)
			{
				play("lightOpen");
			}
			else
			{
				play("darkOpen");
			}
			
			for each (var light:FlxSprite in lights)
			{
				light.visible = false;
			}
		}
		
		public function onEnding() : void
		{
			isEnding = true;
		}
		
		override public function kill() : void
		{
			super.kill();
			for each (var light:FlxSprite in lights)
			{
				light.kill();
			}
			
			
			for each (var orb:Orb in orbs)
			{
				orb.kill();
			}
		}
		
		override public function get activateString() : String
		{
			if ((isLight || PlayState.instance.isEligibleForBothEnd)
				&& PlayState.instance.getMaxPlantGrowth() >= Plant.MAX_GROWTH)
			{
				return PlayState.CATALYZE_TEXT;
			}
			else if (PlayState.instance.isEligibleForResignEnd)
			{
				return PlayState.RESIGN_TEXT;
			}
			else if (PlayState.instance.isEligibleForBothEnd)
			{
				return PlayState.EMBARK_TEXT;
			}
			else
			{
				return isLight ? PlayState.ABANDON_TEXT : PlayState.FLEE_TEXT
			}
		}
	}
	
}