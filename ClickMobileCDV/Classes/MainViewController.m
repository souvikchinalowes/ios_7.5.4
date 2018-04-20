/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

//
//  MainViewController.h
//  ClickMobileCDV
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "MainViewController.h"
#import "UtilitiesCheck.h"
#import "CookiesUtility.h" //CookiePersistency Support


@implementation MainViewController

@synthesize  _CookiesUtility; //CookiePersistency Support

UIActivityIndicatorView *activity;

NSString *clickMobileWeb = @"clickmobileweb";


- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Uncomment to override the CDVCommandDelegateImpl used
        // _commandDelegate = [[MainCommandDelegate alloc] initWithViewController:self];
        // Uncomment to override the CDVCommandQueue used
        // _commandQueue = [[MainCommandQueue alloc] initWithViewController:self];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Uncomment to override the CDVCommandDelegateImpl used
        // _commandDelegate = [[MainCommandDelegate alloc] initWithViewController:self];
        // Uncomment to override the CDVCommandQueue used
        // _commandQueue = [[MainCommandQueue alloc] initWithViewController:self];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark View lifecycle

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    //ßself.webView.delegate=self;
    
    //init UIActivityIndicatorView - only once
    //Idan Ofek - Bug 68503 - don't show activity indacator
    if(activity == nil)
    {
        activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activity.center=self.view.center;
        
        [self.view addSubview:activity];
        [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [self.view addSubview:activity];
        CGAffineTransform transform = CGAffineTransformMakeScale(2.5f, 2.5f);
        activity.transform = transform;
    }
    
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    //[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    
    //self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    //[self setNeedsStatusBarAppearanceUpdate];
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    // Tal #76742 - return YES for supported prientations
    
    //return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    return YES;
}

/* Comment out the block below to over-ride */

/*
 - (UIWebView*) newCordovaViewWithFrame:(CGRect)bounds
 {
 return[super newCordovaViewWithFrame:bounds];
 }
 */

#pragma mark check for URL
/**
 *  method check url/url settings comapre logic [describe in method]
 *
 *  @param Url        - given url from web view
 *  @param UrlSetting - url from setting
 *
 *  @return true/false as accourd for logic
 */
-(BOOL)checkURLLgoic:(NSString*)Url :(NSString *)UrlSetting
{
    UtilitiesCheckUrl *_UrlWithoutHttp = [[UtilitiesCheckUrl alloc] initWithUrlString:Url];
    return [[_UrlWithoutHttp targerUrl] rangeOfString:clickMobileWeb].location != NSNotFound;
}
#pragma mark -


/**
 *  Method - hold from draw native select file
 *
 *  @param viewControllerToPresent
 *  @param flag
 *  @param completion
 */
-(void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    int64_t delayTime = .5;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayTime* NSEC_PER_USEC), dispatch_get_main_queue(),
                   ^{
                       [super presentViewController:viewControllerToPresent animated:flag completion:completion];
                   });
}

@end

@implementation MainCommandDelegate

/* To override the methods, uncomment the line in the init function(s)
 in MainViewController.m
 */

#pragma mark CDVCommandDelegate implementation

- (id)getCommandInstance:(NSString*)className
{
    return [super getCommandInstance:className];
}

/*
 NOTE: this will only inspect execute calls coming explicitly from native plugins,
 not the commandQueue (from JavaScript). To see execute calls from JavaScript, see
 MainCommandQueue below
 */

- (NSString*)pathForResource:(NSString*)resourcepath;
{
    return [super pathForResource:resourcepath];
}

@end

@implementation MainCommandQueue

/* To override, uncomment the line in the init function(s)
 in MainViewController.m
 */
- (BOOL)execute:(CDVInvokedUrlCommand*)command
{
    return [super execute:command];
}

@end
