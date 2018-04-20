//
//  ClickMobilePlugin.m
//  ClickMobileCDV
//
//  Created by ClickMobile Touch Team on 7/15/14.
//
//
#import "ClickMobilePlugin.h"
#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVPluginResult.h>
#import "QSStrings.h"
#import <CoreLocation/CoreLocation.h>
#import "CDVFile.h"


CDVPluginResult *result;

@implementation UserSettingMgr

typedef int FileError;

// Tal - Running on background - start
CLLocationManager *locationManager = nil;
CDVPluginResult *resultGPS;
bool firstTimeRunningOnBackground = true;
//int counter1=0;
//int freq_interval=60;

#pragma CLLocationManager DelegateCDVPluginResult *resultGPS;

- (void) setRunningOnBackground:(CDVInvokedUrlCommand*)command
{

    /*
     NSString *callbackId = [arguments objectAtIndex:0];
     counter1=0;
     NSString *IsAliveSignalFreq = [arguments objectAtIndex:1];
     if([IsAliveSignalFreq isEqualToString:@""])
     {
     freq_interval=60; // Default IsAlive freq.
     }
     else
     {
     
     freq_interval = [IsAliveSignalFreq integerValue];
     }
     */
    NSString* callbackID = command.callbackId;
    
    NSString* strSetRunningOnBackRound = [command.arguments objectAtIndex:0];
    
    // Disable running on background
    if([strSetRunningOnBackRound isEqualToString:@"false"])
    {
        if(locationManager !=nil)
        {
            [locationManager stopUpdatingLocation];
            locationManager = nil;
            firstTimeRunningOnBackground = true;
        }
    }
    
    // Enable running on background
    else
    {
        if(firstTimeRunningOnBackground)
        {
            if(locationManager == nil)
            {
                locationManager = [[CLLocationManager alloc] init];
                locationManager.distanceFilter =  kCLLocationAccuracyBest;
                locationManager.desiredAccuracy = kCLLocationAccuracyBest;
                locationManager.pausesLocationUpdatesAutomatically = NO;
                // locationManager.delegate = self;
            }
            [locationManager startUpdatingLocation];
            firstTimeRunningOnBackground=false;
        }
    }
    
     NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
     [userDefaults setValue:callbackID forKey:@"gpsCallback"];
     [userDefaults synchronize];
     
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    
    /*
     
     //   NSString *newLat = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
     //   NSString *oldLat = [NSString stringWithFormat:@"%f",oldLocation.coordinate.latitude];
     UIApplicationState state = [[UIApplication sharedApplication] applicationState];
     if(state == UIApplicationStateBackground || state == UIApplicationStateInactive)
     {
     ++counter1;
     // NSLog(@"counter is %i",counter1);
     if(counter1==freq_interval-1)
     {
     counter1=0;
     NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
     NSString *callbackId = [[NSString alloc] init];
     
     callbackId=[userDefaults valueForKey:@"gpsCallback"];
     
     resultGPS = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
     [resultGPS setKeepCallbackAsBool:TRUE];
     [self writeJavascript:[resultGPS toSuccessCallbackString:callbackId]];
     }
     }
     //NSLog(@"new location! %@  to   %@",oldLat,newLat);
     */
}
// Tal - end Running on background

// Tal Local push notification - start

- (void)lpnsCreateNewNotification:(CDVInvokedUrlCommand*)command
// This function add local push notification
{
    
    NSString* callbackId = command.callbackId;
    NSString* user_ID = [command.arguments objectAtIndex:0]; // format: userName#ID  (for example: w6-qa#3)
    NSString* msgBody = [command.arguments objectAtIndex:1]; // Message to be display
    NSString* timeFromNow = [command.arguments objectAtIndex:2]; // time from now to schedule LPNS (sec)
    NSString* lpnContext = [command.arguments objectAtIndex: 3]; // Context of LPN
    NSString* createdTime = [command.arguments objectAtIndex:4]; // time that lpn was created
    
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    
    // Time to show local PN - convert from minutes (from user) to secondes
    double timeInterval = [timeFromNow doubleValue] * 60;
    NSTimeInterval intervalTimeFromNow = timeInterval;
    localNotification.fireDate = [[NSDate date] dateByAddingTimeInterval:intervalTimeFromNow];
    
    // Message to be display
    localNotification.alertBody = msgBody;
    
    // Text to display on slider when device locked ("slide to ______")
    //localNotification.alertAction=@"view";
    
    //  Pushing the button will open/not open the  application
    // [localNotification setHasAction:NO];
    
    //localNotification.repeatInterval =  NSMinuteCalendarUnit;
    
    localNotification.timeZone= [NSTimeZone defaultTimeZone];
    
    //localNotification.applicationIconBadgeNumber = 0  ;// [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
    
    
    // Add personal data to local PN
    NSArray *Keys = [NSArray arrayWithObjects:@"udKey",@"allowAlert",@"context",@"createdTime" , @"Minutes",nil];
    NSArray *objects = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%@#%@",@"lpns",user_ID] ,@"no",lpnContext,createdTime,timeFromNow ,nil];
    NSDictionary *personalData = [NSDictionary dictionaryWithObjects:objects forKeys:Keys];
    [localNotification setUserInfo:personalData];
    
    
    // Scehdule the local PN
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    
    // save the local PN to local DB
    NSData *noti = [NSKeyedArchiver archivedDataWithRootObject:localNotification];
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:noti forKey:[NSString stringWithFormat:@"%@#%@",@"lpns",user_ID]];   //lpns#userName#ID    for exmple:  lpns#w6-qa#3
    
    // Update the list of Free IDs (remove from list)
    
    NSArray *listItems = [user_ID componentsSeparatedByString:@"#"];
    
    // ID to remove from list in format id&  (for example: 5&)
    NSString *ID_OF_LPN = [NSString stringWithFormat:@"%@&",listItems[1]];
    
    NSString* listOfFreeIDs = [userDefaults objectForKey:@"LPN_FREE"];
    listOfFreeIDs = [listOfFreeIDs stringByReplacingOccurrencesOfString:ID_OF_LPN withString:@""];
    
    [userDefaults setObject:listOfFreeIDs forKey:@"LPN_FREE"];
    
    [userDefaults synchronize];
    
    CDVPluginResult *result;
    
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
//    [self.commandDelegate evalJs:[result  toSuccessCallbackString:callbackId]];
}


