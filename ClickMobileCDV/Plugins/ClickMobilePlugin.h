//
//  ClickMobilePlugin.h
//  ClickMobileCDV
//
//  Created by ClickMobile Touch Team on 7/15/14.
//
//
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <Cordova/CDV.h>
#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface UserSettingMgr : CDVPlugin <UIDocumentInteractionControllerDelegate>{
    NSString *localFile;
    
}
extern NSString* token;
- (void) getPushNotificationToken:(CDVInvokedUrlCommand*)command;

@end
