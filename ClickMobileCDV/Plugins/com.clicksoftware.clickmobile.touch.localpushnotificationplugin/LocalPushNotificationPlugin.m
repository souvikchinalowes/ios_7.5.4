//
//  LocalPushNotificationPlugin.m
//  ClickMobileCDV
//
//  Created by ClickMobile Touch Team on 10/6/14.
//
//

#import "LocalPushNotificationPlugin.h"
#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVPluginResult.h>
#import "QSStrings.h"
#import <CoreLocation/CoreLocation.h>
#import "CDVFile.h"

@implementation LocalPushNotificationPlugin

- (void)lPNSGetUnusedIdsList:(CDVInvokedUrlCommand*)command
// This function add local push notification
{
    NSString* callbackId = command.callbackId;

    NSMutableString* listOfIDs = [[NSMutableString alloc] init];
    CDVPluginResult *result;
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:listOfIDs];
//    [self writeJavascript:[result toSuccessCallbackString:callbackId]];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];

}

- (void)lPNSCreateNewNotification:(CDVInvokedUrlCommand*)command
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
    
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    
    localNotification.timeZone= [NSTimeZone defaultTimeZone];
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
//    [self writeJavascript:[result toSuccessCallbackString:callbackId]];//warning resault
}


- (void)lPNSCancelSpecificNotification:(CDVInvokedUrlCommand*)command// This function remove local push notificitaion by its ID
{
    NSString* callbackId = command.callbackId;
    
    // Get Identifier (ID) of local Push Notification to remove (from JS)
    NSString* localPNKey = [command.arguments objectAtIndex:0];
    
//    idan ofek - remove issue with 
    NSDictionary *userDefaultDictionary
    = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    
//    =[[[NSDictionary alloc] init];
    
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
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    
    //warning removel
//    [self writeJavascript:[result toSuccessCallbackString:callbackId]];
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
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
//    [self writeJavascript:[result toSuccessCallbackString:callbackId]];
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
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    //warning resualt
//    [self writeJavascript:[result toSuccessCallbackString:callbackId]];
    

}


- (void)lPNSCancelAllNotifications:(CDVInvokedUrlCommand*)command
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
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
//    [self writeJavascript:[result toSuccessCallbackString:callbackId]];
}

- (void)lPNSGetAllPendingNotifications:(CDVInvokedUrlCommand*)command// This function remove all local push notification
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
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    //warning removel
//    [self writeJavascript:[result toSuccessCallbackString:callbackId]];
    
    
    
    
    //[listOfIDs release];
}


- (void)lPNSGetAllMyPendingNotifications:(CDVInvokedUrlCommand*)command
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
    
        //warning removel
//    [self writeJavascript:[result toSuccessCallbackString:callbackId]];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}

- (void)lPNSGetAllPendingNotificationWhichNotMine:(CDVInvokedUrlCommand*)command
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
        //warning removel
//    [self writeJavascript:[result toSuccessCallbackString:callbackId]];
}

-(void) lPNSGetUnusedIdList:(CDVInvokedUrlCommand*)command
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
        //warning removel
//    [self writeJavascript:[result toSuccessCallbackString:callbackId]];
}


@end
