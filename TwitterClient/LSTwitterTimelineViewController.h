//
//  LSTwitterTimelineViewController.h
//  TwitterClient
//
//  Created by Lukman Sanusi on 3/1/14.
//  Copyright (c) 2014 Lukman Sanusi. All rights reserved.
//

//Displays a list of Tweets available for the selected account

#import <UIKit/UIKit.h>

@interface LSTwitterTimelineViewController : UIViewController
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@end
