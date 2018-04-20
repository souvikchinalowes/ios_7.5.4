/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

//
//  AppDelegate.m
//  ClickMobileCDV
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

#import "ClickMobilePlugin.h"
#import <Cordova/CDVPlugin.h>
#import <CoreLocation/CoreLocation.h>
#import "utilitiesCustomUrlScheme.h"
#import "CookiesUtility.h" //CookiePersistency Support
#import "GetPhoneNumber.h"

@implementation AppDelegate

@synthesize window, viewController, webData, _CookiesUtility; //CookiePersistency Support

#pragma mark clean chace utils
- (NSArray *)recursivePathsForResourcesOfType:(NSString *)type inDirectory:(NSString *)directoryPath{
    
    NSMutableArray *filePaths = [[NSMutableArray alloc] init];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:directoryPath];
    
    NSString *filePath;
    
    while ((filePath = [enumerator nextObject]) != nil){
        [filePaths addObject:[directoryPath stringByAppendingPathComponent:filePath]];
    }
    
    return filePaths;
}

- (void)clearUserData:(NSUserDefaults *)userDefaults strLibraryFolder:(NSString *)strLibraryFolder
{
    if (strLibraryFolder != nil) {
        
        //NSString* strDatabasesFolder=[strLibraryFolder stringByAppendingPathComponent:@"WebKit/Databases/"];
        NSString* strLocalStorageFolder=[strLibraryFolder stringByAppendingPathComponent:@"WebKit/LocalStorage/"];
        
        NSFileManager* fileMgr = [[ NSFileManager alloc] init];
        
        @try
        {
            NSError* pError = nil;
            
            BOOL bSuccess = [fileMgr removeItemAtPath:strLocalStorageFolder error:&pError] ;
            if (bSuccess)
            {
                [userDefaults setObject:NO forKey:@"clearUserData_preference"];
            }
            else
            {
                if ([pError code] == NSFileNoSuchFileError)
                {
                    [userDefaults setObject:NO forKey:@"clearUserData_preference"];
                }
                else if ([pError code] == NSFileWriteNoPermissionError)
                {
                    //errorCode = NO_MODIFICATION_ALLOWED_ERR;
                }
            }
        }
        @catch (NSException* e)
        { // NSInvalidArgumentException if path is . or ..
        }
        @finally
        {
            
        }
    }
}

- (void)cleanCacheFromDevice:(NSString *)strLibraryFolder userDefaults:(NSUserDefaults *)userDefaults
{
    if (strLibraryFolder != nil) {
        
        NSString* strCacheFolder;
        
        
        strCacheFolder=[strLibraryFolder stringByAppendingPathComponent:@"Caches/"];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        {
            
            NSError *err;
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            NSString *documentsDirectory = [NSHomeDirectory()
                                            stringByAppendingPathComponent:@"Library"];
            
            @try
            {
                NSArray *givenFiles = [self recursivePathsForResourcesOfType:@"empty.string" inDirectory:documentsDirectory];
                for (NSString *file in givenFiles) {
                    [fileMgr removeItemAtPath:file error:&err];
                }
                
                
            }
            @catch (NSException* e)
            { // NSInvalidArgumentException if path is . or ..
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"" message:e.description delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
                [alert show];
                
            }
            @finally
            {
                [userDefaults setObject:NO forKey:@"clearCache_preference"];
                
            }
        }
        else
        {
            strCacheFolder=[strLibraryFolder stringByAppendingPathComponent:@"Caches/"];
        }
        
        
    }
}

