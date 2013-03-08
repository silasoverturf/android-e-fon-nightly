package
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;

	public class Mavin extends MovieClip
	{
		//local
		public var userID_local:String;
		public var password_local:String;

		public var realm:String = "web.e-fon.ch";
		public var context:String = "/portal"

		public var debugLevel:Number = 1;

 		public var hasPhoneNumber:Boolean = false;
		public var hasQueue:Boolean = false;
		public var hasShortDial:Boolean = false;

		private var rex:RegExp = /[\s\r\n]*/gim;
		//
		public var invalidPW:Boolean;
		public var isAdmin:Boolean;

		public var mavinState:String;
		
		//check what web
		public var checkSend:URLRequest = new URLRequest("https://" + realm);
		public var checkLoader:URLLoader = new URLLoader;
		public var checkRex:RegExp = /;.>([^<]{0,})/;

		//RegExp
		
		//matches F2M email to result[1]
		private var f2mSniffer:RegExp = /name=.fax2emailEmail"value="([0-9a-zA-Z][-._a-zA-Z0-9]*@(?:[0-9a-zA-Z][-._0-9a-zA-Z]*\.)+[a-zA-Z]{2,4})/;

		//matches voicemail values to result[1]
		private var voicemailEmailSniffer:RegExp = /voicemailEmail"value=.([^"]{0,})/;
		private var voicemailGreetingSniffer:RegExp = /voicemailAnrede"style="width:400px"value=.([^"]{0,})/;
		private var voicemailPINSnifffer:RegExp = /voicemailPin"style="width:100px"value="([0-9]{0,})/;
		
		private var smsSniffer:RegExp = /optionvalue="([0-9a-z]{0,15})">([0-9a-zA-Z]{1,10})/gi;

		private var queueSniffer:RegExp =  />([^<]{0,})<\/td><td>[^<]{0,},([^<]{0,})<\/td><td>[^<]{0,}<\/td><td>[^<]{0,}<br\/><\/td><td><spanstyle="color:[0-9a-zA-Z,]{0,};">([a-zA-Z]{0,})<\/span><\/td><td><ahref="javascript:[a-zA-Z]{0,}\(([0-9]{0,})\)"/g; 

		private var accountsSniffer:RegExp = /tdwidth="100px">([0-9a-zA-Z\-]{1,30})<\/td><td>([0-9a-zA-Z\-]{1,30})<\/td><td><[0-9a-zA-Z\-=":\/\/\+]{1,30}>([0-9]{1,20})<\/td><td>(<imgsrc="images\/check.gif"?>|-)<\/td><td>([0-9]{0,6})<\/td><td><imgsrc="images\/ampel_(?:rot|gruen).gif"title="([^"]{0,})"\/><\/td><td>/g;

		//session
		private var jSend:URLRequest = new URLRequest("https://" + realm + context +"/j_acegi_security_check");
		public var jLoader:URLLoader;
		private var jSession:URLVariables;
		private var jData:String;

		//act as
		private var actAsURLRequest:URLRequest;
		private var actAsLoader:URLLoader;

		//f2m
		private var f2mURLRequest:URLRequest = new URLRequest("https://" + realm + context + "/notifications.html");
		private var f2mLoader:URLLoader = new URLLoader;
		private var f2mVars:URLVariables;
		private var f2mData:String;

		//queue
		private var queueSend:URLRequest = new URLRequest("https://" + realm + context + "/callCenterQueueMemberStatus.html");
		private var queueLoader:URLLoader;
		private var queueVars:URLVariables;
		private var queueData:String;

		//sms
		private var smsSend:URLRequest = new URLRequest("https://" + realm + context + "/SMSSender.html");
		private var smsLoader:URLLoader = new URLLoader;
		private var smsVars:URLVariables;
		private var smsData:String;

		//accounts
		private var accountsSend:URLRequest = new URLRequest("https://" + realm + context + "/accounts.html");
		private var accountsLoader:URLLoader = new URLLoader;
		private var accountsData:String;

		public var user:String;                //memberID

		public var redirectionTime:Object = {};//active, choice, desination, delay
		public var redirectionBusy:Object = {};//active, choice, desination
		public var redirectionUnre:Object = {};//active, choice, desination
		public var redirectionAnon:Object = {};//active, choice, desination

		public var calenderManual:Object = {}; //active, choice, desination, private, subject, fromTime, fromDate, untilTime, untilDate
		public var calenderOOF:Object = {};    //active, choice, desination
		public var calenderBusy:Object = {};   //active, chocie, desination

		public var f2mEmail:Array;            //email address
		public var voicemail:Object = {};      //email address, greeting, pin

		public var smsMessage:Object = {};     //recipient, number, message
		public var smsNumber:Array;
		public var smsNumberID:Array;

		public var queueAgent:Array;
		public var queueName:Array;
		public var queueStatus:Array;
		public var queueList:Array;

		public var accountArray:Array;

		public function Mavin()
		{
			checkLoader.load(checkSend);
			checkLoader.addEventListener(Event.COMPLETE, parse);

			var result:Array;

			function parse(event:Event):void
			{
				result = checkRex.exec(checkLoader.data)
				debug(result[1]  + ", Mavin is ready");
			}
		}

		public function authorize(user:String, password:String):void
		{
			debug("Mavin is authorizing");

			userID_local = user;
			password_local = password;

			jSession = new URLVariables();
			jLoader = new URLLoader();

			jSession.j_username = userID_local;
			jSession.j_password = password_local;

			jSend.method = URLRequestMethod.POST;
			jSend.data = jSession

			jLoader.load(jSend)

			jLoader.addEventListener(Event.COMPLETE, parse);

			function parse(event:Event):void
			{
				invalidPW = false;
				isAdmin = false;

				jData = jLoader.data;

				if(jData.search("password") > -1){invalidPW = true;debug("Password is invalid")}

				if(jData.search("memberOverview") > -1){isAdmin = true;debug("User is admin")}

				if(invalidPW == false && isAdmin == false)
				{
					debug("Password is correct, user is not admin");
					loadData();
				}
				dispatchEvent(new Event("authComplete"));
			}
		}

		//loadData
		public function loadData():void
		{
			//if admin, use actasloader for functionality checking
			if(isAdmin == true)
			{
				jData = actAsLoader.data;
			}

			//if !admin, use Jdata for functionality checking
			if(isAdmin == false)
			{
				jData = jLoader.data;
			}

			//whitespace
			jData = jData.replace(rex, "");
			
			//check if queue avaliable
			if(jData.search("Queue") > -1)
			{
				hasQueue = true;
				loadQueue("GET");
			}
			
			//check if shortdials avaliable
			if(jData.search("shortDials") > -1)
			{
				hasShortDial = true;
			}

			//check if numbers are owned
			if(jData.search("optionvalue") > -1)
			{
				hasPhoneNumber = true;
				loadF2M("GET");
				loadRedirection("POST");
			}
		 
			loadAccounts("GET");
			loadSMS("GET");

			debug("loading user modules")
		}
		
		//actAs
		public function actAs(actAsMember:String)
		{
			actAsLoader = new URLLoader();
			actAsURLRequest = new URLRequest("https://" + context + "/actAs.html?member=" + actAsMember);

			actAsLoader.addEventListener(Event.COMPLETE, loadData)
			actAsLoader.load(actAsURLRequest);
		}

		//redirection
		public function loadRedirection(method:String):void
		{
			debug("loadRedirection");
		}

		//f2m
		public function loadF2M(method:String):void
		{
			debug("loading F2M")
			if(method == "GET")
			{
				f2mURLRequest.method = URLRequestMethod.GET;	
			}
			
			if(method == "POST")
			{
				f2mVars = new URLVariables();

				f2mVars.reload = "";
				f2mVars.selectedPhoneNumberId = user;
				f2mVars.fax2emailEmail = f2mEmail[1];

				f2mURLRequest.method =  URLRequestMethod.POST;
				f2mURLRequest.data = f2mVars;
			}
			
			function parse(event:Event):void
			{
				f2mLoader.removeEventListener(Event.COMPLETE, parse)
				//parse F2M
				f2mData = new String(f2mLoader.data);
				f2mData = f2mData.replace(rex,"");
				f2mEmail = f2mSniffer.exec(f2mData);

				//parse Voicemail
				var result:Array;
				voicemail = [];

				result = voicemailEmailSniffer.exec(f2mData);
				voicemail.email = result[1]
				
				result = voicemailGreetingSniffer.exec(f2mData);
				voicemail.greeting = result[1];

				result = voicemailPINSnifffer.exec(f2mData);
				voicemail.PIN = result[1];

				dispatchEvent(new Event("f2mLoadComplete"));
			}

			f2mLoader.addEventListener(Event.COMPLETE, parse);
			f2mLoader.load(f2mURLRequest);
		}

		//loadQueue
		public function loadQueue(agentID:String):void
		{
			queueLoader = new URLLoader();
			queueVars = new URLVariables();

			if(agentID == "GET")
			{
				queueLoader.addEventListener(Event.COMPLETE, parse);
				queueSend.method = URLRequestMethod.GET;

				function parse(event:Event):void
				{
					queueData = queueLoader.data;
					queueData = queueData.replace(rex, "")
					
					//reset locals vars
					queueAgent = [];
					queueName = [];
					queueStatus = [];
					queueList = [];

					var result:Array = queueSniffer.exec(queueData);

					while (result != null)
					{
						queueAgent.push(result[4]);
						queueName.push(result[2]);
						queueStatus.push(result[3]);
						queueList.push(result[1])
						
						result = queueSniffer.exec(queueData);
					}
					dispatchEvent(new Event("queueLoadComplete"));
				}
			}

			if(agentID != "GET" && agentID != "POST")
			{
				queueVars = new URLVariables();
				
				queueSend.method = URLRequestMethod.POST;
				queueSend.data = queueVars;
								
				queueVars.memberId = agentID;
				
				if(queueStatus[queueAgent.indexOf(agentID)] == "Offline")
				{
					queueVars.statusId = "10";
					queueStatus[queueAgent.indexOf(agentID)] = "Online";
				}else{
					queueVars.statusId = "40";
					queueStatus[queueAgent.indexOf(agentID)] = "Offline";
				}
				dispatchEvent(new Event("queueLoadComplete"));
			}

			if(agentID == "POST")
			{
				debug("Function variable must be AgentID if POST is to be method")
			}

			//load
			queueLoader.load(queueSend);
		}

		//
		public function loadSMS(method:String):void
		{
			trace("loadingSMS");

			if(method == "GET")
			{
				smsSend.method = URLRequestMethod.GET;
			}

			if(method == "POST")
			{
				smsVars = new URLVariables();

				smsVars.message = smsMessage.message;
				smsVars.recipientNumber = smsMessage.recipient;
				
				smsVars.numberOfMessageToSendForEachRecipient = "1"
				smsVars.numberOfRecipients = "1"
				smsVars.numberOfMessageToSend = "1"
				smsVars.senderNumber = smsMessage.number;

				smsSend.method = URLRequestMethod.POST;
				smsSend.data = smsVars;
			}

			function parse(event:Event = null):void
			{
				smsData = new String(smsLoader.data);
				smsData = smsData.replace(rex,"");
				
				var smsResult:Array = smsSniffer.exec(smsData);
				
				smsNumberID = [];
				smsNumber = [];

				while (smsResult != null)
				{
					smsNumberID.push(smsResult[1]);
					smsNumber.push(smsResult[2]);
			
					smsResult = smsSniffer.exec(smsData);
				}
				dispatchEvent(new Event("smsLoadComplete"));
			}
			smsLoader.addEventListener(Event.COMPLETE, parse);
			smsLoader.load(smsSend);
		}

		public function loadAccounts(method:String):void
		{
			if(method == "GET")
			{
				accountsLoader.addEventListener(Event.COMPLETE, parse);
				accountsLoader.load(accountsSend);
					
				function parse(event:Event):void
				{
					accountsData = accountsLoader.data;
					
					accountsData = accountsData.replace(rex,"");
					
					accountArray = [];

					var result:Array = accountsSniffer.exec(accountsData);
					while (result != null)
					{
						accountArray.push({uid:result[2], clip:result[3], name:result[4], zip:result[5], status:result[6]})
						result = accountsSniffer.exec(accountsData);
					}

					dispatchEvent(new Event("accountLoadComplete"));
				}
			}

			if(method == "POST")
			{
				debug("Posting to /accountConfig.html is currently not supported");
			}
		}

		//just for testing;
		public function doMath(value1:Number, value2:Number)
		{
			var dump:Number = value1 + value2;

			trace(dump)
			return dump;
		}

		private function debug(debugMessage:String):void
		{
			if(debugLevel == 1){trace(debugMessage);}
		}
	}
}