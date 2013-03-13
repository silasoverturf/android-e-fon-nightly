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
		
		//matches memberIDs
		private var memberIDSniffer:RegExp = /edit&member=([0-9]{0,})/gi;

		//matches memberNames to result[1]
		private var memberNameSniffer:RegExp = /<td>([^<]{0,})(?:<spanclass='newbutton'>[^<]{0,}<\/span>\([^\)]{0,}\)<\/td>|)<tdwidth=.[0-9]{0,3}/gi;

		//matches optionId to result[1];
		private var optionSniffer:RegExp = /optionvalue="([0-9]{4,8})/;

		//matches delay to result[1];
		private var delaySniffer:RegExp = /name="delay1"size="5"value="([0-9]{1,2})/;

		//matches destination to result[1];
		private var destinationSniffer:RegExp = /(?:phone1|phone3|backupNumber)"value="([0-9]{3,15})/g;

		//redirection checked, matches redir type to result[1], redir selection to result[2];
		private var choiceSniffer:RegExp = /<inputtype="radio"name="choice(1|3|Backuprouting|AnonSuppression)"value="([0-9]{0,4})"(?:onclick="controlRedir(?:Normal|Busy|Backup)\(\)|)("checked="checked"|")/gi;

		//matches features to result[1]
		private var featureSniffer:RegExp = /featureId(?:1|2|3|4|Backuprouting|AnonSuppression)"value="([0-9]{1,10})/gi;

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

		//members
		private var memberURLRequest:URLRequest = new URLRequest("https://" + realm + context + "/memberOverview.html");
		private var memberLoader:URLLoader = new URLLoader;
		private var memberData:String;

		//redirection
		private var redirectionURLRequest:URLRequest = new URLRequest("https://" + realm + context + "/redirection.html");
		private var redirectionLoader:URLLoader = new URLLoader;
		private var rVars:URLVariables;
		private var redirectionData:String;

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

		public var redirectionTime:Object = {};//active, choice, destination, delay
		public var redirectionBusy:Object = {};//active, choice, destination
		public var redirectionUnre:Object = {};//active, choice, destination
		public var redirectionAnon:Object = {};//active, choice, destination

		public var calenderManual:Object = {}; //active, choice, destination, private, subject, fromTime, fromDate, untilTime, untilDate
		public var calenderOOF:Object = {};    //active, choice, destination
		public var calenderBusy:Object = {};   //active, chocie, destination

		public var featureArray:Array;

		public var f2mEmail:Array;            //email address
		public var voicemail:Object = {};      //email address, greeting, pin

		public var smsMessage:Object = {};     //recipient, number, message
		public var smsNumber:Array;
		public var smsNumberID:Array;

		public var queueAgent:Array;
		public var queueName:Array;
		public var queueStatus:Array;
		public var queueList:Array;

		public var memberArray:Array;

		public var accountArray:Array;

		public function Mavin(debugL:Number)
		{
			debugLevel = debugL;

			if(debugLevel == 1)
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

				if(jData.search("memberOverview") > -1){isAdmin = true;debug("User is admin, waiting for actAs();")}

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
				loadRedirection("GET");
			}
		 
			loadAccounts("GET");
			loadSMS("GET");
		}
		
		//actAs
		public function actAs(actAsMember:String)
		{
			actAsLoader = new URLLoader();
			actAsURLRequest = new URLRequest("https://" + context + "/actAs.html?member=" + actAsMember);

			actAsLoader.addEventListener(Event.COMPLETE, loadData);
			actAsLoader.addEventListener(Event.COMPLETE, parse);

			actAsLoader.load(actAsURLRequest);

			function parse(event:Event):void
			{
				actAsLoader.removeEventListener(Event.COMPLETE, loadData);
				actAsLoader.removeEventListener(Event.COMPLETE, parse);

				debug("acting as " + actAsMember);
			}
		}

		public function loadMembers(method:String):void
		{
			memberURLRequest.method = URLRequestMethod.GET;
			memberLoader.addEventListener(Event.COMPLETE, parse);

			memberLoader.load(memberURLRequest);

			function parse(event:Event):void
			{
				memberData = memberLoader.data;
				memberData = memberData.replace(rex, "");				

				var result:Array = memberIDSniffer.exec(memberData);
				var result2:Array = memberNameSniffer.exec(memberData);

				memberArray = [];

				while(result != null)
				{
					memberArray.push({id:result[1], name:result2[1]});
					
					result = memberIDSniffer.exec(memberData);
					result2 = memberNameSniffer.exec(memberData);
				}
				dispatchEvent(new Event("loadMemberComplete"))
			}
		}

		//redirection
		public function loadRedirection(method:String):void
		{
			redirectionLoader.addEventListener(Event.COMPLETE, parse);	
			redirectionLoader.load(redirectionURLRequest);

			function parse(event:Event):void
			{	
				redirectionData = redirectionLoader.data;
				//reset all local vars
				redirectionTime = {active:0, choice:0, destination:null, delay:99};
				redirectionBusy = {active:0, choice:0, destination:null};
				redirectionUnre = {active:0, choice:0, destination:null};
				redirectionAnon = {active:0, choice:0, destination:null};

				featureArray = [];

				//reset counters
				var i:Number = 0;
				var i2:Number = 0;
				var i3:Number = 0;
				
				//remove whitespace
				redirectionData = redirectionData.replace(rex,"");
				
				var result:Array = choiceSniffer.exec(redirectionData);
				var result2:Array = destinationSniffer.exec(redirectionData);
				
				//gets all choices with choiceSniffer
				while (result != null)
				{
					trace(result)
					if(result[1] == "1" && result[3].search("checked") != -1)
					{
						redirectionTime.active = 1;
						redirectionTime.choice = result[2];
						redirectionTime.destination = result2[1];
					}

					if(result[1] == "3" && result[3].search("checked") != -1)
					{
						redirectionBusy.active = 1;
						redirectionBusy.choice = result[2];
						redirectionBusy.destination = result2[1];
					}

					if(result[1] == "Backuprouting" && result[3].search("checked") != -1)
					{
						redirectionUnre.active = 1;
						redirectionUnre.choice = result[2];
						redirectionUnre.destination = result2[1];
					}

					if(result[1] == "AnonSuppression" && result[3].search("checked") != -1)
					{
						redirectionAnon.active = 1;
						redirectionAnon.choice = result[2];
					}
					result = choiceSniffer.exec(redirectionData);
					result2 = destinationSniffer.exec(redirectionData);
				}

				//redirectionTime.delay
				result = delaySniffer.exec(redirectionData);

				redirectionTime.delay = result[1];

				//get userId
				result = optionSniffer.exec(redirectionData);

				user = result[1];

				//set feature ids
				result = featureSniffer.exec(redirectionData);

				while(result != null)
				{
					featureArray.push(result[1]);
					result = featureSniffer.exec(redirectionData);
				}

				trace(featureArray)
				
				dispatchEvent(new Event("redirectionLoadComplete"));
				
				trace(redirectionTime.active, redirectionTime.choice, redirectionTime.delay, redirectionTime.destination);
			}
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
			debug("loading Queue");

			queueLoader = new URLLoader();
			queueVars = new URLVariables();

			if(agentID == "GET")
			{
				queueLoader.addEventListener(Event.COMPLETE, parse);
				queueSend.method = URLRequestMethod.GET;

				function parse(event:Event):void
				{
					debug("parsing Queue")

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
						queueList.push(result[1]);
						
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

		private function loadCDR(event:Event = null):void
		{
			/*
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
			*/
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