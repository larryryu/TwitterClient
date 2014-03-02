//
//  LSTweetCollectionViewCell.m
//  TwitterClient
//
//  Created by Lukman Sanusi on 3/1/14.
//  Copyright (c) 2014 Lukman Sanusi. All rights reserved.
//

#import "LSTweetCollectionViewCell.h"

@implementation LSTweetCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self.profileImageContainerView layoutIfNeeded];
    CGFloat cornerRadius = self.profileImageContainerView.frame.size.width/2.0f;
    [self.profileImageContainerView.layer setCornerRadius:cornerRadius];
}

@end
