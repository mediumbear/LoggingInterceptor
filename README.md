LoggingInterceptor
==================

Adding features to an existing iOS project? Can't figure out what screen belongs to what code? Let the App tell you!

Simply drag the LoggingInterceptor.m to your project, and whatever methods you are intererested in will emit a log message whever they execute.

LoggingInterceptor.m uses the Objective-C runtime to inject interceptor code into your App.  
Please read the class comment in the source code, or risk your app being rejected by the App Store.  
__LoggingInterceptor.m must not be included in release builds.__

The included project contains a sample to quickly see how things work.
