//
//  Tweet.h
//  TwitterClient
//
//  Created by Lukman Sanusi on 3/1/14.
//  Copyright (c) 2014 Lukman Sanusi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Tweet : NSManagedObject

@property (nonatomic, retain) NSString * tweetId;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) User *user;

@end
