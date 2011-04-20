Sinatra + Warden = Modular Secure Apps
======================================

An Application skeleton that uses Warden with Sinatra to Authenticate modular sub-applications.

Provides
--------

* Any hits to the App '/' are handled in the Public way. You get Authenticated and if you're OK, Warden strategy limits you to the '/' zone.
* Any hits to the App '/admin' are handled in the Admin way. You get Authenticated as an admin and can work magic in that way. 
* Any hits to the App '/special' are protected in their own way, so it is nice to put special code here do to work... under the hood as they say.

