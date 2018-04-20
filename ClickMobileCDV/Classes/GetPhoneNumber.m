//
//  GetPhoneNumber.m
//  ClickMobileCDV
//
//  Created by China, Souvik - Souvik on 08/03/18.
//

#import "GetPhoneNumber.h"
#import "MainViewController.h"
#import "ClickMobilePlugin.h"

static NSString * const kConfigurationKey = @"com.apple.configuration.managed";
static NSString * const kConfigurationServerURLKey = @"DeviceUdid";


@implementation GetPhoneNumber

- (void)getPhoneNumber
{
    // Set up an autorelease pool here if not using garbage collection.
    __block BOOL isSuccess = NO;
    __block int count = 0;
    // Add your sources or timers to the run loop and do any other setup.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *serverConfig = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kConfigurationKey];
    NSString *DeviceUdid = serverConfig[kConfigurationServerURLKey];
    NSLog(@"DeviceUdid : %@",DeviceUdid);
    
    do
    {
        // Start the run loop but return after each source is handled.
        SInt32 result = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1, YES);
        
        // If a source explicitly stopped the run loop, or if there are no
        // sources or timers, go ahead and exit.
        if ((result == kCFRunLoopRunStopped) || (result == kCFRunLoopRunFinished))
            isSuccess = YES;
        
        __block NSString *phoneNum = @"";
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://aw.lowes.com/apps/deviceoperations.aspx?DeviceUDID=%@&Operation=info&RestAPIKey=1EVAA4AAAAG5A4CQCEAA", DeviceUdid]];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response,
                                                   NSData *data, NSError *connectionError)
         {
             
//             NSLog(@"Web Service Response: %@", data);
             
             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
             long statusCode = (long)[httpResponse statusCode];
             NSLog(@"response status code: %ld", statusCode);
             count++;
             if (data.length > 0 && connectionError == nil)
             {
                 NSDictionary *deviceoperations = [NSJSONSerialization JSONObjectWithData:data
                                                                                  options:0
                                                                                    error:NULL];
                 NSLog(@"JSON data: %@", deviceoperations);
                 isSuccess = YES;
                 if (deviceoperations != nil) {
                     phoneNum = [deviceoperations objectForKey:@"PhoneNumber"];
                     NSLog(@"{MainViewController} Phone Number from webservice: %@", phoneNum);
                     [defaults setValue:phoneNum forKey:@"settingsPhoneNumber"];
                 }else{
                     phoneNum = @"1234098765";
                     NSLog(@"{MainViewController} Phone Number from webservice: %@", phoneNum);
                     [defaults setValue:phoneNum forKey:@"settingsPhoneNumber"];
                     if (count == 1) {
                         //[self displayError: statusCode];
                         NSLog(@"Status code from Response is: %ld",statusCode);
                     }
                 }
             }
         }];
        
        // Check for any other exit conditions here and set the
        // done variable as needed.
    }
    while (!isSuccess);
    
    // Clean up code here. Be sure to release any allocated autorelease pools.
    
    
}

-(void) displayError:(long *)errorCode{
    NSString *errorMessage = @"";
    if (errorCode == (long *)500) {
        errorMessage = @"Status code from Response is: 500";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"!Warning" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}
@end
