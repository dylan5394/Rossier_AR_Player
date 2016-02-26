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
    
    _firebaseDB = [[Firebase alloc] initWithUrl:@"https://usc-rossier-ar.firebaseio.com"];
    // Write data to Firebase
    [_firebaseDB setValue:@"Do you have data? You'll love Firebase."];
    
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
    
    AppDelegate *appDelegateTemp = [[UIApplication sharedApplication]delegate];
    
    appDelegateTemp.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
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
