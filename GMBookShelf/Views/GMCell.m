//
//  GMCell.m
//  GMBookShelf
//
//  Created by Giuseppe Morana on 04/07/15.
//  Copyright (c) 2015 eugenio. All rights reserved.
//

#import "GMCell.h"

@interface GMCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *currencyLabel;
@end

@implementation GMCell


- (void)setBook:(GMBook *)book {
    _book = book;
    
    self.titleLabel.text = (book.title != nil) ? book.title : @"";
    self.authorLabel.text = (book.author != nil) ? book.author : @"";
    self.priceLabel.text = (book.price != nil) ? [book.price description] : @"";
    self.currencyLabel.text = (book.price != nil) ? @"€" : @"";
    self.iconView.image = (book.image != nil) ? book.image : nil;
//    self.iconView.image = [UIImage imageNamed:@"sample.jpeg"];
    
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"jpeg"];
//    self.iconView.image = [UIImage imageWithContentsOfFile:imagePath];
}

@end
