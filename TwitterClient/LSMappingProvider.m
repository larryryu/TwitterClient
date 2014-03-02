//
//  LSMappingProvider.m
//  TwitterClient
//
//  Created by Lukman Sanusi on 3/1/14.
//  Copyright (c) 2014 Lukman Sanusi. All rights reserved.
//

#import "LSMappingProvider.h"
#import "CoreDataHeaders.h"

@implementation LSMappingProvider

+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatter setLocale:enUSPOSIXLocale];
        [dateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
    });
    
    return dateFormatter;
}

+ (RKEntityMapping *)tweetGetResponseInManagedObjectStore:(RKManagedObjectStore *)store{
    RKEntityMapping *tweetMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([Tweet class]) inManagedObjectStore:store];
    
    RKCompoundValueTransformer *transformer = (RKCompoundValueTransformer *)tweetMapping.valueTransformer;
    [transformer insertValueTransformer:(NSFormatter<RKValueTransforming> *)[LSMappingProvider dateFormatter] atIndex:0];
    
    [tweetMapping addAttributeMappingsFromArray:@[@"text"]];
    [tweetMapping addAttributeMappingsFromDictionary:@{@"id"         : @"tweetId",
                                                       @"created_at" : @"createdAt",
                                                       }];
    tweetMapping.identificationAttributes = @[@"tweetId"];
    RKEntityMapping *userMapping = [self userGetResponseInManagedObjectStore:store];
    [tweetMapping addRelationshipMappingWithSourceKeyPath:@"user" mapping:userMapping];
    
    return tweetMapping;
}

+ (RKEntityMapping *)userGetResponseInManagedObjectStore:(RKManagedObjectStore *)store{
    RKEntityMapping *userMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([User class]) inManagedObjectStore:store];
    
    [userMapping addAttributeMappingsFromArray:@[@"name"]];
    [userMapping addAttributeMappingsFromDictionary:@{@"id"                : @"userId",
                                                      @"screen_name"       : @"screenName",
                                                      }];
    userMapping.identificationAttributes = @[@"userId"];
    
    RKEntityMapping *imageMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([TwitterImage class]) inManagedObjectStore:store];
    
    [imageMapping addAttributeMappingsFromDictionary:@{@"profile_image_url" : @"imageURL"}];
    imageMapping.identificationAttributes = @[@"imageURL"];
    
    [userMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:nil toKeyPath:@"profileImage" withMapping:imageMapping]];
    
    return userMapping;
}

@end
