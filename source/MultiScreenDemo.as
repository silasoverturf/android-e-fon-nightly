package 
{
	import feathers.system.DeviceCapabilities;
	import feathers.controls.ScreenNavigator;
	import feathers.controls.ScreenNavigatorItem;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.geom.Rectangle;
	import flash.events.Event;
	import flash.ui.ContextMenu;

	import starling.core.Starling;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	import com.josephlabrecque.multiScreenDemo.Main;

	public class MultiScreenDemo extends Sprite
	{
		private var starling:Starling;

		public function MultiScreenDemo()
		{
			var menu:ContextMenu = new ContextMenu();
			menu.hideBuiltInItems();
			this.contextMenu = menu;

			if (this.stage)
			{
				this.stage.align = StageAlign.TOP_LEFT;
				this.stage.scaleMode = StageScaleMode.NO_SCALE;
			}
			
			DeviceCapabilities.dpi = 265;
			DeviceCapabilities.screenPixelWidth = 480;
			DeviceCapabilities.screenPixelHeight = 800;
			
			this.loaderInfo.addEventListener(Event.COMPLETE, loaderInfoComplete);
		}

		private function loaderInfoComplete(e:Event):void
		{
			//Starling.handleLostContext = true;
			//Starling.multitouchEnabled = true;
			starling = new Starling(Main, this.stage);
			starling.showStats = true;
			starling.showStatsAt(HAlign.LEFT, VAlign.BOTTOM);
			starling.start();
			this.stage.addEventListener(Event.RESIZE, stageResized, false, int.MAX_VALUE, true);
			//this.stage.addEventListener(Event.DEACTIVATE, stageDeactivate, false, 0, true);
		}
		
		private function stageResized(e:Event):void
		{
			starling.stage.stageWidth = this.stage.stageWidth;
			starling.stage.stageHeight = this.stage.stageHeight;

			const viewPort:Rectangle = starling.viewPort;
			viewPort.width = this.stage.stageWidth;
			viewPort.height = this.stage.stageHeight;
			try
			{
				starling.viewPort = viewPort;
			}
			catch(error:Error) {
				//nuthin'
			}
			
			starling.showStatsAt(HAlign.LEFT, VAlign.BOTTOM);
		}
		
		private function stageDeactivate(e:Event):void
		{
			starling.stop();
			this.stage.addEventListener(Event.ACTIVATE, stageActivate, false, 0, true);
		}
		
		private function stageActivate(e:Event):void
		{
			this.stage.removeEventListener(Event.ACTIVATE, stageActivate);
			starling.start();
		}

	}
}