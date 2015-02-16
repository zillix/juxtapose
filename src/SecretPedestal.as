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
		
		private var DISAPPEAR_VELOCITY:int = -50;
		private var REAPPEAR_VELOCITY:int = 100;
		private var isDisappeared:Boolean = false;
		
		private var startPosition:FlxPoint;
		
		private var invertGlow:InvertGlow;
		private var acceptedThisDay:Boolean = false;
		
		public function SecretPedestal(X:Number, Y:Number)
		{
			super(X, Y, World.LIGHT, 4);
			loadGraphic(SecretPedestalSprite);
			offset.x = width / 2;
			orbHeight = 66;
			//scale.x = 2;
			//scale.y = 2;
			//offset.y = height * 3 / 2;
			
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
		
		override public function get canPlaceOrb() : Boolean
		{
			return super.canPlaceOrb && !acceptedThisDay;
		}
		
		override public function addOrb(orb:Orb) : Boolean
		{
			var bool:Boolean = super.addOrb(orb);
			if (bool)
			{
				acceptedThisDay = true;
				invertGlow = new InvertGlow(x, y + (state == World.LIGHT ? -orbHeight : orbHeight));
				invertGlow.pulse(orbs.length);
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
			
			if (invertGlow != null)
			{
				if (!invertGlow.alive)
				{
					if (orbs.length < maxOrbs)
					{
						startDisappearing();
						invertGlow = null;
					}
					else
					{
						invertGlow.revive();
						invertGlow.radius = 50;
					}
				}
				else
				{
					invertGlow.x = x;
					invertGlow.y = y - orbHeight;
				}
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
				acceptedThisDay = false;
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
		
		/*override public function getHitbox() : Rectangle
		{
			var bounds:Rectangle = super.getHitbox();
			bounds.width -= 50;
			return bounds;
		}
		*/
		override public function getExamineText() : Vector.<PlayText>
		{
			var text:Vector.<PlayText> = new Vector.<PlayText>();
			addText(text, "a strange lamp");
			addText(text, "it sheds no light");
					
			
			return text;
		}
		
		override public function get canActivate() : Boolean 
		{
			return orbs.length == maxOrbs;
		}
		
		override public function activate() : void { PlayState.instance.onJuxtapose(); }
		
		override public function get activateString() : String { return "juxtapose"; }
		
	}
	
}