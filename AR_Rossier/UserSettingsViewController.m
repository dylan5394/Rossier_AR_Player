//
//  UserSettingsViewController.m
//  AR_Rossier
//
//  Created by Dylan Kyle Davis on 3/23/16.
//  Copyright © 2016 AR_Rossier. All rights reserved.
//

#import "AppDelegate.h"
#import <Firebase/Firebase.h>
#import "UserSettingsViewController.h"

@interface UserSettingsViewController ()

@end

@implementation UserSettingsViewController {
    
    Firebase * _firebaseDB;
    AppDelegate * _temp;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _temp = [[UIApplication sharedApplication]delegate];
    _firebaseDB = _temp.firebaseDB;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)changeEmail {
    
    [_firebaseDB changeEmailForUser:@"oldemail@firebase.com" password:@"correcthorsebatterystaple"
                 toNewEmail:@"newemail@firebase.com" withCompletionBlock:^(NSError *error) {
                     if (error) {
                         // There was an error processing the request
                     } else {
                         // Email changed successfully
                     }
                 }];
}

-(void)changePassword {
    
    [_firebaseDB changePasswordForUser:@"bobtony@example.com" fromOld:@"correcthorsebatterystaple"
                         toNew:@"batteryhorsestaplecorrect" withCompletionBlock:^(NSError *error) {
                             if (error) {
                                 // There was an error processing the request
                             } else {
                                 // Password changed successfully
                             }
                         }];
}

-(void)logOutUser {
    
    [_firebaseDB unauth];
    
    AppDelegate * temp = [[UIApplication sharedApplication] delegate];
    temp.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"loginVC"];
}

-(void)sendPasswordReset {
    
    [_firebaseDB resetPasswordForUser:@"bobtony@example.com" withCompletionBlock:^(NSError *error) {
        if (error) {
            // There was an error processing the request
        } else {
            // Password reset sent successfully
        }
    }];
}

-(void)deleteUser {
    
    [_firebaseDB removeUser:@"bobtony@example.com" password:@"correcthorsebatterystaple"
withCompletionBlock:^(NSError *error) {
    if (error) {
        // There was an error processing the request
    } else {
        // User deleted
    }
}];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
