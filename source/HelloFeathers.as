package
{
	import starling.display.*;
	import flash.display.MovieClip;
	import feathers.themes.MetalWorksMobileTheme;
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.controls.Callout;
	import starling.events.Event;
 
	class HelloFeathers extends MovieClip
	{
		public function HelloFeathers()
		{
			this.addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler );
		}
 
		protected var theme:MetalWorksMobileTheme
		protected var button:Button;
 
		protected function addedToStageHandler( event:Event ):void
		{
			this.theme = new MetalWorksMobileTheme(this.stage);
 
			this.button = new Button();
			this.button.label = "Click Me";
			this.addChild(button);
 
			this.button.addEventListener(Event.TRIGGERED, bt);
 
			this.button.validate();
			this.button.x = (this.stage.stageWidth - this.button.width) / 2;
			this.button.y = (this.stage.stageHeight - this.button.height) / 2;
		}
 
		private function bt(e:Event):void
		{
			const label:Label = new Label();
			label.text = "Hi, I'm Feathers!\nHave a nice day.";
			Callout.show(label, this.button);
		}
	}	
}