- (void)lpnsCancelSpecificNotification:(CDVInvokedUrlCommand*)command// This function remove local push notificitaion by its ID
{
    NSString* callbackId = command.callbackId;
    
    // Get Identifier (ID) of local Push Notification to remove (from JS)
    NSString* localPNKey = [command.arguments objectAtIndex:0];
    
    
    NSDictionary *userDefaultDictionary = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    //warning removeal
//    =[[NSDictionary alloc] init];
//    NSUserDefaults *userDefaultDictionary

    for (NSString* key in userDefaultDictionary) {
        // NSString* value = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] objectForKey:key];
        if( [key rangeOfString:  [NSString stringWithFormat:@"#%@",localPNKey]].location != NSNotFound)
        {
            // cancel
            // Get data of local P.N from iOS DB by ID
            NSData *dataArchivedLocalPN = [[NSUserDefaults standardUserDefaults] objectForKey:key];
            // Convert data to UILOcalNotification
            UILocalNotification *localPN = [NSKeyedUnarchiver unarchiveObjectWithData:dataArchivedLocalPN];
            
            // Cancel the local P.N
            [[UIApplication sharedApplication] cancelLocalNotification:localPN];
            
            // Remove local P.N from DB
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults removeObjectForKey:key];
            
            // Update list of free id (add to list];
            NSMutableString *listOfFreeIDs = [userDefaults objectForKey:@"LPN_FREE"];
            [listOfFreeIDs appendString: [NSString stringWithFormat:@"%@&",localPNKey]];
            [userDefaults setObject:listOfFreeIDs forKey:@"LPN_FREE"];
            [userDefaults synchronize];
            
            
        }
    }
    
    CDVPluginResult *result;
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    
    //warning resault
//    [self.commandDelegate evalJs:[result toSuccessCallbackString:callbackId]];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId ];
    
}

