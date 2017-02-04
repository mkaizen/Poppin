//
//  PAWConfigManager.h
//  AnyWall
//
//  Created by Nikita Lutsenko on 9/5/14.
//  Copyright (c) 2014 Parse Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 Manages config for the entire application.
 Acts as a proxy for PFConfig to get the values for options.
 */
@interface PAWConfigManager : NSObject

+ (instancetype)sharedManager;

- (void)fetchConfigIfNeeded;

- (NSArray *)filterDistanceOptions;
- (NSUInteger)postMaxCharacterCount;

@end
