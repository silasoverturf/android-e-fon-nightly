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

		//
		public var invalidPW:Boolean;
		public var isAdmin:Boolean;

		public var mavinState:String;
		
		//check what web
		public var checkSend:URLRequest = new URLRequest("https://" + realm);
		public var checkLoader:URLLoader = new URLLoader;
		public var checkRex:RegExp = /;.>([^<]{0,})/;

		//session
		private var jSend:URLRequest = new URLRequest("https://" + realm + context +"/j_acegi_security_check");
		private var jLoader:URLLoader;
		private var jSession:URLVariables;
		private var jData:String;

		//queue
		private var queueSend:URLRequest = new URLRequest("https://" + realm + context + "/callCenterQueueMemberStatus.html");
		private var queueLoader:URLLoader;
		private var queueVars:URLVariables;
		private var queueData:String;

		public var user:Number;                //memberID

		public var redirectionTime:Object = {};//active, choice, desination, delay
		public var redirectionBusy:Object = {};//active, choice, desination
		public var redirectionUnre:Object = {};//active, choice, desination
		public var redirectionAnon:Object = {};//active, choice, desination

		public var calenderManual:Object = {}; //active, choice, desination, private, subject, fromTime, fromDate, untilTime, untilDate
		public var calenderOOF:Object = {};    //active, choice, desination
		public var calenderBusy:Object = {};   //active, chocie, desination

		public var f2mEmail:String;            //email address

		public var queueAgent:Array;
		public var queueName:Array;
		public var queueStatus:Array;
		public var queueList:Array;

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
				jData = mavin.jLoader.data;
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
		
		//loadQueue
		private function loadQueue(agentID:String):void
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

					while (queueResult != null)
					{
						queueAgent.push(result[4]);
						queueName.push(result[2]);
						queueStatus.push(result[3]);
						queueList.push(result[1])
						
						result = queueSniffer.exec(queueData);
					}
					dispatchEvent(new Event("queueGetComplete"));
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
				dispatchEvent(new Event("queuePostComplete"));
			}

			if(agentID == "POST")
			{
				debug("Function variable must be AgentID if POST is to be method")
			}

			//load
			queueLoader.load(queueSend);
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