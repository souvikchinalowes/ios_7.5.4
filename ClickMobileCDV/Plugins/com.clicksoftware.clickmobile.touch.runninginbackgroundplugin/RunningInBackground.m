//
//  RunningInBackground.m
//  ClickMobileCDV
//
//  Created by ClickMobile Touch Team on 10/6/14.
//
//

#import "RunningInBackground.h"


#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVPluginResult.h>
#import "QSStrings.h"
#import <CoreLocation/CoreLocation.h>
#import "CDVFile.h"


@implementation RunningInBackground

CLLocationManager *locationManager;

- (void) setPhonegapKeepRunning:(CDVInvokedUrlCommand*)command
{
//       NSString* callbackID = command.callbackId;
    BOOL bUseRunningOnBackgroundLogic= [[command.arguments objectAtIndex:0] boolValue];
   
    
    if(locationManager == nil)
    {
        locationManager = [[CLLocationManager alloc] init];

        //idan ofek new ios 9 property to update GPS while in background
        #if __IPHONE_9_0
        float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (ver >= 9.0) {
            // Only executes on version 9 or above.
            locationManager.allowsBackgroundLocationUpdates = YES;
        }
        #endif
        //end-idan ofek new ios 9 property to update GPS while in background
        locationManager.distanceFilter =  kCLLocationAccuracyBest;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.pausesLocationUpdatesAutomatically = NO;
        
    }
   
    // Disable running on background
    if(!bUseRunningOnBackgroundLogic)
    {
        @try {
#ifdef __IPHONE_8_0
            if(locationManager != nil)
            {
                [locationManager stopUpdatingLocation];
            }
            
            [locationManager requestWhenInUseAuthorization];
            
#endif
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
        }
        @finally {
            
        }
    }
    
    // Enable running on background
    else
    {
        [locationManager startUpdatingLocation];
        
        @try {
#ifdef __IPHONE_8_0
         
            // Do any additional setup after loading the view from its nib.
            [locationManager requestAlwaysAuthorization];
            
#endif
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
        }
        @finally {
            
        }

    }
     
}


- (void)getGpsMode:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = command.callbackId;

     NSString*  STSTUS  = @"UNKNOEN";
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        // user allowed
        STSTUS = @"kCLAuthorizationStatusDenied";
    }
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        // user allowed
        STSTUS = @"kCLAuthorizationStatusAuthorizedWhenInUse";
    }
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        // user allowed
        STSTUS = @"kCLAuthorizationStatusAuthorizedAlways";
    }
    
    CDVPluginResult *result;
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:STSTUS];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    
    //idan ofek - warring removal
//    [self.commandDelegate evalJs:[result toSuccessCallbackString:callbackId]];
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



@end
