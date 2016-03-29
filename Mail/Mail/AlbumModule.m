//
//  AlbumModule.m
//  Mail
//
//  Created by Nikolay on 28.03.16.
//  Copyright © 2016 Nikolay. All rights reserved.
//

#import "AlbumModule.h"

@interface AlbumModule ()

@property (strong, nonatomic) PHFetchResult *fetchedAlbumRequest;

@end

@implementation AlbumModule

- (instancetype)initWithfetchedCollection :(PHAssetCollection *)fetchedAlbum
{
    self = [super init];
    if (self) {
        self.fetchedAlbum = fetchedAlbum;
        PHAssetCollection *assetCollection = (PHAssetCollection *)self.fetchedAlbum;
        PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
        fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        self.fetchedAlbumRequest = [PHAsset fetchAssetsInAssetCollection:assetCollection options:fetchOptions];
        self.count = self.fetchedAlbumRequest.count;
        self.title = fetchedAlbum.localizedTitle;
    }
    return self;
}

- (PHAsset *)getAssetForIndex:(NSInteger)index
{
    PHAsset *imageAsset = self.fetchedAlbumRequest[index];
    return imageAsset;
}

- (PHAsset *)getLastAsset
{
    PHAsset *imageAsset = [self.fetchedAlbumRequest lastObject];
    return imageAsset;
}

@end
