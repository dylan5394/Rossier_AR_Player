//
//  ImageRecognitionViewController.m
//  AR_Rossier
//
//  Created by Dylan Kyle Davis on 2/12/16.
//  Copyright © 2016 AR_Rossier. All rights reserved.
//

#import "AppDelegate.h"
#import "PRARManager.h"
#import "ImageRecognitionViewController.h"

#include <stdlib.h>

#define NUMBER_OF_POINTS    20

static int kMSResultTypes = MSResultTypeImage | MSResultTypeQRCode | MSResultTypeEAN13;

@interface ImageRecognitionViewController () <MSAutoScannerSessionDelegate, UIActionSheetDelegate, PRARManagerDelegate>

@property (weak, nonatomic) IBOutlet UIView *videoPreview;

@property (strong, nonatomic) PRARManager * prARManager;

@end

@implementation ImageRecognitionViewController {
    
    MSAutoScannerSession *_scannerSession;
    MSScanner *_scanner;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
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
    
    
    self.prARManager = [[PRARManager alloc] initWithSize:self.videoPreview.frame.size delegate:self showRadar:false captureLayer:captureLayer];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //CLLocationCoordinate2D locationCoordinates = CLLocationCoordinate2DMake(0.0,0.0);
    //[self.prARManager startARWithData:[self getDummyData] forLocation:locationCoordinates];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    //[self.prARManager stopAR];
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
    [self updateInterfaceOrientation:self.interfaceOrientation];
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
    /*
    NSString *title = [result type] == MSResultTypeImage ? @"Image" : @"Barcode";
    NSString *message = [NSString stringWithFormat:@"%@:\n%@", title, [result string]];
    UIActionSheet *aSheet = [[UIActionSheet alloc] initWithTitle:message
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:nil];
    [aSheet showInView:self.view];
     */
    [self performSegueWithIdentifier:@"imageFound" sender:self];
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

/*
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [_scannerSession resumeProcessing];
}
 */

#pragma mark - Dummy data

-(NSArray*)getDummyData
{
    NSMutableArray *points = [NSMutableArray arrayWithCapacity:NUMBER_OF_POINTS];
    
    srand48(time(0));
    for (int i=0; i<NUMBER_OF_POINTS; i++)
    {
        CLLocationCoordinate2D pointCoordinates = [self getRandomLocation];
        NSDictionary *point = [self createPointWithId:i at:pointCoordinates];
        [points addObject:point];
    }
    
    return [NSArray arrayWithArray:points];
}

-(CLLocationCoordinate2D)getRandomLocation
{
    double latRand = drand48() * 90.0;
    double lonRand = drand48() * 180.0;
    double latSign = drand48();
    double lonSign = drand48();
    
    CLLocationCoordinate2D locCoordinates = CLLocationCoordinate2DMake(latSign > 0.5 ? latRand : -latRand,
                                                                       lonSign > 0.5 ? lonRand*2 : -lonRand*2);
    return locCoordinates;
}

// Creates the Data for an AR Object at a given location
-(NSDictionary*)createPointWithId:(int)the_id at:(CLLocationCoordinate2D)locCoordinates
{
    NSDictionary *point = @{
                            @"id" : @(the_id),
                            @"title" : [NSString stringWithFormat:@"Link/Video/Photo %d", the_id],
                            @"lon" : @(locCoordinates.longitude),
                            @"lat" : @(locCoordinates.latitude)
                            };
    return point;
}

#pragma mark - PRAR delegate methods

-(void)prarDidSetupAR:(UIView *)arView withCameraLayer:(AVCaptureVideoPreviewLayer *)cameraLayer {
    
    /*
     CALayer *videoPreviewLayer = [self.videoPreview layer];
     [videoPreviewLayer setMasksToBounds:YES];
     
     CALayer *captureLayer = [_scannerSession captureLayer];
     [captureLayer setFrame:[self.videoPreview bounds]];
     
     [videoPreviewLayer insertSublayer:captureLayer
     below:[[videoPreviewLayer sublayers] objectAtIndex:0]];
     
     [self.view.layer addSublayer:cameraLayer];
     [self.view addSubview:arView];
     
     [self.view bringSubviewToFront:[self.view viewWithTag:AR_VIEW_TAG]];
     */
    
    NSLog(@"Displaying AR now");
    
    [self.videoPreview.layer addSublayer:cameraLayer];
    [self.videoPreview addSubview:arView];
    [self.videoPreview bringSubviewToFront:[self.videoPreview viewWithTag:AR_VIEW_TAG]];
}

-(void)prarUpdateFrame:(CGRect)arViewFrame {
    
    [[self.videoPreview viewWithTag:AR_VIEW_TAG] setFrame:arViewFrame];
}

-(void) prarGotProblem:(NSString *)problemTitle withDetails:(NSString *)problemDetails {
    
    NSLog(@"Problem happened");
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
