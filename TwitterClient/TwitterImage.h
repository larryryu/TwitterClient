//
//  TwitterImage.h
//  TwitterClient
//
//  Created by Lukman Sanusi on 3/1/14.
//  Copyright (c) 2014 Lukman Sanusi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface TwitterImage : NSManagedObject

@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) id image;
@property (nonatomic, retain) User *profileUser;

@end
