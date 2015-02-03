package 
{
	import flash.geom.Rectangle;
	import org.flixel.FlxSprite;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class CrushPlant extends GameSprite 
	{
		[Embed(source = "data/crushPlant.png")]	public var CrushPlantSprite:Class;
		public var growth:int = 0;
		
		public static const MAX_GROWTH:int = 4;
		
		public function CrushPlant(X:Number, Y:Number)
		{
			super(X, Y,World.LIGHT);
			loadGraphic(CrushPlantSprite, true, false, 40, 40);
			addAnimation("0", [0], 0, false);
			addAnimation("1", [1], 0, false);
			addAnimation("2", [2], 0, false);
			addAnimation("3", [3], 0, false);
			addAnimation("4", [4], 0, false);
			//offset.x = width;
			offset.y = height;
			scale.x = 2;
			scale.y = 2;
		}
		
			override public function update() : void
		{
			super.update();
		}
		
		override public function onStateChanged(newState:int) : void
		{
			super.onStateChanged(newState);
			if (growth == MAX_GROWTH)
			{
				return;
			}
			
			if (newState == World.LIGHT)
			{
				grow();
			}
		}
		
		public function grow() : void
		{
			growth = Math.min(growth + 1, MAX_GROWTH);
			play(growth.toString());
			
			if (growth == MAX_GROWTH)
			{
				PlayState.instance.crushLightMachine();
			}
		}
		
		
	}
	
}