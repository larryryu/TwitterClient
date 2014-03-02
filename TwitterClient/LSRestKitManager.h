//
//  LSRestKitManager.h
//  TwitterClient
//
//  Created by Lukman Sanusi on 3/1/14.
//  Copyright (c) 2014 Lukman Sanusi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataHeaders.h"

@import Social;

@interface LSRestKitManager : NSObject
@property (nonatomic, strong, readonly) RKObjectManager *objectManager;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) RKManagedObjectStore *managedObjectStore;

+ (instancetype)sharedManager;
/**
 Takes an SLRequest request url and passes it to an RKManagedObjectRequestOperation to perform the request instead. This allows the response mapping operation to occur after a response is received.
 */
- (void)performSLRequest:(SLRequest *)request success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;
@end
