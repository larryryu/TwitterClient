//
//  LSLoginTableViewController.m
//  TwitterClient
//
//  Created by Lukman Sanusi on 2/28/14.
//  Copyright (c) 2014 Lukman Sanusi. All rights reserved.
//

#import "LSLoginTableViewController.h"
#import "LSTwitterWebServiceManager.h"

@interface LSLoginTableViewController ()
@property (nonatomic, strong) NSArray *twitterAccounts;
@end

@implementation LSLoginTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Table view data source

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self fetchAccounts];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchAccounts) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)fetchAccounts{
    // fetch ACAccounts from the Accounts store to populate tableView
    [[LSTwitterWebServiceManager sharedManager] fetchTwitterAccountsWithCompletion:^(NSArray *accounts, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.twitterAccounts = accounts;
            [self.tableView reloadData];
        });
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.twitterAccounts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cellToReturn = [tableView dequeueReusableCellWithIdentifier:@"AccountCell" forIndexPath:indexPath];
    ACAccount *account = self.twitterAccounts[indexPath.row];
    [cellToReturn.textLabel setText:account.username];
    return cellToReturn;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSInteger rowCount = self.twitterAccounts.count;
    return  rowCount ? @"Select Account" : @"No Accounts Available (See Help)";
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // pass the selected account to the webservice manager so it can use that to generate requests
    [[LSTwitterWebServiceManager sharedManager] logInWithAccount:self.twitterAccounts[indexPath.row] completion:^(NSError *error, id response) {
        if (!error) {
            UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"TimelineNavigationController"];
            [self presentViewController:nav animated:YES completion:nil];
        }else{
            NSLog(@"Errror: %@", error.localizedDescription);
        }
    }];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
