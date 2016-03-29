//
//  TableCellAlbum.h
//  Mail
//
//  Created by Nikolay on 28.03.16.
//  Copyright © 2016 Nikolay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableCellAlbum : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imagePhotoAlbum;
@property (weak, nonatomic) IBOutlet UILabel *titleAlbum;
@property (weak, nonatomic) IBOutlet UILabel *countPhoto;
@end