- (void)cleanCacheBasedOnFolderLocation:(NSUserDefaults *)userDefaults strLibraryFolder:(NSString *)strLibraryFolder
{
    // TAL
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    if (strLibraryFolder != nil) {
        
        NSString* strCacheFolder;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        {
            strCacheFolder=[strLibraryFolder stringByAppendingPathComponent:@"Caches/com.clicksoftware.ClickMobileCDV/"];
        }
        else
        {
            strCacheFolder=[strLibraryFolder stringByAppendingPathComponent:@"Caches/"];
        }
        
        NSFileManager* fileMgr = [[ NSFileManager alloc] init];
        
        @try
        {
            NSError* pError = nil;
            
            BOOL bSuccess = [ fileMgr removeItemAtPath:strCacheFolder error:&pError];
            
            NSFileManager* fileMgr = [[ NSFileManager alloc] init];
            
            NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString* strFilesFolder = [paths objectAtIndex:0];
            NSLog(@"Folder Path: %@",[paths objectAtIndex:0]);
            
            NSDirectoryEnumerator* en = [fileMgr enumeratorAtPath:[paths objectAtIndex:0]];
            
            
            NSString* file;
            
            while (file = [en nextObject]) {
                NSLog(@"Remove: %@",[strFilesFolder stringByAppendingPathComponent:file]);
                bSuccess = [fileMgr removeItemAtPath:[strFilesFolder stringByAppendingPathComponent:file] error:&pError];
                
                if (!bSuccess)
                {
                    if ([pError code] == NSFileNoSuchFileError)
                    {
                        [userDefaults setObject:NO forKey:@"clearFiles_preference"];
                    }
                    else if ([pError code] == NSFileWriteNoPermissionError)
                    {
                        NSLog(@"Error: %@", pError);
                    }
                }
            }
            
            
            if (bSuccess)
            {
                [userDefaults setObject:NO forKey:@"clearCache_preference"];
            }
            else
            {
                if ([pError code] == NSFileNoSuchFileError)
                {
                    [userDefaults setObject:NO forKey:@"clearCache_preference"];
                }
                else if ([pError code] == NSFileWriteNoPermissionError)
                {
                    //errorCode = NO_MODIFICATION_ALLOWED_ERR;
                }
            }
        }
        @catch (NSException* e)
        { // NSInvalidArgumentException if path is . or ..
        }
        @finally
        {
 
        }
    }
}

