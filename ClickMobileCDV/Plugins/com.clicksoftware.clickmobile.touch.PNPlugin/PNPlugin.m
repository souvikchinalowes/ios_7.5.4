//
//  PNPlugin.m
//  ClickMobileCDV
//
//  Created by ClickMobile Touch Team on 10/6/14.
//
//

#import "PNPlugin.h"
#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVPluginResult.h>
#import "QSStrings.h"
#import <CoreLocation/CoreLocation.h>
#import "CDVFile.h"
#import "CookiesUtility.h"

@implementation PNPlugin


//getPushNotificationToken
- (void) register:(CDVInvokedUrlCommand*)command
{

    CDVPluginResult * result = nil;
//    NSString* jsString = nil;
    NSString* callbackId = command.callbackId;
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    //  [userDefaults setValue:token forKey:@"token"];
    
    NSString* returnStr = [userDefaults objectForKey:@"token"];
//    CookiesUtility *_CookiesUtility = [[CookiesUtility alloc] init];

    
    @try {
        
//        [_CookiesUtility loadWebViewHTTPCookies];
//        [_CookiesUtility saveWebViewHTTPCookies];
//        
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:returnStr];
    
//    jsString = [result toSuccessCallbackString:callbackId];
//    
//    
//    [self writeJavascript:jsString];
    
    
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];

}



@end