- (void)CancelAllNotifications:(CDVInvokedUrlCommand*)command
// This function remove all local push notification
{
    NSString* callbackId = command.callbackId;
    NSString *userName = [command.arguments objectAtIndex:0];
    NSString* context = [command.arguments objectAtIndex:1];
    
    NSMutableString *newListOfFreeIDsToAdd = [[NSMutableString alloc] init];
    bool needToCheckContext = true;
    
    // check if context is empty
    if([context isEqualToString:@""])
    {
        needToCheckContext = false;
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    //clear all local push notification from local DB
    NSDictionary *userDefaultDictionary=[[NSDictionary alloc] init];
    userDefaultDictionary = [userDefaults dictionaryRepresentation];
    NSString* EntryToRemove = [@"lpns#" stringByAppendingString:userName];
    
    for (NSString* key in userDefaultDictionary) {
        
        if( [key rangeOfString: EntryToRemove].location != NSNotFound)
        {
            // Get data of local P.N from iOS DB by ID
            NSData *dataArchivedLocalPN = [[NSUserDefaults standardUserDefaults] objectForKey:key];
            
            // Convert data to UILOcalNotification
            UILocalNotification *localPN = [NSKeyedUnarchiver unarchiveObjectWithData:dataArchivedLocalPN];
            
            
            if(needToCheckContext)
            {
                NSString* lpnContext = [localPN.userInfo objectForKey:@"context"];
                if([lpnContext isEqualToString:context])
                {
                    
                    // Cancel the local P.N
                    [[UIApplication sharedApplication] cancelLocalNotification:localPN];
                    
                    // Remove local P.N from DB
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
                    
                    // Add ID to list of free IDs
                    NSString *lpnID = [[localPN.userInfo objectForKey:@"udKey"] componentsSeparatedByString:@"#"][2];
                    [newListOfFreeIDsToAdd appendString: [NSString stringWithFormat:@"%@&",lpnID]];
                }
            }
            else // no need to chech the context
            {
                // Remove local P.N from DB
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
                
                // Add ID to list of free IDs
                NSString *lpnID = [[localPN.userInfo objectForKey:@"udKey"] componentsSeparatedByString:@"#"][2];
                [newListOfFreeIDsToAdd appendString: [NSString stringWithFormat:@"%@&",lpnID]];
                
            }
            
        }
    }
    
    if(![newListOfFreeIDsToAdd isEqualToString:@""])
    {
        NSMutableString *listOfFreeLPN = [userDefaults objectForKey:@"LPN_FREE"];
        [listOfFreeLPN appendString:newListOfFreeIDsToAdd];
        [userDefaults setObject:listOfFreeLPN forKey:@"LPN_FREE"];
        [userDefaults synchronize];
    }
    
    CDVPluginResult *result;
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
//    [self writeJavascript:[result toSuccessCallbackString:callbackId]];
//    warning removal
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}

- (void)removeAllMyLocalPushNotification:(CDVInvokedUrlCommand*)command// This function remove all user local push notification
{
    NSString* callbackId = command.callbackId;
    NSString* userName = [command.arguments objectAtIndex:0];
    NSString* context=[command.arguments objectAtIndex:1];
    
    NSMutableString *newListOfFreeIDsToAdd = [[NSMutableString alloc] init];
    bool needToCheckContext = true;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    
    // check if context is empty
    if([context isEqualToString:@""])
    {
        needToCheckContext = false;
    }
    
    NSDictionary *userDefaultDictionary=[[NSDictionary alloc] init];
    userDefaultDictionary = [userDefaults dictionaryRepresentation];
    for (NSString* key in userDefaultDictionary) {
        
        // Get data of local P.N from iOS DB by ID
        NSData *dataArchivedLocalPN = [userDefaults objectForKey:key];
        
        // Convert data to UILOcalNotification
        UILocalNotification *localPN = [NSKeyedUnarchiver unarchiveObjectWithData:dataArchivedLocalPN];
        
        // Check if DB entry is related to local push notification of specific user
        if( [key rangeOfString:  [NSString stringWithFormat:@"lpns#%@",userName]].location != NSNotFound)
        {
            // cancel notification
            
            
            NSString* lpnContext = [localPN.userInfo objectForKey:@"context"];
            if((needToCheckContext && [lpnContext isEqualToString:context]) || !needToCheckContext)
            {
                // Cancel the local P.N
                [[UIApplication sharedApplication] cancelLocalNotification:localPN];
                
                // Remove local P.N from DB
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
                
                
                // Add ID to list of free IDs
                NSString *lpnID = [[localPN.userInfo objectForKey:@"udKey"] componentsSeparatedByString:@"#"][2];
                [newListOfFreeIDsToAdd appendString: [NSString stringWithFormat:@"%@&",lpnID]];
            }
        }
    }
    
    if(![newListOfFreeIDsToAdd isEqualToString:@""])
    {
        NSMutableString *listOfFreeLPN = [userDefaults objectForKey:@"LPN_FREE"];
        [listOfFreeLPN appendString:newListOfFreeIDsToAdd];
        [userDefaults setObject:listOfFreeLPN forKey:@"LPN_FREE"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    CDVPluginResult *result;
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
//    warning removal
//    [self writeJavascript:[result toSuccessCallbackString:callbackId]];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}


- (void)lpnsCancelAllNotifications:(CDVInvokedUrlCommand*)command
{
    // ***!!!!
    /*
     This function Cancel all local push notifications.
     in case the user name is not null, it will cancel all local push notifications that not related to the user!
     */
    
    NSString* callbackId = command.callbackId;
    NSString* userName = [command.arguments objectAtIndex:0];
    NSString* context = [command.arguments objectAtIndex:1];
    
    NSMutableString *newListOfFreeIDsToAdd = [[NSMutableString alloc] init];
    bool needToCheckContext = true;
    bool needToCheckUsername = true;
    
    // check if context is empty
    if([context isEqualToString:@""])
    {
        needToCheckContext = false;
    }
    
    if([userName isEqualToString:@""])
    {
        needToCheckUsername = false;
    }
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userDefaultDictionary=[[NSDictionary alloc] init];
    userDefaultDictionary = [userDefaults dictionaryRepresentation];
    for (NSString* key in userDefaultDictionary) {
        NSArray *listItems = [key componentsSeparatedByString:@"#"];
        if([listItems count]>2)
        {
            if((needToCheckUsername && ![listItems[1] isEqualToString:userName]) || !needToCheckUsername )
            {
                // Cancel LPN
                
                // Get data of local P.N from iOS DB by ID
                NSData *dataArchivedLocalPN = [[NSUserDefaults standardUserDefaults] objectForKey:key];
                // Convert data to UILOcalNotification
                UILocalNotification *localPN = [NSKeyedUnarchiver unarchiveObjectWithData:dataArchivedLocalPN];
                
                NSString* lpnContext = [localPN.userInfo objectForKey:@"context"];
                if((needToCheckContext && [lpnContext isEqualToString:context]) || !needToCheckContext)
                {
                    // Cancel the local P.N
                    [[UIApplication sharedApplication] cancelLocalNotification:localPN];
                    
                    // Remove local P.N from DB
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
                    
                    // Add ID to list of free IDs
                    NSString *lpnID = [[localPN.userInfo objectForKey:@"udKey"] componentsSeparatedByString:@"#"][2];
                    [newListOfFreeIDsToAdd appendString: [NSString stringWithFormat:@"%@&",lpnID]];
                }
            }
        }
    }
    
    
    if(![newListOfFreeIDsToAdd isEqualToString:@""])
    {
        NSMutableString *listOfFreeLPN = [userDefaults objectForKey:@"LPN_FREE"];
        [listOfFreeLPN appendString:newListOfFreeIDsToAdd];
        [userDefaults setObject:listOfFreeLPN forKey:@"LPN_FREE"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    CDVPluginResult *result;
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
//    warning removeval
//    [self writeJavascript:[result toSuccessCallbackString:callbackId]];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}

- (void)lpnsGetAllPendingNotifications:(CDVInvokedUrlCommand*)command// This function remove all local push notification
{
    NSString* callbackId = command.callbackId;
    NSString* userName = [command.arguments objectAtIndex:0];
    NSString* context = [command.arguments objectAtIndex:1];
    
    bool needToCheckContext = true;
    bool needToCheckUserName = true;
    // check if context is empty
    if([context isEqualToString:@""])
    {
        needToCheckContext = false;
    }
    if([userName isEqualToString:@""])
    {
        needToCheckUserName = false;
    }
    
    NSMutableString* listOfIDs = [[NSMutableString alloc] init]; // List of pending lpns IDs in format id&id&id&... for example: 1&3&4
//    
//    NSMutableString* notificationInfo = [[NSMutableString alloc] init];
//    
    
    NSDictionary *userDefaultDictionary=[[NSDictionary alloc] init];
    userDefaultDictionary = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    
    for (NSString* key in userDefaultDictionary) {
        //key: lpns#w6-qa#5
        NSArray *listItems = [key componentsSeparatedByString:@"#"];
        if([listItems count]>2)
        {
            if([listItems[0] isEqualToString:@"lpns"])
            
            {
                if( (needToCheckUserName && [listItems[1] isEqualToString:userName]) || !needToCheckUserName )
                {
                    // Get data of local P.N from iOS DB by ID
                    NSData *dataArchivedLocalPN = [[NSUserDefaults standardUserDefaults] objectForKey:key];
                    // Convert data to UILOcalNotification
                    UILocalNotification *localPN = [NSKeyedUnarchiver unarchiveObjectWithData:dataArchivedLocalPN];
                    
                    NSString* lpnsID = listItems[2];
                    
                    NSString* lpnContext = [localPN.userInfo objectForKey:@"context"];
                    
                    NSString* lpnsMessageBody = localPN.alertBody;
                    
                    NSString* lpnsUserName = listItems[1];
                    
                    //Minutes
                    NSString* lpnsMinutes =[localPN.userInfo objectForKey:@"Minutes"];
                    
                    NSString* lpnsCreatedTime = [localPN.userInfo objectForKey:@"createdTime"];
                    //NSString* notificationInfo = @"UserName" + lpnsUserName + @"&Message" + lpnsMessageBody + @"&Minutes" + lpnsMinutes + @"Context" + lpnContext;
                    
                    //    [notificationInfo appendString:  [NSString stringWithFormat:@"@UserName %@Message%@Minutes%@Context%@",lpnsUserName , lpnsMessageBody , lpnsMinutes , lpnContext]];
                    
                    
                    
                    //NSArray *Keys = [NSArray arrayWithObjects:@"udKey",@"allowAlert",@"context",@"createdTime",nil];
                    
                    /*
                     
                     
                     
                     NSString* callbackId = [arguments objectAtIndex:0];
                     NSString* user_ID = [arguments objectAtIndex:1]; // format: userName#ID  (for example: w6-qa#3)
                     NSString* timeFromNow = [arguments objectAtIndex:2]; // time from now to schedule LPNS (sec)
                     NSString* msgBody = [arguments objectAtIndex:3]; // Message to be display
                     NSString* lpnContext = [arguments objectAtIndex: 4]; // Context of LPN
                     NSString* createdTime = [arguments objectAtIndex:5]; // time that lpn was created
                     */
                    if((needToCheckContext && [lpnContext isEqualToString:context]) || !needToCheckContext)
                    {
                        NSString *CurrentUser = [NSString stringWithFormat:@"UserName=%@&ID=%@&Context=%@&Message=%@&CreatedTime=%@&Minutes=%@~",lpnsUserName,lpnsID,lpnContext,lpnsMessageBody,lpnsCreatedTime,lpnsMinutes];
                        
                        [listOfIDs appendString:CurrentUser];
                    }
                }
            }
        }
    }
    
    CDVPluginResult *result;
    
    
    
    NSMutableDictionary* resultDict = [[NSMutableDictionary alloc] init];
    [resultDict setObject:listOfIDs     forKey:@"result"];
    
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
//    warning removael
//    [self writeJavascript:[result toSuccessCallbackString:callbackId]];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    
    //[listOfIDs release];
}


- (void)lpnsGetAllMyPendingNotifications:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = command.callbackId;
    NSString* userName = [command.arguments objectAtIndex:0]; //w6-qa
    NSString* context = [command.arguments objectAtIndex:1];
    
    bool needToCheckContext = true;
    
    // check if context is empty
    if([context isEqualToString:@""])
    {
        needToCheckContext = false;
    }
    
    
    NSMutableString* listOfIDs = [[NSMutableString alloc] init]; // List of pending lpns IDs in format id&id&id&... for example: 1&3&4
    
    NSMutableString* notificationInfo = [[NSMutableString alloc] init];
    
    
    NSDictionary *userDefaultDictionary=[[NSDictionary alloc] init];
    userDefaultDictionary = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    for (NSString* key in userDefaultDictionary) {
        //key: lpns#w6-qa#5
        NSArray *listItems = [key componentsSeparatedByString:@"#"];
        
        
        
        if([listItems[0] isEqualToString:@"lpns"] && [listItems[1] isEqualToString:userName])
        {
            // Get data of local P.N from iOS DB by ID
            NSData *dataArchivedLocalPN = [[NSUserDefaults standardUserDefaults] objectForKey:key];
            // Convert data to UILOcalNotification
            UILocalNotification *localPN = [NSKeyedUnarchiver unarchiveObjectWithData:dataArchivedLocalPN];
            
            NSString* lpnContext = [localPN.userInfo objectForKey:@"context"];
            
            //createdTime
            NSString* lpnCreatedTime = [localPN.userInfo objectForKey:@"createdTime"];
            
            
            //NSString* lpnContext = [localPN.userInfo objectForKey:@"context"];
            
            NSString* lpnsMessageBody = localPN.alertBody;
            
            NSString* lpnsUserName = listItems[1];
            
            //Minutes
            NSString* lpnsMinutes =[localPN.userInfo objectForKey:@"Minutes"];
            
            //NSString* notificationInfo = @"UserName" + lpnsUserName + @"&Message" + lpnsMessageBody + @"&Minutes" + lpnsMinutes + @"Context" + lpnContext;
            
            [notificationInfo appendString:  [NSString stringWithFormat:@"UserName %@&Message %@&Minutes %@&Context %@&CreatedTime %@",lpnsUserName , lpnsMessageBody , lpnsMinutes , lpnContext , lpnCreatedTime]];
            
            
            
            if((needToCheckContext && [lpnContext isEqualToString:context]) || !needToCheckContext)
            {
                [listOfIDs appendString: [NSString stringWithFormat:@"%@&",notificationInfo]];
            }
        }
    }
    
    CDVPluginResult *result;
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:listOfIDs];
//    warning remove
//    [self writeJavascript:[result toSuccessCallbackString:callbackId]];
    
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}

- (void)lpnsGetAllPendingNotificationWhichNotMine:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = command.callbackId;
    NSString* userName = [command.arguments objectAtIndex:0]; //w6-qa
    NSString* context = [command.arguments objectAtIndex:1];
    
    
    bool needToCheckContext = true;
    
    // check if context is empty
    if([context isEqualToString:@""])
    {
        needToCheckContext = false;
    }
    
    
    NSMutableString* listOfIDs = [[NSMutableString alloc] init]; // List of pending lpns IDs in format id&id&id&... for example: 1&3&4
    
    
    NSDictionary *userDefaultDictionary=[[NSDictionary alloc] init];
    userDefaultDictionary = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    for (NSString* key in userDefaultDictionary) {
        //key: lpns#w6-qa#5
        NSArray *listItems = [key componentsSeparatedByString:@"#"];
        
        if([listItems[0] isEqualToString:@"lpns"] && !([listItems[1] isEqualToString:userName]))
        {
            // Get data of local P.N from iOS DB by ID
            NSData *dataArchivedLocalPN = [[NSUserDefaults standardUserDefaults] objectForKey:key];
            // Convert data to UILOcalNotification
            UILocalNotification *localPN = [NSKeyedUnarchiver unarchiveObjectWithData:dataArchivedLocalPN];
            
            NSString* lpnContext = [localPN.userInfo objectForKey:@"context"];
            
            
            if((needToCheckContext && ![lpnContext isEqualToString:context]) || !needToCheckContext)
            {
                [listOfIDs appendString: [NSString stringWithFormat:@"%@&",listItems[2]]];
            }
        }
    }
    
    CDVPluginResult *result;
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:listOfIDs];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
//    warning removal
//    [self writeJavascript:[result toSuccessCallbackString:callbackId]];
}

-(void) lpnsGetUnusedIdList:(CDVInvokedUrlCommand*)command
{
    /* This function return list of all LPN unused ID in format: id1&id2&id3.....   for example: 2&5&6
     
     once return the list, Initialize it to be empty!
     
     The list of free IDs change in the following casses:
     
     1. Add LPN ->  remove the ID from the list.
     2. Cancel LPN -> Add the ID/IDs to the list.
     3. Enter foreground -> Add the IDs of the lpns that already fired.
     4. Getting LPN while app in foreground -> add the ID to the list.
     
     
     LOCAL DB:
     The entry for the list of free IDs is: LPN_FREE
     The format of the value for the entry is: id1&id2&id3.....   for example: 2&5&6
     */
    
    NSString* callbackId = command.callbackId;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // Get list of unused IDs
    NSString *lpnFreeIDs = [userDefaults objectForKey:@"LPN_FREE"];
    
    // Empty the list of unused IDs in local DB
    [userDefaults setObject:@"" forKey:@"LPN_FREE"];
    [userDefaults synchronize];
    
    CDVPluginResult *result;
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:lpnFreeIDs];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
//    warning removeal
//    [self writeJavascript:[result toSuccessCallbackString:callbackId]];
}
// Tal local push notification - finish

- (void)getClickMobileURLSetting:(CDVInvokedUrlCommand*)command
{
    
    NSString* callbackId = command.callbackId;
    
	////////////
	//--initialize the settings value first;
	// if not all settings values will be null --
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	
	if (![userDefaults objectForKey:@"url_preference"])
	{
		[userDefaults setObject:@"http://<SERVER ADDRESS>/ClickMobileWEB/Default.aspx" forKey:@"url_preference"];
		
		[userDefaults synchronize];
	}
	
	NSString* url = [userDefaults stringForKey:@"url_preference"];
    
	CDVPluginResult * result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: url];

    if (result) {
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    }

    
//warning removal
//	NSString* jsString = [result toSuccessCallbackString:callbackId];
//	
//	if (jsString)
//	{
//		[self writeJavascript: jsString];
//	}
}

- (void)getClearImagesSetting:(CDVInvokedUrlCommand*)command
{
	
	NSString* callbackId = command.callbackId;
	
	////////////
	//--initialize the settings value first;
	// if not all settings values will be null --
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	
	if (![userDefaults objectForKey:@"url_preference"])
	{
		[userDefaults setObject:@"http://<SERVER ADDRESS>/ClickMobileWEB/Default.aspx" forKey:@"url_preference"];
		
		[userDefaults synchronize];
	}
	
	
	NSString* url = [userDefaults stringForKey:@"url_preference"];
	
	CDVPluginResult * result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:url];

    if (result) {
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    }
    
//	NSString* jsString = [result toSuccessCallbackString:callbackId];
//	
//	if (jsString)
//	{
//		[self writeJavascript: jsString];
//	}
}

