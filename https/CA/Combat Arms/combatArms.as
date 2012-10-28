package 
{
	import flash.display.*;
	import flash.net.*;
	import flash.geom.*;
	import flash.events.*;
	import flash.xml.*;
	import flash.text.*;
	import flash.events.MouseEvent;
	import fl.display.ProLoader;
	import flash.utils.getTimer;
	import com.greensock.plugins.*;
	import com.greensock.TweenMax;
	import com.greensock.text.SplitTextField;
	import com.greensock.easing.*;
	
	public class combatArms extends MovieClip 
	{
		//Img loading
		private var imgLoader:ProLoader;
		private var imgUrlArray:Array;
		private var imgUrl:String;

		//Split text fields
		private var stfHome:SplitTextField;
		private var stfSubtype:SplitTextField;
		
		//XML
		private var myXML:XML;
		private var XML_URL:String;
		private var myXMLURL:URLRequest;
		private var myLoader:URLLoader;
		
		//Primary Array
		private var primaryArray:Array;
		
		//Weapon detail arrays
		private var lineup:String;

		private var lineupArray:Array;
		private var priceArray:Array;
		private var descriptionArray:Array;
		private var damageArray:Array;
		private var portabilityArray:Array;
		private var rofArray:Array;
		private var accuracyArray:Array;
		private var recoilArray:Array;
		private var firingArray:Array;		
		
		//Throw props
		private var t1:uint;
		private var t2:uint;
		private var y1:Number;
		private var y2:Number;
		
		//Patterns
		private var hyphenPattern:RegExp;
		private var spacePattern:RegExp;

		//Public Funtion
		public function combatArms()
		{
     
			TweenPlugin.activate([ThrowPropsPlugin]);
			
			primaryArray = ["assault","sub","sniper","machine","shotgun","launcher"];
						
			lineupArray = [];
			priceArray = [];
			descriptionArray = [];
			damageArray = [];
			portabilityArray = [];
			rofArray = [];
			accuracyArray = [];
			recoilArray = [];
			firingArray = [];
			imgUrlArray = [];
			t1, t2, y1, y2;
			
			hyphenPattern = /-/gi;
			spacePattern = / /gi;
			
			stfHome = new SplitTextField(homeText,SplitTextField.TYPE_WORDS);
			
			TweenMax.allTo(stfHome.textFields,0,{x:"+200",autoAlpha:0,blurFilter:{blurX:20}},0);
			TweenMax.allTo(stfHome.textFields,1.5,{delay:0.5,x:"-200",autoAlpha:1,blurFilter:{blurX:00}, ease:Sine.easeInOut, onComplete:stfHome.addEventListener(MouseEvent.CLICK, loadXML)
},0.1)
			
			backBtn.addEventListener(MouseEvent.CLICK, home);
			weaponDetailMc.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler)
			infoBtn.addEventListener(MouseEvent.CLICK, infoHandler);
		}

		//Load and push XML vars, fire subType event
		private function loadXML(event:MouseEvent):void
		{	
			stfHome.removeEventListener(MouseEvent.CLICK, loadXML);
			infoBtn.removeEventListener(MouseEvent.CLICK, infoHandler);
			
			TweenMax.to(infoBtn,2,{autoAlpha:0, ease:Sine.easeInOut});
			
			var objects:Array = stfHome.getObjectsUnderPoint(new Point(event.stageX,event.stageY));
			if (objects.length != 0)
			{
				var clickedTextField:TextField = objects[0] as TextField;
			}
		
			myXML = new XML  ;
			XML_URL = "http://www.timothyoverturf.com/XML/" + primaryArray[stfHome.textFields.indexOf(clickedTextField)] + ".xml";
			myXMLURL = new URLRequest(XML_URL);
			myLoader = new URLLoader(myXMLURL);
			myLoader.addEventListener("complete",xmlLoaded);
		
			headerHandler("activate","loading");
			//Load XML;
			function xmlLoaded(event:Event):void
			{
				myXML = XML(myLoader.data);
				var xmlDoc:XMLDocument = new XMLDocument  ;
				xmlDoc.ignoreWhite = true;
				var menuXML:XML = XML(myLoader.data);
				xmlDoc.parseXML(menuXML.toXMLString());
		
				subtypeText.text = ".";
				//Assign variables
				for each (var Guns:XML in myXML..Gun)
				{
					lineup = Guns.lineup.toString();
					subtypeText.appendText("\n" + lineup);
		
					descriptionArray.push(Guns.Description);
					priceArray.push(Guns.price);
					damageArray.push(Guns.Damage);
					portabilityArray.push(Guns.portability);
					rofArray.push(Guns.rof);
					accuracyArray.push(Guns.accuracy);
					recoilArray.push(Guns.recoil);
					firingArray.push(Guns.firing);
					lineupArray.push(Guns.lineup);
		
					imgUrl = lineup.replace(spacePattern, "_")
					
					imgUrlArray.push(imgUrl.replace(hyphenPattern, "_"));
				}
		
				subType();
				header1.headerText2.text = primaryArray[stfHome.textFields.indexOf(clickedTextField)];
		 	}
		}
		
		//Create/activate stf and fire subType tweens
		private function subType(event:Event = null):void
		{
			stfSubtype = new SplitTextField(subtypeText,SplitTextField.TYPE_LINES);
			stfSubtype.activate();
			
			TweenMax.allTo(stfHome.textFields,1,{x:"-320",autoAlpha:0,blurFilter:{blurX:20}, ease:Sine.easeInOut},0.1);
			TweenMax.allTo(stfSubtype.textFields,0,{autoAlpha:0,blurFilter:{blurX:20}, ease:Sine.easeInOut},0);
		
			TweenMax.allTo(stfSubtype.textFields,1,{x:"-320",autoAlpha:1,blurFilter:{blurX:0}, ease:Sine.easeInOut},0.1);
			
			stfSubtype.addEventListener(MouseEvent.CLICK, weaponDetail);
			
			//weaponDetailMc.removeChild(imgLoader);
		}
		
		//Toggle header state and assign title text
		private function headerHandler(headerState:String, string:String):void
		{
			if (headerState == "activate")
			{
				TweenMax.to(header1,1.5,{y:-55, ease:Sine.easeInOut});
				TweenMax.to(backBtn,1.5,{x:30, ease:Sine.easeInOut});
				header1.headerText2.text = string;
			}
		
			if (headerState == "deactivate")
			{
				TweenMax.to(header1,1.5,{y:0, ease:Sine.easeInOut});
				TweenMax.to(backBtn,1.5,{x:-30, ease:Sine.easeInOut});
				header1.headerText2.text = "arms";
			}
		}
		
		private function infoHandler(event:MouseEvent):void
		{
			infoBtn.removeEventListener(MouseEvent.CLICK, infoHandler);
			TweenMax.to(info,2,{y:80, ease:Sine.easeInOut});
			TweenMax.to(infoBtn,2,{autoAlpha:0, ease:Sine.easeInOut});
			headerHandler("activate", "info");
			TweenMax.allTo(stfHome.textFields,1,{x:"-320",autoAlpha:0,blurFilter:{blurX:20}, ease:Sine.easeInOut},0.1);
		}
		
		//Assign XML vars, and fire weaponDetail tweens
		private function weaponDetail(event:MouseEvent):void
		{
			weaponDetailMc.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler)
			
			TweenMax.allTo(stfSubtype.textFields,1,{x:"-320",autoAlpha:0,blurFilter:{blurX:20}, ease:Sine.easeInOut},0.1);
			TweenMax.to(weaponDetailMc,1,{delay:1,x:10, blurFilter:{blurX:0}, autoAlpha:1, ease:Sine.easeInOut});
		
			var objects2:Array = stfSubtype.getObjectsUnderPoint(new Point(event.stageX,event.stageY));
			if (objects2.length != 0)
			{
				var clickedTextField2:TextField = objects2[0] as TextField;
				
				weaponDetailMc.lineText.text = lineupArray[stfSubtype.textFields.indexOf(clickedTextField2)-1] + " line";
				weaponDetailMc.firingText.text = "fire mode: " + firingArray[stfSubtype.textFields.indexOf(clickedTextField2)-1]; 
				
				TweenMax.to(weaponDetailMc.damageBar,1,{delay:1.5,width:damageArray[stfSubtype.textFields.indexOf(clickedTextField2)-1] * 3, ease:Sine.easeInOut});
				TweenMax.to(weaponDetailMc.recoilBar,1,{delay:1.5,width:recoilArray[stfSubtype.textFields.indexOf(clickedTextField2)-1] * 3, ease:Sine.easeInOut});
				TweenMax.to(weaponDetailMc.rofBar,1,{delay:1.5,width:rofArray[stfSubtype.textFields.indexOf(clickedTextField2)-1] * 3, ease:Sine.easeInOut});
				TweenMax.to(weaponDetailMc.accuracyBar,1,{delay:1.5,width:accuracyArray[stfSubtype.textFields.indexOf(clickedTextField2)-1] * 3, ease:Sine.easeInOut});
				TweenMax.to(weaponDetailMc.portabilityBar,1,{delay:1.5,width:portabilityArray[stfSubtype.textFields.indexOf(clickedTextField2)-1] * 3, ease:Sine.easeInOut});
				
				weaponDetailMc.descriptionText.text = descriptionArray[stfSubtype.textFields.indexOf(clickedTextField2)-1];
				
				weaponDetailMc.descriptionText.autoSize = TextFieldAutoSize.LEFT;
				
				imgLoader = new ProLoader();
				imgLoader.load(new URLRequest("http://nxcache.nexon.net/combatarms/shop/main_" + imgUrlArray[stfSubtype.textFields.indexOf(clickedTextField2)-1] + ".jpg"));
				imgLoader.scaleX = 0.54;
				imgLoader.scaleY = 0.54;
				
				weaponDetailMc.addChild(imgLoader);
			}
		}
		
		//Reset
		private function home(event:MouseEvent):void
		{
			stfHome.addEventListener(MouseEvent.CLICK, loadXML);
			weaponDetailMc.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler)
		
			TweenMax.to(info,2,{y:-353, ease:Sine.easeInOut, onComplete:infoBtn.addEventListener(MouseEvent.CLICK, infoHandler)});
			TweenMax.to(infoBtn,2,{delay:1.5,autoAlpha:1, ease:Sine.easeInOut});
			
			headerHandler("deactivate","arms");
			
			TweenMax.to(weaponDetailMc,1,{x:340, blurFilter:{blurX:20}, autoAlpha:0, ease:Sine.easeInOut});
			
			TweenMax.allTo(stfHome.textFields,1,{delay:1, x:"+320",autoAlpha:1,blurFilter:{blurX:0}},0.1);
			TweenMax.allTo(stfSubtype.textFields,1,{x:"+320",autoAlpha:0,blurFilter:{blurX:20}, ease:Sine.easeInOut, onComplete:stfSubtype.deactivate},0.1);
			
			lineup = "";
			lineupArray = [];
			priceArray = [];
			descriptionArray = [];
			damageArray = [];
			portabilityArray = [];
			rofArray = [];	
			accuracyArray = [];
			recoilArray = [];
			firingArray = [];
			imgUrlArray = [];
		}
		
		//Throwprops Start
		private function mouseDownHandler(event:MouseEvent):void 
		{
			TweenMax.killTweensOf(weaponDetailMc);
			y1 = y2 = weaponDetailMc.y;
			t1 = t2 = getTimer();
			weaponDetailMc.startDrag(false, new Rectangle(10, -99999, 0, 99999999));
			weaponDetailMc.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			weaponDetailMc.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		private function enterFrameHandler(event:Event):void 
		{
			y2 = y1;
			t2 = t1;
			y1 = weaponDetailMc.y;
			t1 = getTimer();
		}
		
		private function mouseUpHandler(event:MouseEvent):void 
		{
			weaponDetailMc.stopDrag();
			weaponDetailMc.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			weaponDetailMc.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			var time:Number = (getTimer() - t2) / 1000;
			var yVelocity:Number = (weaponDetailMc.y - y2) / time;
			var yOverlap:Number = Math.max(0, weaponDetailMc.height - 300);
			ThrowPropsPlugin.to(weaponDetailMc, {throwProps:{y:{velocity:yVelocity, max:78, min:460-weaponDetailMc.height, resistance:300} }, ease:Strong.easeOut, motionBlur:true}, 3, 0.3, 1);
		}
		//Throwprops End
    }
}