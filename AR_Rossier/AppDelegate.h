//
//  AppDelegate.h
//  AR_Rossier
//
//  Created by Haley Lenner on 2/5/16.
//  Copyright © 2016 AR_Rossier. All rights reserved.
//

#import "KeychainItemWrapper.h"
#import <UIKit/UIKit.h>
#import <Moodstocks/Moodstocks.h>
#import <Firebase/Firebase.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MSScanner *scanner;
@property (strong, nonatomic) Firebase * firebaseDB;
@property (strong, nonatomic) NSNumber * expirationToken;
@property (strong, nonatomic) NSString * cacheFilePath;
@property (strong, nonatomic) KeychainItemWrapper * keychain;

@end

