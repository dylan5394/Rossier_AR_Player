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
        
        self.triggers = [[NSMutableArray alloc] init]; //initWithArray query firebase
        AppDelegate *temp = [[UIApplication sharedApplication]delegate];
        self.firebaseDB = temp.firebaseDB;
        
        [[self.firebaseDB childByAppendingPath:@"images"] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            [self.triggers removeAllObjects];
            
            for(FDataSnapshot* child in snapshot.children) {
                
                NSDictionary * newTrigger = [[NSDictionary alloc] initWithObjectsAndKeys:
                                             child.value[@"description"], kDescription,
                                             child.value[@"media_link"], kLink,
                                             child.value[@"string"], kImageString,
                                             child.key, kAutoId,
                                             nil];
                [self.triggers addObject:newTrigger];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTriggerTable" object:nil];
            
        } withCancelBlock:^(NSError *error) {
            NSLog(@"%@", error.description);
        }];
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
    
    if (index >= self.triggers.count){
        NSLog(@"out of bounds");
    }
    
    Firebase * usersRef = [_firebaseDB childByAppendingPath:@"images"];
    Firebase * postRef = [usersRef childByAppendingPath:[self.triggers[index] valueForKey:kAutoId]];
    
    [postRef removeValue];
    [self.triggers removeObjectAtIndex:index];
}

- (void)addTrigger: (NSMutableDictionary*) newTrigger{
    
    //add the trigger locally to the array then add it to the database
    Firebase * usersRef = [_firebaseDB childByAppendingPath:@"images"];
    Firebase * postRef = [usersRef childByAutoId];
    
    [newTrigger setObject:postRef.key forKey:kAutoId];
    
    [postRef setValue:newTrigger];
    [self.triggers addObject:newTrigger];
    
}

- (NSInteger) numTriggers{
    
    return self.triggers.count;
}

- (NSDictionary *) getTrigger:(NSUInteger)index {
    
    return self.triggers[index];
}

@end

