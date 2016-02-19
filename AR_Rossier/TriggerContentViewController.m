//
//  TriggerContentViewController.m
//  AR_Rossier
//
//  Created by Dylan Kyle Davis on 2/19/16.
//  Copyright © 2016 AR_Rossier. All rights reserved.
//

#import "TriggerContentViewController.h"

@interface TriggerContentViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation TriggerContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL * url = [NSURL URLWithString:@"https://www.youtube.com/watch?v=GBKy-hSedg8"];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    
    [self.webView loadRequest:request];
}

- (void) webViewDidStartLoad: (UIWebView *) webView{
    
    [self.activityIndicator startAnimating];
}

- (void) webViewDidFinishLoad: (UIWebView *) webView{
    
    [self.activityIndicator stopAnimating];
}

- (void) webView: (UIWebView *) webView
didFailLoadWithError:(nullable NSError *)error {
    
    [self.activityIndicator stopAnimating];
}

- (void) viewWillDisappear:(BOOL)animated {
    
    if([self.webView isLoading]) {
        
        [self.webView stopLoading];
    }
    
    //self.webView.delegate = nil;
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
