//
//  GMThemeManager.m
//  GMBookShelf
//
//  Created by Giuseppe Morana on 08/07/15.
//  Copyright (c) 2015 eugenio. All rights reserved.
//

#import "GMTheme.h"

@implementation GMTheme

+ (UIImage *)placeholder {
    return [UIImage imageNamed:@"placeholder"];
}

+ (UIImage *)placeholderBig {
    return [UIImage imageNamed:@"placeholder_big"];
}

+ (UIColor *)backgroundColor {
    return [UIColor colorWithRed:(243.0f / 255.0f) green:(238.0f / 255.0f) blue:(234.0f / 255.0f) alpha:1.0f];
}

+ (UIColor *)foregroundColor {
    return [UIColor colorWithRed:(223.0f / 255.0f) green:(208.0f / 255.0f) blue:(208.0f / 255.0f) alpha:1.0f];
}

@end
