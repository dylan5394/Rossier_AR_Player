//
//  SignUpViewController.m
//  AR_Rossier
//
//  Created by Dylan Kyle Davis on 2/12/16.
//  Copyright © 2016 AR_Rossier. All rights reserved.
//

#import "SignUpViewController.h"
#import <Firebase/Firebase.h>

@interface SignUpViewController ()

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
