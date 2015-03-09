package 
{
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class SuperSecretEndSprite extends FlxGroup
	{
		[Embed(source = "data/nyxOverlay.png")]	public var NyxOverlaySprite:Class;
		[Embed(source = "data/solOverlay.png")]	public var SolOverlaySprite:Class;
		
		public var overlay:FlxSprite;
		public var text:GameText;
		public var state:int;
		
		public static const MAX_OVERLAY_ALPHA:Number = .9;
		public static const OVERLAY_ALPHA_RATE:Number = 1;
		public static const OVERLAY_FADE_RATE:Number = .5;
		
		protected var nextTextCount:Number = 0;
		protected static const TEXT_TIMER:Number = .33;
		protected var nextTextIndex:int = 0;
		
		protected var startedEnd:Boolean = false;
		
		protected var textList:Vector.<String> = new Vector.<String>;
		
		public function SuperSecretEndSprite(State:int)
		{
			super();
			state = State;
		
			overlay = new FlxSprite(FlxG.width / 2, FlxG.height / 2, state == World.LIGHT ? SolOverlaySprite : NyxOverlaySprite);
			add(overlay);
			overlay.offset.x = overlay.width / 2;
			overlay.offset.y = overlay.height / 2;
			overlay.alpha = 0;
			
			if (state == World.DARK)
			{
				overlay.angle = 180;
			}
			
			var textColor:uint =0xffffffff;
			var fullShadowColor:uint = 0xff000000;
			
			text = new GameText(World.BOTH, FlxG.width / 2, FlxG.height / 2, FlxG.width, "");
			
			if (state == World.DARK)
			{
				text.angle = 180;
				text.x += 0;
				text.y += FlxG.height * 2 / 2;
			}
			
			text.setFormat("HACHEA", 80, textColor, "center");
			text.fullShadow = fullShadowColor;
			text.fullShadowMagnitude = 10;
			text.offset.x = text.width / 2;
		//	text.blend = "invert";
			add(text);
			
			if (state == World.LIGHT)
			{
				textList = new < String > ["the", " light", " of", "\nSOL", "\nwill", " scorch", " the", " world"];
			}
			else
			{
				textList = new < String > ["the", " umbra", " of", "\nNYX", "\nwill", " shroud", " the", " world"];
			}
		}
		
		override public function update() : void
		{
			super.update();
			
			if (!startedEnd)
			{
				overlay.alpha = Math.min(overlay.alpha + FlxG.elapsed * OVERLAY_ALPHA_RATE, MAX_OVERLAY_ALPHA);
			}
			else
			{
				overlay.alpha -= FlxG.elapsed * OVERLAY_FADE_RATE;
				text.alpha -= FlxG.elapsed * OVERLAY_FADE_RATE;
			}
			
			
			text.offset.x = text.width / 2;
			text.offset.y = FlxG.height / 2;
			
			if (overlay.alpha == MAX_OVERLAY_ALPHA)
			{
				nextTextCount += FlxG.elapsed;
				if (nextTextCount >= TEXT_TIMER)
				{
					if (nextTextIndex < textList.length)
					{
						nextTextCount = 0;
						text.text += textList[nextTextIndex];
						nextTextIndex++;
						FlxG.shake(.05, .2);
					}
					else if (!startedEnd)
					{
						startEnd();
					}
				}
			}
		}
		
		protected function startEnd() : void
		{
			startedEnd = true;
			FlxG.shake(.06, 2);
			FlxG.flash(state == World.LIGHT ? 0xffffffff : 0xff000000, 
				1, 
				state == World.LIGHT ? 
					PlayState.instance.onSolEnd
					: PlayState.instance.onNyxEnd);
		}
	}
	
}