//
//  LSRestKitManager.m
//  TwitterClient
//
//  Created by Lukman Sanusi on 3/1/14.
//  Copyright (c) 2014 Lukman Sanusi. All rights reserved.
//

#import "LSRestKitManager.h"
#import "LSMappingProvider.h"

extern NSString *const kTwitterBaseURL;

@interface LSRestKitManager()

@property (nonatomic, strong) RKObjectManager *objectManager;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) RKManagedObjectStore *managedObjectStore;

@end

@implementation LSRestKitManager

+ (instancetype)sharedManager
{
    static LSRestKitManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LSRestKitManager alloc] init];
    });
    return manager;
}

/**
 Standard RestKit Configuration
 */
- (id)init
{
    self = [super init];
    if (self) {
//        RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
//        RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
        
        self.objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:kTwitterBaseURL]];
        self.objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
        
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        
        // Initialize managed object store
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TwitterClient" withExtension:@"momd"];
        self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        self.managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:self.managedObjectModel];
        self.objectManager.managedObjectStore = self.managedObjectStore;
        
        [self initMapping];
        [self initCoreData];
        [self initFetchRequestBlock];
    }
    
    return self;
}

- (void)initMapping
{
    NSIndexSet *statusCodeSet = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    
    RKEntityMapping *tweetGetResponseMapping = [LSMappingProvider tweetGetResponseInManagedObjectStore:self.managedObjectStore];
    RKResponseDescriptor *tweetResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:tweetGetResponseMapping method:(RKRequestMethodGET) pathPattern:kTwitterTimeLinePath keyPath:nil statusCodes:statusCodeSet];
    
    [self.objectManager addResponseDescriptor:tweetResponseDescriptor];
}

- (void)initCoreData
{
    [self.managedObjectStore createPersistentStoreCoordinator];
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"TwitterClient.sqlite"];
    NSError *error;
    
    [self.managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
    if (error) {
        NSLog(@"Could not create persistent store: %@", error);
    }
    
    // Create the managed object contexts
    [self.managedObjectStore createManagedObjectContexts];
    self.managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:self.managedObjectStore.persistentStoreManagedObjectContext];
}

/**
    This takes care of orphan/deleted objects. See http://restkit.org/api/latest/Classes/RKManagedObjectRequestOperation.html#//api/name/deletesOrphanedObjects
 */
- (void)initFetchRequestBlock{
    [self.objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:kTwitterTimeLinePath];
        NSDictionary *argsDict = nil;
        BOOL match = [pathMatcher matchesPath:[URL relativePath] tokenizeQueryStrings:NO parsedArguments:&argsDict];
        if (match) {
            return [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Tweet class])];
        }
        return nil;
    }];
}

- (void)performSLRequest:(SLRequest *)request success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure{
    
    NSURLRequest *urlRequest = [request preparedURLRequest];
    
    NSManagedObjectContext *managedObjectContext = [self objectManager].managedObjectStore.mainQueueManagedObjectContext;
    RKManagedObjectRequestOperation *operation = [[self objectManager] managedObjectRequestOperationWithRequest:urlRequest managedObjectContext:managedObjectContext success:success failure:failure];
    [[self objectManager] enqueueObjectRequestOperation:operation];
}

@end