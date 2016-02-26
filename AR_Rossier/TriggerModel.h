//
//  TriggerModel.h
//  AR_Rossier
//
//  Created by Haley Lenner on 2/26/16.
//  Copyright © 2016 AR_Rossier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TriggerModel : NSObject

- (int) value;
+ (instancetype) sharedModel;
- (void)removeTrigger;
- (void)addTrigger;
- (int) numTriggers;
- (void) updateData;

//remove
//add
//numTriggers


@end
