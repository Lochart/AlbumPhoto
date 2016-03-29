//
//  CollectionPhoto.m
//  Mail
//
//  Created by Nikolay on 28.03.16.
//  Copyright © 2016 Nikolay. All rights reserved.
//

#import "CollectionPhoto.h"
#import "CollectionCellPhoto.h"
#import "TableViewAlbum.h"
#import "PhotoModule.h"
#import "PreviewPhoto.h"
#import <MediaPlayer/MediaPlayer.h>
#import "PHAsset+Utility.h"

@interface CollectionPhoto ()

@property (strong, nonatomic) AlbumModule *album;

@end

@implementation CollectionPhoto

//static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.album.title;
    UIBarButtonItem *deleteAlbumButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAlbum) ];
    self.navigationItem.rightBarButtonItem = deleteAlbumButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[PhotoModule sharedInstance] getCollections];
    self.album = [PhotoModule sharedInstance].allCollections[self.albumIndex];
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.album.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PHAsset *cellImage =  [self.album getAssetForIndex:indexPath.item];
    CollectionCellPhoto *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CollectionCellPhoto class]) forIndexPath:indexPath];
    [[PHImageManager defaultManager] requestImageForAsset:cellImage
                                               targetSize:CGSizeMake(100, 100)
                                              contentMode:PHImageContentModeAspectFill
                                                  options:nil
                                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                                cell.cellImagePhoto.image = result;
                                            }];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *mediaAsset = [self.album getAssetForIndex:indexPath.item];
    if (mediaAsset.mediaType == 1) {
        PreviewPhoto *imageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PreviewPhoto"];
        
        PHAsset *cellImage = mediaAsset;
        imageViewController.asset = [self.album getAssetForIndex:indexPath.item];
        imageViewController.assetCollection = self.album.fetchedAlbum;
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
        [[PHImageManager defaultManager]  requestImageForAsset:cellImage
                                                    targetSize:[self targetSize]
                                                   contentMode:PHImageContentModeAspectFill
                                                       options:options
                                                 resultHandler:^(UIImage *result, NSDictionary *info) {
                                                     imageViewController.image = result;
                                                     [imageViewController refreshImage];
                                                 }];
        
        [self.navigationController pushViewController:imageViewController animated:YES];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
        __block NSURL *videoURL;
        [[PHImageManager defaultManager] requestAVAssetForVideo:mediaAsset options:nil resultHandler:^(AVAsset *videoAsset, AVAudioMix *mix, NSDictionary *info) {
            AVURLAsset *urlAsset = (AVURLAsset *)videoAsset;
            videoURL = urlAsset.URL;
            if ([[NSFileManager defaultManager] fileExistsAtPath:[videoURL path]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
                    [self presentViewController:moviePlayer animated:YES completion:nil];
                });
            }		 
        }];
    }
}

- (CGSize)targetSize
{
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) * scale, CGRectGetHeight([UIScreen mainScreen].bounds) *scale);
    return targetSize;
}

- (void)deleteAlbum
{
    if (self.album.fetchedAlbum) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetCollectionChangeRequest deleteAssetCollections:@[self.album.fetchedAlbum]];
        } completionHandler:^(BOOL success, NSError *error) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[self navigationController] popViewControllerAnimated:YES];
                });
            } else {
                NSLog(@"Error: %@", error);
            }
        }];
    }
}

@end
