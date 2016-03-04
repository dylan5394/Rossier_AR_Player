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

@interface TriggerModel : NSObject

+ (instancetype) sharedModel;
- (void)removeTrigger: (NSUInteger) index;
- (void)addTrigger: (NSDictionary *)newTrigger;
- (NSInteger) numTriggers;
- (void) updateData;
- (NSDictionary *) getTrigger: (NSUInteger) index;
- (NSMutableArray *) getArrayForDelegate;

@end
