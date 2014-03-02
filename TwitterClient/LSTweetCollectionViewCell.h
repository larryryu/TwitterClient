//
//  LSTweetCollectionViewCell.h
//  TwitterClient
//
//  Created by Lukman Sanusi on 3/1/14.
//  Copyright (c) 2014 Lukman Sanusi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSTweetCollectionViewCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UIImageView *profileImageView;
@property (nonatomic, weak) IBOutlet UIView *profileImageContainerView;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *profileNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *screenNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *tweetTextLabel;
@end
