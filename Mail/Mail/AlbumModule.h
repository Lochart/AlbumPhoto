//
//  AlbumModule.h
//  Mail
//
//  Created by Nikolay on 28.03.16.
//  Copyright © 2016 Nikolay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PHAsset+Utility.h"

@interface AlbumModule : NSObject

@property (assign, nonatomic) NSInteger count;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) PHAssetCollection *fetchedAlbum;

- (instancetype)initWithfetchedCollection:(PHAssetCollection *)fetchedAlbum;
- (PHAsset *)getAssetForIndex:(NSInteger)index;
- (PHAsset *)getLastAsset;

@end
