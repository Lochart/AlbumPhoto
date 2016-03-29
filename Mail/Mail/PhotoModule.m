//
//  PhotoModule.m
//  Mail
//
//  Created by Nikolay on 28.03.16.
//  Copyright © 2016 Nikolay. All rights reserved.
//

#import "PhotoModule.h"
#import "AlbumModule.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation PhotoModule

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)getCollections
{
    PHFetchResult *fetchedCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    self.allCollections = [[NSMutableArray alloc] init];
    for (PHAssetCollection *newCollection in fetchedCollections) {
        AlbumModule *newAlbum = [[AlbumModule alloc] initWithfetchedCollection :newCollection];
        [self.allCollections addObject:newAlbum];
    }
}


@end
