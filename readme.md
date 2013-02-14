##Android/iOS App for e-fon portal access

This app enables streamlined e-fon portal from mobile devices. Currently  diversion, queues, SMS and Accounts are available.

The portal connection is currently achieved with HTTP encrypted TLS. The conventional HTML is loaded and parsed manually using regular expressions. Variables are POSTed using the AS3 "URLRequestMethod".

The build1.fla and build.as are the main Flash documents and program class. The build.apk is the final Android ready build. It can be download and manually installed on your Android device, as long as the "Installation of apps from unknown sources" is checked. This setting can usually be found in the settings > security > device administration. The build1.swf is used for desktop based testing. The build1-app.xml file is used from defining app permissions.

##How to install on android

1. Enable the setting "Installation of apps from unknown sources". Usually found in the settings > security > device administration

2. Download the build.apk file.

3. Choose the file from your download manager and follow the onscreen instructions.

##How to install on iOS

Will be updated once iOS nightly build is ready.

##Server communication functions
Currently almost all functions that contain server communications are being rewritten (Issue#7). Calling the function will look like this ```load[page](method);```. Depending on method and current app status a ```flush[page]();``` will also be called. All local -> server variable setting will also be handled within the main function.

```ActionScript
private function load[page](method:String):void
  	{
			if(method == "GET")
			{
				[page]URLRequest.method = URLRequestMethod.GET;	
			}

			if(method == "POST")
			{
				[page]_vars = new URLVariables();

				[page]_vars.variable = "";

				[page]URLRequest.method =  URLRequestMethod.POST;
				[page]URLRequest.data = [page]_vars;
			}

			[page]Loader.addEventListener(Event.COMPLETE, parse[page]);
			[page]Loader.load([page]URLRequest);

			function parse[page](event:Event = null):void
			{
			  //RegExp parsing

				if(main.currentFrame == [page].frame)
				{
					flush[page]();
				}
			}
		}
```

##Program Concept

The app is compiled with Flash Pro, currently with Air 3.5. UI Structure is defined in the .fla file and all other functions like UI flushing, variable posting and .html parsing are handled by the .as class file. When compiled to Android with Air the Actionscript is interpreted by Adobe's AVM. On iOS all functions are handled by the LLVM compiled by Flash Pro.

