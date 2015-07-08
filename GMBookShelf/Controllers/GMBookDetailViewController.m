//
//  GMBookDetailViewController.m
//  GMBookShelf
//
//  Created by Giuseppe Morana on 04/07/15.
//  Copyright (c) 2015 eugenio. All rights reserved.
//

#import "GMBookDetailViewController.h"
#import "GMHttpClient.h"

@interface GMBookDetailViewController() {
    UITapGestureRecognizer *_tapBehindGesture;
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
    
    self.imageView.image = self.book.image;
    self.priceLabel.text = [self.book.price description];
    self.titleLabel.text = self.book.title;
    self.authorLabel.text = self.book.author;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDownloadImage:)
                                                 name:NOTIFICATION_IMAGE_DOWNLOADED
                                               object:nil];
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
        self.imageView.image = image;
    }
}

@end
