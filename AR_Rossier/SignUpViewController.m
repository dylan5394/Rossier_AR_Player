//
//  SignUpViewController.m
//  AR_Rossier
//
//  Created by Dylan Kyle Davis on 2/12/16.
//  Copyright © 2016 AR_Rossier. All rights reserved.
//

#import "AppDelegate.h"
#import "SignUpViewController.h"
#import <Firebase/Firebase.h>

@interface SignUpViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation SignUpViewController {
    
    Firebase * _firebaseDB;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AppDelegate *temp = [[UIApplication sharedApplication]delegate];
    _firebaseDB = temp.firebaseDB;    
    
    //Resign the keyboard if a user taps outside of the text field or keyboard
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(hideKeyBoard)];
    
    [self.view addGestureRecognizer:tapGesture];
}

-(void)hideKeyBoard {
    
    if(self.emailField.isFirstResponder) {
        [self.emailField resignFirstResponder];
    }
    else if(self.passwordField.isFirstResponder) {
        [self.passwordField resignFirstResponder];
    }
    else if(self.nameField.isFirstResponder) {
        [self.nameField resignFirstResponder];
    }
}

- (IBAction)signUpTapped:(id)sender {
    
    //need to add error checking for email and password field
    [_firebaseDB createUser:self.emailField.text password:self.passwordField.text withValueCompletionBlock:^(NSError *error, NSDictionary *result) {
     if (error) {
         // There was an error creating the account
         NSLog(@"There was an error creating the account");
     } else {
         NSString *uid = [result objectForKey:@"uid"];
         NSLog(@"Successfully created user account with uid: %@", uid);
         
         AppDelegate *temp = [[UIApplication sharedApplication]delegate];

         [temp.keychain setObject:self.emailField.text forKey:(id)kSecAttrAccount];
         [temp.keychain setObject:self.passwordField.text forKey:(id)kSecValueData];
         
         temp.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
     }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
