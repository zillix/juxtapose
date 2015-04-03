package {
	import com.newgrounds.components.MedalPopup;
	import flash.display.MovieClip;
	import flash.events.Event;
	import org.flixel.*;
	[SWF(width="600", height="600", backgroundColor="#000000")]
	[Frame(factoryClass="Preloader")] 
	//[Frame(factoryClass="NGPreloader")] I'm not committing the NGPreloader! Build one yourself :)
	public class Main extends FlxGame
	{
		public function Main():void
		{
			var scale:int = 1;
			super(600 / scale, 600 / scale, PlayState, scale);
		}
		
		override protected function create(FlashEvent:Event):void
		{
			super.create(FlashEvent);
			
			var medalPopup:MedalPopup = new SilentMedalPopup();
            medalPopup.x = medalPopup.y = 5;
            if (root is MovieClip)
			{
				(root as MovieClip).addChild(medalPopup);
			}
		}
	}
}