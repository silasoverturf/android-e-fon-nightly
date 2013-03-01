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

		public var context:String = "web.e-fon.ch/portal"

		//
		public var invalidPW:Boolean;
		public var isAdmin:Boolean;

		public var mavinState:String;
		
		//session
		public var jSend:URLRequest = new URLRequest("https://" + context + "/j_acegi_security_check");
		public var j_Loader:URLLoader;
		public var jSession:URLVariables;
		public var jData:String;

		public function Mavin()
		{
			trace("Mavin initializing");
		}

		public function authorize(user:String, password:String):void
		{
			trace("Mavin is authorizing");

			userID_local = user;
			password_local = password;

			jSession = new URLVariables();
			j_Loader = new URLLoader();

			jSession.j_username = userID_local;
			jSession.j_password = password_local;

			jSend.method = URLRequestMethod.POST;
			jSend.data = jSession

			j_Loader.load(jSend)

			j_Loader.addEventListener(Event.COMPLETE, parse);

			function parse(event:Event):Boolean
			{
				invalidPW = false;
				isAdmin = false;

				jData = j_Loader.data;

				if(jData.search("password") > -1){invalidPW = true;}

				if(jData.search("memberOverview") > -1){isAdmin = true;}

				if(invalidPW == false && isAdmin == false)
				{
					loadData();
				}
			}
		}
		
		private function loadData():void
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
				queueActive = true;
				functionCount = functionCount + 1;
				loadQueue("GET");
			}
			
			//check if shortdials avaliable
			if(jData.search("shortDials") > -1){shortDialsActive = true;}

			//check if numbers are owned
			if(jData.search("optionvalue") > -1)
			{
				//loadCDR();
				loadF2M("GET");
				loadRedirection("GET");

				//update functino count
				functionCount = functionCount + 2;
			}
			
			loadAccounts("GET");
			loadSMS("GET");

			mavinState = "home";
		}

		public function loadAccounts(method:String):void
		{
			if(method == "GET")
			{
				accountsLoader.addEventListener(Event.COMPLETE, parse);
				accountsLoader.load(accountsSend);
					
				function parse(event:Event):Array
				{
					var accountsData:String = new String(accountsLoader.data);
					
					accountsData = accountsData.replace(rex,"");
					
					var accountID:Array = [];
					var accountCLIP:Array = [];
					var accountZIP:Array = [];
					var accountStatus:Array = [];

					var accountsResult:Array = accountsSniffer.exec(accountsData);
					while (accountsResult != null)
					{
						accountID.push(accountsResult[2]);
						accountCLIP.push(accountsResult[3]);
						accountZIP.push(accountsResult[5]);
						accountStatus.push(accountsResult[6]);
						
						accountsResult = accountsSniffer.exec(accountsData);
					}

					return accountID, accountCLIP, accountZIP, accountStatus
				}
			}

			if(method == "POST")
			{
				trace("Posting to /accountConfig.html is currently not supported")
			}
		}


		//just for testing;
		public function doMath(value1:Number, value2:Number)
		{
			var dump:Number = value1 + value2;

			trace(dump)
			return dump;
		}
	}
}