- (void)setClearImagesSetting:(CDVInvokedUrlCommand*)command
{
	
	NSString* callbackId = command.callbackId;
	////////////
	//--initialize the settings value first;
	// if not all settings values will be null --
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	
	if (![userDefaults objectForKey:@"url_preference"])
	{
		[userDefaults setObject:@"http://<SERVER ADDRESS>/ClickMobileWEB/Default.aspx" forKey:@"url_preference"];
		
		[userDefaults synchronize];
	}
	
	
	NSString* url = [userDefaults stringForKey:@"url_preference"];
	
	CDVPluginResult * result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: url ];
	
//	NSString* jsString = [result toSuccessCallbackString:callbackId];
//	
//	if (jsString)
//	{
//		[self writeJavascript: jsString];
//	}
    
    if (result) {
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    }
}

- (void)getClearCacheSetting:(CDVInvokedUrlCommand*)command
{
	
	NSString* callbackId = command.callbackId;
	////////////
	//--initialize the settings value first;
	// if not all settings values will be null --
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	
	if (![userDefaults objectForKey:@"url_preference"])
	{
		[userDefaults setObject:@"http://<SERVER ADDRESS>/ClickMobileWEB/Default.aspx" forKey:@"url_preference"];
		
		[userDefaults synchronize];
	}
	
	
	NSString* url = [userDefaults stringForKey:@"url_preference"];
	
	CDVPluginResult * result = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsString: url ];

    if (result) {
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    }
    
