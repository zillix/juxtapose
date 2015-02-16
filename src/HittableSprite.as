package 
{
	import org.flixel.*;
	/**
	 * ...
	 * @author zillix
	 */
	public class HittableSprite extends GameSprite
	{
		[Embed(source = "data/damage.mp3")]	public var DamageSound:Class;
		
		public var enemyHitsToDamage:int = 20;
		protected var enemyHits:int = 0;
		protected var damagedThisDay:Boolean = false;
	
		public function HittableSprite(X:Number, Y:Number, S:int)
		{
			super(X, Y, S);
		}
		
		public function onEnemyHit(gameSprite:GameSprite) : void
		{
			if (!alive || damagedThisDay)
			{
				return;
			}
			
			emitParticle(gameSprite.x, gameSprite.y, 2, true, 0, 1, 0, 0, 0, 1.5);
			
			enemyHits++;
			if (enemyHits >= enemyHitsToDamage)
			{
				damagedThisDay = true;
				damage(gameSprite);
				enemyHits = 0;
				FlxG.play(DamageSound, PlayState.SFX_VOLUME);
				
			}
		}
		
		public function damage(enemy:GameSprite) : void {}
		
		override public function onStateChanged(newState:int ) : void
		{
			damagedThisDay = false;
		}
		
	}
	
}