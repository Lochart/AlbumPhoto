//
//  PhotoModule.h
//  Mail
//
//  Created by Nikolay on 28.03.16.
//  Copyright © 2016 Nikolay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoModule : NSObject

@property (strong, nonatomic) NSMutableArray *allCollections;

+ (instancetype)sharedInstance;
- (void)getCollections;

@end