//	NSString* jsString = [result toSuccessCallbackString:callbackId];
//	
//	if (jsString)
//	{
//		[self.commandDelegate evalJs: jsString];
//	}
}

- (void) getPushNotificationToken:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult * result = nil;
//    NSString* jsString = nil;
    NSString* callbackId = command.callbackId;
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
  //  [userDefaults setValue:token forKey:@"token"];
    
    NSString* returnStr = [userDefaults objectForKey:@"token"];

    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:returnStr];
    //warning removal
//    jsString = [result toSuccessCallbackString:callbackId];
    
//    [self writeJavascript:jsString];
    
    if (result) {
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    }
}

- (void) setUserCredentials:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult * result = nil;
//    NSString* jsString = nil;
    NSString* callbackId = command.callbackId;
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:[command.arguments objectAtIndex:0] forKey:@"user_name"];
    [userDefaults setValue:[command.arguments objectAtIndex:1] forKey:@"device_type"];
    [userDefaults setValue:[command.arguments objectAtIndex:2] forKey:@"device_uuid"];
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    
//    warning removeal
//    jsString = [result toSuccessCallbackString:callbackId];
//    
//    [self writeJavascript:jsString];
//
//  warning removeal
    if (result) {
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    }
}

- (void) openWith:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult * pluginResult;
    NSString* callbackID = command.callbackId;
    
    NSString* path = [command.arguments objectAtIndex:0];
    
    NSString* uti = [command.arguments objectAtIndex:1];
    
    NSLog(@"path %@, uti:%@",path, uti);
    
    //    NSArray* parts = [path componentsSeparatedByString:@"/"];
    //    NSString* previewDocumentFileName = [parts lastObject];
    //    NSLog(@"The file name is %@",previewDocumentFileName);
    //
    //    NSData* fileRemote = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:path]];
    //
    //    NSArray* paths = cNSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSString* documentsDirectory = [paths objectAtIndex:0];
    //    if (!documentsDirectory)
    //    {
    //        NSLog(@"Documents directory not found");
    //    }
    //    localFile = [documentsDirectory stringByAppendingPathComponent:previewDocumentFileName];
    //    NSLog(@"localFile: %@",localFile);
    //    [localFile retain];
    //    [fileRemote writeToFile:localFile atomically:YES];
    //    NSLog(@"Resource file '%@' has been written to the Documents directory from online",previewDocumentFileName);
    //
    NSURL* fileURL = [NSURL fileURLWithPath:path];
    //    NSURL *fileURL = [NSURL fileURLWithPath:localFile];
    NSLog(@"fileURL: %@",fileURL);
    UIDocumentInteractionController* controller = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    controller.delegate = self;
    controller.UTI = uti;
    //    BOOL result = [controller presentPreviewAnimated:YES];

