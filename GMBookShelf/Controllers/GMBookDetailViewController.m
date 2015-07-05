//
//  GMBookDetailViewController.m
//  GMBookShelf
//
//  Created by Giuseppe Morana on 04/07/15.
//  Copyright (c) 2015 eugenio. All rights reserved.
//

#import "GMBookDetailViewController.h"

@interface GMBookDetailViewController()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;

@end

@implementation GMBookDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView.image = self.book.image;
    self.priceLabel.text = [self.book.price description];
    self.titleLabel.text = self.book.title;
    self.authorLabel.text = self.book.author;
}

@end
