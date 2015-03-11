package
{
	import flash.geom.Rectangle;
	import org.flixel.*;
	import com.newgrounds.API;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class OrbBeam extends GameSprite 
	{
		[Embed(source = "data/orbBeamSound.mp3")]	public var OrbBeamSound:Class;
		[Embed(source = "data/orbBeamActivated.mp3")]	public var BeamActivatedSound:Class;
		public var MAX_WIDTH:Number = 40;
		public var MIN_WIDTH:Number = 5;
		public var EXPAND_SPEED:Number = 70;
		public var FRONT_COLOR:uint = 0xff00FFFF;
		public var BEAM_HEIGHT:Number = 250;
		public var FRONT_ALPHA:Number = .7;
		
		public static var BLACK_BEAM:uint = 0xff000000;
		public static var WHITE_BEAM:uint = 0xffffffff;
		
		public var elapsedTime:Number = 0;
		
		public var fullTime:Number = 0;
		
		public var growing:Boolean = true;
		public var disappear:Boolean = true;
		public var activated:Boolean = false;
		
		public var charges:Boolean = false;
		public var currentCharge:Number = 0 ;
		public var chargedLastFrame:Boolean = false;
		public static var MAX_CHARGE:Number = 2;
		public static var MIN_CHARGE:Number = -.55;
		public function OrbBeam(X:Number, Y:Number, state:int, Disappear:Boolean = true)
		{
			super(X, Y, state);
			FlxG.play(OrbBeamSound, PlayState.SFX_VOLUME);
			var color:uint = state == World.DARK ? WHITE_BEAM : BLACK_BEAM;
			makeGraphic(MIN_WIDTH, BEAM_HEIGHT, color);
			alpha = FRONT_ALPHA;
			
			if (state == World.LIGHT)
			{
				offset.y = BEAM_HEIGHT;
			}
			offset.x = width / 2;
			disappear = Disappear;
		}
		
		public override function update():void
		{
			elapsedTime += FlxG.elapsed;
			if (!charges)
			{
				var targetWidth:Number = width;
				if (growing)
				{
					targetWidth = MIN_WIDTH + elapsedTime * EXPAND_SPEED;
				}
				else
				{
					if (disappear)
					{
						targetWidth = MAX_WIDTH -  (elapsedTime  - fullTime) * EXPAND_SPEED;
					}
					else
					{
						targetWidth = MAX_WIDTH;
					}
				}
				scale.x = targetWidth / width;
				
				if (targetWidth >= MAX_WIDTH)
				{
					growing = false;
					fullTime = elapsedTime;
				}
				
				if (!growing && width * scale.x <= 1 && disappear)
				{
					alive = false;
					visible = false;
					
					if (getLampPostOrbCount() == LampPost.MAX_LAMP_POSTS)
					{
						PlayState.instance.triggerNyxBeam();
					}
				}
			}
			else
			{
				var lastScale:Number = scale.x;
				scale.x = Math.max(0, currentCharge / MAX_CHARGE * MAX_WIDTH / MIN_WIDTH);
				if (lastScale == 0 && scale.x > 0)
				{
					API.logCustomEvent("sol_beam_visible");
				}
				
				if (!chargedLastFrame && !isFullyCharged)
				{
					currentCharge = Math.max(currentCharge- FlxG.elapsed, MIN_CHARGE);
				}
				
				chargedLastFrame = false;
			}
		}
		
		override public function get canExamine() : Boolean 
		{ 
			return super.canExamine && 
				((!charges && !disappear)
				|| (charges && isFullyCharged)); 
		}
		
		override public function examine() : void
		{
			if (!activated)
			{
				activated = true;
				
				FlxG.play(BeamActivatedSound, PlayState.SFX_VOLUME);
				if (state == World.DARK)
				{
					PlayState.instance.triggerNyxEnding();
				}
				else
				{
					PlayState.instance.triggerSolEnding();
				}
			}
		}
		
		override public function get examineString() : String { 
			return state == World.DARK ? PlayState.NYX_TEXT : PlayState.SOL_TEXT;
		}
		
		
		
		private function getLampPostOrbCount() : int
		{
			var count:int = 0;
			for each (var orbHolder:OrbHolder in PlayState.instance.darkOrbHolders.members)
			{
				if ((orbHolder is LampPost) && orbHolder.orbs.length == 1)
				{
					count++;
				}
			}
			
			return count;
		}
		
		override public function getHitbox() : Rectangle
		{
			var box:Rectangle = super.getHitbox();
			box.width = 10;
			return box;
		}
		
		public function charge() : void
		{
			chargedLastFrame = true;
			var lastCharge:Number = currentCharge;
			currentCharge = Math.min(FlxG.elapsed + currentCharge, MAX_CHARGE);
			
			if (lastCharge < MAX_CHARGE && currentCharge >= MAX_CHARGE)
			{
				API.logCustomEvent("sol_beam_created");
			}
		}
		
		public function get isFullyCharged() : Boolean
		{
			return currentCharge >= MAX_CHARGE;
		}
		
		//override public function getExamineText() : Vector.<PlayText> { return null }
		
	}
	
}