//    MainViewController* cont = (MainViewController*)[self viewController];
    
//    CGRect rect = CGRectMake(0, 0, cont.view.bounds.size.width, cont.view.bounds.size.height);
    //    BOOL result =   [controller presentOptionsMenuFromRect:rect inView:cont.view animated:YES];
    //    BOOL result = [controller presentOpenInMenuFromRect:rect inView:cont.view animated:YES];
    //    [controller presentOpenInMenuFromRect:rect inView:self.webView animated:YES];
    
    BOOL result = [controller presentPreviewAnimated:YES];
    //    [self setupControllerWithURL:fileURL usingDelegate:self];
    if (result == YES)
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@""];
    }
    
    if (result) {
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
    }
    
//    [self.commandDelegate evalJs:[pluginResult toSuccessCallbackString:callbackID]];
    
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL
                                               usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    NSLog(@"File URL: %@",fileURL);
    
    UIDocumentInteractionController *interactionController =
    [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    [interactionController presentPreviewAnimated:YES];
    return interactionController;
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController
{
    return [self viewController];
}


- (void) documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
    NSLog(@"documentInteractionControllerDidDismissOpenInMenu");
    [self cleanupTempFile:controller];
}

- (void) documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application
{
    NSLog(@"didEndSendingToApplication: %@",application);
    [self cleanupTempFile:controller];
}

