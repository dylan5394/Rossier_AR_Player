//
//  TriggerModel.h
//  AR_Rossier
//
//  Created by Haley Lenner on 2/26/16.
//  Copyright © 2016 AR_Rossier. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kDescription = @"description";
static NSString * const kLink = @"media_link";
static NSString * const kImageString = @"string";
static NSString * const kAutoId = @"autoid";

static NSString * const kAdd = @"add";
static NSString * const kRemove = @"remove";

@interface TriggerModel : NSObject

+ (instancetype) sharedModel;
- (void)removeTrigger: (NSUInteger) index;
- (void)addTrigger: (NSMutableDictionary *)newTrigger withImageData: (NSData *) imageData;
- (NSInteger) numTriggers;
- (NSDictionary *) getTrigger: (NSUInteger) index;

@end