- (id)init
{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    /** If you need to do any extra app-specific initialization, you can do it here
     *  -jm
     **/
    NSHTTPCookieStorage* cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
    int cacheSizeMemory = 8 * 1024 * 1024; // 8MB
    int cacheSizeDisk = 32 * 1024 * 1024; // 32MB
#if __has_feature(objc_arc)
    NSURLCache* sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
#else
    NSURLCache* sharedCache = [[[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"] autorelease];
#endif
    [NSURLCache setSharedURLCache:sharedCache];
    
    _CookiesUtility= [[CookiesUtility alloc] init];//CookiePersistency Support
    [_CookiesUtility loadWebViewHTTPCookies];//CookiePersistency Support
    
    self = [super init];
    
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString* strLibraryFolder = ([libraryPaths count] > 0) ? [libraryPaths objectAtIndex:0] : nil;
    
    //Delete user data according the settings
    
    bool bclearAppliactionCache_preference = [userDefaults boolForKey:@"clearAppliactionCache_preference"];
    if (bclearAppliactionCache_preference == true) {
        [self clearUserData:userDefaults strLibraryFolder:strLibraryFolder];
        [self cleanCacheFromDevice:strLibraryFolder userDefaults:userDefaults];
        [self cleanCacheBasedOnFolderLocation:userDefaults strLibraryFolder:strLibraryFolder];
        [_CookiesUtility deleteAllWebViewCookies];
        [userDefaults setObject:NO forKey:@"clearAppliactionCache_preference"];
    }
    
    
    
    bool bClearFiles = [userDefaults boolForKey:@"clearFiles_preference"];
    if (bClearFiles == true)
    {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSFileManager* fileMgr = [[ NSFileManager alloc] init];
        //        NSArray *subpaths = [fileMgr subpathsAtPath:[paths objectAtIndex:0]];
        @try
        {
            NSString* strFilesFolder = [paths objectAtIndex:0];
            NSLog(@"Folder Path: %@",[paths objectAtIndex:0]);
            
            NSDirectoryEnumerator* en = [fileMgr enumeratorAtPath:[paths objectAtIndex:0]];
            NSError* pError = nil;
            BOOL bSuccess = YES;
            
            NSString* file;
            
            while (file = [en nextObject]) {
                NSLog(@"Remove: %@",[strFilesFolder stringByAppendingPathComponent:file]);
                bSuccess = [fileMgr removeItemAtPath:[strFilesFolder stringByAppendingPathComponent:file] error:&pError];
                
                if (!bSuccess)
                {
                    if ([pError code] == NSFileNoSuchFileError)
                    {
                        [userDefaults setObject:NO forKey:@"clearFiles_preference"];
                    }
                    else if ([pError code] == NSFileWriteNoPermissionError)
                    {
                        NSLog(@"Error: %@", pError);
                    }
                }
            }
            if (bSuccess)
            {
                [userDefaults setObject:NO forKey:@"clearFiles_preference"];
            }
        }
        @catch (NSException* e)
        { // NSInvalidArgumentException if path is . or ..
            [userDefaults setObject:NO forKey:@"clearFiles_preference"];
        }
        @finally
        {
            
        }
    }
    
    return self;
}


- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    //GetPhoneNumber from Air watch DB
    GetPhoneNumber *phoneNumberObj = [[GetPhoneNumber alloc] init];
    [phoneNumberObj getPhoneNumber];
    
#ifdef __IPHONE_8_0
    
    if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    
#else
    //register to receive notifications
    UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
#endif
    
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
#if __has_feature(objc_arc)
    self.window = [[UIWindow alloc] initWithFrame:screenBounds];
#else
    self.window = [[[UIWindow alloc] initWithFrame:screenBounds] autorelease];
#endif
    self.window.autoresizesSubviews = YES;
    
#if __has_feature(objc_arc)
    self.viewController = [[MainViewController alloc] init];
#else
    self.viewController = [[[MainViewController alloc] init] autorelease];
#endif
    
    //  Don't remove this lines - other wise the client will not support file upload/running from phonegap
    //  Add user agent to navigator string [when taken from browser]
    
    NSString* suffixUA = @" phonegap";
    
    // Rotem - feature #26666
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    suffixUA = [NSString stringWithFormat:@"%@%@%@", @" PGVersion:", build, suffixUA];
    
    // Rotem - feature #55286
    NSString* appID = @"";
    if ([appID length] != 0) {
        suffixUA = [NSString stringWithFormat:@"%@%@%@", @" AppID:", appID, suffixUA];
    }
    
    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    
    NSString* finalUA = [[webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"] stringByAppendingString:suffixUA] ;
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:finalUA, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    //  end-Don't remove this lines - other wise the client will not support file upload/running from phonegap
    
    
    // Set your app's start page by setting the <content src='foo.html' /> tag in config.xml.
    // If necessary, uncomment the line below to override it.
    // self.viewController.startPage = @"index.html";
    
    // NOTE: To customize the view's frame size (which defaults to full screen), override
    // [self.viewController viewWillAppear:] in your view controller.
    
    //NSString * url = [[NSUserDefaults standardUserDefaults] stringForKey:@"url_preference"];
    NSString *configPath = [[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:configPath];
    NSString *url = [dict objectForKey:@"DeliveryURL"];
    if (url != nil) {
        [[NSUserDefaults standardUserDefaults] setObject: url forKey:@"url_preference"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    NSLog(@"url before is %@", url);
    
    // Note: this will not work for boolean values as noted by bpapa below.
    
    // If you use booleans, you should use objectForKey above and check for null
    
    if(!url) {
        
        [self registerDefaultsFromSettingsBundle];
        
        url = [[NSUserDefaults standardUserDefaults] stringForKey:@"url_preference"];
        
    }
    
    NSLog(@"url after is %@", url);
    
    // Rotem: Bug #59690
    if ([url length]<2) {
        url = @"http://<SERVER ADDRESS>/ClickMobileWEB/default.aspx";
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *phoneNum = [defaults stringForKey:@"settingsPhoneNumber"];
    NSURL *modifyReqURL = [[NSURL alloc] init];
    // If the number doesn't exist in settings, try to retrieve it from the device
    
    modifyReqURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?LWSdeliverymobilephnum=%@", url, phoneNum]];
    
    // Log the request URL after it's been modified
    NSLog(@"URL after uid added: %@", modifyReqURL.absoluteString);

    // Create a new NSURLRequest
    NSURLRequest *newURLRequest = [[NSURLRequest alloc] initWithURL:modifyReqURL];
    //request = newURLRequest;
    
    NSURLRequest * request = newURLRequest;
//    NSURL * urlRedirect = [NSURL URLWithString:url];
//    NSURLRequest * request = [NSURLRequest requestWithURL:urlRedirect];
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    [self.viewController.webViewEngine loadRequest:request];
    
    return YES;
}

- (void)registerDefaultsFromSettingsBundle {
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key && [[prefSpecification allKeys] containsObject:@"DefaultValue"]) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
#endif


// repost all remote and local notification using the default NSNotificationCenter so multiple plugins may respond
- (void)            application:(UIApplication*)application
    didReceiveLocalNotification:(UILocalNotification*)notification
{
    // Tal - local push notification start
    UIApplicationState state = [application applicationState];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if(state == UIApplicationStateActive)
    {
        NSString *allowAlert = [notification.userInfo objectForKey:@"allowAlert"];
        
        if([allowAlert isEqualToString:@"yes"]) // allow alert while app is open
        {
            
            /*
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Remi" message:notification.alertBody delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alert show];
             
             */
        }
        
        NSString *udKey = [notification.userInfo objectForKey:@"udKey"];
        
        // Remove local P.N from DB
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:udKey];
        
        // Update the free IDs list (add to list)
        NSString *lpnID = [[notification.userInfo objectForKey:@"udKey"] componentsSeparatedByString:@"#"][2];
        
        NSMutableString *listOfFreeIDs = [userDefaults objectForKey:@"LPN_FREE"];
        [listOfFreeIDs appendString:[NSString stringWithFormat:@"%@&",lpnID]];
        
        [userDefaults setObject:listOfFreeIDs forKey:@"LPN_FREE"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
    application.applicationIconBadgeNumber=0;
    
    // re-post ( broadcast )
    [[NSNotificationCenter defaultCenter] postNotificationName:CDVLocalNotification object:notification];
}

- (void)                                application:(UIApplication *)application
   didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"Device Token: %@", deviceToken);
    NSString* token;
    //    token = [[NSString alloc] initWithString: [[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""] stringByReplacingOccurrencesOfString: @">" withString: @""] stringByReplacingOccurrencesOfString: @" " withString: @""] ];
    //
    //  idan ofek - memory issue relax
    token = [NSString stringWithFormat:@"%@",[[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<" withString:@""]
                                               stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""]];
    
    
    //    token=[NSString stringWithFormat:[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""] stringByReplacingOccurrencesOfString: @">" withString: @""] stringByReplacingOccurrencesOfString: @" " withString: @""] ;
    //
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:token forKey:@"token"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CDVRemoteNotification object:token];
    
}

- (void)                                 application:(UIApplication *)application
    didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    /*
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"token? Failed to get token " message:@"More info..." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Say Hello",nil];
     [alert show];
     */
    NSLog(@"Failed to get token, error: %@", error);
    
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:@"" forKey:@"token"];
    
    
    
    // re-post ( broadcast )
    [[NSNotificationCenter defaultCenter] postNotificationName:CDVRemoteNotificationError object:error];
}

- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    // iPhone doesn't support upside down by default, while the iPad does.  Override to allow all orientations always, and let the root view controller decide what's allowed (the supported orientations mask gets intersected).
    NSUInteger supportedInterfaceOrientations = (1 << UIInterfaceOrientationPortrait) | (1 << UIInterfaceOrientationLandscapeLeft) | (1 << UIInterfaceOrientationLandscapeRight) | (1 << UIInterfaceOrientationPortraitUpsideDown);
    
    return supportedInterfaceOrientations;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
}



- (void) applicationDidEnterBackground:(UIApplication *)application
{
    
    utilitiesCustomUrlScheme *customUriUtility = [[utilitiesCustomUrlScheme alloc] init];
    NSString * strLastOpenAppFromUri = [ [customUriUtility nameSpaceToSaveToDisk] stringByAppendingString:[customUriUtility nameSpaceOpenAppFromUri]];
    
    [customUriUtility addParamFromUriQuery:strLastOpenAppFromUri valueParam:@"false"];
    [_CookiesUtility saveWebViewHTTPCookies]; //CookiePersistency Support
    
}

-(void)onTick:(NSTimer *)timer {
    //do smth
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter =  kCLLocationAccuracyBest;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.pausesLocationUpdatesAutomatically = NO;
    // Do any additional setup after loading the view from its nib.
    [locationManager requestAlwaysAuthorization];
    CLLocation *curPos = locationManager.location;
    
    NSString *latitude = [[NSNumber numberWithDouble:curPos.coordinate.latitude] stringValue];
    
    NSString *longitude = [[NSNumber numberWithDouble:curPos.coordinate.longitude] stringValue];
    
    NSLog(@"Lat: %@", latitude);
    NSLog(@"Long: %@", longitude);
}


- (void) applicationDidBecomeActive:(UIApplication *)application
{

    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [webData appendData:data];
    NSLog(@"theConnection didReceiveData");
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [webData setLength: 0];
    NSLog(@"theConnection didReceiveResponse");
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"ERROR with theConenction");
    @try {
        
        // #003 - Verify if webData already released before release it (release of pointer that already released will cause bad memory access)
        if(webData!=nil)
        {
            webData=nil;
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"Catch Error with theConnection: name: %@, reason: %@, description: %@", [exception name], [exception reason],   [exception description]);
    }
    @finally {
        
    }
    //    [connection release];
    //    [webData release];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"DONE");
    NSLog(@"DONE. Received Bytes: %d", [webData length]);
    NSString *theXML = [[NSString alloc] initWithBytes: [webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
    NSLog(@"%@",theXML);
    UIApplication *app = [UIApplication sharedApplication];
    if (backgroundTask != UIBackgroundTaskInvalid) {
        [app endBackgroundTask:backgroundTask];
        backgroundTask = UIBackgroundTaskInvalid;
    }
}

-(BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    //    if clickMobile is part of the scheme
    if ([[url scheme] isEqualToString:@"clickmobilescheme"]) {
        
        //save the paramters [if there are some of tham]
        utilitiesCustomUrlScheme *customUrlUtility = [[utilitiesCustomUrlScheme alloc] init];
        [customUrlUtility saveToUserDefaultQueryParamAsString:[[[url query] componentsSeparatedByString:@"?"] objectAtIndex:0] querySpliter:@"&"];
        
        //add OpenFromUri paramter - need to test if been given from uri from safari
        NSString * strOpenAppFromUri =
        [[customUrlUtility nameSpaceToSaveToDisk]
         stringByAppendingString:[customUrlUtility nameSpaceOpenAppFromUri]];
        
        [customUrlUtility addParamFromUriQuery:strOpenAppFromUri valueParam:@"true"];
        //end-add OpenFromUri paramter - need to test if been given from uri from safari
    }
    
    if (url)
    {
        NSFileManager* fileMgr = [[ NSFileManager alloc] init];
        @try
        {
            NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
            NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString * documentDirPath = [paths objectAtIndex:0];
            NSString * inboxDirPath = [documentDirPath stringByAppendingPathComponent:@"Inbox"];
            NSString * cmDirPath = [documentDirPath stringByAppendingPathComponent:@"ClickMobile"];
            NSDirectoryEnumerator* en = [fileMgr enumeratorAtPath:inboxDirPath];
            NSString* userName = [userDefaults stringForKey:@"user_name"];
            NSString * userFileDirPath;
            NSString* file;
            BOOL bClickSubDirExsits = NO;
            BOOL bSuccess = YES;
            NSError* pError = nil;
            if ([cmDirPath length]>0)
            {
                userFileDirPath = [cmDirPath stringByAppendingPathComponent:userName];
                if ([userFileDirPath length]>0)
                {
                    bClickSubDirExsits = YES;
                }
            }
            
            if (bClickSubDirExsits)
            {
                while (file = [en nextObject]) {
                    //                    bSuccess = [fileMgr co]
                    //                    bSuccess = [fileMgr removeItemAtPath:[inboxDirPath stringByAppendingPathComponent:file] error:&pError];
                    NSLog(@"File in Inbox: %@",[inboxDirPath stringByAppendingPathComponent:file]);
                    bSuccess = [fileMgr moveItemAtPath:[inboxDirPath stringByAppendingPathComponent:file] toPath:[userFileDirPath stringByAppendingPathComponent:file] error:&pError];
                    NSLog(@"File in %@ folder: %@",userName,[userFileDirPath stringByAppendingPathComponent:file]);
                }
            }
        }
        @catch (NSException* e)
        { // NSInvalidArgumentException if path is . or ..
        }
        @finally
        {
        }
        NSLog(@"A file (url:%@) has been transferd to the application from %@",url,sourceApplication);
        
    }
    return YES;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

//CookiePersistency Support  new function
- (void)applicationWillTerminate:(UIApplication *)application
{
    [_CookiesUtility saveWebViewHTTPCookies];
}


@end