- (void) cleanupTempFile:(UIDocumentInteractionController *)controller
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError* error;
    BOOL fileExists = [fileManager fileExistsAtPath:localFile];
    
    NSLog(@"Path to file: %@", localFile);
    NSLog(@"File exists: %d", fileExists);
    NSLog(@"Is deletable file or path: %d", [fileManager isDeletableFileAtPath:localFile]);
    
    if (fileExists)
    {
        BOOL success = [fileManager removeItemAtPath:localFile error:&error];
        if (!success) NSLog(@"Error: %@",[error localizedDescription]);
    }
}

- (void) previewFile:(CDVInvokedUrlCommand*)command
{
    //PluginResult* pluginResult;
    NSString* callbackID = command.callbackId;
    
    NSString* path = [command.arguments objectAtIndex:0];
    
    NSString* uti = [command.arguments objectAtIndex:1];
    
    NSLog(@"path %@, uti:%@",path, uti);
    NSURL * fileURL = [NSURL fileURLWithPath:path];
    
    [self setupControllerWithURL:fileURL usingDelegate:self];
    
}

- (void) writeBinaryData:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = command.callbackId;
	NSString* argFileName = [command.arguments objectAtIndex:0];
	NSString* argData = [command.arguments objectAtIndex:1];
	unsigned long long pos = (unsigned long long)[[ command.arguments objectAtIndex:1] longLongValue];
	
	//NSString* fileName = argFileName;
	
	[self truncateFile:argFileName atPosition:pos];
	
	[self writeBinaryToFile: argFileName withData:argData append:YES callback: callbackId];
}

