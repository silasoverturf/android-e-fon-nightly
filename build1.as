package 
{
	import com.greensock.*;
	import com.greensock.easing.*;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.display.*;
	import flash.net.*;
	import flash.events.Event;

	trace("classes imported");

	public class build1 extends MovieClip
	{
		////variable defenition
		//local vars
		private var userID_local:String;
		private var password_local:String;

		public var i:Number = 0;
		public var i2:Number = 0;
		public var i3:Number = 0;
		
		//white space remover
		private var rex:RegExp = /[\s\r\n]*/gim;
		
		//session vars
		private var j_session:URLVariables;
		private var j_send:URLRequest;
		private var j_loader:URLLoader;

		//local redirection vars ->
		private var redirectionData:String;
		private var redirectionLoader:URLLoader;
		private var redirectionURLRequest:URLRequest;

		//local redirection vars <-
		private var selectedNumber:String;
		private var numberID:String;

		private var testingArray:Array = ["testing"];

		private var timeRedir:Array = [0,0];//=[active, choice, destination delay,];
		private var busyRedir:Array = [0,0];// =[active, choice, destination];
		private var unregRedir:Array = [0,0];// =[active, choice, destination];
		private var dumpRedir:Array = [];
		private var dumpContainer:String;
		private var timeDelay:String;
		//private var selectedPhoneNumberId:Number;

		//redirection post vars
		private var r_vars:URLVariables;
		private var r_send:URLRequest;
		private var r_loader:URLLoader;
		
		//redir regular expressions
		private var optionValue:RegExp = /optionvalue="[0-9]{4,8}"/;
		private var selectedValue:RegExp = /selected="selected">[0-9]{10}/;
		
		private var delaySniffer:RegExp = /(?:phone1|phone3|backupNumber)"value="[0-9]{3,12}/g;
		private var choiceSniffer:RegExp = /<inputtype="radio"name="choice(?:1|3|Backuprouting)"value="[0-9]{0,4}"onclick="controlRedir(?:Normal|Busy|Backup)\(\)(?:"checked="checked"|)/g;
		private var numberSniffer:RegExp = /name="delay1"size="5"value="[0-9]{1,2}/;
		
		private var numberStripper:RegExp = /name="delay1"size="5"value="/;
		private var bloatStripper:RegExp = /(?:phone1|phone3|backupNumber)"value="/g;

		trace("vars built");
		
		public function build1()
		{
			//naming
			//main.saveBtn.btn_txt.text = "Speichern";

			//placement
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			bg.width = stage.stageWidth;
			bg.height = stage.stageHeight;

			header.x = stage.stageWidth / 2;
			header.y = stage.stageHeight * 0.19;
			header.scaleX = stage.stageWidth / 320;
			header.scaleY = stage.stageHeight / 480;

			login.x = stage.stageWidth / 2;
			login.y = stage.stageHeight * 0.5;
			login.scaleX = stage.stageWidth / 320;
			login.scaleY = stage.stageHeight / 480;

			loginBtn.x = stage.stageWidth / 2;
			loginBtn.y = stage.stageHeight * 0.7;
			loginBtn.scaleX = stage.stageWidth / 320;
			loginBtn.scaleY = stage.stageHeight / 480;

			main.x = stage.stageWidth / 2;
			main.y = stage.stageHeight * 0.3;
			main.scaleX = stage.stageWidth / 320;
			main.scaleY = stage.stageHeight / 480;

			loading.x = stage.stageWidth / 2;
			loading.y = stage.stageHeight * 0.3;
			loading.scaleX = stage.stageWidth / 320;
			loading.scaleY = stage.stageHeight / 480;

			//intro
			TweenMax.from(header, 0.5, {delay:0.5, alpha:0, y:"+20", ease:Strong.easeInOut});
			TweenMax.from(login, 0.5, {delay:0.8, alpha:0, ease:Cubic.easeInOut});
			TweenMax.from(loginBtn, 0.5, {delay:1.1, alpha:0, ease:Cubic.easeInOut});
			TweenMax.to(main, 0, {alpha:0, y:"+500"});

			//initial listeners;
			loginBtn.addEventListener(MouseEvent.CLICK, transmit);

			//change menu
			//transmit
			trace("UI built");
			trace("ready for login");
		}


		private function transmit(event:MouseEvent):void
		{

			loginBtn.removeEventListener(MouseEvent.CLICK, transmit);
			main.saveBtn.addEventListener(MouseEvent.CLICK, transmitRedir);
			TweenMax.to(header, 0.5, {alpha:0, y:"-500", ease:Strong.easeInOut});
			TweenMax.to(login, 0.5, {alpha:0, delay:0.1, y:"-500", ease:Cubic.easeInOut});
			TweenMax.to(loginBtn, 0.5, {alpha:0, delay:0.2, y:"-500", ease:Cubic.easeInOut});
			TweenMax.to(loading, 0.5, {alpha:1, ease:Cubic.easeInOut});
			TweenMax.to(loading.loading, 0.75, {rotation:"-360", ease:Cubic.easeInOut, repeat:-1});

			userID_local = login.userid_txt.text;
			password_local = login.password_txt.text;

			trace(userID_local, password_local);

			j_session = new URLVariables();
			j_send = new URLRequest("https://web.e-fon.ch/portal/j_acegi_security_check");

			j_send.method = URLRequestMethod.POST;
			j_send.data = j_session;

			j_loader = new URLLoader  ;

			j_loader.addEventListener(Event.COMPLETE, completeHandler);

			j_session.j_username = userID_local;
			j_session.j_password = password_local;

			j_loader.load(j_send);

			trace("logging in");
			function completeHandler(event:Event):void
			{
				trace("log in complete, getting redirection");
				redirectionLoader = new URLLoader();
				redirectionURLRequest = new URLRequest("https://web.e-fon.ch/portal/redirection.html");

				redirectionLoader.addEventListener(Event.COMPLETE, redirectionHandler);

				function redirectionHandler(event:Event):void
				{
					redirectionData = new String(redirectionLoader.data);
					j_loader.removeEventListener(Event.COMPLETE, completeHandler);
					parse();
				}
				redirectionLoader.load(redirectionURLRequest);
			}

		}

		private function parse(event:Event = null):void
		{
			redirectionData = redirectionData.replace(rex,"");
			trace("parsing redirection");

			TweenMax.to(main, 0.5, {motionBlur:true, delay:0.3,alpha:1, y:"-500", ease:Cubic.easeInOut});
			TweenMax.to(loading, 0.5, {alpha:0, y:-200, ease:Cubic.easeInOut});
			var result:Array = choiceSniffer.exec(redirectionData);

			while (result != null)
			{
				dumpRedir.push(result);
				result = choiceSniffer.exec(redirectionData);
			}

			for each (var dumpVar in dumpRedir)
			{
				dumpContainer = dumpRedir[i2];
				if (dumpContainer.search("checked") != -1)
				{
					if (i2 == 0){timeRedir = [1,1];}
					if (i2 == 1){timeRedir = [1,2];}
					if (i2 == 2){timeRedir = [1,3];}
					if (i2 == 3){busyRedir = [1,1];}
					if (i2 == 4){busyRedir = [1,2];}
					if (i2 == 5){unregRedir = [1,1];}
					if (i2 == 6){unregRedir = [1,2];}
				}
				i2 = i2 + 1;
			}
		
			result = [];
			dumpRedir = [];
			result = delaySniffer.exec(redirectionData);

			while (result != null)
			{
				dumpRedir.push(result);
				result = delaySniffer.exec(redirectionData);
			}

			for each (var delayVar in dumpRedir)
			{
				dumpContainer = dumpRedir[i3];
				dumpContainer = dumpContainer.replace(bloatStripper,"");
				dumpRedir[i3] = dumpContainer;
				if (i3 == 0)
				{
					timeRedir[2] = dumpContainer;
				}

				if (i3 == 1)
				{
					busyRedir[2] = dumpContainer;
				}

				if (i3 == 2)
				{
					unregRedir[2] = dumpContainer;
				}
				i3 = i3 + 1;
			}
			timeDelay = numberSniffer.exec(redirectionData);
			timeRedir.push(timeDelay.replace(numberStripper, ""));
			trace(timeRedir, busyRedir, unregRedir);
			UIflush();
		}

		private function UIflush(event:Event = null):void
		{
			if (timeRedir[0] == 1){main.timeCheck.gotoAndStop(1);}
			if (timeRedir[0] == 0){main.timeCheck.gotoAndStop(2);}
			if (busyRedir[0] == 1){main.timeCheck.gotoAndStop(1);}
			if (busyRedir[0] == 0){main.busyCheck.gotoAndStop(2);}
			if (unregRedir[0] == 1){main.unregCheck.gotoAndStop(1);}
			if (unregRedir[0] == 0){main.unregCheck.gotoAndStop(2);}
			
			main.timeText.text = "Nach " + timeRedir[3] + "s umleiten auf " + timeRedir[2];
			main.busyText.text = "Falls besetzt umleiten auf " + busyRedir[2];
			main.unregText.text = "Falls Endgeräte nicht erreichbar umleiten auf " + unregRedir[2];
		}

		private function transmitRedir(event:MouseEvent):void
		{
			j_loader.load(j_send);

			j_loader.addEventListener(Event.COMPLETE, transmitRedir2);

			function transmitRedir2(event:Event):void
			{

				r_vars = new URLVariables();
				r_send = new URLRequest("https://web.e-fon.ch/portal/redirection.html");

				r_send.method = URLRequestMethod.POST;
				r_send.data = r_vars;

				r_loader = new URLLoader  ;

				r_vars.featureId1 = 0;
				r_vars.featureId2 = 0;
				r_vars.featureId3 = 0;
				r_vars.featureId4 = 0;
				r_vars.featureIdBackuprouting = 0;
				r_vars.featureIdAnonSuppression = 0;
				r_vars.reload = 
				r_vars.selectedPhoneNumberId = 50288;
				r_vars._uml_normal1 = visible;
				r_vars._uml_busy = visible;
				r_vars._uml_backuprouting = visible;
				r_vars._uml_anonSuppression = visible;
				r_vars._uml_manualStatus = visible;
				r_vars._manualStatusPrivate = visible;
				r_vars._uml_calOof = visible;
				r_vars._uml_calBusy = visible;
				trace(r_vars);

				//r_loader.load(r_send);
			}
		}
	}
}