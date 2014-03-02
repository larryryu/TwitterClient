//
//  LSTwitterWebServiceManager.h
//  TwitterClient
//
//  Created by Lukman Sanusi on 3/1/14.
//  Copyright (c) 2014 Lukman Sanusi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSRestKitManager.h"
@import Accounts;
@import Social;

typedef void (^TwitterWebServiceCompletion)(NSError *error, id response);

@interface LSTwitterWebServiceManager : NSObject
@property (strong, nonatomic) ACAccountStore *accountStore;

+ (instancetype)sharedManager;

- (NSManagedObjectContext *)managedObjectContext;
/**
 Fetches ACAccount objects
 */
- (void)fetchTwitterAccountsWithCompletion:(void(^)(NSArray *accounts, NSError *error))completion;
/**
 Sets the current account
 */
- (void)logInWithAccount:(ACAccount *)account completion:(TwitterWebServiceCompletion)completion;
/**
 Fetches timeline tweets for the selected twitter account.
 */
- (void)getTimeLimeTweetsWithCompletion:(TwitterWebServiceCompletion)completion;

@end