- (void) writeBinaryToFile:(NSString*)fileName withData:(NSString*)data append:(BOOL)shouldAppend callback: (NSString*) callbackId
{
    CDVPluginResult * result = nil;
//	NSString* jsString = nil;
	FileError errCode = INVALID_MODIFICATION_ERR;
	int bytesWritten = 0;
    
    //NSRange range = [data rangeOfString:@","];
    //NSString *fixedDataString = [data substringFromIndex:(range.location + 1)];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* dirName = [userDefaults stringForKey:@"user_name"];
    
    NSData * encData = [QSStrings decodeBase64WithString:data];
    
    NSString * dirPath = [NSString stringWithFormat:@"Documents/ClickMobile/%@",dirName];
    
    NSString * documentsDir = [NSHomeDirectory() stringByAppendingPathComponent:dirPath];
    NSString * fullPath = [documentsDir stringByAppendingPathComponent:fileName];
    
    NSLog(@"Full path %@", fullPath);
    
    
    
	if (fullPath) {
		NSOutputStream* fileStream = [NSOutputStream outputStreamToFileAtPath:fullPath append:shouldAppend ];
        
        if (fileStream) {
            
            NSError* error = [fileStream streamError];
            
			NSUInteger len = [ encData length ];
            
			[ fileStream open ];
			
			bytesWritten = [ fileStream write:[encData bytes] maxLength:len];
            
			[ fileStream close ];
            
			if (bytesWritten > 0) {
                
				result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:fullPath];
                if (result) {
                    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
                }
                
//				jsString = [result toSuccessCallbackString:callbackId];
                
                //} else {
				// can probably get more detailed error info via [fileStream streamError]
				//errCode already set to INVALID_MODIFICATION_ERR;
				//bytesWritten = 0; // may be set to -1 on error
			}
            else
            {
                if (error)
                NSLog(@"Error: %@",[error localizedDescription]);
            }
		} // else fileStream not created return INVALID_MODIFICATION_ERR
	} else {
		// invalid filePath
		errCode = NOT_FOUND_ERR;
	}
    
    if (result) {
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    }
    
//	if(!jsString) {
//		// was an error
//		result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt: errCode cast: @"window.localFileSystem._castError"];
//		jsString = [result toErrorCallbackString:callbackId];
//	}
//	[self writeJavascript: jsString];
//	
}

- (unsigned long long) truncateFile:(NSString*)filePath atPosition:(unsigned long long)pos
{
    
	unsigned long long newPos = 0UL;
	
	NSFileHandle* file = [ NSFileHandle fileHandleForWritingAtPath:filePath];
	if(file)
	{
		[file truncateFileAtOffset:(unsigned long long)pos];
		newPos = [ file offsetInFile];
		[ file synchronizeFile];
		[ file closeFile];
	}
	return newPos;
}

- (void)getClearFilesSetting:(CDVInvokedUrlCommand*)command

{
	
	NSString* callbackId = command.callbackId;
	
	////////////
	//--initialize the settings value first;
	// if not all settings values will be null --
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	
	if (![userDefaults objectForKey:@"clearFiles_preference"])
	{
		[userDefaults setObject:NO forKey:@"clearFiles_preference"];
		
		[userDefaults synchronize];
	}
	
	
	BOOL clearFiles = (BOOL)[userDefaults boolForKey:@"clearFiles_preference"];
    
    int resultValue = 0;
    
    if (clearFiles) {
        NSFileManager* fileMgr = [[ NSFileManager alloc] init];
        @try
        {
            NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            BOOL bClickSubDirExsits = YES;
            NSArray *subpaths = [fileMgr subpathsAtPath:[paths objectAtIndex:0]];
            NSString* strFilesFolder;
            @try {
                strFilesFolder = [[paths objectAtIndex:0]stringByAppendingString:[@"/"stringByAppendingString:[subpaths objectAtIndex:0]]];
            }
            @catch (NSException *exception) {
                bClickSubDirExsits = NO;
            }
            BOOL bSuccess = YES;
            if (bClickSubDirExsits)
            {
                NSLog(@"Folder Path: %@",strFilesFolder);
                NSDirectoryEnumerator* en = [fileMgr enumeratorAtPath:strFilesFolder];
                NSError* pError = nil;
                
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
                
            }
            
            if (bSuccess)
            {
                resultValue = 1;
                [userDefaults setObject:NO forKey:@"clearFiles_preference"];
            }
        }
        @catch (NSException* e)
		{ // NSInvalidArgumentException if path is . or ..
        }
		@finally
		{
		}
        
    }
    
    CDVPluginResult * result = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsInt: resultValue];

    if (result) {
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    }
    
//    warning removeal
//	NSString* jsString = [result toSuccessCallbackString:callbackId];
//	
//	if (jsString)
//	{
//		[self writeJavascript: jsString];
//	}
}


@end
