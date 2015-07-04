//
//  EUBook.h
//  EUBookShelf
//
//  Created by Giuseppe Morana on 03/07/15.
//  Copyright (c) 2015 eugenio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GMBook : NSObject

+ (GMBook *)bookWithDictionary:(NSDictionary *)dict;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSString *author;         // detail
@property (nonatomic, strong) NSNumber *price;          // detail
@property (nonatomic, strong) NSString *imageUrlString; // detail

@property (nonatomic, strong) UIImage *image;

/**
 * @return YES if author, price and imageUrlString are already populated
 */
- (BOOL)hasDetails;

@end
