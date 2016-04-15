//
//  AddTriggerViewController.m
//  AR_Rossier
//
//  Created by Dylan Kyle Davis on 2/19/16.
//  Copyright © 2016 AR_Rossier. All rights reserved.
//

#import "TriggerModel.h"
#import "AppDelegate.h"
#import <Firebase/Firebase.h>
#import "AddTriggerViewController.h"

@interface AddTriggerViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *linkTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@property (strong, nonatomic) TriggerModel * model;

@end

@implementation AddTriggerViewController {
    
    Firebase * _firebaseDB;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AppDelegate *temp = [[UIApplication sharedApplication]delegate];
    _firebaseDB = temp.firebaseDB;
    
    self.linkTextField.delegate=self;
    
    self.model = [TriggerModel sharedModel];
    
    //Add a gesture recognizer to dismiss the keyboard when a user taps outside of the keyboard field
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(hideKeyBoard)];
    
    [self.view addGestureRecognizer:tapGesture];
}

-(void)hideKeyBoard {
    
    if(self.linkTextField.isFirstResponder) {
        [self.linkTextField resignFirstResponder];
    }
    else if(self.descriptionTextField.isFirstResponder) {
        [self.descriptionTextField resignFirstResponder];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) enableSaveButtonForLink: (NSString *) linkText
                          image: (UIImage *) image{
    
    self.saveButton.enabled = (linkText.length>0 && image);
}

-(BOOL) textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    
    //Used to enable the save button if an image exists in the image view and a description of the trigger is provided
    if([textField isEqual:self.linkTextField]) {
     
        NSString * changedString = [textField.text
                                    stringByReplacingCharactersInRange:range
                                    withString:string];
        
        [self enableSaveButtonForLink: changedString
                                image: self.imageView.image];

    }
    
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    //get the selected image and set the imageview to that image
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    
    _imageView.image = originalImage;
    
    [self enableSaveButtonForLink:self.linkTextField.text image:originalImage];
    
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    //picker canceled, do nothing
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)addPhotoButtonTapped:(id)sender {
    
    //Launch an action sheet, then decide to launch photo roll or camera
    UIAlertController *actionSheet = [UIAlertController
                                      alertControllerWithTitle:nil
                                      message:nil
                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cameraAction = [UIAlertAction
                                   actionWithTitle:@"Take a new image"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                       
                                       
                                       UIImagePickerController * picker = [[UIImagePickerController alloc] init];
                                       
                                       picker.delegate = self;
                                       picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                       
                                       [self presentViewController:picker animated:YES completion:NULL];
                                       
                                       
                                   }];
    
    UIAlertAction *photoLibraryAction = [UIAlertAction
                                         actionWithTitle:@"Choose existing image"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *action) {
                                             
                                             
                                             UIImagePickerController * picker = [[UIImagePickerController alloc] init];
                                             
                                             picker.delegate = self;
                                             picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                             
                                             [self presentViewController:picker animated:YES completion:NULL];
                                             
                                             
                                         }];
    
    [actionSheet addAction:cameraAction];
    [actionSheet addAction:photoLibraryAction];
    
    UIPopoverPresentationController *popover = actionSheet.popoverPresentationController;
    if (popover)
    {
        popover.sourceView = sender;
        popover.sourceRect = [sender bounds];
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}

- (IBAction)cancelButtonTapped:(id)sender {
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
    
    if(self.completionHandler) {
        self.completionHandler(nil, nil, nil, nil);
    }
}

- (IBAction)addTriggerButtonTapped:(id)sender {
    
    //Convert the image to string type before adding
    UIImage * uploadImage = self.imageView.image;
    
    if(uploadImage.size.height>uploadImage.size.width) {
        
        UIGraphicsBeginImageContext(CGSizeMake(uploadImage.size.width, uploadImage.size.width));
        [uploadImage drawInRect:CGRectMake(0,0,uploadImage.size.width, uploadImage.size.width)];
        uploadImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    else {
        
        UIGraphicsBeginImageContext(CGSizeMake(uploadImage.size.height, uploadImage.size.height));
        [uploadImage drawInRect:CGRectMake(0,0,uploadImage.size.height, uploadImage.size.height)];
        uploadImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    NSLog(@"Height of chosen image: %f", uploadImage.size.height);
    NSLog(@"Width of chosen image: %f", uploadImage.size.width);
    
    NSData * testData = UIImageJPEGRepresentation(uploadImage, 1.0);
    NSLog(@"Size of uncompressed image: %lu bytes", (unsigned long)testData.length);
    
    NSData *imageData = UIImageJPEGRepresentation(uploadImage, 0.8);
    NSLog(@"Size of compressed image: %lu bytes", (unsigned long)imageData.length);
    
    NSString * base64String = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    if(self.completionHandler) {
        self.completionHandler(base64String, self.linkTextField.text, self.descriptionTextField.text, imageData);
    }
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
