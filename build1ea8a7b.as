﻿package 
{
	//import
	import com.greensock.*;
	import com.greensock.easing.*;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.ui.*;
	import flash.geom.Rectangle;
	
	trace("classes imported");

	public class build1ea8a7b extends MovieClip
	{
		//set multitouch mode for MouseEvents
		Multitouch.inputMode=MultitouchInputMode.GESTURE;
		
		//swiping
		private var ind:int = 0;
		private var currX:Number = 0;
		
		//local session vars
		private var userID_local:String;
		private var password_local:String;

		//counters
		public var i:Number = 0;
		public var i2:Number = 0;
		public var i3:Number = 0;
		
		//white space remover
		private var rex:RegExp = /[\s\r\n]*/gim;
		
		//session vars
		private var j_session:URLVariables;
		private var j_send:URLRequest;
		private var j_loader:URLLoader;

		//redirection loaders
		private var redirectionData:String;
		private var redirectionLoader:URLLoader = new URLLoader();
		private var redirectionURLRequest:URLRequest = new URLRequest("https://web.e-fon.ch/portal/redirection.html");//?selectedPhoneNumberId=selectedNumber;
		
		//f2m loaders
		private var f2mData:String;
		private var f2mLoader:URLLoader = new URLLoader();
		private var f2mURLRequest:URLRequest = new URLRequest("https://web.e-fon.ch/portal/notifications.html");//?selectedPhoneNumberId=selectedNumber;
		
		//f2m posters
		private var f2m_vars:URLVariables;
		private var f2m_send:URLRequest = new URLRequest("https://web.e-fon.ch/portal/notifications.html");//?selectedPhoneNumberId=selectedNumber;
		private var f2m_loader:URLLoader = new URLLoader;
		
		//f2m regexp
		private var f2mSniffer:RegExp = /name="fax2emailEmail"value="[0-9a-zA-Z][-._a-zA-Z0-9]*@(?:[0-9a-zA-Z][-._0-9a-zA-Z]*\.)+[a-zA-Z]{2,4}/;
		private var f2mStripper:RegExp = /name="fax2emailEmail"value="/;
		
		//f2m local
		private var f2mEmail:String;
		
		private var testingArray:Array = ["testing"];
		
		//localized redirection vars
		private var selectedNumber:String;
		private var numberID:String;
		
		private var featureArray:Array = [];//[feature1, feature2, feature3, feature4, featureBackuprouting, featureAnonSuppression]
		
		private var timeRedir:Array = [0,0];//=[active, choice, destination, delay];
		private var timeDelay:String;
		
		private var busyRedir:Array = [0,0];// =[active, choice, destination];
		private var unregRedir:Array = [0,0];// =[active, choice, destination];
		
		private var redirChoice:Array = ["","","",];// [timeChoice, busyChoice, unregChoice]
		
		//intermediate dump vars
		private var dumpRedir:Array = [];
		private var dumpContainer:String;

		//redirection post vars
		private var r_vars:URLVariables;
		private var r_send:URLRequest = new URLRequest("https://web.e-fon.ch/portal/redirection.html");
		private var r_loader:URLLoader = new URLLoader;
		
		//selectedNumber regexp
		private var optionSniffer:RegExp = /optionvalue="[0-9]{4,8}/;
		private var optionStripper:RegExp = /optionvalue="/;
		
		//delay & choice regexp
		private var delaySniffer:RegExp = /(?:phone1|phone3|backupNumber)"value="[0-9]{3,12}/g;
		private var bloatStripper:RegExp = /(?:phone1|phone3|backupNumber)"value="/g;
		
		private var choiceSniffer:RegExp = /<inputtype="radio"name="choice(?:1|3|Backuprouting)"value="[0-9]{0,4}"onclick="controlRedir(?:Normal|Busy|Backup)\(\)(?:"checked="checked"|)/g;
		
		//destination regexp
		private var numberSniffer:RegExp = /name="delay1"size="5"value="[0-9]{1,2}/;
		private var numberStripper:RegExp = /name="delay1"size="5"value="/;
		
		//featureIDs regexp
		private var featureSniffer:RegExp = /featureId(?:1|2|3|4|Backuprouting|AnonSuppression)"value="[0-9]{1,10}/g;
		private var featureStripper:RegExp = /featureId(?:1|2|3|4|Backuprouting|AnonSuppression)"value="/;
		
		//SMS
		private var sms_vars:URLVariables;
		private var sms_send:URLRequest = new URLRequest("https://web.e-fon.ch/portal/SMSSender.html");
		private var sms_loader:URLLoader = new URLLoader;
		
		public function build1()
		{
			//stage aligment
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			//bg setup
			main.timeContainer.switcher.gotoAndStop(2);
			main.busyContainer.switcher.gotoAndStop(4);
			main.unregContainer.switcher.gotoAndStop(6);
			
			bg.width = stage.stageWidth;
			bg.height = stage.stageHeight;
			
			//mc placement and scaling
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
			
			//hide main
			TweenMax.to(main, 0, {autoAlpha:0, y:"+1000"});

			//initial listeners;
			loginBtn.addEventListener(MouseEvent.CLICK, transmit);
			main.timeContainer.addEventListener(MouseEvent.CLICK, tempHandler);
			main.busyContainer.addEventListener(MouseEvent.CLICK, tempHandler2);
			main.unregContainer.addEventListener(MouseEvent.CLICK, tempHandler3);
			
			main.timeContainer.addEventListener(MouseEvent.CLICK, targetTest);
			main.busyContainer.addEventListener(MouseEvent.CLICK, targetTest2);
			main.unregContainer.addEventListener(MouseEvent.CLICK, targetTest3);
			
			
			//options.addEventListener(MouseEvent.CLICK, scrolling);
			
			stage.addEventListener(MouseEvent.CLICK, getTarget);

			trace("ready for login");
			
		}
		
		//scrolling
		private function getTarget(event:MouseEvent):void
		{
			trace(event.target.name);
		}
		
		//targetTest,2,3 temporary handlers until testing is done
		private function targetTest(event:MouseEvent):void
		{
			if(event.target.name == "phoneIcon"){main.timeContainer.switcher.gotoAndStop(2);main.timeContainer.switcher.destination.text = "";main.timeContainer.switcher.Delay.text = "";};
			if(event.target.name == "voicemailIcon"){main.timeContainer.switcher.gotoAndStop(3);main.timeContainer.switcher.destination.text = "s umleiten auf Voicemail";main.timeContainer.switcher.Delay.text = "";};
			if(event.target.name == "fax2mailIcon"){main.timeContainer.switcher.gotoAndStop(3);main.timeContainer.switcher.destination.text ="s umleiten auf Fax2Mail";main.timeContainer.switcher.Delay.text = "";};
			if(event.target.name == "Check"){main.timeContainer.Check.play();}
		}
		
		private function targetTest2(event:MouseEvent):void
		{
			if(event.target.name == "phoneIcon"){main.busyContainer.switcher.gotoAndStop(4);main.busyContainer.switcher.destination.text = "";};
			if(event.target.name == "voicemailIcon"){main.busyContainer.switcher.gotoAndStop(5);main.busyContainer.switcher.destination.text = "Falls besetzt umleiten auf Voicemail";};
			if(event.target.name == "Check"){main.busyContainer.Check.play();}
		}
		
		private function targetTest3(event:MouseEvent):void
		{
			if(event.target.name == "phoneIcon"){main.unregContainer.switcher.gotoAndStop(6);main.unregContainer.switcher.destination.text = "";};
			if(event.target.name == "voicemailIcon"){main.unregContainer.switcher.gotoAndStop(7);main.unregContainer.switcher.destination.text = "Falls Endgeräte nicht erreichbar umleiten auf Voicemail"};
			if(event.target.name == "Check"){main.unregContainer.Check.play();}
		}
		
		//tempHandlers,2,3 temporary handlers until testing is done
		private function tempHandler(event:MouseEvent):void
		{
			TweenMax.to(main.timeContainer.selecter, 0.2, {y:50, ease:Cubic.easeInOut});
			TweenMax.to(main.busyContainer.selecter, 0.2, {y:0, ease:Cubic.easeInOut});
			TweenMax.to(main.unregContainer.selecter, 0.2, {y:0, ease:Cubic.easeInOut});
			
			TweenMax.to(main.busyContainer, 0.2, {y:118, ease:Cubic.easeInOut});
			TweenMax.to(main.unregContainer, 0.2, {y:168, ease:Cubic.easeInOut});
		}
		
		private function tempHandler2(event:MouseEvent):void
		{
			TweenMax.to(main.timeContainer.selecter, 0.2, {y:-80, ease:Cubic.easeInOut});
			TweenMax.to(main.busyContainer.selecter, 0.2, {y:50, ease:Cubic.easeInOut});
			TweenMax.to(main.unregContainer.selecter, 0.2, {y:0, ease:Cubic.easeInOut});
			
			TweenMax.to(main.busyContainer, 0.2, {y:5, ease:Cubic.easeInOut});
			TweenMax.to(main.unregContainer, 0.2, {y:105, ease:Cubic.easeInOut});
		}
		
		private function tempHandler3(event:MouseEvent):void
		{
			TweenMax.to(main.timeContainer.selecter, 0.2, {y:-80, ease:Cubic.easeInOut});
			TweenMax.to(main.busyContainer.selecter, 0.2, {y:0, ease:Cubic.easeInOut});
			TweenMax.to(main.unregContainer.selecter, 0.2, {y:50, ease:Cubic.easeInOut});
			
			TweenMax.to(main.busyContainer, 0.2, {y:5, ease:Cubic.easeInOut});
			TweenMax.to(main.unregContainer, 0.2, {y:55, ease:Cubic.easeInOut});
		}

		//handle listeners, builds j_session, posts and requests redirection.html
		private function transmit(event:MouseEvent):void
		{
			//UI management
			//stage.addEventListener(Event.ENTER_FRAME, loop);
			//main.addEventListener(TransformGestureEvent.GESTURE_SWIPE, onSwipe);
			loginBtn.removeEventListener(MouseEvent.CLICK, transmit);
			TweenMax.to(header, 0.5, {autoAlpha:1, y:-500, ease:Strong.easeInOut});
			TweenMax.to(login, 0.5, {autoAlpha:1, delay:0.1, y:-500, ease:Cubic.easeInOut});
			TweenMax.to(loginBtn, 0.5, {autoAlpha:1, delay:0.2, y:-500, ease:Cubic.easeInOut});
			TweenMax.to(loading, 0.5, {autoAlpha:1, ease:Cubic.easeInOut});
			TweenMax.to(loading.loading, 0.75, {rotation:"-360", ease:Cubic.easeInOut, repeat:-1});

			//flush local j_session w/ text fields
			userID_local = login.userid_txt.text;
			password_local = login.password_txt.text;

			j_session = new URLVariables();
			j_send = new URLRequest("https://web.e-fon.ch/portal/j_acegi_security_check");

			j_send.method = URLRequestMethod.POST;
			j_send.data = j_session;

			j_loader = new URLLoader  ;
			
			//add listener so redirection.html can be requested on complete
			j_loader.addEventListener(Event.COMPLETE, completeHandler);
			
			//build server j_session
			j_session.j_username = userID_local;
			j_session.j_password = password_local;

			//post j_session
			j_loader.load(j_send);

			trace("logging in" );

			
			//get redirection.html, onComplete -> parseRedir
			function completeHandler(event:Event = null):void
			{
				trace("log in complete, getting redirection");
				
				redirectionLoader.addEventListener(Event.COMPLETE, redirectionHandler);
				loadF2M();
				function redirectionHandler(event:Event):void
				{
					redirectionData = new String(redirectionLoader.data);
					j_loader.removeEventListener(Event.COMPLETE, completeHandler);
					parseRedir();
				}
				redirectionLoader.load(redirectionURLRequest);
			}

		}
		
		/*swiping
		private function onSwipe(event:TransformGestureEvent):void
		{
			trace("onSwipe");
			if(event.offsetX == 1 && ind > 0)
				ind--;
			if(event.offsetX == -1 && ind < 4)
				ind++;
		}
		
		private function loop(event:Event):void
		{
			currX += (ind*1024 - currX * 0.15);
			main.scrollRect = new Rectangle(currX, 0, 1024, 768);
		}
		*/
		//manual parsing of .html
		private function parseRedir(event:Event = null):void
		{
			//reset all local vars
			featureArray = [];
			timeRedir = [0,0];
			busyRedir = [0,0];
			unregRedir = [0,0];
			redirChoice = ["","","",];
			timeDelay = null;
			dumpRedir = [];
			dumpContainer = null;
			
			//reset counters
			i=0;
			i2=0;
			i3=0;
			
			///remove whitespace
			redirectionData = redirectionData.replace(rex,"");

			trace("parsing redirection");
			
			//UI management, check if main at correct position
			if(main.y > 500)
			{
				TweenMax.to(main, 0.5, {delay:0.3,autoAlpha:1, y:"-1000", ease:Cubic.easeInOut});
				TweenMax.to(loading, 0.5, {autoAlpha:0, y:-200, ease:Cubic.easeInOut});
				//TweenMax.to(options, 0.5, {delay:0.3,autoAlpha:1, y:stage.stageHeight, ease:Cubic.easeInOut});
			}
			
			var result:Array = choiceSniffer.exec(redirectionData);
			var result2:Array = featureSniffer.exec(redirectionData);
			
			//gets all choices with choiceSniffer
			while (result != null)
			{
				dumpRedir.push(result);
				result = choiceSniffer.exec(redirectionData);
			}
			
			//dumps to appropriate localized arrary
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
			
			//gets delay with delaySniffer
			while (result != null)
			{
				dumpRedir.push(result);
				result = delaySniffer.exec(redirectionData);
			}
			
			//clean up of delayVar
			for each (var delayVar in dumpRedir)
			{
				dumpContainer = dumpRedir[i3];
				dumpContainer = dumpContainer.replace(bloatStripper,"");
				dumpRedir[i3] = dumpContainer;
				
				if (i3 == 0){timeRedir[2] = dumpContainer;}
				if (i3 == 1){busyRedir[2] = dumpContainer;}
				if (i3 == 2){unregRedir[2] = dumpContainer;}
				
				i3 = i3 + 1;
			}

			//get timeDelay
			timeDelay = numberSniffer.exec(redirectionData);
			timeRedir.push(timeDelay.replace(numberStripper, ""));
			trace(timeRedir, busyRedir, unregRedir);
			
			//get selected numberID
			numberID = optionSniffer.exec(redirectionData);
			numberID = numberID.replace(optionStripper, "");
			trace(numberID);
			
			//reset counter
			i3 = 0;
			
			//sniff for feature vars
			while (result2 != null)
			{
				featureArray.push(result2);
				result2 = featureSniffer.exec(redirectionData);
			}
			
			//clean up feature vars
			for each(var featureVar in featureArray)
			{
				
				dumpContainer = featureArray[i3];
				dumpContainer = dumpContainer.replace(featureStripper,"");
				featureArray[i3] = dumpContainer;
				i3 = i3 + 1;
			}
			
			//flush to UI
			VtoUI();
		}
		
		//UI flushing
		private function VtoUI(event:Event = null):void
		{
			//checks
			if (timeRedir[0] == 1){main.timeContainer.Check.gotoAndStop(1);}
			if (timeRedir[0] == 0){main.timeContainer.Check.gotoAndStop(2);}
			if (busyRedir[0] == 1){main.busyContainer.Check.gotoAndStop(1);}
			if (busyRedir[0] == 0){main.busyContainer.Check.gotoAndStop(2);}
			if (unregRedir[0] == 1){main.unregContainer.Check.gotoAndStop(1);}
			if (unregRedir[0] == 0){main.unregContainer.Check.gotoAndStop(2);}
			
			//timeRedir flush
			if (timeRedir[1] == 1){main.timeContainer.switcher.gotoAndStop(2);main.timeContainer.switcher.destination.text = timeRedir[2];main.timeContainer.switcher.Delay.text = timeRedir[3];}
			if (timeRedir[1] == 2){main.timeContainer.switcher.gotoAndStop(3);main.timeContainer.switcher.destination.text = "s umleiten auf Voicemail";main.timeContainer.switcher.Delay.text = timeRedir[3];}
			if (timeRedir[1] == 3){main.timeContainer.switcher.gotoAndStop(3);main.timeContainer.switcher.destination.text = "s umleiten auf Fax2Mail";main.timeContainer.switcher.Delay.text = timeRedir[3];}
			
			//busyRedir flush
			if (busyRedir[1] == 1){main.busyContainer.switcher.gotoAndStop(4);main.busyContainer.switcher.destination.text = busyRedir[2];}
			if (busyRedir[1] == 2){main.busyContainer.switcher.gotoAndStop(5);main.busyContainer.switcher.destination.text = "Falls besetzt umleiten auf Voicemail";}
			
			//unregRedir flush
			if (unregRedir[1] == 1){main.unregContainer.switcher.gotoAndStop(6);main.unregContainer.switcher.destination.text = unregRedir[2];}
			if (unregRedir[1] == 2){main.unregContainer.switcher.gotoAndStop(7);main.unregContainer.switcher.destination.text = "Falls Endgeräte nicht erreichbar umleiten auf Voicemail"}
			
			main.saveBtn.addEventListener(MouseEvent.CLICK, transmitRedir);
			main.saveBtn.btn_txt.text = "Save";
		}
		
		//UI reverse flushing
		private function UItoV(event:Event = null):void
		{
			r_vars = new URLVariables();
			
			r_vars._uml_normal1 = "visible";
			r_vars._uml_busy = "visible";
			r_vars._uml_backuprouting = "visible";
			r_vars._uml_anonSuppression = "visible";
			r_vars._uml_manualStatus = "visible";
			r_vars._manualStatusPrivate = "visible";
			r_vars._uml_calOof = "visible";
			r_vars.reload = "";
			r_vars._uml_calBusy = "visible";
			
			//flush featureIDs
			r_vars.featureId1 = featureArray[0];
			r_vars.featureId2 = featureArray[1];
			r_vars.featureId3 = featureArray[2];
			r_vars.featureId4 = featureArray[3];
			r_vars.featureIdBackuprouting = featureArray[4];
			r_vars.featureIdAnonSuppression = featureArray[5];
			r_vars.selectedPhoneNumberId = numberID;

			//r_vars conditionals constructor
			if (main.timeContainer.Check.currentFrame == 1)
			{
				r_vars.uml_normal1 = true;
				r_vars.delay1 = main.timeContainer.switcher.Delay.text;
				
				if(main.timeContainer.switcher.currentFrame == 2){r_vars.choice1 = "1";r_vars.phone1 = main.timeContainer.switcher.destination.text};
				if(main.timeContainer.switcher.currentFrame == 3 && main.timeContainer.switcher.destination.text == "s umleiten auf Voicemail"){r_vars.choice1 = "2"};
				if(main.timeContainer.switcher.currentFrame == 3 && main.timeContainer.switcher.destination.text == "s umleiten auf Fax2Mail")(r_vars.choice1 = "3");
			}
			
			if (main.busyContainer.Check.currentFrame == 1)
			{
				r_vars.uml_busy = true
				if(main.busyContainer.switcher.currentFrame == 4){r_vars.choice3 = "1";r_vars.phone3 = main.busyContainer.switcher.destination.text}
				if(main.busyContainer.switcher.currentFrame == 5){r_vars.choice3 = "2"}
			}
			
			if (main.unregContainer.Check.currentFrame == 1)
			{
				r_vars.uml_backuprouting = true
				if(main.unregContainer.switcher.currentFrame == 6){r_vars.choiceBackuprouting = "1";r_vars.backupNumber = main.unregContainer.switcher.destination.text}
				if(main.unregContainer.switcher.currentFrame == 7){r_vars.choiceBackuprouting = "2"}
			}
			
			if (main.timeContainer.Check.currentFrame == 2){}
			if (main.busyContainer.Check.currentFrame == 2){}
			if (main.unregContainer.Check.currentFrame == 2){}
		}

		//r_vars posting
		private function transmitRedir(event:MouseEvent):void
		{
			j_loader.load(j_send);

			j_loader.addEventListener(Event.COMPLETE, transmitRedir2);
			
			main.saveBtn.removeEventListener(MouseEvent.CLICK, transmitRedir);
			trace(transmitRedir);
			main.saveBtn.btn_txt.text = "Saving";
			//UItoV flush
			UItoV();

			
			function transmitRedir2(event:Event = null):void
			{
				r_send.method = URLRequestMethod.POST;
				r_send.data = r_vars;
				
				//listen for r_vars complete
				r_loader.addEventListener(Event.COMPLETE, getRedir);
				
				//post r_vars
				r_loader.load(r_send);
				
				if(r_vars.choice1 == "3")
				{
					transmitF2M();
				}
				
				//reget redir on complete r_vars post...
				function getRedir(event:Event)
				{
					function redirectionHandler(event:Event):void
					{
						//...and reparseRedir on complete
						redirectionData = new String(redirectionLoader.data);
						j_loader.removeEventListener(Event.COMPLETE, transmitRedir2);
						parseRedir();
						
					}
					redirectionLoader.load(redirectionURLRequest);
				}
			}
		}
		
		private function transmitF2M(event:Event = null):void
		{
			
		}
		
		private function loadF2M(event:Event = null):void
		{
			f2mLoader.addEventListener(Event.COMPLETE, parseF2M);
			f2mLoader.load(f2mURLRequest);
			
			function parseF2M(event:Event = null):void
			{
				trace("parsing f2m");
				f2mData = new String(f2mLoader.data);
				f2mData = f2mData.replace(rex,"");
				f2mEmail = f2mSniffer.exec(f2mData);
				f2mEmail = f2mEmail.replace(f2mStripper,"")
				main.timeContainer.selecter.fax2mailIcon.email.text = f2mEmail;
			}
		}
		
		private function SMS(event:MouseEvent)
		{
			/*
			j_loader.load(j_send);
			
			j_loader.addEventListener(Event.COMPLETE, sendSMS);
			
			sms_vars.message = main.SMSmessage.text;
			sms_vars.recipientNumber = main.recipient.text;
			
			sms_vars.numberOfMessageToSendForEachRecipient = "1"
			sms_vars.numberOfRecipients = "1"
			sms_vars.numberOfMessageToSend = "1"
			sms_vars.senderNumber = "anonymous"

			
			function sendSMS(event:Event = null):void
			{
				sms_send.method = URLRequestMethod.POST;
				sms_send.data = sms_vars;
				
				sms_loader.addEventListener(Event.COMPLETE, SMSsent);
				
				function SMSsent(event:Event = null):void
				{
					trace("SMS Sent");
				}
			}
			*/
		}
	}
}