//
//  LSTwitterWebServiceManager.m
//  TwitterClient
//
//  Created by Lukman Sanusi on 3/1/14.
//  Copyright (c) 2014 Lukman Sanusi. All rights reserved.
//

#import "LSTwitterWebServiceManager.h"

NSString *const kTwitterBaseURL = @"https://api.twitter.com/1.1/";
NSString *const kTwitterTimeLinePath = @"statuses/home_timeline.json";
NSString *const kTwitterAutenticationPath = @"oauth/request_token";

//construct URL with the base path and relatve path
static NSURL * twitterApiUrlWithPath(NSString *path){
    NSURL *url = [NSURL URLWithString:path relativeToURL:[NSURL URLWithString:kTwitterBaseURL]];
    return url;
}

@interface LSTwitterWebServiceManager ()
@property (nonatomic, strong) ACAccount *currentAccount;
@end

@implementation LSTwitterWebServiceManager

+ (instancetype)sharedManager{
    static LSTwitterWebServiceManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LSTwitterWebServiceManager alloc] init];
    });
    return manager;
}

- (RKObjectManager *)objectManager{
    return [[LSRestKitManager sharedManager] objectManager];
}

- (NSManagedObjectContext *)managedObjectContext{
    return [LSRestKitManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
}

#pragma mark - Accounts

-(ACAccountStore *)accountStore{
    if (!_accountStore) {
        _accountStore = [[ACAccountStore alloc] init];
    }
    return _accountStore;
    
}

- (void)fetchTwitterAccountsWithCompletion:(void(^)(NSArray *accounts, NSError *error))completion{
    ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [self.accountStore requestAccessToAccountsWithType:twitterAccountType options:nil completion:^(BOOL granted, NSError *error) {
        if(granted) {
            NSArray *accounts = [self.accountStore accountsWithAccountType:twitterAccountType];
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (completion) completion(accounts, nil);
            });
        }else{
            if (completion) completion(nil, error);
        }
    }];
}

- (void)logInWithAccount:(ACAccount *)account completion:(TwitterWebServiceCompletion)completion{
    self.currentAccount = account;
    if (completion) completion(nil, account);
}

#pragma mark - Tweets
/*
 fetches timeline tweets for the selected twitter account we constrcut the request with an SLRequest and pass it to the RKObject manager instead so that ti maps the response to core data objects
*/
- (void)getTimeLimeTweetsWithCompletion:(TwitterWebServiceCompletion)completion{
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:(SLRequestMethodGET) URL:twitterApiUrlWithPath(kTwitterTimeLinePath) parameters:nil];
    request.account = self.currentAccount;
    
    [[LSRestKitManager sharedManager] performSLRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (completion) completion(nil, mappingResult);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (completion) completion(error, nil);
    }];
}

@end
