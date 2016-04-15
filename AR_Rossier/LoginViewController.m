//
//  LoginViewController.m
//  AR_Rossier
//
//  Created by Dylan Kyle Davis on 2/8/16.
//  Copyright © 2016 AR_Rossier. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LoginViewController{
    
    Firebase * _firebaseDB;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AppDelegate *temp = [[UIApplication sharedApplication]delegate];
    _firebaseDB = temp.firebaseDB;
    
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)LoginButtonTapped:(id)sender {
    
    [_firebaseDB authUser:self.emailField.text password:self.passwordField.text withCompletionBlock:^(NSError *error, FAuthData *authData) {
            if (error) {
                // There was an error logging in to this account
                NSLog(@"There was in error logging in");
                
                //We should add text (using UILabel most likely) to the view that says incorrect username or password
            
            } else {
                // We are now logged in
                NSLog(@"Login was successful");
                
                AppDelegate * temp = [[UIApplication sharedApplication] delegate];
                temp.expirationToken = authData.expires;
                
                //change this to store in the keychain
                [temp.keychain setObject:self.emailField.text forKey:(id)kSecAttrAccount];
                [temp.keychain setObject:self.passwordField.text forKey:(id)kSecValueData];
                
                temp.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
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
