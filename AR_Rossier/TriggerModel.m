//
//  TriggerModel.m
//  AR_Rossier
//
//  Created by Haley Lenner on 2/26/16.
//  Copyright © 2016 AR_Rossier. All rights reserved.
//

#import "TriggerModel.h"
#import "AppDelegate.h"
#import <Moodstocks/Moodstocks.h>

#define MS_API_KEY    @"85qwth1qw8xr7sc89wph"
#define MS_API_SECRET @"QTQtOUrILbGaQ85n"

@interface TriggerModel() <NSURLSessionDelegate>

@property (strong, nonatomic) NSMutableArray* triggers;
@property (weak, nonatomic) Firebase * firebaseDB;

@end

@implementation TriggerModel

- (id)init
{
    self = [super init];
    if (self) {
        
        self.triggers = [[NSMutableArray alloc] init];
        AppDelegate *temp = [[UIApplication sharedApplication]delegate];
        self.firebaseDB = temp.firebaseDB;
        
        //Pull the firebase DB data and add it one by one into the array in this model
        [[self.firebaseDB childByAppendingPath:@"images"] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            [self.triggers removeAllObjects];
            
            for(FDataSnapshot* child in snapshot.children) {
                
                NSDictionary * newTrigger = [[NSDictionary alloc] initWithObjectsAndKeys:
                                             child.value[kDescription], kDescription,
                                             child.value[kLink], kLink,
                                             child.value[kImageString
                                                         ], kImageString,
                                             child.key, kAutoId,
                                             nil];
                [self.triggers addObject:newTrigger];
            }
            //Notify the TriggerTableViewController that the database has been loaded and that the tableview may ditch the cache data
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
        NSLog(@"The trigger index to remove is invalid");
    }
    
    //Access the correct, unique branch of the database the trigger is stored in
    Firebase * usersRef = [_firebaseDB childByAppendingPath:@"images"];
    Firebase * postRef = [usersRef childByAppendingPath:[self.triggers[index] valueForKey:kAutoId]];
    
    //Remove the trigger from the firebase DB, the local array, and the moodstocks DB
    [self moodstocksDelete:postRef.key];
    
    [postRef removeValue];
    [self.triggers removeObjectAtIndex:index];
}

- (void)addTrigger: (NSMutableDictionary*) newTrigger
     withImageData: (NSData *) imageData{
    
    //Network transfer may take a while, so let this function run in the background if the user backgrounds the app
    UIBackgroundTaskIdentifier bTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^() {
        
        NSLog(@"No more time left, shutting down the app");
    }];
    
    //Create a unique branch for the new trigger under the images path
    Firebase * usersRef = [_firebaseDB childByAppendingPath:@"images"];
    Firebase * postRef = [usersRef childByAutoId];
    
    [self moodstocksAdd:postRef.key
                  image:imageData
                firebaseRef: postRef
                trigger:newTrigger];
    
    [[UIApplication sharedApplication] endBackgroundTask:bTask];
    bTask = UIBackgroundTaskInvalid;
}

- (NSInteger) numTriggers{
    
    return self.triggers.count;
}

- (NSDictionary *) getTrigger:(NSUInteger)index {
    
    return self.triggers[index];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    //Here we pass the correct moodstocks login information so that we may access our moodstocks database from HTTP
    if (challenge.previousFailureCount == 0) {
        NSURLCredential *credential = [NSURLCredential credentialWithUser:MS_API_KEY password:MS_API_SECRET persistence:NSURLCredentialPersistenceForSession];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

- (void)moodstocksDelete: (NSString *) imageID{
    
    //Form a URL request to delete a moodstocks image from our database
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"http://api.moodstocks.com/v2/ref/%@", imageID]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"DELETE"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];

    NSURLSession * session = [NSURLSession sessionWithConfiguration:configuration
                                            delegate:(id)self
                                       delegateQueue:[NSOperationQueue mainQueue]];
    
    //Begin the delete request with completion handler
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!data) {
            NSLog(@"dataTaskWithURL error: %@", error);
            return;
        }
        
        NSError *parseError;
        id responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        if (responseObject) {
            // got the JSON I was expecting; go ahead and use it; I'll just log it for now
            NSLog(@"responseObject = %@", responseObject);
        
            
        } else {
            // if it wasn't JSON, it's probably some error, so it's sometimes useful to see what the HTML actually says
            NSLog(@"responseString = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            
        }
    }];
    [task resume];
    
}

