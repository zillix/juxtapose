package {
	import org.flixel.*;
	[SWF(width="600", height="600", backgroundColor="#000000")]
	[Frame(factoryClass="Preloader")]
	public class Main extends FlxGame
	{
		public function Main():void
		{
			var scale:int = 1;
			super(600 / scale, 600 / scale, PlayState, scale);
		}
	}
}