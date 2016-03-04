//
//  TriggerTableViewController.m
//  AR_Rossier
//
//  Created by Haley Lenner on 2/8/16.
//  Copyright © 2016 AR_Rossier. All rights reserved.
//

#import "TriggerModel.h"
#import "TriggerTableViewController.h"

@interface TriggerTableViewController ()

@property (strong, nonatomic) TriggerModel * model;
@property (strong, nonatomic) NSMutableArray * cachedData;

@end

@implementation TriggerTableViewController {
    
    BOOL _databaseLoaded;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _databaseLoaded = false;
    
    self.model = [TriggerModel sharedModel];
    
    self.cachedData = [[NSMutableArray alloc]
                       initWithArray:[[NSUserDefaults standardUserDefaults]
                                      objectForKey:@"myArray"]];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    //refresher to be called when the table is pulled down
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor grayColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(getLatestTasks)
                  forControlEvents:UIControlEventValueChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:@"refreshTriggerTable" object:nil];
}

-(void)refreshView:(NSNotification *) notification {
    
    _databaseLoaded = true;
    [self.tableView reloadData];
}

-(void) getLatestTasks {
    
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.model.numTriggers;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trigger" forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary * currentTrigger;
    if(_databaseLoaded) {
       
        currentTrigger = [self.model getTrigger:indexPath.row];
    }
    else {
        currentTrigger = [_cachedData objectAtIndex:indexPath.row];
    }
    cell.detailTextLabel.text = currentTrigger[kDescription];
    cell.textLabel.text = currentTrigger[kDescription];
    
    
    NSData *data = [[NSData alloc]initWithBase64EncodedString:currentTrigger[kImageString] options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    cell.imageView.image = [UIImage imageWithData:data];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.model removeTrigger:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
