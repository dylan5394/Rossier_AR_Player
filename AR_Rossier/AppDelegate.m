//
//  AppDelegate.m
//  AR_Rossier
//
//  Created by Haley Lenner on 2/5/16.
//  Copyright © 2016 AR_Rossier. All rights reserved.
//

#import "TriggerModel.h"
#import "ImageRecognitionViewController.h"
#import "AppDelegate.h"
#import <Moodstocks/Moodstocks.h>

#define MS_API_KEY    @"85qwth1qw8xr7sc89wph"
#define MS_API_SECRET @"QTQtOUrILbGaQ85n"

NSString * const kToken = @"token";

@interface AppDelegate ()

@property (strong, nonatomic) NSMutableArray * info;
@property BOOL isLoggedIn;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    //Set the launch screen as the initial view so that the user isn't looking at the main app while their credentials are verified
    UIStoryboard *launchBoard = [UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIViewController *launchVC = [launchBoard instantiateInitialViewController];
    self.window.rootViewController = launchVC;
    [self.window makeKeyAndVisible];
    
    
    //Initialize the keychain
    self.keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"ITP342.AR-Rossier.password" accessGroup:nil];
    [self.keychain setObject:(id)kSecAttrAccessibleWhenUnlocked forKey:(id)kSecAttrAccessible];
    
    //Sync with the moodstocks database and load the images in that database into our scanner
    self.firebaseDB = [[Firebase alloc] initWithUrl:@"https://usc-rossier-ar.firebaseio.com"];
    NSString *path = [MSScanner cachesPathFor:@"scanner.db"];
    _scanner = [[MSScanner alloc] init];
    [_scanner openWithPath:path key:MS_API_KEY secret:MS_API_SECRET error:nil];
    
    //Set completion block for when the sync finishes
    void (^completionBlock)(MSSync *, NSError *) = ^(MSSync *op, NSError *error) {
        if (error)
            NSLog(@"Sync failed with error: %@", [error ms_message]);
        else
            NSLog(@"Sync succeeded (%li images(s))", (long)[_scanner count:nil]);
    };
    
    void (^progressionBlock)(NSInteger) = ^(NSInteger percent) {
        NSLog(@"Sync progressing: %li%%", (long)percent);
    };
    
    // Launch the synchronization
    [_scanner syncInBackgroundWithBlock:completionBlock progressBlock:progressionBlock];
    
    //Read from the token storage file
    NSLog(@"Checking token.plist file for an auth token");
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    NSLog(@"%@", documentsDirectory);
    self.tokenFilePath = [documentsDirectory stringByAppendingPathComponent:@"Token.plist"];
    self.cacheFilePath = [NSString stringWithString:[documentsDirectory stringByAppendingPathComponent:@"Cache.plist"]];
    self.info = [NSMutableArray arrayWithContentsOfFile:self.tokenFilePath];
    
    //check to see if a token exists, try to authenticate it if it does
    if(self.info && self.info.count == 1) {
        [self.firebaseDB authWithCustomToken:[self.info[0] valueForKey:kToken] withCompletionBlock:^(NSError *error, FAuthData *authData) {
            
            NSString * storyboardID;
            if (error) {
                storyboardID = @"loginVC";
                NSLog(@"Login Failed, sending user to the loginVC! %@", error);
                
            } else {
                storyboardID = @"mainVC";
                NSLog(@"Login succeeded, sending the user straight to the mainVC! %@", authData);
            }
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            UIViewController *initViewController = [storyboard instantiateViewControllerWithIdentifier:storyboardID];
            self.window.rootViewController = initViewController;
            [self.window makeKeyAndVisible];
        }];
    }
    else {
        
        NSLog(@"There was no token found for this user");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        UIViewController *initViewController = [storyboard instantiateViewControllerWithIdentifier:@"loginVC"];
        self.window.rootViewController = initViewController;
        [self.window makeKeyAndVisible];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    FAuthData * authData = [self.firebaseDB authData];
    if (authData) {
        NSLog(@"Authenticated user with uid: %@", authData.uid);
    }
    else {
        //make the user login again if their token expired while the app was backgrounded
        NSLog(@"The token has expired, must login again");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        UIViewController *initViewController = [storyboard instantiateViewControllerWithIdentifier:@"loginVC"];
        self.window.rootViewController = initViewController;
        [self.window makeKeyAndVisible];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [_scanner close:nil];
    
    //Cache the trigger array so we dont need to wait for a database query next login
    NSMutableArray * cacheArray = [[NSMutableArray alloc] init];
    TriggerModel * tempModel = [TriggerModel sharedModel];
    for(NSUInteger i = 0; i < [tempModel numTriggers]; i++) {
        
        [cacheArray addObject:[tempModel getTrigger:i]];
    }
    [cacheArray writeToFile:self.cacheFilePath atomically:YES];
    
    //persist the current user's token to documents folder if they exit the app
    if(self.firebaseDB.authData) {
        [self.info removeAllObjects];
        NSLog(@"Saving the auth token and exiting the app");
        NSDictionary * newDict = [[NSDictionary alloc] initWithObjectsAndKeys:self.firebaseDB.authData.token, kToken, nil];
        [self.info addObject:newDict];
        [self.info writeToFile:self.tokenFilePath atomically:YES];
    }
}

@end
