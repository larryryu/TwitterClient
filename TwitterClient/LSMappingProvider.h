//
//  LSMappingProvider.h
//  TwitterClient
//
//  Created by Lukman Sanusi on 3/1/14.
//  Copyright (c) 2014 Lukman Sanusi. All rights reserved.
//

/* 
 Provides mapping for Tweet, User, TwitterImage which are used by RKResponseMapperOperation to map the json response to core data objects
 
 Restkit Mapping Documentation
 https://github.com/RestKit/RestKit/wiki/Object-mapping
 */

#import <Foundation/Foundation.h>

@interface LSMappingProvider : NSObject
+ (RKEntityMapping *)tweetGetResponseInManagedObjectStore:(RKManagedObjectStore *)store;
+ (RKEntityMapping *)userGetResponseInManagedObjectStore:(RKManagedObjectStore *)store;
@end
