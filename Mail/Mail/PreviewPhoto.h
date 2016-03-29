//
//  PreviewPhoto.h
//  Mail
//
//  Created by Nikolay on 28.03.16.
//  Copyright © 2016 Nikolay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHAsset+Utility.h"

@interface PreviewPhoto : UIViewController<UIScrollViewDelegate>

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) PHAsset *asset;
@property (strong, nonatomic) PHAssetCollection *assetCollection;

- (void)refreshImage;


@end
