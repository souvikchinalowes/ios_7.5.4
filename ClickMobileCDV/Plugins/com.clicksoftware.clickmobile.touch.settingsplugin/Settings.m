//
//  Settings.m
//  ClickMobileCDV
//
//  Created by ClickMobile Touch Team on 10/7/14.
//
//

#import "Settings.h"
#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVPluginResult.h>
#import "QSStrings.h"
#import <CoreLocation/CoreLocation.h>
#import "CDVFile.h"

@implementation Settings


- (void)getUrlSetting:(CDVInvokedUrlCommand*)command
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * url = [userDefaults stringForKey:@"url_preference"];
    
    NSString* callbackId = command.callbackId;
    
    CDVPluginResult * result = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsString: url];
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
//    NSString* jsString = [result toSuccessCallbackString:callbackId];
    
//    if (jsString)
//    {
//        [self.commandDelegate evalJs: jsString];
//    }
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
    //warning removel
//    NSString* jsString = [result toSuccessCallbackString:callbackId];
    
//    if (jsString)
//    {
//        [self writeJavascript: jsString];
//    }
}

- (void)setClearImagesSetting:(CDVInvokedUrlCommand*)command
{
    /*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"setClearImagesSetting" message:@"More info..." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Say Hello",nil];
    [alert show];
     */
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
    if (result) {
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];        
    }

        //warning removel
//    NSString* jsString = [result toSuccessCallbackString:callbackId];
//    
//    if (jsString)
//    {
//        [self writeJavascript: jsString];
//    }
}



- (void)getClearFilesSetting:(CDVInvokedUrlCommand*)command

{
    /*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"getClearFilesSetting" message:@"More info..." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Say Hello",nil];
    [alert show];
     */
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
            //[fileMgr release];
        }
        
    }
    
    CDVPluginResult * result = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsInt: resultValue];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    //warning removel
//    NSString* jsString = [result toSuccessCallbackString:callbackId];
//    
//    if (jsString)
//    {
//        [self writeJavascript: jsString];
//    }
}


@end
