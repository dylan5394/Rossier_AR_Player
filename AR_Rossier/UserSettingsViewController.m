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
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

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

-(IBAction)changePassword:(id)sender {
    
    [_firebaseDB changePasswordForUser:[_temp.keychain valueForKey:(id)kSecAttrAccount] fromOld:[_temp.keychain valueForKey:(id)kSecValueData]
                         toNew:@"batteryhorsestaplecorrect" withCompletionBlock:^(NSError *error) {
                             if (error) {
                                 // There was an error processing the request
                             } else {
                                 // Password changed successfully
                             }
                         }];
}

-(IBAction)logOut:(id)sender {
    
    
    //Log the user out and send them to the login view controller
    [_firebaseDB unauth];
    
    AppDelegate * temp = [[UIApplication sharedApplication] delegate];
    temp.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"loginVC"];
}

-(IBAction)deleteUser:(id)sender {
    
    [_firebaseDB removeUser:[_temp.keychain valueForKey:(id)kSecAttrAccount] password:[_temp.keychain valueForKey:(id)kSecValueData]
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
