package 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class EndSprite extends FlxSprite 
	{
		public var focus:FlxSprite;
		public static const END_GRAPHIC_WIDTH:int = 110;
		public static const END_GRAPHIC_HEIGHT:int = 50;
		public var gameText:GameText;
		public var end:int;
		public var worldAngle:Number;
		
		public var FADE_RATE:Number = 1;
		public function EndSprite(Angle:Number, Distance:Number, Color:uint, EndString:String, End:int,  Focus:FlxSprite)
		{
			var X:Number = Distance * Math.cos(PlayState.toRadians(Angle)) + Focus.x;
			var Y:Number = Distance * Math.sin(PlayState.toRadians(Angle)) + Focus.y;
			super(X, Y);
			makeGraphic(END_GRAPHIC_WIDTH, END_GRAPHIC_HEIGHT, Color);
			offset.x = width / 2;
			offset.y = height / 2;
			
			angle = Angle + 90;
			end = End;
			worldAngle = Angle;
			
			var X2:Number = (Distance + 10)* Math.cos(PlayState.toRadians(Angle)) + Focus.x;
			var Y2:Number = (Distance + 10)* Math.sin(PlayState.toRadians(Angle)) + Focus.y;
			gameText = new GameText(World.BOTH, X2, Y2, END_GRAPHIC_WIDTH, EndString);
			gameText.setFormat("HACHEA", 16,  0xffffffff, "center");
			gameText.offset.x = gameText.width / 2;
			gameText.fullShadow = 0xff000000;
			gameText.angle = Angle + 90;
			gameText.antialiasing = true;
			PlayState.instance.endingTextFields.add(gameText);
			
			alpha = 0;
			
		}
		
		public function get isShown() : Boolean
		{
			return PlayState.instance.shouldShowEndings && PlayState.instance.isEndingUnlocked(end);
		}
		
		override public function update() : void
		{
			if (isShown)
			{
				alpha += FlxG.elapsed * FADE_RATE;
			}
			else
			{
				alpha -= FlxG.elapsed * FADE_RATE;
			}
			super.update();
			gameText.alpha = alpha;
		}
		
	}
	
}