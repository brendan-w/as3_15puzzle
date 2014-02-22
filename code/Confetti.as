//Brendan Whitfield
package code
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class Confetti extends MovieClip
	{
		//constants
		private const minAccel:Number = 0.25;
		private const maxAccel:Number = 0.75;
		private const maxSpin:Number = 5;
		//objects
		private var manager:Object = null;
		//vars
		private var speed:Number = 0;
		private var spin:Number = 0;
		private var accel:Number = 0;

		public function Confetti(mgr:Main)
		{
			manager = mgr;
			gotoAndStop(int(Math.random() * framesLoaded) + 1); //randomize color
			//random acceleration (bracketed by minAccel and maxAccel)
			accel = (Math.random() * (maxAccel / minAccel)) + minAccel;
			//random spin
			spin = Math.random() * maxSpin;
			//random spin direction
			if(Math.random() > 0.5) spin *= -1;
			//loop every frame
			addEventListener(Event.ENTER_FRAME, frameLoop);
		}
		
		//adjust the position and rotation on every frame
		private function frameLoop(e:Event):void
		{
			//update the position and speed
			speed += accel;
			this.y += speed;
			this.rotation += spin;
			//delete the piece if it's offstage
			if(this.y > stage.stageHeight)
			{
				//kill this piece
				removeEventListener(Event.ENTER_FRAME, frameLoop);
				manager.removeMe(this);
			}
		}
	}
}