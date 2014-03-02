//
//  UIimageTransformer.m
//  TwitterClient
//
//  Created by Lukman Sanusi on 3/1/14.
//  Copyright (c) 2014 Lukman Sanusi. All rights reserved.
//

#import "UIImageTransformer.h"

@implementation UIImageTransformer
+ (Class)transformedValueClass
{
    return [NSData class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    if (value == nil)
        return nil;
    
    // I pass in raw data when generating the image, save that directly to the database
    if ([value isKindOfClass:[NSData class]])
        return value;
    
    return UIImagePNGRepresentation((UIImage *)value);
}

- (id)reverseTransformedValue:(id)value
{
    return [UIImage imageWithData:(NSData *)value];
}
@end
