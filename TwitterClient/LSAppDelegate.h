//
//  LSAppDelegate.h
//  TwitterClient
//
//  Created by Lukman Sanusi on 2/28/14.
//  Copyright (c) 2014 Lukman Sanusi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)saveContext;

@end
