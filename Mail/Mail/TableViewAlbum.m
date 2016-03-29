//
//  TableViewAlbum.m
//  Mail
//
//  Created by Nikolay on 28.03.16.
//  Copyright © 2016 Nikolay. All rights reserved.
//

#import "TableViewAlbum.h"
#import "TableCellAlbum.h"
#import "CollectionPhoto.h"
#import "AlbumModule.h"
#import "PhotoModule.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "PHAsset+Utility.h"


@interface TableViewAlbum ()<PHPhotoLibraryChangeObserver, UIImagePickerControllerDelegate ,UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource>


@property (strong, nonatomic) UIImage *capturedImage;
@property (strong, nonatomic) PHAsset *capturedVideo;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) UIPopoverController *popoverController;

@end

@implementation TableViewAlbum

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.mode == ViewModeBrowse) {
        UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(openCamera) ];
        self.navigationItem.rightBarButtonItem = cameraButton;
        
        UIBarButtonItem *addAlbumButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(getNameOfAlbum) ];
        self.navigationItem.leftBarButtonItem = addAlbumButton;
        
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    } else {
        self.tableView.tableHeaderView = [self headerView];
    }
    [[PhotoModule sharedInstance] getCollections];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [PhotoModule sharedInstance].allCollections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self albumCellForIndexPath:indexPath];
    if (self.mode == ViewModeChooseAlbum) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (UITableViewCell *)albumCellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellAlbum";
    __block TableCellAlbum *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                                        forIndexPath:indexPath];
    AlbumModule *album = [PhotoModule sharedInstance].allCollections[indexPath.row];
    cell.titleAlbum.text = album.title;
    cell.countPhoto.text = [NSString stringWithFormat:@"count: %li", [album count]];
    
    [[PHImageManager defaultManager] requestImageForAsset: [album getLastAsset]
                                               targetSize:cell.imagePhotoAlbum.bounds.size
                                              contentMode:PHImageContentModeAspectFill
                                                  options:nil
                                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [cell.imagePhotoAlbum setContentMode:UIViewContentModeScaleAspectFill];
                                                    [cell.imagePhotoAlbum setClipsToBounds:YES];
                                                    cell.imagePhotoAlbum.image = result;
                                                });
                                            }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.mode == ViewModeBrowse) {
        CollectionPhoto *albumViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CollectionPhoto"];
        albumViewController.albumIndex = indexPath.row;
        [self.navigationController pushViewController:albumViewController animated:YES];
    } else {
        AlbumModule *selectedAlbum = [PhotoModule sharedInstance].allCollections[indexPath.row];
        if (self.capturedImage) {
            [self savePhoto:self.capturedImage toAlbum:selectedAlbum.fetchedAlbum];
        } else if (self.capturedVideo) {
            __weak typeof(self) weakSelf = self;
            [self.capturedVideo saveToAlbum:selectedAlbum.title completionBlock:^(BOOL success){
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }];
        }
    }
}

- (void)openCamera
{
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.imagePickerController animated:YES completion:NULL];
    } else {
        [self openGallery];
    }
}

- (void)openGallery
{
    self.imagePickerController= [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePickerController.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString*) kUTTypeImage];
    
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    TableViewAlbum *selectAlbumController = [self.storyboard instantiateViewControllerWithIdentifier:@"TableViewAlbum"];
    selectAlbumController.mode = ViewModeChooseAlbum;
    
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage]) {
        self.capturedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.capturedVideo = nil;
        
        selectAlbumController.capturedImage = self.capturedImage;
        
    } else {
        [PHAsset saveVideoAtURL:[info objectForKey: UIImagePickerControllerMediaURL]
                       location:nil
                completionBlock:^(PHAsset *asset, BOOL success) {
                    selectAlbumController.capturedImage = nil;
                    selectAlbumController.capturedVideo = asset;
                }];
    }
    [self.navigationController presentViewController:selectAlbumController animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)getNameOfAlbum
{
    
    NSLog(@"w=%f",MIN(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds)));
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Please enter new album name" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self addAlbumWithName:[alert.textFields firstObject].text];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField){ }];
    [self presentViewController:alert animated:YES completion:^{
        [self.view endEditing:YES];
    }];
}

- (void)addAlbumWithName:(NSString *)aName
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHFetchOptions *fetchOptions = [PHFetchOptions new];
        fetchOptions.predicate = [NSPredicate predicateWithFormat:@"title LIKE %@", aName];
        PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:fetchOptions];
        
        if (fetchResult.count == 0) {
            [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:aName];
        }
    } completionHandler:nil];
}

- (void)savePhoto:(UIImage *)theImage toAlbum:(PHAssetCollection *) theAlbum
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetCollectionChangeRequest *albumRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection: theAlbum];
        PHAssetChangeRequest *createImageRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:theImage];
        [albumRequest addAssets:@[createImageRequest.placeholderForCreatedAsset]];
    } completionHandler:^(BOOL success, NSError *error) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[PhotoModule sharedInstance] getCollections];
        [self.tableView reloadData];
    });
}

- (UIView *)headerView
{
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.tableView.frame.size.width, 64.0)];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame: CGRectMake(15, 25, sectionHeaderView.frame.size.width, 20.0)];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    [headerLabel setFont:[UIFont fontWithName:@"Verdana" size:20.0]];
    [sectionHeaderView addSubview:headerLabel];
    headerLabel.text = @"Please select album:";
    return sectionHeaderView;
}

@end
