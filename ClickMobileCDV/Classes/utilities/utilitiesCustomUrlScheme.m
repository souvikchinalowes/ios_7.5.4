//
//  utilitiesCustomUrlScheme.m
//  ClickMobileCDV
//
//  Created by ClickMobile Touch Team on 5/12/15.
//
//

#import "utilitiesCustomUrlScheme.h"

@implementation utilitiesCustomUrlScheme
@synthesize
nameSpaceToSaveToDisk,userDefaults
,nameSpaceLastOpenAppFromUri,nameSpaceOpenAppFromUri;

//Init - update property nameSpaceToSaveToDisk to custom uri
-(id)init
{
    if (self = [super init]) {
        nameSpaceToSaveToDisk = @"custom.uri.";
        nameSpaceOpenAppFromUri = @"openAppFromUri";
        nameSpaceLastOpenAppFromUri =@"lastOpenAppFromUri";
        userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

///Method - split key & value from paramter
///paramters:
///1.param - the given param
-(NSArray*)splitQueryParamIntoKeyAndValue:(NSString *)param
{
    NSString *equalQueryChar = @"=";
    return [param componentsSeparatedByString:equalQueryChar];
}

///Method - get a query string with paramters,
///paramters:
///1.queryString - the full query string
///2.querySpliter - the split param
-(void)saveToUserDefaultQueryParamAsString:(NSString*)queryString querySpliter:(NSString*)querySpliter;
{
    //remove all custom uri from user defaults
    [self cleanUserDefaultsThatMatchPrefix:[self nameSpaceToSaveToDisk] ];
    //end-remove all custom uri from user defaults
    
    for (NSString *param in [queryString componentsSeparatedByString:querySpliter]) {
        //split the query param into name & value
        
        NSArray *keyValue =  [self splitQueryParamIntoKeyAndValue:param];
        
//      count must be equal == 2
        if ([keyValue count]==2) {
            
            [self addParamFromUriQuery:
             [nameSpaceToSaveToDisk stringByAppendingString:
                            [keyValue objectAtIndex:0]]
                            valueParam:[keyValue objectAtIndex:1]
             ];
        }
    }
}

///Method - set a param in user default
///paramters:
///1.keyParamter - name of param
///2.valueParamter - value of param
-(void)addParamFromUriQuery:(NSString*)keyParamter valueParam:(NSString*)valueParamter
{
    [userDefaults removeObjectForKey:keyParamter];
    [userDefaults setObject:valueParamter forKey:keyParamter];
    NSLog(@"add key : %@ value : %@",keyParamter,valueParamter);
    [userDefaults synchronize];
}

///Method - return a string paramter from userDefault
///paramters:
///1.nameParamter - name of param to grab from the user default
-(NSString*)getParamFromUriQuery:(NSString*)nameParamter
{
    @try {
        return [userDefaults stringForKey:nameParamter];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }

    return nil;
}


//Method - return a array of - custom uri namespaceing - after a matching of prefix paramter
//paramter:
//1.prefixCustomUri - the prefix of paramters to find in the user defaults
-(NSDictionary*)getAllParamtersThatMatchPreix:(NSString *)prefixCustomUri
{
    @try
    {
        NSPredicate *predicatePrefixCustomUri =
            [NSPredicate predicateWithFormat:@"(SELF contains[cd] %@)", prefixCustomUri];
        
        NSArray *userDefaultsKeysArr =[[[userDefaults dictionaryRepresentation] allKeys]
                         filteredArrayUsingPredicate:predicatePrefixCustomUri];
        
        NSMutableDictionary *returnArr = [[NSMutableDictionary alloc] init];
        
        for (NSString *key in userDefaultsKeysArr) {
//            returnArr@[key] = [userDefaults stringForKey:key];
//            [returnArr setValue:[userDefaults stringForKey:key] forKey:key];
            [returnArr setObject:[userDefaults stringForKey:key] forKey:key];
        }
        
        return returnArr;
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }

    return NULL;
}

//Method - clean user defaults - custom uri namespaceing - after a matching of prefix paramter
//paramter:
//1.prefixCustomUri - the prefix of paramters to find in the user defaults
-(void)cleanUserDefaultsThatMatchPrefix:(NSString *)prefixCustomUri
{
    
    @try {
        
        NSPredicate *predicatePrefixCustomUri =
        [NSPredicate predicateWithFormat:@"(SELF contains[cd] %@)", prefixCustomUri];
        
        for (NSString *serachedKey in [[[userDefaults dictionaryRepresentation] allKeys]
                                  filteredArrayUsingPredicate:predicatePrefixCustomUri]) {
            
            [userDefaults removeObjectForKey:serachedKey];
        }

    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }

}

@end
