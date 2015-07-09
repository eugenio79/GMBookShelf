//
//  GMBookDetailViewController.m
//  GMBookShelf
//
//  Created by Giuseppe Morana on 04/07/15.
//  Copyright (c) 2015 eugenio. All rights reserved.
//

#import "GMBookDetailViewController.h"
#import "GMHttpClient.h"
#import "GMTheme.h"

@interface GMBookDetailViewController() {
    UITapGestureRecognizer *_tapBehindGesture;
    BOOL _viewLoaded;
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *currencyLabel;

@end

@implementation GMBookDetailViewController

#pragma mark - controller lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView.layer.borderWidth = 1.0f;
    self.imageView.layer.borderColor = [GMTheme foregroundColor].CGColor;
    self.imageView.layer.cornerRadius = 5.0f;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFetchBookDetails:)
                                                 name:NOTIFICATION_DETAILS_RECEIVED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDownloadImage:)
                                                 name:NOTIFICATION_IMAGE_DOWNLOADED
                                               object:nil];
    
    [self _refreshDetails];
}

- (void)_refreshDetails {
    
    self.titleLabel.text = (self.book.title != nil) ? self.book.title : @"";
    self.authorLabel.text = (self.book.author != nil) ? self.book.author : @"";
    
    if (self.book.image != nil) {
        
        [self _updateImage:self.book.image];
    } else {
        self.imageView.image = [GMTheme placeholderBig];
    }
    self.priceLabel.text = (self.book.price != nil) ? [self.book.price description] : @"";
    self.currencyLabel.hidden = self.book.price == nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - utility methods

- (void)didFetchBookDetails:(NSNotification *)notification {
    
    GMBook *book = notification.userInfo[@"book"];
    
    if (![book.ID isEqualToString:self.book.ID]) {
        // not mine
        return;
    }
    
    if (notification.userInfo[@"error"] != nil) {
        
        NSLog(@"error while trying to fetch image at url: %@", book.imageUrlString);
        return;
    }
    
    self.book = book;
    [self _refreshDetails];
}

- (void)didDownloadImage:(NSNotification *)notification {
    
    GMBook *book = notification.userInfo[@"book"];
    
    if (![book.ID isEqualToString:self.book.ID]) {
        // not mine
        return;
    }
    
    if (notification.userInfo[@"error"] != nil) {
        
        NSLog(@"error while trying to fetch image at url: %@", book.imageUrlString);
        return;
    }
    
    UIImage *image = notification.userInfo[@"image"];
    if (image != nil) {
        [self _updateImage:self.book.image];
    } else {
        self.imageView.image = [GMTheme placeholderBig];
    }
}

- (void)_updateImage:(UIImage *)image {
    
    [UIView transitionWithView:self.imageView duration:0.3f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.imageView.image = image;
    } completion:nil];
}

@end
