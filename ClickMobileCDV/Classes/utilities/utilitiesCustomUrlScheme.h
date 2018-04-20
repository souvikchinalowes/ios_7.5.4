//
//  utilitiesCustomUrlScheme.h
//  ClickMobileCDV
//
//  Created by ClickMobile Touch Team on 5/12/15.
//
//

#import <Foundation/Foundation.h>

//class - utillity class to handle with the process of saveing / retriving
//custom paramters from custom uri/url
//as to custom scheme with "clickMobileCustom"

@interface utilitiesCustomUrlScheme : NSObject

    @property(nonatomic,strong) NSString *nameSpaceToSaveToDisk;
    @property(nonatomic,strong) NSString *nameSpaceLastOpenAppFromUri;
    @property(nonatomic,strong) NSString *nameSpaceOpenAppFromUri;

    @property(nonatomic,strong) NSUserDefaults *userDefaults;

    -(void)saveToUserDefaultQueryParamAsString:(NSString*)queryString querySpliter:(NSString*)querySpliter;

    -(void)addParamFromUriQuery:(NSString*)keyParamter valueParam:(NSString*)valueParamter;

    -(NSString*)getParamFromUriQuery:(NSString*)nameParamter;

    -(NSDictionary*)getAllParamtersThatMatchPreix:(NSString *)prefixCustomUri;

    -(void)cleanUserDefaultsThatMatchPrefix:(NSString *)prefixCustomUri;

@end
