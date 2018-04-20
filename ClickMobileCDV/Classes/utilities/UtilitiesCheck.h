//
//  UtilitiesCheck.h
//  ClickMobileCDV
//
//  Created by ClickMobile Touch Team on 1/11/15.
//
//

#import <Foundation/Foundation.h>

@interface UtilitiesCheckUrl : NSObject
@property(nonatomic,strong) NSString *targerUrl;
-(id)initWithUrlString:(NSString*)url;
-(NSString*)clipHttpOrHttps;
-(NSString*)clipAfterLastQuestionMark;
-(NSString*)clipAfterLastSlash;
@end
