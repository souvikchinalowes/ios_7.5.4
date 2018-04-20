//
//  CookiesUtility.h
//  ClickMobileCDV
//
//  Created by ClickMobile Touch Team on 11/23/15.
//
//

#import <Foundation/Foundation.h>

@interface CookiesUtility : NSObject
 
-(void)loadWebViewHTTPCookies;
-(void)saveWebViewHTTPCookies;
-(void)deleteAllWebViewCookies;
@end
