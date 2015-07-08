//
//  GMCell.h
//  GMBookShelf
//
//  Created by Giuseppe Morana on 04/07/15.
//  Copyright (c) 2015 eugenio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMBook.h"

@interface GMCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *hSeparator;
@property (weak, nonatomic) IBOutlet UIView *vSeparator;

@property (nonatomic, strong) GMBook *book;

@end
