//
//  UtilitiesCheck.m
//  ClickMobile819CDV
//
//  Created by ClickMobile Touch Team on 1/7/15.
//  Copyright (c) 2015 ClickSoftware. All rights reserved.
//

#import "UtilitiesCheck.h"

@implementation UtilitiesCheckUrl
@synthesize targerUrl;

/**
 *  cto'r - init with base url & clip http from traget url param
 *
 *  @param url - given url param
 *
 *  @return self object
 */
-(id)initWithUrlString:(NSString*)url
{
    if (self=[super init]) {
        targerUrl=[url lowercaseString];
        [self clipHttpOrHttps];
    }
    return self;
}
/**
 *  Method - clip http/https from the url
 *
 *  @return url without http/https
 */
-(NSString*)clipHttpOrHttps
{
    return [[targerUrl stringByReplacingOccurrencesOfString:@"https://" withString:@""] stringByReplacingOccurrencesOfString:@"http://" withString:@""];
}

/**
 *  Method - clip all string after question mark;
 *
 *  @return url without question mark
 */
-(NSString*)clipAfterLastQuestionMark
{
    
    if ([targerUrl rangeOfString:@"?"].location != NSNotFound) {
        return [targerUrl substringWithRange:[targerUrl rangeOfString:@"?" options:NSBackwardsSearch]];
    }
    return targerUrl;
    
}

/**
 *  Mehtod - clip all string after last slash
 *
 *  @return url without last slash
 */
-(NSString*)clipAfterLastSlash
{
    if ([targerUrl rangeOfString:@"/"].location != NSNotFound) {
        return [targerUrl substringWithRange:[targerUrl rangeOfString:@"/" options:NSBackwardsSearch]];
    }
    return targerUrl;
}
@end
