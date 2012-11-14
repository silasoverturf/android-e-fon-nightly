##Android/iOS App for e-fon portal access

This app enables streamlined e-fon portal from mobile devies. Currently only diversion can be configured, but SMS Sending and CDR access is being implemented soon. 

The portal connection is currently acieved with HTTP and TLS. The conventional HTML is loaded and parsed manually using regular expressions. All variables are POSTed using the AS3 "URLRequestMethod" and transported with HTTP and TLS.
