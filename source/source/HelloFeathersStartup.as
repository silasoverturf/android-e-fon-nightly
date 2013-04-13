package 
{
	import flash.display.MovieClip;
	import starling.core.*;
 
	public class HelloFeathersStartup extends MovieClip
	{
		public function HelloFeathersStartup()
		{
			var st:Starling = new Starling(HelloFeathers, this.stage);
			st.showStats = true;
			st.start();
		}
	}
}