//
//  ImageRecognitionViewController.m
//  AR_Rossier
//
//  Created by Dylan Kyle Davis on 2/12/16.
//  Copyright © 2016 AR_Rossier. All rights reserved.
//

#import "AppDelegate.h"
#import "ImageRecognitionViewController.h"
#import "TriggerModel.h"
#import "TriggerContentViewController.h"

#include <stdlib.h>

#define NUMBER_OF_POINTS    20

static int kMSResultTypes = MSResultTypeImage | MSResultTypeQRCode | MSResultTypeEAN13;

@interface ImageRecognitionViewController () <MSAutoScannerSessionDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *videoPreview;
@property (strong, nonatomic) TriggerModel * model;
@property (strong, nonatomic) NSString * clickedLink;

@end

@implementation ImageRecognitionViewController {
    
    MSAutoScannerSession *_scannerSession;
    MSScanner *_scanner;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.model = [TriggerModel sharedModel];
    
    _scanner = [(AppDelegate *)[[UIApplication sharedApplication] delegate] scanner];
    
    _scannerSession = [[MSAutoScannerSession alloc] initWithScanner:_scanner];
    
    _scannerSession.delegate = self;
    
    _scannerSession.resultTypes = kMSResultTypes;
    
    CALayer *videoPreviewLayer = [self.videoPreview layer];
    [videoPreviewLayer setMasksToBounds:YES];
    
    CALayer *captureLayer = [_scannerSession captureLayer];
    [captureLayer setFrame:[self.videoPreview bounds]];
    
    [videoPreviewLayer insertSublayer:captureLayer
                                below:[[videoPreviewLayer sublayers] objectAtIndex:0]];
    
    [_scannerSession startRunning];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

-(void) dealloc {
    
    [_scannerSession stopRunning];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_scannerSession resumeProcessing];
}

- (void)viewWillLayoutSubviews
{
    [self updateInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:orientation duration:duration];
    [self updateInterfaceOrientation:orientation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)session:(id)scannerSession didFindResult:(MSResult *)result
{
    NSString *title = [result type] == MSResultTypeImage ? @"Image" : @"Barcode";
    NSString *message = [NSString stringWithFormat:@"%@:\n%@", title, [result string]];
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:message
                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    //Find the correct trigger that was recognized
    for(int i =0; i < [self.model numTriggers]; i ++) {
        
        //Create an action sheet button leading to a link for each link that is associated with the trigger
        if([[self.model getTrigger:i][kAutoId] isEqualToString:[result string]]) {
            
            for(NSString* link in [self.model getTrigger:i][kLink]) {
                
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:link
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                         self.clickedLink = title;
                                         [self performSegueWithIdentifier:@"imageFound" sender:self];
                                         
                                     }];
                [alert addAction:ok];
            }
        }
    }
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 [_scannerSession resumeProcessing];
                                 
                             }];
    
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)updateInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [_scannerSession setInterfaceOrientation:interfaceOrientation];
    
    AVCaptureVideoPreviewLayer *captureLayer = (AVCaptureVideoPreviewLayer *) [_scannerSession captureLayer];
    
    captureLayer.frame = self.view.bounds;
    
    // AVCapture orientation is the same as UIInterfaceOrientation
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            [[captureLayer connection] setVideoOrientation:AVCaptureVideoOrientationPortrait];
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            [[captureLayer connection] setVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
            break;
        case UIInterfaceOrientationLandscapeLeft:
            [[captureLayer connection] setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
            break;
        case UIInterfaceOrientationLandscapeRight:
            [[captureLayer connection] setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
            break;
        default:
            break;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    TriggerContentViewController * nextVC = [segue destinationViewController];
    nextVC.link = self.clickedLink;
}


@end
