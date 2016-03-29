//
//  PreviewPhoto.m
//  Mail
//
//  Created by Nikolay on 28.03.16.
//  Copyright © 2016 Nikolay. All rights reserved.
//

#import "PreviewPhoto.h"

@interface PreviewPhoto ()
@property (weak, nonatomic) IBOutlet UIImageView *imagePreviewPhoto;

@property (assign, nonatomic) BOOL isStatusBarWhite;

@end

@implementation PreviewPhoto


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshImage) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIScrollviewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imagePreviewPhoto;
}

- (IBAction)imageViewTapped:(id)sender {
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (self.isStatusBarWhite) {
        return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleDefault;
}

#pragma mark - Utils

- (void)refreshImage
{
    if (CGRectGetWidth(self.imagePreviewPhoto.frame) == 0) {
        self.imagePreviewPhoto.frame = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    }
    self.imagePreviewPhoto.image = self.image;
}

@end
