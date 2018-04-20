//
//  UserCredentialsPlugin.h
//  ClickMobileCDV
//
//  Created by ClickMobile Touch Team on 10/13/14.
//
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <Cordova/CDV.h>
#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface UserCredentialsPlugin : CDVPlugin <UIDocumentInteractionControllerDelegate>{
    NSString *localFile;
    
}
@end
