//
//  GMCell.m
//  GMBookShelf
//
//  Created by Giuseppe Morana on 04/07/15.
//  Copyright (c) 2015 eugenio. All rights reserved.
//

#import "GMCell.h"
#import "GMTheme.h"

@interface GMCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation GMCell

- (void)setBook:(GMBook *)book {
    _book = book;
    
    self.contentView.frame = self.frame;    // workaround to avoid some unexpected constraint errors in logs
    
    self.titleLabel.text = (book.title != nil) ? book.title : @"";
    self.iconView.image = (book.image != nil) ? book.image : [GMTheme placeholder];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.iconView.layer.borderWidth = 1.0f;
    self.iconView.layer.borderColor = [GMTheme foregroundColor].CGColor;
    self.iconView.layer.cornerRadius = 5.0f;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.iconView.image = [GMTheme placeholder];
}

@end
