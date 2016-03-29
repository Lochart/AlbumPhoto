//
//  TableViewAlbum.h
//  Mail
//
//  Created by Nikolay on 28.03.16.
//  Copyright © 2016 Nikolay. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ViewMode) {
    ViewModeBrowse,
    ViewModeChooseAlbum
};

@interface TableViewAlbum : UITableViewController

@property (assign, nonatomic) ViewMode mode;

@end
