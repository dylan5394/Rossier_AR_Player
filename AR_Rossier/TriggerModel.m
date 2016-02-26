//
//  TriggerModel.m
//  AR_Rossier
//
//  Created by Haley Lenner on 2/26/16.
//  Copyright © 2016 AR_Rossier. All rights reserved.
//

#import "TriggerModel.h"
#import "AppDelegate.h"

@interface TriggerModel()

@property (strong, nonatomic) NSMutableArray* triggers;
@property (weak, nonatomic) Firebase * firebaseDB;

@end

@implementation TriggerModel

- (id)init
{
    self = [super init];
    if (self) {
        _triggers = [[NSMutableArray alloc] init]; //initWithArray query firebase
        AppDelegate *temp = [[UIApplication sharedApplication]delegate];
        _firebaseDB = temp.firebaseDB;
        
        
    }
    return self;
}

+ (instancetype) sharedModel {
    static TriggerModel *_sharedModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedModel = [[self alloc] init];
    });
    return _sharedModel;
}
- (void)removeTrigger: (NSUInteger) index{
    //if greater than or equal to the size of array
    if (index >= self.triggers.count){
        NSLog(@"out of bounds");
    }
    [self.triggers removeObjectAtIndex:index];
};
- (void)addTrigger{
    //check API, query for images and get images
    
};
- (int) numTriggers{
    return (int) _triggers.count;
}
@end

