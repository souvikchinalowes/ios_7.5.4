//
//  LocalPushNotificationPlugin.h
//  ClickMobileCDV
//
//  Created by ClickMobile Touch Team on 10/6/14.
//
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <Cordova/CDV.h>
#import <UIKit/UIKit.h>
#import "MainViewController.h"


@interface LocalPushNotificationPlugin : CDVPlugin <UIDocumentInteractionControllerDelegate>{
    NSString *localFile;
    
}


@end
