//
//  AddTriggerViewController.h
//  AR_Rossier
//
//  Created by Dylan Kyle Davis on 2/19/16.
//  Copyright © 2016 AR_Rossier. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AddTriggerCompletionHandler)(NSString * imageString,
                                           NSString * linkString,
                                           NSString * descriptionString,
                                           NSData * imageData);

@interface AddTriggerViewController : UIViewController

@property (copy, nonatomic) AddTriggerCompletionHandler completionHandler;

@end