-(void)moodstocksAdd: (NSString *) imageID
              image: (NSData *) imageData
             firebaseRef:(Firebase *) postRef
             trigger:(NSMutableDictionary *) newTrigger{
    
    //Create the PUT request URL to add an image to moodstocks
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"http://api.moodstocks.com/v2/ref/%@", imageID]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    // set Content-Type in HTTP header
    NSString *boundary = @"unique-consistent-string";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    // post body
    NSMutableData *body = [NSMutableData data];
    // add image data
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@; filename=newImage.jpg\r\n", @"image_file"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    //Configure the session to only allow 1 connection per host so that the requests run in serial order (image added to queue then flagged as synchronizable)
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [configuration setHTTPMaximumConnectionsPerHost:1];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:configuration
                                                           delegate:(id)self
                                                      delegateQueue:[NSOperationQueue mainQueue]];
    
    //Begin the put request
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!data) {
            NSLog(@"dataTaskWithURL error: %@", error);
            return;
        }
        
        NSError *parseError;
        id responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        if (responseObject) {
            // got the JSON I was expecting; go ahead and use it; I'll just log it for now
            NSLog(@"responseObject = %@", responseObject);
        } else {
            // if it wasn't JSON, it's probably some error, so it's sometimes useful to see what the HTML actually says
            NSLog(@"responseString = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            
        }
    }];
    [task resume];
    
    
    //Now send a cURL command to moodstocks database telling them to update our offline cache
    NSURL * offlineSynchURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.moodstocks.com/v2/ref/%@/offline", imageID]];
    NSMutableURLRequest * offlineSynchRequest = [NSMutableURLRequest requestWithURL:offlineSynchURL];
    [offlineSynchRequest setHTTPMethod:@"POST"];
    [offlineSynchRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    NSURLSessionTask * offlineSynchTask = [session dataTaskWithRequest:offlineSynchRequest completionHandler:^(NSData *data, NSURLResponse * response, NSError * error) {
        
        if (!data) {
            NSLog(@"dataTaskWithURL error: %@", error);
            return;
        }
        
        NSError *parseError;
        id responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        if (responseObject) {
            // got the JSON I was expecting; go ahead and use it; I'll just log it for now
            NSLog(@"responseObject = %@", responseObject);
            
            //Save the unique branch ID
            [newTrigger setObject:postRef.key forKey:kAutoId];
            
            //Add the trigger to the firebase DB & store it in the local array
            [postRef setValue:newTrigger];
            [self.triggers addObject:newTrigger];
            
            MSScanner * scanner = [(AppDelegate*)[[UIApplication sharedApplication] delegate] scanner];
            void (^completionBlock)(MSSync *, NSError *) = ^(MSSync *op, NSError *error) {
                if (error)
                    NSLog(@"Sync failed with error: %@", [error ms_message]);
                else
                    NSLog(@"Sync succeeded (%li images(s))", (long)[scanner count:nil]);
            };
            
            void (^progressionBlock)(NSInteger) = ^(NSInteger percent) {
                NSLog(@"Sync progressing: %li%%", (long)percent);
            };
            
            // Launch the synchronization
            [scanner syncInBackgroundWithBlock:completionBlock progressBlock:progressionBlock];
            
        } else {
            // if it wasn't JSON, it's probably some error, so it's sometimes useful to see what the HTML actually says
            NSLog(@"responseString = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            
        }
        
    }];
    [offlineSynchTask resume];
    
}

@end

