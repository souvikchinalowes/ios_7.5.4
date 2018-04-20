//
//  FilesPlugin.m
//  ClickMobileCDV
//
//  Created by ClickMobile Touch Team on 10/7/14.
//
//

#import "FilesPlugin.h"
#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVPluginResult.h>
#import "QSStrings.h"
#import <CoreLocation/CoreLocation.h>
#import "CDVFile.h"


@implementation FilesPlugin


typedef int FileError;

- (void) openWith:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult * pluginResult;
    NSString* callbackID = command.callbackId;
    
    NSString* path = [command.arguments objectAtIndex:0];
    
    
    
    NSString* uti = @"public.jpeg";
    
    
    
    //UTI
    NSDictionary *inventory = @{
                                @"jpg" : @"public.jpeg",
                                @"jpeg" : @"public.jpeg",
                                @"png" : @"public.png",
                                @"tif" : @"public.jpeg",
                                @"tiff" : @"public.jpeg",
                                @"pdf" : @"com.adobe.pdf",
                                @"doc" : @"com.microsoft.word.doc",
                                @"docx" : @"org.openxmlformats.wordprocessingml.document",
                                @"bmp" : @"com.microsoft.bmp",
                                @"xls" : @"com.microsoft.excel.xls",
                                @"ppt" : @"com.microsoft.powepoint.?ppt",
                                @"txt" : @"public.plain-text",
                                @"html" : @"public.html",
                                @"htm" : @"public.html",
                                @"xml" : @"public.xml",
                                @"xlsx" : @"org.openxmlformats.spreadsheetml.sheet",
                                @"gif" : @"com.compuserve.gif",
                                @"psd" : @"com.adobe.photoshop-?image",
                                };
//    const CFStringRef  kUTTagClassFilenameExtension ;
    
    //warning removal
//    CFStringRef fileExtension = (CFStringRef) [path pathExtension];
    //end-warning removal
    
    NSString *value = [inventory objectForKey:[path pathExtension]];
    //CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    //UTI
    
    
    NSURL* fileURL = [NSURL fileURLWithPath:path];
    //    NSURL *fileURL = [NSURL fileURLWithPath:localFile];
    NSLog(@"fileURL: %@",fileURL);
    UIDocumentInteractionController* controller = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    controller.delegate = self;
    controller.UTI = value;
    //    BOOL result = [controller presentPreviewAnimated:YES];
    
//    MainViewController* cont = (MainViewController*)[self viewController];
    
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
//    [self writeJavascript:[pluginResult toSuccessCallbackString:callbackID]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
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
//    NSString* callbackID = command.callbackId;
//    [callbackID retain];
    
    NSString* path = [command.arguments objectAtIndex:0];
//    [path retain];
    
    NSString* uti = [command.arguments objectAtIndex:1];
//    [uti retain];
    
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
//    warning removal
//    NSString* jsString = nil;
    
//    idan ofek - warning removeal
//    FileError errCode = INVALID_MODIFICATION_ERR;
    
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
                [self.commandDelegate sendPluginResult:result callbackId:callbackId];
                //warning removel
                //
//                jsString = [result toSuccessCallbackString:callbackId];
                
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
    }

    
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    
            //warning removel
//    if(!jsString) {
////        // was an error
////        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt: errCode cast: @"window.localFileSystem._castError"];
//        jsString = [result toErrorCallbackString:callbackId];
//    }
//    [self writeJavascript: jsString];
    
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









@end
