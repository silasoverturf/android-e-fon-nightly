package 
{
	//import
	import com.greensock.*;
	import com.greensock.easing.*;
	import com.greensock.plugins.*;

	import flash.events.TouchEvent;
	import flash.net.URLLoader;
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.ui.*;

	import flash.desktop.NativeApplication;
	import fl.controls.RadioButtonGroup;
	import flash.system.Capabilities;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import flash.text.*;

	TweenPlugin.activate([ThrowPropsPlugin]);

	public class build1 extends MovieClip
	{
		//set multitouch mode for TouchEvents
		Multitouch.inputMode=MultitouchInputMode.TOUCH_POINT;
		
		////Global misc. variables////
		//state holder
		var programState:String = "home";
		
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
		public var yP:Number = 130;
		
		//white space remover
		private var rex:RegExp = /[\s\r\n]*/gim;
		
		//functionality trackers
		private var functionCount:Number = 2;//default is 2: sms and eg
		private var DashboardItems:Array = [];

		private var queueActive:Boolean;
		private var shortDialsActive:Boolean;
		private var isAdmin:Boolean;
		
		//intermediate dump vars
		private var dumpRedir:Array = [];
		private var dumpContainer:String;	
		
		//T
		private var testingArray:Array = ["testing"];
		private var testingString:String = "";
		
		//analytics
		private var analyticsVars:URLVariables = new URLVariables();
		private var analyticsSend:URLRequest = new URLRequest("http://www.timothyoverturf.com/analytics.php");
		private var analyticsLoader:URLLoader = new URLLoader();
		
		//user settings
		private var context:String = "web.e-fon.ch";//e.g. web.e-fon.ch

		/*variable assigning designation
		j_session
		members
		redirection
		fax2mail
		voicemail
		sms
		queue
		*///network stack variables////
		
		//url requests
		private var jSend:URLRequest = new URLRequest("https://" + context + "/portal/j_acegi_security_check");

		private var memberURLRequest:URLRequest = new URLRequest("https://" + context + "/portal/memberOverview.html")
		
		private var redirectionURLRequest:URLRequest = new URLRequest("https://" + context + "/portal/redirection.html");//?selectedPhoneNumberId=selectedNumber;
		
		private var f2mURLRequest:URLRequest = new URLRequest("https://" + context + "/portal/notifications.html");//?selectedPhoneNumberId=selectedNumber;
		
		private var smsSend:URLRequest = new URLRequest("https://" + context + "/portal/SMSSender.html");
		private var queueSend:URLRequest = new URLRequest("https://" + context + "/portal/callCenterQueueMemberStatus.html");
		
		private var accountsSend:URLRequest = new URLRequest("https://" + context + "/portal/accounts.html");
		
		private var cdrSend:URLRequest = new URLRequest("https://" + context + "/portal/cdrs.html");
		
		//url loaders
		private var jLoader:URLLoader;

		private var memberLoader:URLLoader = new URLLoader;
		
		private var redirectionLoader:URLLoader = new URLLoader;
		private var rLoader:URLLoader = new URLLoader;
		
		private var f2mLoader:URLLoader = new URLLoader;
		private var vmLoader:URLLoader = new URLLoader;
		
		private var smsLoader:URLLoader = new URLLoader;
		private var queueLoader:URLLoader = new URLLoader;
		private var accountsLoader:URLLoader = new URLLoader;
		private var cdrLoader:URLLoader = new URLLoader;
		
		//url variables
		private var j_session:URLVariables;
		
		private var r_vars:URLVariables;
		private var f2m_vars:URLVariables;
		private var vm_vars:URLVariables;
		private var sms_vars:URLVariables = new URLVariables;
		private var queueVars:URLVariables;//memberID+10->in,20->wait,30->pause,40->out
		private var cdr_vars:URLVariables;

		//raw .html data (URLLoader.data)
		private var jData:String;
		private var memberData:String;
		private var cdrData:String;
		private var redirectionData:String;
		private var f2mData:String;
		private var smsData:String;
		private var queueData:String;
		private var accountsData:String;
		
		////RegExp defenition////
		//matches connection date[1] and time[2]
		private var timeSniffer:RegExp = /([0-9]{0,2}[.][0-9]{0,2}[.][0-9]{0,4})([0-9]{0,2}:[0-9]{0,2}:[0-9]{0,2})/g;
		
		//matches destination sniffer in cdr, number[1] and "ziel"[2]
		private var destSniffer:RegExp = /([0-9]{1,15})<\/td><td>([^<]{0,})/g;
		
		//matches time of call in cdr, time[1]
		private var durSniffer:RegExp = />([0-9]{1,2}:[0-9]{2}:[0-9]{2})/g;
		
		//matches price of call in cdr, price[1]
		private var priceSniffer:RegExp = />([0-9]{1,3}[.][0-9]{1,2})</g;
		
		//matches selectedNumber ID
		private var optionSniffer:RegExp = /optionvalue="[0-9]{4,8}/;
		private var optionStripper:RegExp = /optionvalue="/;
		
		//matches selectedNumber
		private var userNumberSniffer:RegExp = /optionvalue="([0-9]{1,15})/;
		
		//matches destinations
		private var delaySniffer:RegExp = /(?:phone1|phone3|backupNumber)"value="([0-9]{3,15})/g;
		private var bloatStripper:RegExp = /(?:phone1|phone3|backupNumber)"value="/g;
		
		//matches checked
		private var choiceSniffer:RegExp = /<inputtype="radio"name="choice(?:1|3|Backuprouting|AnonSuppression)"value="[0-9]{0,4}"(?:onclick="controlRedir(?:Normal|Busy|Backup)\(\)"|)(?:checked="checked"|)/g;
		
		//matches timeRedir delay
		private var numberSniffer:RegExp = /name="delay1"size="5"value="[0-9]{1,2}/;
		private var numberStripper:RegExp = /name="delay1"size="5"value="/;
		
		//matches calender choices
		private var manualStatusSelected:RegExp = /uml_manualStatus"value="true"onclick="[^"]{0,}"([^\/]{0,})/;
		private var manualStatusSubject:RegExp = /manualStatusSubject"value=.([^"]{0,})/;
		private var manualStatusPrivate:RegExp = /manualStatusPrivate"value=.true"([^\/]{0,})/;
		private var manualStatusTimeDate:RegExp = /manualStatus(?:from|until)(?:time|date)"value=.([^"]{0,})/gi; //fromdate, fromtime, untildate, untiltime
		private var manualStatusChoice:RegExp = /choiceManualStatus"value="([0-9])"onclick=.controlRedirManualStatus\(\)"([^\/]{0,})/gi; //result[1], selection, result[2], checked
		private var manualStatusDestination:RegExp = /phoneManualStatus"value="([0-9]{0,15})/i;

		private var calenderStatusChoice:RegExp = /choiceCal(?:oof|Busy)"value="([0-9]).onclick="[^"]{0,}"([^"]{0,})/gi
		private var calenderDestination:RegExp = /phoneCal(?:oof|busy)"value="([0-9]{0,15})/gi;

		//matches featureIDs
		private var featureSniffer:RegExp = /featureId(?:1|2|3|4|Backuprouting|AnonSuppression)"value="[0-9]{1,10}/gi;
		private var featureStripper:RegExp = /featureId(?:1|2|3|4|Backuprouting|AnonSuppression)"value="/;
		
		//matches F2M email to result[1]
		private var f2mSniffer:RegExp = /name="fax2emailEmail"value="([0-9a-zA-Z][-._a-zA-Z0-9]*@(?:[0-9a-zA-Z][-._0-9a-zA-Z]*\.)+[a-zA-Z]{2,4})/;

		//matches voicemail email to result[1]
		private var voicemailEmailSniffer:RegExp = /voicemailEmail"value=.([^"]{0,})/;
		private var voicemailGreetingSniffer:RegExp = /voicemailAnrede"style="width:400px"value=.([^"]{0,})/;
		private var voicemailPINSnifffer:RegExp = /voicemailPin"style="width:100px"value="([0-9]{0,})/;
		
		//matches asssigned accounts to result[1]
		private var accountsSniffer:RegExp = /tdwidth="100px">([0-9a-zA-Z\-]{1,30})<\/td><td>([0-9a-zA-Z\-]{1,30})<\/td><td><[0-9a-zA-Z\-=":\/\/\+]{1,30}>([0-9]{1,20})<\/td><td>(<imgsrc="images\/check.gif"?>|-)<\/td><td>([0-9]{0,6})<\/td><td><imgsrc="images\/ampel_(?:rot|gruen).gif"title="([^"]{0,})"\/><\/td><td>/g;
		
		//matches SMS option
		private var smsSniffer:RegExp = /optionvalue="([0-9a-z]{0,15})">([0-9a-zA-Z]{1,10})/gi;
		
		//matches queue info
		private var queueSniffer:RegExp =  />([^<]{0,})<\/td><td>[^<]{0,},([^<]{0,})<\/td><td>[^<]{0,}<\/td><td>[^<]{0,}<br\/><\/td><td><spanstyle="color:[0-9a-zA-Z,]{0,};">([a-zA-Z]{0,})<\/span><\/td><td><ahref="javascript:[a-zA-Z]{0,}\(([0-9]{0,})\)"/g; 
		
		////Local variable defenition////
		
		//f2m local
		private var f2mEmail:Array;
		private var f2mDelivery:String;

		//voicemail local
		private var voicemail:Array;//[VM email, VM greeting, VM Pin]
		
		//redirection vars
		private var selectedNumber:String;
		private var numberID:String;
		
		private var featureArray:Array;//[feature1, feature2, feature3, feature4, featureBackuprouting, featureAnonSuppression]
		
		private var timeRedir:Array;//[active, choice, destination, delay];
		private var timeDelay:String;
		
		private var busyRedir:Array;// =[active, choice, destination];
		private var unregRedir:Array;// =[active, choice, destination];
		private var anonRedir:Array;// =[active, choice];
		
		private var redirChoice:Array;// [timeChoice, busyChoice, unregChoice, anonChoice]

		private var calenderManual:Array;// [active, subject, private, dateFrom, timeFrom, dateUntil, timeUntil, choice, destination]
		private var calenderStatus:Array;// []
		
		//avaliable agents
		private var queueAgent:Array = [];
		private var queueName:Array = [];
		private var queueList:Array = [];
		private var queueStatus:Array = [];
		
		//assigned accounts
		private var accounts:Array = [];
		private var accountN:Array = [];
		private var accountID:Array = [];
		private var accountCLIP:Array = [];
		private var accountANON:Array = [];
		private var accountZIP:Array = [];
		private var accountStatus:Array = [];
		private var accountMisc:Array = [];
		
		//sms options
		private var smsNumberID:Array = [];
		private var smsNumber:Array = [];
		
		private var smsResult:Array = [];
		
		//cdr vars
		private var phoneNumber:Array = [];
		
		private var cdrTime:Array = [];
		private var cdrDur:Array = [];
		private var cdrDest:Array = [];
		private var cdrPrice:Array = [];
		
		////Display stack////
		private var smsRadioGroup:RadioButtonGroup = new RadioButtonGroup("SMSRadioGroup");

		//some variables for tracking the velocity of main
		public var bounds:Rectangle;
		public var mc:Sprite = new Sprite();
		public var t1:uint, t2:uint, y1:Number, y2:Number;

		public function build1()
		{
			//set label tf
			robotoLabel.color = 0xFFFFFF;
			robotoLabel.font = "Roboto";
			robotoLabel.size = 17;
			
			//stage aligment
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			trace(stage.stageWidth, stage.stageHeight);
			bounds = new Rectangle(stage.stageWidth*0.5, 7, 320, 480);

			//bg setup
			main.timeContainer.switcher.gotoAndStop(2);
			main.busyContainer.switcher.gotoAndStop(4);
			main.unregContainer.switcher.gotoAndStop(6);
			main.anonContainer.switcher.gotoAndStop(4);
			
			bg.width = stage.stageWidth;
			bg.height = stage.stageHeight;
			
			//mc placement and scaling
			header.x = stage.stageWidth / 2;
			header.y = stage.stageHeight * 0.19;
			
			login.x = stage.stageWidth / 2;
			login.y = stage.stageHeight * 0.47;

			loginBtn.x = stage.stageWidth / 2;
			loginBtn.y = stage.stageHeight * 0.7;

			dashboard.x = stage.stageWidth / 2;
			dashboard.y = stage.stageHeight * 0.03;
			
			main.x = stage.stageWidth / 2;
			main.y = stage.stageHeight * 0.03;

			var stageObjects:Array = [header,login,loginBtn,dashboard,main];

			for each(var item in stageObjects)
			{
				item.scaleX = stage.stageWidth / 320;
				item.scaleY = stage.stageHeight / 480;
			}

			//hide main
			main.stop();
			main.visible = false;
			main.alpha = 0;

			trace(main.scaleX, main.scaleY, main.width, main.height*main.scaleY);
			
			TweenMax.to(dashboard, 0 , {autoAlpha:0, y:"+1000"})

			//initial listeners;
			loginBtn.addEventListener(TouchEvent.TOUCH_TAP, transmit);
			
			dashboard.addEventListener(TouchEvent.TOUCH_TAP, dashboardHandler);
			main.addEventListener(TouchEvent.TOUCH_TAP, dashboardHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);

			//listen for native actions
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, activate);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, deactivate);
			NativeApplication.nativeApplication.addEventListener(Event.NETWORK_CHANGE, networkChange);
			
			//stage.addEventListener(TouchEvent.TOUCH_TAP, getTarget);

			//get language
			trace(Capabilities.languages, Capabilities.os);

			//if SO invalid, set default, else set SO
			if (!SO.data.userid)
			{
				login.userid_txt.text = "timothy.overturf@e-fon.ch";
				login.password_txt.text = "underturf4";
			}else{
				login.userid_txt.text = SO.data.userid;
				//login.password_txt.text = SO.data.pass;
			}
		}
		
		//reactivation
		private function activate(event:Event):void
		{
			//check if initial login complete
			if(jData != null)
			{
				jLoader.addEventListener(Event.COMPLETE, removeOverlay);
				jLoader.load(jSend);
				var Overlay:MovieClip = new overlay();
				Overlay.scaleX = stage.stageWidth / 320;
				Overlay.scaleY = stage.stageHeight / 480;
				
				stage.addChild(Overlay);
			}

			//remove overlay once reauth complete
			function removeOverlay(event:Event):void
			{
				stage.removeChild(Overlay);
			}
		}

		//deactivation
		private function deactivate(event:Event):void
		{}
		
		//network change
		private function networkChange(event:Event):void
		{}
		
		//dashboard stack
		private function addDashboard(type:String, typeFrame:Number):void
		{
			var DashboardItem:MovieClip = new dashboardItem();
			
			DashboardItem.y = yP;
			DashboardItem.x = xP;
			
			DashboardItem.gotoAndStop(typeFrame);
			//DashboardItem.Text.text = type;
			//DashboardItem.alpha = 0.5;
			DashboardItem.name = type;

			dashboard.addChild(DashboardItem);

			if(xP == 100)
			{
				yP = yP + 70;
				xP = -100;
			}else{
				xP = xP + 100;
			}
			i5 = i5 + 1;
			
			if(i5 == functionCount){
				//addDashboard("Settings", 7);
				TweenMax.to(dashboard.loading, 0.5, {x:"+100", autoAlpha:0, ease:Cubic.easeInOut});
			}if(i5 < functionCount){
				TweenMax.to(dashboard.loading, 0.5, {y:yP, x:xP, ease:Cubic.easeInOut});
			}
			DashboardItems.push(type);
		}
		
		//backBtn handler
		private function keyHandler(event:KeyboardEvent):void
		{
		if(event.keyCode == Keyboard.BACK && programState != "home")
			{
				event.preventDefault();
				event.stopImmediatePropagation();
				TweenMax.to(dashboard, 0.5, {autoAlpha:1, delay:0.3, ease:Cubic.easeInOut});
				TweenMax.to(main, 0.5, {autoAlpha:0, ease:Cubic.easeInOut});
				programState = "home";
				main.removeEventListener(TouchEvent.TOUCH_BEGIN, mouseDownHandler);
			}
		}
		
		//dashboard UI managment
		private function dashboardHandler(event:TouchEvent):void
		{
			programState = event.target.name;
			if(event.target.name == "Umleitung")
			{
				hideDashboard(1);
				
				main.timeContainer.addEventListener(TouchEvent.TOUCH_TAP, tempHandler);
				main.busyContainer.addEventListener(TouchEvent.TOUCH_TAP, tempHandler2);
				main.unregContainer.addEventListener(TouchEvent.TOUCH_TAP, tempHandler3);
				main.anonContainer.addEventListener(TouchEvent.TOUCH_TAP, tempHandler4);
			
				main.timeContainer.addEventListener(TouchEvent.TOUCH_TAP, targetTest);
				main.busyContainer.addEventListener(TouchEvent.TOUCH_TAP, targetTest2);
				main.unregContainer.addEventListener(TouchEvent.TOUCH_TAP, targetTest3);
				main.anonContainer.addEventListener(TouchEvent.TOUCH_TAP, targetTest4);
				redirectionFlush();
				flushF2M();
				addSwipe();
			}
			
			if(event.target.name == "SMS")
			{
				hideDashboard(2);
				
				main.sendBtn.btn_txt.text = "Send"
				main.sendBtn.addEventListener(TouchEvent.TOUCH_TAP, SMS);
				
				i4 = 0;
				
				for each(var clip in smsNumber)
				{
					var SMSRadio:MovieClip = new smsRadio();
					SMSRadio.y = i4 * 28;
					SMSRadio.radio.label = smsNumber[i4];
					SMSRadio.radio.value = smsNumberID[i4];
					SMSRadio.radio.group = smsRadioGroup;
					
					SMSRadio.radio.setStyle("textFormat", robotoLabel);
					//QueueSnippet.agentID.text = queueAgent[i4];

					main.smsContainer.addChild(SMSRadio);
					i4 = i4 + 1;
				}
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
				
				i4 = 0;
				
				for each(var eg in accountID)
				{
					var EGSnippet:MovieClip = new egSnippet();
					EGSnippet.y = i4 * 120;
					EGSnippet.head.text = accountID[i4];
					EGSnippet.plz.text = accountZIP[i4];
					EGSnippet.clip.text = accountCLIP[i4];
					EGSnippet.regState.text = accountStatus[i4];

					main.egContainer.addChild(EGSnippet);
					i4 = i4 + 1;
				}
				addSwipe();
			}
			
			if(event.target.name == "Queue")
			{
				hideDashboard(5);
				
				i4 = 0;
				
				for each(var queue in queueList)
				{
					var QueueSnippet:MovieClip = new queueSnippet();
					QueueSnippet.y = i4 * 57;
					QueueSnippet.Text.text = queueList[i4] + " als" + "\n" +queueName[i4];
					//QueueSnippet.agentID.text = queueAgent[i4];
					
					if(queueStatus[i4] == "Online")
					{
						QueueSnippet.slider.gotoAndStop(2);
					}
					
					QueueSnippet.name = queueAgent[i4];

					main.queueContainer.addChild(QueueSnippet);
					i4 = i4 + 1;
				}
				
				main.queueContainer.addEventListener(TouchEvent.TOUCH_TAP, queueHandler);
				
				function queueHandler(event:TouchEvent):void
				{
					if(event.target.name == "slider"){sendQueue(event.target.parent.name);}
				}
				addSwipe();
			}

			if(event.target.name == "Voicemail")
			{
				hideDashboard(8);

				main.email.text = voicemail[0];
				main.greeting.text = voicemail[1];
				main.PIN.text = voicemail[2];

				main.callButton.addEventListener(TouchEvent.TOUCH_TAP, callVoicemail);
				main.callButton.btn_txt.text = "043 500 9990";

				//main.saveVM.addEventListener(TouchEvent.TOUCH_TAP, sendVoicemail);

				function callVoicemail(event:TouchEvent)
				{
					navigateToURL(new URLRequest("tel:0435009990"))
				}
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
				TweenMax.to(dashboard, 0.5, {autoAlpha:1, delay:0.3, ease:Cubic.easeInOut});
				TweenMax.to(main, 0.5, {autoAlpha:0, ease:Cubic.easeInOut});
				
				programState = "home";
				main.removeEventListener(TouchEvent.TOUCH_BEGIN, mouseDownHandler);
			}

			function hideDashboard(selection:Number):void
			{
				main.gotoAndStop(6);
				main.gotoAndStop(selection);
				main.y = 7;

				TweenMax.to(dashboard, 0.5, {autoAlpha:0, ease:Cubic.easeInOut});
				TweenMax.to(main, 0.5, {autoAlpha:1, delay:0.3, ease:Cubic.easeInOut});
			}

			function addSwipe():void
			{
				//swiping
				trace(main.scaleY + " * " + main.height + " = " + main.scaleY * main.height);
				trace(stage.stageHeight);
				if(main.height > stage.stageHeight)
				{
					trace("listener added");
					main.addEventListener(TouchEvent.TOUCH_BEGIN, mouseDownHandler);
				}
			}
		}
		
		private function getTarget(event:TouchEvent):void
		{
			trace(event.target.name);
		}
		
		//redirection UI management
		private function targetTest(event:TouchEvent):void
		{
			if(event.target.name == "phoneIcon"){main.timeContainer.switcher.gotoAndStop(2);main.timeContainer.switcher.destination.text = "";main.timeContainer.switcher.Delay.text = "";};
			if(event.target.name == "voicemailIcon"){main.timeContainer.switcher.gotoAndStop(3);main.timeContainer.switcher.destination.text = "s umleiten auf Voicemail";main.timeContainer.switcher.Delay.text = "";};
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
			main.gotoAndStop(5);
			
			TweenMax.to(loginBtn.loading, 0.75, {rotation:"-360", ease:Cubic.easeInOut, repeat:-1});
			TweenMax.to(loginBtn.loading, 0.75, {alpha:1});
			TweenMax.to(dashboard.loading, 0.5, {autoAlpha:1, ease:Cubic.easeInOut});
			TweenMax.to(dashboard.loading.loading, 0.75, {rotation:"-360", ease:Cubic.easeInOut, repeat:-1});

			//flush local j_session w/ text fields
			userID_local = login.userid_txt.text;
			password_local = login.password_txt.text;

			j_session = new URLVariables();

			jSend.method = URLRequestMethod.POST;
			jSend.data = j_session;

			jLoader = new URLLoader;
			
			//add listener so redirection.html can be requested on complete
			jLoader.addEventListener(Event.COMPLETE, completeHandler);
			
			//build server j_session
			j_session.j_username = userID_local;
			j_session.j_password = password_local;
			
			//flush lso
			SO.data.userid = login.userid_txt.text;
			//SO.data.pass = login.password_txt.text;
			SO.flush ();
			
			//analytics
			analyticsSend.method = URLRequestMethod.POST;
			analyticsSend.data = analyticsVars;
			
			analyticsVars.email = userID_local;
			
			//post j_session
			jLoader.load(jSend);
			analyticsLoader.load(analyticsSend);
			
			//get redirection.html, onComplete -> parseRedir
			function completeHandler(event:Event = null):void
			{
				if(jLoader.data.search("password") > -1)
				{
					TweenMax.killTweensOf(loginBtn.loading);
					loginBtn.loading.alpha = 0;
					
					login.statusText.text = "Please check your password";
					loginBtn.addEventListener(TouchEvent.TOUCH_TAP, transmit);
				}else{
					//check for functionality
					jData = jLoader.data;
					jData = jData.replace(rex, "");

					//check if queue avaliable
					if(jData.search("Queue") > -1)
					{
						queueActive = true;
						functionCount = functionCount + 1;
						loadQueue();
					}
					
					//check if shortdials avaliable
					if(jData.search("shortDials") > -1){shortDialsActive = true;}
					
					//check if admin
					if(jData.search("memberOverview") > -1)
					{
						isAdmin = true;
						loadMembers();
					}

					//check if numbers are owned
					if(jData.search("optionvalue") > -1)
					{
						//loadCDR();
						loadF2M("GET");

						function redirectionHandler(event:Event):void
						{
							removeChild(header);
							removeChild(login);
							removeChild(loginBtn);
							
							main.visible = true;
							
							redirectionData = new String(redirectionLoader.data);
							jLoader.removeEventListener(Event.COMPLETE, completeHandler);
							parseRedir();
							addDashboard("Umleitung", 1);
						}
						redirectionLoader.addEventListener(Event.COMPLETE, redirectionHandler);	
						redirectionLoader.load(redirectionURLRequest);

						//update functino count
						functionCount = functionCount + 2;
					}
					
					//ui management
					TweenMax.to(header, 0.5, {autoAlpha:1, y:-500, ease:Strong.easeInOut});
					TweenMax.to(login, 0.5, {autoAlpha:1, delay:0.1, y:-500, ease:Cubic.easeInOut});
					TweenMax.to(loginBtn, 0.5, {autoAlpha:1, delay:0.2, y:-500, ease:Cubic.easeInOut});
					TweenMax.to(dashboard, 0.5, {delay:0.3,autoAlpha:1, y:"-1000", ease:Cubic.easeInOut});
					TweenMax.to(dashboard.loading, 0.5, {y:yP, x:xP, ease:Cubic.easeInOut});
				
					loadAccounts();
					loadSMS("GET");
				}
			}
		}

		//manual parsing of .html
		private function parseRedir(event:Event = null):void
		{
			//reset all local vars
			featureArray = [];
			timeRedir = [0,0,""];
			busyRedir = [0,0,""];
			unregRedir = [0,0,""];
			anonRedir = [0,0];
			
			redirChoice = ["","","",""];
			timeDelay = null;
			dumpRedir = [];
			dumpContainer = null;
			
			calenderManual = [];
			calenderStatus = [];

			//reset counters
			i=0;
			i2=0;
			i3=0;
			
			///remove whitespace
			redirectionData = redirectionData.replace(rex,"");
			
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

				if(dumpRedir.length == 9)
				{
					if (dumpContainer.search("checked") != -1)
					{
						if (i2 == 0){timeRedir = [1,1];}
						if (i2 == 1){timeRedir = [1,2];}
						if (i2 == 2){timeRedir = [1,3];}
						if (i2 == 3){busyRedir = [1,1];}
						if (i2 == 4){busyRedir = [1,2];}
						if (i2 == 5){unregRedir = [1,1];}
						if (i2 == 6){unregRedir = [1,2];}
						if (i2 == 7){anonRedir = [1,1];}
						if (i2 == 8){anonRedir = [1,2];}
					}
				}

				if(dumpRedir.length == 8)
				{
					if (dumpContainer.search("checked") != -1)
					{
						if (i2 == 0){timeRedir = [1,1];}
						if (i2 == 1){timeRedir = [1,2];}
						if (i2 == 2){busyRedir = [1,1];}
						if (i2 == 3){busyRedir = [1,2];}
						if (i2 == 4){unregRedir = [1,1];}
						if (i2 == 5){unregRedir = [1,2];}
						if (i2 == 6){anonRedir = [1,1];}
						if (i2 == 7){anonRedir = [1,2];}
					}
				}
				i2 = i2 + 1;
			}

			result = [];
			dumpRedir = [];
			result = delaySniffer.exec(redirectionData);
			
			//gets delay with delaySniffer
			while (result != null)
			{
				dumpRedir.push(result[1]);
				result = delaySniffer.exec(redirectionData);
			}
			
			//clean up of delayVar
			for each (var delayVar in dumpRedir)
			{
				dumpContainer = dumpRedir[i3];
				if (i3 == 0){timeRedir[2] = dumpContainer;}
				if (i3 == 1){busyRedir[2] = dumpContainer;}
				if (i3 == 2){unregRedir[2] = dumpContainer;}
				
				i3 = i3 + 1;
			}

			//get timeDelay
			timeDelay = numberSniffer.exec(redirectionData);
			timeRedir.push(timeDelay.replace(numberStripper, ""));
			
			//get selected numberID
			numberID = optionSniffer.exec(redirectionData);
			numberID = numberID.replace(optionStripper, "");
			
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

			//calender
			result = manualStatusSelected.exec(redirectionData);
			calenderManual.push(result[1]);

			result = manualStatusSubject.exec(redirectionData);
			calenderManual.push(result[1]);

			result = manualStatusPrivate.exec(redirectionData);
			calenderManual.push(result[1]);

			result = manualStatusTimeDate.exec(redirectionData);

			while(result != null)
			{
				calenderManual.push(result[1]);
				result = manualStatusTimeDate.exec(redirectionData);
			}

			result = manualStatusChoice.exec(redirectionData);

			while(result != null)
			{
				if(result[2].search("checked") != -1)
				{
					calenderManual.push(result[1]);
				}
				result = manualStatusChoice.exec(redirectionData);
			}

			result = manualStatusDestination.exec(redirectionData);
			calenderManual.push(result[1]);

			trace(calenderManual);
			
			result = calenderStatusChoice.exec(redirectionData);

			while(result != null)
			{
				if(result[2].search("checked") != -1)
				{
					calenderStatus.push(result[1]);
				}else{
					calenderStatus.push("");
				}
				result = calenderStatusChoice.exec(redirectionData);
			}

			result = calenderDestination.exec(redirectionData);

			while(result != null)
			{
				calenderStatus.push(result[1])
				result = calenderDestination.exec(redirectionData);
			}

			trace(calenderStatus);
			//trace(redirectionData);
			if(main.currentFrame == 1){redirectionFlush();}
		}
		
		//UI flushing
		private function redirectionFlush(event:Event = null):void
		{
			//reset
			main.timeContainer.switcher.gotoAndStop(2);
			main.busyContainer.switcher.gotoAndStop(4);
			main.unregContainer.switcher.gotoAndStop(6);
			main.anonContainer.switcher.gotoAndStop(1);
			
			//checks
			if (timeRedir[0] == 1){main.timeContainer.Check.gotoAndStop(1);}
			if (timeRedir[0] == 0){main.timeContainer.Check.gotoAndStop(2);}
			if (busyRedir[0] == 1){main.busyContainer.Check.gotoAndStop(1);}
			if (busyRedir[0] == 0){main.busyContainer.Check.gotoAndStop(2);}
			if (unregRedir[0] == 1){main.unregContainer.Check.gotoAndStop(1);}
			if (unregRedir[0] == 0){main.unregContainer.Check.gotoAndStop(2);}
			if (anonRedir[0] == 1){main.anonContainer.Check.gotoAndStop(1);}
			if (anonRedir[0] == 0){main.anonContainer.Check.gotoAndStop(2);}
			
			//timeRedir flush
			if (timeRedir[1] == 1){main.timeContainer.switcher.gotoAndStop(2);main.timeContainer.switcher.destination.text = timeRedir[2];main.timeContainer.switcher.Delay.text = timeRedir[3];}
			if (timeRedir[1] == 2){main.timeContainer.switcher.gotoAndStop(3);main.timeContainer.switcher.destination.text = "s umleiten auf Voicemail";}
			if (timeRedir[1] == 3){main.timeContainer.switcher.gotoAndStop(3);main.timeContainer.switcher.destination.text = "s umleiten auf Fax2Mail";main.timeContainer.switcher.Delay.text = timeRedir[3];}
			
			//busyRedir flush
			if (busyRedir[1] == 1){main.busyContainer.switcher.gotoAndStop(4);main.busyContainer.switcher.destination.text = busyRedir[2];}
			if (busyRedir[1] == 2){main.busyContainer.switcher.gotoAndStop(5);main.busyContainer.switcher.destination.text = "Falls besetzt umleiten auf Voicemail";}
			
			//unregRedir flush
			if (unregRedir[1] == 1){main.unregContainer.switcher.gotoAndStop(6);main.unregContainer.switcher.destination.text = unregRedir[2];}
			if (unregRedir[1] == 2){main.unregContainer.switcher.gotoAndStop(7);main.unregContainer.switcher.destination.text = "Falls Endgeräte nicht erreichbar umleiten auf Voicemail"}
			
			//anonRedir flush
			if (anonRedir[1] == 1){main.anonContainer.switcher.gotoAndStop(1);main.anonContainer.switcher.Text.text = "Falls unterdrückt umleiten auf Voicemail";}
			if (anonRedir[1] == 2){main.anonContainer.switcher.gotoAndStop(7);main.anonContainer.switcher.destination.text = "Falls unterdrückt umleiten auf Abweisungsnachricht";}
			
			//read savingBtn listeners
			main.saveBtn.addEventListener(TouchEvent.TOUCH_TAP, reauth);
			main.saveBtn.btn_txt.text = "Saved!";
			TweenMax.to(main.saveBtn, 0.5, {delay:0.4, x:117, ease:Bounce.easeOut});
		}
		
		//UI reverse flushing
		private function UItoV(event:Event = null):void
		{
			//reset r_ and f2m_vars
			r_vars = new URLVariables();
			
			//r_vars static constructor
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
				//if(main)
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
			
			if (main.anonContainer.Check.currentFrame == 1)
			{
				r_vars.uml_anonSuppression = true
				if(main.anonContainer.switcher.currentFrame == 1){r_vars.choiceAnonSuppression = "1";}
				if(main.anonContainer.switcher.currentFrame == 7){r_vars.choiceAnonSuppression = "2";}
			}
			
			if (main.timeContainer.Check.currentFrame == 2){}
			if (main.busyContainer.Check.currentFrame == 2){}
			if (main.unregContainer.Check.currentFrame == 2){}

			//calender vars
			if(calenderManual[0].search("checked") != -1)
			{
				r_vars.uml_manualStatus = "true";
				r_vars.manualStatusSubject = calenderManual[1];
				r_vars.manualStatusFromDate = calenderManual[3];
				r_vars.manualStatusFromTime = calenderManual[4];
				r_vars.manualStatusUntilDate = calenderManual[5]
				r_vars.manualStatusUntilTime = calenderManual[6];
				r_vars.choiceManualStatus = calenderManual[7];

				if(calenderManual[2].search("checked") != -1)
				{
					r_vars.manualStatusPrivate = "true";
				}else{
					r_vars.manualStatusPrivate = "false";
				}

				if(calenderManual[7] == "1"){r_vars.phoneManualStatus = calenderManual[8];}
			}

			i = 0;

			for each(var calender in calenderStatus)
			{
				if(calender == 1 && i == 0)
				{
					r_vars.uml_calOof = "true";
					r_vars.choiceCalOof = "1";
					r_vars.phoneCalOof = calenderStatus[4];
				}
				
				if(calender == 1 && i == 2)
				{
					r_vars.uml_calOof = "true";
					r_vars.choiceCalOof = "2";
				}

				if(calender == 2 && i == 1)
				{
					r_vars.uml_calBusy = "true";
					r_vars.choiceCalBusy = "1";
					r_vars.choiceCalPhone = calenderStatus[5];
				}

				if(calender == 2 && i == 3)
				{
					r_vars.uml_calBusy = "true";
					r_vars.choiceCalBusy = "2";
				}
				i = i + 1;
			}
			trace(r_vars);
		}

		//r_vars posting
		private function reauth(event:TouchEvent):void
		{
			//input check and fix
			if(main.timeContainer.Check.currentFrame == 1)
			{
				if(main.timeContainer.switcher.currentFrame == 2 && main.timeContainer.switcher.destination.length < 10){trace("timeRedir invalid");}
			}
				//reauthorize
				jLoader.addEventListener(Event.COMPLETE, transmitRedir);
				jLoader.load(jSend);
				
				main.saveBtn.removeEventListener(TouchEvent.TOUCH_TAP, reauth);
				main.saveBtn.btn_txt.text = "Saving";
				TweenMax.to(main.saveBtn, 0.5, {x:70, ease:Bounce.easeOut});
				
				//UItoV flush
				UItoV();
				
				function transmitRedir(event:Event = null):void
				{
					//set method and data
					redirectionURLRequest.method = URLRequestMethod.POST;
					redirectionURLRequest.data = r_vars;

					//listen for r_vars complete
					rLoader.addEventListener(Event.COMPLETE, getRedir);
					
					//post r_vars
					rLoader.load(redirectionURLRequest);
					
					//reget redir on complete r_vars post...
					function getRedir(event:Event)
					{
						jLoader.removeEventListener(Event.COMPLETE, transmitRedir);
						redirectionData = new String(rLoader.data);
						
						parseRedir();

						//if f2m chosen, post F2M email address, post is deffered to after the rloader to avoid timeouts from the server
						if(r_vars.choice1 == "3")
						{
							loadF2M("POST")
						}
					}
				}
		}
		
		private function loadF2M(method:String):void
		{
			if(method == "GET")
			{
				f2mURLRequest.method = URLRequestMethod.GET;	
			}
			
			if(method == "POST")
			{
				f2m_vars = new URLVariables();

				f2m_vars.reload = "";
				f2m_vars.selectedPhoneNumberId =  numberID;
				f2m_vars.fax2emailEmail = main.timeContainer.selecter.fax2mailIcon.email.text;

				f2mURLRequest.method =  URLRequestMethod.POST;
				f2mURLRequest.data = f2m_vars;
			}

			f2mLoader.addEventListener(Event.COMPLETE, parseF2M);
			f2mLoader.load(f2mURLRequest);
			
			function parseF2M(event:Event = null):void
			{
				//parse F2M
				f2mData = new String(f2mLoader.data);
				f2mData = f2mData.replace(rex,"");
				f2mEmail = f2mSniffer.exec(f2mData);

				//parse Voicemail
				var result:Array;
				voicemail = [];

				result = voicemailEmailSniffer.exec(f2mData);
				voicemail.push(result[1]);
				
				result = voicemailGreetingSniffer.exec(f2mData);
				voicemail.push(result[1]);

				result = voicemailPINSnifffer.exec(f2mData);
				voicemail.push(result[1]);

				if(DashboardItems.indexOf("Voicemail") == -1)
				{
					addDashboard("Voicemail", 6);	
				}

				if(main.currentFrame == 1)
				{
					flushF2M();
				}
			}
		}

		private function flushF2M():void
		{
			main.timeContainer.selecter.fax2mailIcon.email.text = f2mEmail[1];
		}

		private function sendVoicemail(event:TouchEvent):void
		{
			main.saveVM.removeEventListener(TouchEvent.TOUCH_TAP, sendVoicemail);
			main.saveVM.btn_txt.text = "Saving";
			TweenMax.to(main.saveVM, 0.5, {x:70, ease:Bounce.easeOut});
		}
		
		private function loadSMS(method:String):void
		{
			if(method == "GET")
			{
				smsSend.method = URLRequestMethod.GET;
				smsLoader.addEventListener(Event.COMPLETE, parseSMS);
			}

			if(method == "POST")
			{
				sms_vars = new URLVariables();

				sms_vars.message = main.smsContainer2.SMSmessage.text;
				sms_vars.recipientNumber = main.smsContainer2.recipient.text;
				
				sms_vars.numberOfMessageToSendForEachRecipient = "1"
				sms_vars.numberOfRecipients = "1"
				sms_vars.numberOfMessageToSend = "1"
				sms_vars.senderNumber = smsRadioGroup.selectedData;

				smsLoader.addEventListener(Event.COMPLETE, SMSsent);
				smsSend.method = URLRequestMethod.POST;
				smsSend.data = sms_vars;

				main.sendBtn.removeEventListener(TouchEvent.TOUCH_TAP, SMS);
			
				TweenMax.to(main.sendBtn, 0.5, {delay:0.4, x:65, ease:Bounce.easeOut});
				main.sendBtn.btn_txt.text = "Sending"
			}


			smsLoader.load(smsSend);
			
			function parseSMS(event:Event = null):void
			{
				smsData = new String(smsLoader.data);
				smsData = smsData.replace(rex,"");
				
				var smsResult:Array = smsSniffer.exec(smsData);
				
				while (smsResult != null)
				{
					smsNumberID.push(smsResult[1]);
					smsNumber.push(smsResult[2]);
		
					smsResult = smsSniffer.exec(smsData);
				}
				if(method == "GET"){addDashboard("SMS", 5)};
			}

			function SMSsent(event:Event = null):void
			{
				TweenMax.to(main.sendBtn, 0.5, {delay:0.4, x:120, ease:Bounce.easeOut});
				main.sendBtn.btn_txt.text = "Sent!"
				main.sendBtn.addEventListener(TouchEvent.TOUCH_TAP, SMS);
			}
		}
		
		private function SMS(event:TouchEvent):void
		{
			loadSMS("POST");
		}
		
		private function loadCDR(event:Event = null):void
		{
			jData = jData.replace(rex,"");
			phoneNumber = userNumberSniffer.exec(jData);
			
			cdr_vars = new URLVariables();
			
			cdr_vars.selector = "missed";
			cdr_vars.accountCode = phoneNumber[1];
			cdr_vars.periodFromDate = "01.02.2013";
			cdr_vars.periodFromTime = "00:00:00";
			cdr_vars.periodUntilDate = "03.02.2013";
			cdr_vars.periodUntilTime = "23:59:59";
			cdr_vars.orderBy = "cdr.startDate desc";
			cdr_vars.size = "50";
			cdr_vars.showExcel = 
			cdr_vars.offset = "0";
			
			cdrSend.method = URLRequestMethod.POST;
			cdrSend.data = cdr_vars;
			
			cdrLoader = new URLLoader;
			
			cdrLoader.addEventListener(Event.COMPLETE, loadOutgoing);
			cdrLoader.load(cdrSend);
			
			function loadOutgoing():void
			{
				cdrData = cdrLoader.data.replace(rex,"");
				
				cdr_vars.selector = "outgoing";
				cdrSend.data = cdr_vars;
				
				cdrLoader = new URLLoader;
				
				cdrLoader.removeEventListener(Event.COMPLETE, loadOutgoing);
				cdrLoader.addEventListener(Event.COMPLETE, loadIncoming);
				cdrLoader.load(cdrSend);
				
				function loadIncoming():void
				{
					cdrData = cdrLoader.data.replace(rex,"");
				
					cdr_vars.selector = "incoming";
					cdr_vars.selectionType = "1";
					
					cdrSend.data = cdr_vars;
				
					cdrLoader = new URLLoader;
				
					cdrLoader.removeEventListener(Event.COMPLETE, loadIncoming);
					cdrLoader.addEventListener(Event.COMPLETE, returnIncoming);
					cdrLoader.load(cdrSend);
					
					function returnIncoming():void
					{
						cdrData = cdrLoader.data.replace(rex,"");
						addDashboard("CDR", 4);
					}
				}
			}
		}
		
		private function loadQueue(event:Event = null):void
		{
			queueLoader.addEventListener(Event.COMPLETE, parse);
			
			function parse(event:Event):void
			{
				queueData = queueLoader.data
				queueData = queueData.replace(rex, "")
				
				//accountsResult = [];				
				var queueResult:Array = queueSniffer.exec(queueData);
				while (queueResult != null)
				{
					queueAgent.push(queueResult[4]);
					queueName.push(queueResult[2]);
					queueStatus.push(queueResult[3]);
					queueList.push(queueResult[1])
					
					queueResult = queueSniffer.exec(queueData);
				}
				addDashboard("Queue", 2);
			}
			//clean queue data
			queueLoader.load(queueSend);
		}
		
		private function sendQueue(agentID:String):void
		{
			queueVars = new URLVariables();
			
			queueSend.method = URLRequestMethod.POST;
			queueSend.data = queueVars;
			
			queueLoader = new URLLoader;
			
			queueVars.memberId = agentID;
			
			if(queueStatus[queueAgent.indexOf(agentID)] == "Offline")
			{
				queueVars.statusId = "10";
				queueStatus[queueAgent.indexOf(agentID)] = "Online";
			}else{
				queueVars.statusId = "40";
				queueStatus[queueAgent.indexOf(agentID)] = "Offline";
			}
			queueLoader.load(queueSend);
		}
		
		private function loadAccounts(event:Event = null):void
		{
			accountsLoader.addEventListener(Event.COMPLETE, parseAccounts);
			accountsLoader.load(accountsSend);
				
			function parseAccounts(event:Event):void
			{
				accountsData = new String(accountsLoader.data);
				
				accountsData = accountsData.replace(rex,"");
				
				var accountsResult:Array = accountsSniffer.exec(accountsData);
				while (accountsResult != null)
				{
					accountID.push(accountsResult[2]);
					accountCLIP.push(accountsResult[3]);
					accountZIP.push(accountsResult[5]);
					accountStatus.push(accountsResult[6]);
					
					accountsResult = accountsSniffer.exec(accountsData);
				}
				addDashboard("Accounts", 3);
			}
		}

		private function loadMembers():void
		{

		}

		
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
		 	var grace:Number = stage.stageHeight / 480 * 8
		 	var yOverlap:Number = stage.stageHeight - main.height - grace;
		 	if(yOverlap > 7){yOverlap = 7};
		 	ThrowPropsPlugin.to(main, {ease:Strong.easeOut, throwProps:{y:{velocity:yVelocity, max:bounds.top, min:yOverlap, resistance:200}}}, 10, 0.25, 1);
		 	trace(main.scaleY*480);
		 	trace(bounds.top, bounds.top - yOverlap)
		}
	}
}