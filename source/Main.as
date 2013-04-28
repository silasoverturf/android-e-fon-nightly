package 
{
	//import
	import com.greensock.*;
	import com.greensock.easing.*;
	import com.greensock.plugins.*;

	import flash.events.TouchEvent;
	import flash.net.*;
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;

	import flash.desktop.NativeApplication;
	import fl.controls.RadioButtonGroup;
	import flash.system.Capabilities;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import flash.text.*;

	import Mavin;

	TweenPlugin.activate([ThrowPropsPlugin]);

	public class Main extends MovieClip
	{
		//set multitouch mode for TouchEvents
		Multitouch.inputMode=MultitouchInputMode.TOUCH_POINT;
		
		////Global misc. variables////
		//state holder
		var programState:String = "home";

		//configObject
		public var configObject:Object 
		
		//local LSO
		var SO:SharedObject = SharedObject.getLocal("e-fon");
		
		//swiping
		private var ind:int = 0;
		private var currX:Number = 0;
		
		//local session vars
		private var userID_local:String;
		private var password_local:String;

		//text formats
		public var robotoLabel:TextFormat = new TextFormat();
		
		//counters
		public var i:Number = 0;
		public var i2:Number = 0;
		public var i3:Number = 0;
		public var i4:Number = 0;
		public var i5:Number = 0;
		
		//ui counter
		public var xP:Number = -100;
		public var yP:Number = 110;
		
		//white space remover
		private var rex:RegExp = /[\s\r\n]*/gim;
		
		//functionality trackers
		private var functionCount:Number = 2;//default is 2: sms and eg

		//matches ip address to result[1]
		private var IPSniffer:RegExp = /[0-9]{0,3}\.[0-9]{0,3}\.[0-9]{0,3}\.[0-9]{0,3}/i;

		//matches date to result[1], time to result[2]
		private var dateSniffer:RegExp = /([0-9]{0,2}\.[0-9]{0,2}\.[0-9]{0,4})([0-9]{0,2}:[0-9]{0,2})/i;
		
		////Display stack////
		private var smsRadioGroup:RadioButtonGroup = new RadioButtonGroup("SMSRadioGroup");

		//some variables for tracking the velocity of main
		public var bounds:Rectangle;
		public var mc:Sprite = new Sprite();
		public var t1:uint, t2:uint, y1:Number, y2:Number;

		//init mavin
		var mavin:Mavin = new Mavin();

		public function Main()
		{
			//set bg
			bg.gotoAndStop(1);

			//set logo
			header.gotoAndStop(1);

			//set label tf
			robotoLabel.color = 0xFFFFFF;
			robotoLabel.font = "Roboto";
			robotoLabel.size = 17;
			
			//stage aligment
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			bounds = new Rectangle(stage.stageWidth*0.5, 7, 320, 480);

			//UI setup
			bg.width = stage.stageWidth;
			bg.height = stage.stageHeight;

			header.x = stage.stageWidth / 2;
			header.y = stage.stageHeight * 0.19;
			
			login.x = stage.stageWidth / 2;
			login.y = stage.stageHeight * 0.47;

			loginBtn.x = stage.stageWidth / 2;
			loginBtn.y = stage.stageHeight * 0.7;

			dashboard.x = stage.stageWidth / 2;
			dashboard.y = 0;
			
			topMenu.x = stage.stageWidth * 0.5
			topMenu.y = 0;

			main.x = stage.stageWidth / 2;
			main.y = stage.stageHeight * 0.03;

			var stageObjects:Array = [header,login,loginBtn,dashboard,main,topMenu];

			for each(var item in stageObjects)
			{
				item.scaleX = stage.stageWidth / 320;
				item.scaleY = stage.stageWidth / 320;
			}

			//hide main
			main.stop();
			main.visible = false;
			main.alpha = 0;

			//and topMenu
			topMenu.stop();
			topMenu.visible = false;
			topMenu.alphe = 0;
			
			dashboard.visible = false;
			dashboard.alpha = 0;

			//initial listeners;
			loginBtn.addEventListener(TouchEvent.TOUCH_TAP, transmit);
			
			dashboard.addEventListener(TouchEvent.TOUCH_TAP, dashboardHandler);
			main.addEventListener(TouchEvent.TOUCH_TAP, dashboardHandler);
			topMenu.addEventListener(TouchEvent.TOUCH_TAP, dashboardHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);

			//listen for native actions
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, activate);
			
			//stage.addEventListener(TouchEvent.TOUCH_TAP, getTarget);

			//get language
			trace(Capabilities.languages, Capabilities.os);

			//if SO invalid, set default, else set SO
			if(!SO.data.userid)
			{
				login.userid_txt.text = "user@example.com";
				login.password_txt.text = "password";
			}else{
				login.userid_txt.text = SO.data.userid;
				login.password_txt.text = SO.data.pass;
			}
		}
		
		//reactivation
		private function activate(event:Event):void
		{
			//reauth on reactivate
			//mavin.authorize(SO.data.userid, SO.data.pass)
		}

		//dashboard stack
		private function addDashboard(type:String, typeFrame:Number):void
		{
			var DashboardItem:MovieClip = new dashboardItem();
			
			DashboardItem.y = yP;
			DashboardItem.x = xP;
			
			DashboardItem.gotoAndStop(typeFrame);
			DashboardItem.name = type;

			dashboard.addChild(DashboardItem);

			//set offset for next item
			if(xP == 100)
			{
				yP = yP + 70;
				xP = -100;
			}else{
				xP = xP + 100;
			}
			i5 = i5 + 1;
			
			//check if loading done
			if(i5 == functionCount){
				TweenMax.to(dashboard.loading, 0.5, {autoAlpha:0, ease:Cubic.easeInOut});
			}if(i5 < functionCount){
				TweenMax.to(dashboard.loading, 0.5, {y:yP, x:xP, ease:Cubic.easeInOut});
			}
		}
		
		//backBtn handler
		private function keyHandler(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.BACK && programState != "home" && programState != "members")
			{
				//if !home, prevent default and hideMain();
				event.preventDefault();
				event.stopImmediatePropagation();
				hideMain();
			}
		}
		
		//dashboard UI managment
		private function dashboardHandler(event:TouchEvent):void
		{
			programState = event.target.name;
			if(event.target.name == "Umleitung")
			{
				hideDashboard(1);
				flushRedirection();
				flushF2M();
				addSwipe();
			}
			
			if(event.target.name == "SMS")
			{
				hideDashboard(2);
				flushSMS();
				addSwipe();
			}
			
			if(event.target.name == "CDR")
			{
				hideDashboard(3);
				addSwipe();
			}
			
			if(event.target.name == "Accounts")
			{
				hideDashboard(4);
				flushAccount();
				addSwipe();
			}
			
			if(event.target.name == "Queue")
			{
				hideDashboard(5);
				flushQueue();
				addSwipe();
			}

			if(event.target.name == "Voicemail")
			{
				flushVoicemail();
				addSwipe();
			}

			if(event.target.name == "Settings")
			{
				hideDashboard(9);
				addSwipe();
			}	

			if(event.target.name == "info")
			{
				hideDashboard(7);
				
				main.github.addEventListener(TouchEvent.TOUCH_TAP, openGit);
				main.ticket.addEventListener(TouchEvent.TOUCH_TAP, sendTicket);
				
				function openGit(event:TouchEvent):void
				{
					navigateToURL(new URLRequest("https://github.com/silasoverturf/android-e-fon-nightly/issues"));
				}
				
				function sendTicket(event:TouchEvent):void
				{
					navigateToURL(new URLRequest("mailto:support@e-fon.ch"));
				}
				addSwipe();
			}
			
			if(event.target.name == "backBtn")
			{
				hideMain();
			}

			function addSwipe():void
			{
				//add swipe if main > stage
				if(main.height > stage.stageHeight)
				{
					main.addEventListener(TouchEvent.TOUCH_BEGIN, mouseDownHandler);
				}
			}
		}

		private function hideDashboard(selection:Number):void
		{
			main.gotoAndStop(6);
			topMenu.gotoAndStop(selection);
			main.gotoAndStop(selection);
			main.y = 7;
			TweenMax.to(dashboard, 0.5, {autoAlpha:0, ease:Cubic.easeInOut});
			TweenMax.to(main, 0.5, {autoAlpha:1, delay:0.3, ease:Cubic.easeInOut});
			TweenMax.to(topMenu, 0.5, {autoAlpha:1, delay:0.3, ease:Cubic.easeInOut});
		}

		private function reset(selection:Number):void
		{
			main.gotoAndStop(6);

			main.gotoAndStop(selection);
			topMenu.gotoAndStop(selection);
		}

		private function hideMain():void
		{
			TweenMax.to(dashboard, 0.5, {autoAlpha:1, delay:0.3, ease:Cubic.easeInOut});
			TweenMax.to(main, 0.5, {autoAlpha:0, ease:Cubic.easeInOut});
			TweenMax.to(topMenu, 0.5, {autoAlpha:0, ease:Cubic.easeInOut});
				
			programState = "home";
			main.removeEventListener(TouchEvent.TOUCH_BEGIN, mouseDownHandler);
		}
		
		private function getTarget(event:TouchEvent):void
		{
			trace(event.target.name);
		}
		
		//redirection UI management
		private function targetTest(event:TouchEvent):void
		{
			if(event.target.name == "phoneIcon"){main.timeContainer.switcher.gotoAndStop(2);main.timeContainer.switcher.destination.text = "";main.timeContainer.switcher.Delay.text = "0";};
			if(event.target.name == "voicemailIcon"){main.timeContainer.switcher.gotoAndStop(3);main.timeContainer.switcher.destination.text = "s umleiten auf Voicemail";main.timeContainer.switcher.Delay.text = "0";};
			if(event.target.name == "fax2mailIcon"){main.timeContainer.switcher.gotoAndStop(3);main.timeContainer.switcher.destination.text ="s umleiten auf Fax2Mail";main.timeContainer.switcher.Delay.text = "0";};
			if(event.target.name == "Check"){main.timeContainer.Check.play();}
		}
		
		private function targetTest2(event:TouchEvent):void
		{
			if(event.target.name == "phoneIcon"){main.busyContainer.switcher.gotoAndStop(4);main.busyContainer.switcher.destination.text = "";};
			if(event.target.name == "voicemailIcon"){main.busyContainer.switcher.gotoAndStop(5);main.busyContainer.switcher.destination.text = "Falls besetzt umleiten auf Voicemail";};
			if(event.target.name == "Check"){main.busyContainer.Check.play();}
		}
		
		private function targetTest3(event:TouchEvent):void
		{
			if(event.target.name == "phoneIcon"){main.unregContainer.switcher.gotoAndStop(6);main.unregContainer.switcher.destination.text = "";};
			if(event.target.name == "voicemailIcon"){main.unregContainer.switcher.gotoAndStop(7);main.unregContainer.switcher.destination.text = "Falls Endgeräte nicht erreichbar umleiten auf Voicemail"};
			if(event.target.name == "Check"){main.unregContainer.Check.play();}
		}
		
		private function targetTest4(event:TouchEvent):void
		{
			if(event.target.name == "phoneIcon"){main.anonContainer.switcher.gotoAndStop(7);main.anonContainer.switcher.destination.text = "Falls unterdrückt umleiten auf Abweisungsnachricht";};
			if(event.target.name == "voicemailIcon"){main.anonContainer.switcher.gotoAndStop(1);main.anonContainer.switcher.Text.text = "Falls unterdrückt umleiten auf Voicemail"};
			if(event.target.name == "Check"){main.anonContainer.Check.play();}
		}
		
		//redirection UI management
		private function tempHandler(event:TouchEvent):void
		{
			TweenMax.to(main.timeContainer.selecter, 0.2, {y:50, ease:Cubic.easeInOut});
			TweenMax.to(main.busyContainer.selecter, 0.2, {y:0, ease:Cubic.easeInOut});
			TweenMax.to(main.unregContainer.selecter, 0.2, {y:0, ease:Cubic.easeInOut});
			TweenMax.to(main.anonContainer.selecter, 0.2, {y:0, ease:Cubic.easeInOut});
			
			TweenMax.to(main.busyContainer, 0.2, {y:238, ease:Cubic.easeInOut});
			TweenMax.to(main.unregContainer, 0.2, {y:288, ease:Cubic.easeInOut});
			TweenMax.to(main.anonContainer, 0.2, {y:338, ease:Cubic.easeInOut});
		}
		
		private function tempHandler2(event:TouchEvent):void
		{
			TweenMax.to(main.timeContainer.selecter, 0.2, {y:-80, ease:Cubic.easeInOut});
			TweenMax.to(main.busyContainer.selecter, 0.2, {y:50, ease:Cubic.easeInOut});
			TweenMax.to(main.unregContainer.selecter, 0.2, {y:0, ease:Cubic.easeInOut});
			TweenMax.to(main.anonContainer.selecter, 0.2, {y:0, ease:Cubic.easeInOut});
			
			TweenMax.to(main.busyContainer, 0.2, {y:125, ease:Cubic.easeInOut});
			TweenMax.to(main.unregContainer, 0.2, {y:225, ease:Cubic.easeInOut});
			TweenMax.to(main.anonContainer, 0.2, {y:275, ease:Cubic.easeInOut});
		}
		
		private function tempHandler3(event:TouchEvent):void
		{
			TweenMax.to(main.timeContainer.selecter, 0.2, {y:-80, ease:Cubic.easeInOut});
			TweenMax.to(main.busyContainer.selecter, 0.2, {y:0, ease:Cubic.easeInOut});
			TweenMax.to(main.unregContainer.selecter, 0.2, {y:50, ease:Cubic.easeInOut});
			TweenMax.to(main.anonContainer.selecter, 0.2, {y:0, ease:Cubic.easeInOut});
			
			TweenMax.to(main.busyContainer, 0.2, {y:125, ease:Cubic.easeInOut});
			TweenMax.to(main.unregContainer, 0.2, {y:175, ease:Cubic.easeInOut});
			TweenMax.to(main.anonContainer, 0.2, {y:275, ease:Cubic.easeInOut});
		}
		
		private function tempHandler4(event:TouchEvent):void
		{
			TweenMax.to(main.timeContainer.selecter, 0.2, {y:-80, ease:Cubic.easeInOut});
			TweenMax.to(main.busyContainer.selecter, 0.2, {y:0, ease:Cubic.easeInOut});
			TweenMax.to(main.unregContainer.selecter, 0.2, {y:0, ease:Cubic.easeInOut});
			TweenMax.to(main.anonContainer.selecter, 0.2, {y:50, ease:Cubic.easeInOut});
			
			TweenMax.to(main.busyContainer, 0.2, {y:125, ease:Cubic.easeInOut});
			TweenMax.to(main.unregContainer, 0.2, {y:175, ease:Cubic.easeInOut});
			TweenMax.to(main.anonContainer, 0.2, {y:225, ease:Cubic.easeInOut});
		}

		//handle listeners, builds j_session, posts and requests redirection.html
		private function transmit(event:TouchEvent):void
		{
			//UI management
			loginBtn.removeEventListener(TouchEvent.TOUCH_TAP, transmit);
			
			TweenMax.to(loginBtn.loading, 0.75, {rotation:"-360", ease:Cubic.easeInOut, repeat:-1});
			TweenMax.to(loginBtn.loading, 0.75, {alpha:1});
			TweenMax.to(dashboard.loading, 0.5, {autoAlpha:1, ease:Cubic.easeInOut});
			TweenMax.to(dashboard.loading.loading, 0.75, {rotation:"-360", ease:Cubic.easeInOut, repeat:-1});

			//flush local j_session w/ text fields
			mavin.addEventListener("authComplete", checkAuthStatus);
			mavin.addEventListener("IOerror", networkError);
			mavin.authorize(login.userid_txt.text,login.password_txt.text);

			//flush lso
			SO.data.userid = login.userid_txt.text;
			SO.data.pass = login.password_txt.text;
			SO.flush ();
			
			//check if admin, pw
			function checkAuthStatus(event:Event):void
			{
				//check pw, if true, reset
				if(mavin.invalidPW == true)
				{
					TweenMax.killTweensOf(loginBtn.loading);
					loginBtn.loading.alpha = 0;
					
					login.statusText.text = "Please check your password";
					loginBtn.addEventListener(TouchEvent.TOUCH_TAP, transmit);
				}

				//check admin, if true, listen for members
				if(mavin.isAdmin == true)
				{
					mavin.removeEventListener("authComplete", checkAuthStatus);
					mavin.addEventListener("memberLoadComplete", flushMembers);
				}

				//else, listen for modules
				if(mavin.isAdmin == false && mavin.invalidPW == false)
				{
					mavin.removeEventListener("authComplete", checkAuthStatus);

					mavin.addEventListener("smsLoadComplete", addSMS);
					mavin.addEventListener("accountLoadComplete", addAccount);
					mavin.addEventListener("queueLoadComplete", addQueue);
					mavin.addEventListener("redirectionLoadComplete", addRedirection);
					mavin.addEventListener("f2mLoadComplete", addVoicemail);

					//ui management
					TweenMax.to(header, 0.5, {autoAlpha:1, y:-500, ease:Strong.easeInOut});
					TweenMax.to(login, 0.5, {autoAlpha:1, delay:0.1, y:-500, ease:Cubic.easeInOut});
					TweenMax.to(loginBtn, 0.5, {autoAlpha:1, delay:0.2, y:-500, ease:Cubic.easeInOut});
					TweenMax.to(dashboard, 0.5, {delay:0.3,autoAlpha:1, ease:Cubic.easeInOut});
					TweenMax.to(dashboard.loading, 0.5, {y:yP, x:xP, ease:Cubic.easeInOut});
					TweenMax.to(main, 0.5, {autoAlpha:0, ease:Cubic.easeInOut});

					programState = "home";

					//set function count
					if(mavin.hasPhonenumber == true){functionCount = functionCount + 2}
					if(mavin.hasQueue == true){functionCount = functionCount + 1}
				}
			}
		}

		private function networkError(event:Event):void
		{
			trace("mavin IO error");
		}

		private function addRedirection(event:Event):void
		{
			addDashboard("Umleitung", 1);

			mavin.removeEventListener("redirectionLoadComplete", addRedirection);
		}

		private function addSMS(event:Event):void
		{
			addDashboard("SMS", 5);
			
			mavin.removeEventListener("smsLoadComplete", addSMS);
		}

		private function addAccount(event:Event):void
		{
			addDashboard("Accounts", 3);
			
			mavin.removeEventListener("accountLoadComplete", addAccount);
			mavin.addEventListener("accountLoadComplete", refreshAccount);
		}

		private function refreshAccount(event:Event):void
		{
			flushAccount();
		}

		private function addQueue(event:Event):void
		{
			addDashboard("Queue", 2);

			mavin.removeEventListener("queueLoadComplete", addQueue);
			mavin.addEventListener("queueLoadComplete", refreshQueue);
		}

		private function refreshQueue(event:Event):void
		{
			flushQueue();
		}

		private function addVoicemail(event:Event):void
		{
			addDashboard("Voicemail", 6);

			mavin.removeEventListener("f2mLoadComplete", addVoicemail);
		}
		
		//redirection flushing
		private function flushRedirection():void
		{
			//listeners
			main.timeContainer.addEventListener(TouchEvent.TOUCH_TAP, tempHandler);
			main.busyContainer.addEventListener(TouchEvent.TOUCH_TAP, tempHandler2);
			main.unregContainer.addEventListener(TouchEvent.TOUCH_TAP, tempHandler3);
			main.anonContainer.addEventListener(TouchEvent.TOUCH_TAP, tempHandler4);
			
			main.timeContainer.addEventListener(TouchEvent.TOUCH_TAP, targetTest);
			main.busyContainer.addEventListener(TouchEvent.TOUCH_TAP, targetTest2);
			main.unregContainer.addEventListener(TouchEvent.TOUCH_TAP, targetTest3);
			main.anonContainer.addEventListener(TouchEvent.TOUCH_TAP, targetTest4);

			//reset
			main.timeContainer.switcher.gotoAndStop(2);
			main.busyContainer.switcher.gotoAndStop(4);
			main.unregContainer.switcher.gotoAndStop(6);
			main.anonContainer.switcher.gotoAndStop(1);
			
			//checks
			if(mavin.redirectionTime.active == 1){main.timeContainer.Check.gotoAndStop(2);}
			if(mavin.redirectionTime.active == 0){main.timeContainer.Check.gotoAndStop(1);}
			if(mavin.redirectionBusy.active == 1){main.busyContainer.Check.gotoAndStop(2);}
			if(mavin.redirectionBusy.active == 0){main.busyContainer.Check.gotoAndStop(1);}
			if(mavin.redirectionUnre.active == 1){main.unregContainer.Check.gotoAndStop(2);}
			if(mavin.redirectionUnre.active == 0){main.unregContainer.Check.gotoAndStop(1);}
			if(mavin.redirectionAnon.active == 1){main.anonContainer.Check.gotoAndStop(2);}
			if(mavin.redirectionAnon.active == 0){main.anonContainer.Check.gotoAndStop(1);}

			//timeRedir flush
			if(mavin.redirectionTime.choice == 1){main.timeContainer.switcher.gotoAndStop(2);main.timeContainer.switcher.destination.text = mavin.redirectionTime.destination;}
			if(mavin.redirectionTime.choice == 2){main.timeContainer.switcher.gotoAndStop(3);main.timeContainer.switcher.destination.text = "s umleiten auf Voicemail";}
			if(mavin.redirectionTime.choice == 3){main.timeContainer.switcher.gotoAndStop(3);main.timeContainer.switcher.destination.text = "s umleiten auf Fax2Mail";}
			
			main.timeContainer.switcher.Delay.text = mavin.redirectionTime.delay;
			//busyRedir flush
			if(mavin.redirectionBusy.choice == 1){main.busyContainer.switcher.gotoAndStop(4);main.busyContainer.switcher.destination.text = mavin.redirectionBusy.destination;}
			if(mavin.redirectionBusy.choice == 2){main.busyContainer.switcher.gotoAndStop(5);main.busyContainer.switcher.destination.text = "Falls besetzt umleiten auf Voicemail";}
			
			//unregRedir flush
			if(mavin.redirectionUnre.choice == 1){main.unregContainer.switcher.gotoAndStop(6);main.unregContainer.switcher.destination.text = mavin.redirectionUnre.destination;}
			if(mavin.redirectionUnre.choice == 2){main.unregContainer.switcher.gotoAndStop(7);main.unregContainer.switcher.destination.text = "Falls Endgeräte nicht erreichbar umleiten auf Voicemail"}
			
			//anonRedir flush
			if(mavin.redirectionAnon.choice == 1){main.anonContainer.switcher.gotoAndStop(1);main.anonContainer.switcher.Text.text = "Falls unterdrückt umleiten auf Voicemail";}
			if(mavin.redirectionAnon.choice == 2){main.anonContainer.switcher.gotoAndStop(7);main.anonContainer.switcher.destination.text = "Falls unterdrückt umleiten auf Abweisungsnachricht";}

			//set saveBtn
			topMenu.saveBtn.addEventListener(TouchEvent.TOUCH_TAP, saveRedir);
			topMenu.saveBtn.btn_txt.text = "Saved!";
			TweenMax.to(topMenu.saveBtn, 0.5, {delay:0.4, x:120, ease:Bounce.easeOut});
		}

		private function flushF2M():void
		{
			main.timeContainer.selecter.fax2mailIcon.email.text = mavin.f2mEmail[1];
		}

		private function flushSMS():void
		{
			topMenu.sendBtn.btn_txt.text = "Send";
			TweenMax.to(topMenu.sendBtn, 0.5, {x:120, ease:Bounce.easeOut});

			topMenu.sendBtn.addEventListener(TouchEvent.TOUCH_TAP, SMS);
			
			i4 = 0;
			
			for each(var clip in mavin.smsNumber)
			{
				var SMSRadio:MovieClip = new smsRadio();
				SMSRadio.y = i4 * 28;
				SMSRadio.radio.label = mavin.smsNumber[i4];
				SMSRadio.radio.value = mavin.smsNumberID[i4];
				SMSRadio.radio.group = smsRadioGroup;
				
				SMSRadio.radio.setStyle("textFormat", robotoLabel);

				main.smsContainer.addChild(SMSRadio);
				i4 = i4 + 1;
			}
		}

		private function flushVoicemail():void
		{
			hideDashboard(8);

			main.callButton.addEventListener(TouchEvent.TOUCH_TAP, callVoicemail);

			function callVoicemail(event:TouchEvent)
			{
				navigateToURL(new URLRequest("tel:0435009990"))
			}

			function sendVoicemail(event:TouchEvent):void
			{
				mavin.loadVoicemail({method:"POST"});
			}

			main.email.text = mavin.voicemail.email;
			main.greeting.text = mavin.voicemail.greeting;
			main.PIN.text = mavin.voicemail.PIN;

			main.callButton.btn_txt.text = "043 500 9990";
		}
		
		private function SMS(event:TouchEvent):void
		{
			topMenu.sendBtn.btn_txt.text = "Sending";
			TweenMax.to(topMenu.sendBtn, 0.5, {x:65, ease:Bounce.easeOut});

			mavin.smsMessage = {message:main.smsContainer2.SMSmessage.text, recipient:main.smsContainer2.recipient.text, number:smsRadioGroup.selectedData}
			mavin.loadSMS("POST");

			topMenu.sendBtn.removeEventListener(TouchEvent.TOUCH_TAP, SMS);
			mavin.addEventListener("smsLoadComplete", confirm);

			function confirm():void
			{
				mavin.removeEventListener("smsLoadComplete", confirm);
				if(main.currentFrame == 2){flushSMS();}
			}
		}
		
		private function flushQueue():void
		{
			if(main.currentFrame == 5)
			{	
				reset(5);

				main.queueContainer.addEventListener(TouchEvent.TOUCH_TAP, queueHandler);
				topMenu.refreshBtn.addEventListener(TouchEvent.TOUCH_TAP, refreshQueue);
				topMenu.stopBtn.addEventListener(TouchEvent.TOUCH_TAP, logoutAll);

				i3 = 0;
				i4 = 0;

				//for each queue, addChild
				for each(var queue in mavin.queueList)
				{
					var QueueSnippet:MovieClip = new queueSnippet();
					QueueSnippet.y = i4 * 57;
					QueueSnippet.Text.text = mavin.queueList[i3] + " als";
					QueueSnippet.Text2.text = mavin.queueName[i3];
					
					if(mavin.queueStatus[i3] == "Online")
					{
						QueueSnippet.slider.gotoAndStop(2);
					}
					
					QueueSnippet.name = mavin.queueAgent[i3];

					main.queueContainer.addChild(QueueSnippet);
					i4 = i4 + 1;
					i3 = i3 + 1;
				}

				function queueHandler(event:TouchEvent):void
				{
					if(event.target.name == "slider"){mavin.loadQueue(event.target.parent.name);}
				}

				function logoutAll(event:TouchEvent):void
				{
					mavin.logoutAllQueue();
				}
			}
		}

		private function flushAccount():void
		{
			if(main.currentFrame == 4)
			{
				reset(4);

				i4 = 0;
				
				for each(var Account in mavin.accountArray)
				{
					var EGSnippet:MovieClip = new egSnippet();

					EGSnippet.y = i4 * 120;
					EGSnippet.head.text = Account.uid;
					EGSnippet.plz.text = Account.zip;
					EGSnippet.clip.text = Account.clip;
					if(Account.status.length > 30)
					{
						var result:Array = dateSniffer.exec(Account.status);
						EGSnippet.regState.text = "Registriert von " + IPSniffer.exec(Account.status);
						EGSnippet.regState2.text = "bis " + result[1] + " um " + result[2];
					}else{
						EGSnippet.regState.text = "Nicht registriert"
						EGSnippet.regState2.text = "";
					}

					main.egContainer.addChild(EGSnippet);
					i4 = i4 + 1;
				}
			}
		}

		private function flushMembers():void
		{
			hideDashboard(10);
			
			programState = "members";

			i4 = 0;

			for each(var member in mavin.memberArray)
			{
				var MemberSnippet:MovieClip = new memberSnippet();
				MemberSnippet.y = i4 * 57;
				MemberSnippet.Text.text = member.name;
				MemberSnippet.name = member.id;

				main.memberContainer.addChild(MemberSnippet);
				i4 = i4 + 1;
			}

			main.memberContainer.addEventListener(TouchEvent.TOUCH_TAP, memberHandler);

			function memberHandler(event:TouchEvent):void
			{
				if(event.target.name == "actAs"){mavin.actAs(event.target.parent.name);}
			}

			TweenMax.to(header, 0.5, {autoAlpha:1, y:-500, ease:Strong.easeInOut});
			TweenMax.to(login, 0.5, {autoAlpha:1, delay:0.1, y:-500, ease:Cubic.easeInOut});
			TweenMax.to(loginBtn, 0.5, {autoAlpha:1, delay:0.2, y:-500, ease:Cubic.easeInOut});
		}

		private function saveRedir(event:TouchEvent):void
		{
			//reset mavin redir vars
			mavin.redirectionTime.active = 0;
			mavin.redirectionBusy.active = 0;
			mavin.redirectionUnre.active = 0;
			mavin.redirectionAnon.active = 0;

			if(main.timeContainer.Check.currentFrame == 1)
			{
				//if(main)
				mavin.redirectionTime.active = 1;
				mavin.redirectionTime.delay = main.timeContainer.switcher.Delay.text;
				mavin.redirectionTime.designation = main.timeContainer.switcher.destination.text;

				if(main.timeContainer.switcher.currentFrame == 2){mavin.redirectionTime.choice = 1};
				if(main.timeContainer.switcher.currentFrame == 3 && main.timeContainer.switcher.destination.text == "s umleiten auf Voicemail"){mavin.redirectionTime.choice = 2;}
				if(main.timeContainer.switcher.currentFrame == 3 && main.timeContainer.switcher.destination.text == "s umleiten auf Fax2Mail"){mavin.redirectionTime.choice = 3;}
			}
			
			if(main.busyContainer.Check.currentFrame == 1)
			{
				mavin.redirectionBusy.active = 1;
				mavin.redirectionBusy.destination = main.busyContainer.switcher.destination.text;

				if(main.busyContainer.switcher.currentFrame == 4){mavin.redirectionBusy.choice = 1;}
				if(main.busyContainer.switcher.currentFrame == 5){mavin.redirectionBusy.choice = 2;}
			}
			
			if(main.unregContainer.Check.currentFrame == 1)
			{
				mavin.redirectionUnre.active = 1;
				mavin.redirectionUnre.destination = main.unregContainer.switcher.destination.text;

				if(main.unregContainer.switcher.currentFrame == 6)
				{
					mavin.redirectionUnre.choice = 1;
				}
				
				if(main.unregContainer.switcher.currentFrame == 7)
				{
					mavin.redirectionUnre.choice = 2;
				}
			}
			
			if(main.anonContainer.Check.currentFrame == 1)
			{
				mavin.redirectionAnon.active = 1

				if(main.anonContainer.switcher.currentFrame == 1){mavin.redirectionAnon.choice = 1;}
				if(main.anonContainer.switcher.currentFrame == 7){mavin.redirectionAnon.choice = 2;}
			}	

			mavin.f2mEmail[1] = main.timeContainer.selecter.fax2mailIcon.email.text;

			//saveReidr
			mavin.loadRedirection("POST");

			//UI Management
			topMenu.saveBtn.removeEventListener(TouchEvent.TOUCH_TAP, saveRedir);
			topMenu.saveBtn.btn_txt.text = "Saving";
			TweenMax.to(topMenu.saveBtn, 0.5, {x:65, ease:Bounce.easeOut});

			mavin.addEventListener("redirectionLoadComplete", complete);

			function complete(event:Event):void
			{
				topMenu.saveBtn.addEventListener(TouchEvent.TOUCH_TAP, saveRedir);
				mavin.removeEventListener("redirectionLoadComplete", complete);
				if(main.currentFrame == 1){flushRedirection();}
			}
		}
		
		////swiping////
		private function mouseDownHandler(event:TouchEvent):void
		{
			TweenLite.killTweensOf(main);
		 	y1 = y2 = main.y;
		 	t1 = t2 = getTimer();
		 	main.startDrag(false, new Rectangle(bounds.x, -99999, 0, 99999999));
		 	main.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		 	main.stage.addEventListener(TouchEvent.TOUCH_END, mouseUpHandler);
		}

		private function enterFrameHandler(event:Event):void
		{
		 	//track velocity using the last 2 frames for more accuracy
		 	y2 = y1;
		 	t2 = t1;
		 	y1 = main.y;
		 	t1 = getTimer();
		}

		private function mouseUpHandler(event:TouchEvent):void
		{
			main.stopDrag();
		 	main.stage.removeEventListener(TouchEvent.TOUCH_END, mouseUpHandler);
		 	main.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		 	var time:Number = (getTimer() - t2) / 1000;
		 	var yVelocity:Number = (main.y - y2) / time;
		 	var grace:Number = stage.stageHeight / 480 * 12;
		 	var yOverlap:Number = stage.stageHeight - main.height - grace;
		 	if(yOverlap > 7){yOverlap = 7};
		 	ThrowPropsPlugin.to(main, {ease:Strong.easeOut, throwProps:{y:{velocity:yVelocity, max:bounds.top, min:yOverlap, resistance:200}}}, 10, 0.25, 0);
		}
	}
}