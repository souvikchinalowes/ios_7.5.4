//
//  UserCredentialsPlugin.m
//  ClickMobileCDV
//
//  Created by ClickMobile Touch Team on 10/13/14.
//
//

#import "UserCredentialsPlugin.h"
#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVPluginResult.h>
#import "QSStrings.h"
#import <CoreLocation/CoreLocation.h>
#import "CDVFile.h"

@implementation UserCredentialsPlugin

- (void) setUserCredentials:(CDVInvokedUrlCommand*)command
{
    
    CDVPluginResult * result = nil;
//    NSString* jsString = nil; //warning removel
    NSString* callbackId = command.callbackId;
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setValue:[command.arguments objectAtIndex:0] forKey:@"user_name"];
    [userDefaults setValue:[command.arguments objectAtIndex:1] forKey:@"device_type"];
    [userDefaults setValue:[command.arguments objectAtIndex:2] forKey:@"device_uuid"];
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
//    jsString = [result toSuccessCallbackString:callbackId];
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    
//    [self writeJavascript:jsString];

    
}

@end
