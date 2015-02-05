package 
{
	import flash.geom.Rectangle;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class SecretPedestal extends OrbHolder 
	{
		[Embed(source = "data/secretPedestal.png")]	public var SecretPedestalSprite:Class;
		
		private var DISAPPEAR_VELOCITY:int = -100;
		private var REAPPEAR_VELOCITY:int = 100;
		private var isDisappeared:Boolean = false;
		
		private var startPosition:FlxPoint;
		
		private var invertGlow:InvertGlow;
		
		public function SecretPedestal(X:Number, Y:Number)
		{
			super(X, Y, World.LIGHT, 5);
			loadGraphic(SecretPedestalSprite);
			offset.x = 0;
			orbHeight = 86;
			scale.x = 2;
			scale.y = 2;
			offset.y = height * 3 / 2;
			
			startPosition = new FlxPoint(X, Y);
			/*scale.x = scale.y = 2;
			offset.x = -width / 2;
			offset.y = height * 3 / 2;
			*/
			
			if (PlayState.instance.DEBUG)
			{
				visible = true;
			}
			else
			{
				visible = false;
			}
		}
		
		override public function playPlacementSound() : void
		{
			//FlxG.play(StatueSound, PlayState.SFX_VOLUME);
		}
		
		override public function addOrb(orb:Orb) : Boolean
		{
			var bool:Boolean = super.addOrb(orb);
			if (bool)
			{
				invertGlow = new InvertGlow(x, y + (state == World.LIGHT ? -orbHeight : orbHeight));
				PlayState.instance.invertGlows.add(invertGlow);
				orb.consume();
			}
			
			return bool;
		}
		
		override public function get canTakeOrb() : Boolean
		{
			return false;
		}
		
		override public function update() : void
		{
			super.update();
			
			if (invertGlow != null && !invertGlow.alive)
			{
				startDisappearing();
				invertGlow = null;
			}
			
			if (velocity.y < 0 && y <= startPosition.y -height)
			{
				isDisappeared = true;
				velocity.y = 0;
			}
			
			if (velocity.y > 0 && y >= startPosition.y)
			{
				velocity.y = 0;
				y = startPosition.y;
			}
		}
		
		public function doBonus(): void
		{
			
		}
		
		override public function onStateChanged(newState:int) : void
		{
			if (newState == World.LIGHT && isDisappeared)
			{
				startReappearing();
			}
		}
		
		private function startDisappearing() : void
		{
			velocity.y = DISAPPEAR_VELOCITY;
		}
		
		private function startReappearing() : void
		{
			velocity.y = REAPPEAR_VELOCITY;
			isDisappeared = false;
		}
		
		
		
		/*override protected function arrangeOrbs() : void
		{
			for (var i:int = 0; i < orbs.length; i++)
			{
				var realOrb:Orb = orbs[i];
				var orb:FlxPoint = orbPoints[i];
				orb.x = x + ORB_OFFSET;
				orb.y = y + (state == World.LIGHT ? -orbHeight : orbHeight);
				realOrb.targetPoint = orb;
			}
		}*/
		
		/*override public function getHitbox() : Rectangle
		{
			var bounds:Rectangle = super.getHitbox();
			bounds.width -= 50;
			return bounds;
		}
		*/
		/*override public function getExamineText() : Vector.<PlayText>
		{
			var text:Vector.<PlayText> = new Vector.<PlayText>();
			var orbCount:int = PlayState.instance.getOrbCount(state);
			var day:int = PlayState.instance.day;
			
			switch (seedsSpawned)
			{
				case 0:
					addText(text, "a disturbing statue");
					addText(text, "it looks like something would fit in its mouth");
					break;
					
				case 1:
					addText(text, "a strange statue");
					break;
					
				case 2:
					addText(text, "an elegant statue. it looks like it wants more orbs.");
					break;
					
				case 3:
					addText(text, "a sublime statue");
					break;
			}
			
			return text;
		}*/
		
		override public function get canActivate() : Boolean 
		{
			/*if (PlayState.instance.isEligibleForWorshipEnd)
			{
				return true;
			}*/
			
			return false;
		}
		
		override public function activate() : void { PlayState.instance.onWorship(); }
		
		override public function get activateString() : String { return "worship"; }
		
	}
	
}