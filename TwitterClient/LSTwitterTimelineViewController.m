//
//  LSTwitterTimelineViewController.m
//  TwitterClient
//
//  Created by Lukman Sanusi on 3/1/14.
//  Copyright (c) 2014 Lukman Sanusi. All rights reserved.
//

#import "LSTwitterTimelineViewController.h"
#import "LSTwitterWebServiceManager.h"
#import "LSTweetCollectionViewCell.h"
#import <UIImageView+AFNetworking.h>

@interface LSTwitterTimelineViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate>
{
    NSMutableArray *_objectChanges;
    NSMutableArray *_sectionChanges;
    
    NSDateFormatter *dateFormatter;
    LSTweetCollectionViewCell *sizingCell;
}
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end

@implementation LSTwitterTimelineViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _objectChanges = [NSMutableArray array];
    _sectionChanges = [NSMutableArray array];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:(NSDateFormatterShortStyle)];
    [dateFormatter setTimeStyle:(NSDateFormatterShortStyle)];
    
    UINib *cellNib = [UINib nibWithNibName:@"SizingCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"TweetCell"];
    sizingCell = [[cellNib instantiateWithOwner:nil options:nil] objectAtIndex:0];
    
    self.managedObjectContext = [[LSTwitterWebServiceManager sharedManager] managedObjectContext];
    [self performFetch];
    
    [[LSTwitterWebServiceManager sharedManager] getTimeLimeTweetsWithCompletion:^(NSError *error, id response) {
        
    }];
}

#pragma mark - UICollectionViewDatasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    LSTweetCollectionViewCell *tweetCell = (LSTweetCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TweetCell" forIndexPath:indexPath];
    
    [tweetCell setBackgroundColor:[UIColor whiteColor]];
    [self configureCell:tweetCell forItemAtIndexPath:indexPath];
    return tweetCell;
}

- (void)configureCell:(LSTweetCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    Tweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.tweetTextLabel.text = tweet.text;
    cell.dateLabel.text = [dateFormatter stringFromDate:tweet.createdAt];
    cell.profileNameLabel.text = tweet.user.name;
    cell.screenNameLabel.text = tweet.user.screenName;
    
    if (tweet.user.profileImage.image) {
        cell.profileImageView.image = tweet.user.profileImage.image;
    }else{
        NSURL *imageURL = [NSURL URLWithString:tweet.user.profileImage.imageURL];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:imageURL];
        [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        
        [cell.profileImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            cell.profileImageView.image = image;
            tweet.user.profileImage.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
        }];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize size = [(UICollectionViewFlowLayout *)collectionViewLayout itemSize];
    
    [sizingCell setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 320.0f)];
    [self configureCell:sizingCell forItemAtIndexPath:indexPath];
    
    size.height = [sizingCell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    return size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10.0f, 0.0f, 10.0f, 0.0f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10.0f;
}

#pragma mark - Fetched results controller

- (void)performFetch{
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
}

- (NSFetchedResultsController *)fetchedResultsController{
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([Tweet class])];
    NSSortDescriptor *dateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    [fetchRequest setSortDescriptors:@[dateDescriptor]];
    
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    frc.delegate = self;
    
    _fetchedResultsController = frc;
    
    return _fetchedResultsController;
}

#pragma - mark Actions

- (IBAction)logoutButtonAction:(id)sender{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tweetButtonAction:(id)sender{
    SLComposeViewController *composeVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [self presentViewController:composeVC animated:YES completion:nil];
}

#pragma mark - Fetched results controller delegate

/*
    Nasty this happen when you couple NSFetchedResultsController and UICollectionviewController hence the workaround as described here
    http://ashfurrow.com/blog/how-to-use-nsfetchedresultscontroller-with-uicollectionview
 */

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = @(sectionIndex);
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @(sectionIndex);
            break;
    }
    
    [_sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [_objectChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    
    if ([_sectionChanges count] > 0)
    {
        [self.collectionView performBatchUpdates:^{
            
            for (NSDictionary *change in _sectionChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                    }
                }];
            }
        } completion:nil];
    }
    
    if ([_objectChanges count] > 0 && [_sectionChanges count] == 0)
    {
        [self.collectionView performBatchUpdates:^{
            
            for (NSDictionary *change in _objectChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            
                            [self.collectionView insertItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeMove:
                            [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                            break;
                    }
                }];
            }
        } completion:nil];
    }
    
    [_sectionChanges removeAllObjects];
    [_objectChanges removeAllObjects];
}

@end
