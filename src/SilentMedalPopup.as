package 
{
	import com.newgrounds.components.MedalPopup;
	import flash.media.SoundTransform;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class SilentMedalPopup extends MedalPopup 
	{
		public function SilentMedalPopup()
		{
			super();
			var soundTr:SoundTransform = new SoundTransform();
			soundTr.volume = 0;
			
			this.soundTransform = soundTr;
		}
	}
	
}