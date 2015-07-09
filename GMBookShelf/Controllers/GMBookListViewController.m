//
//  ViewController.m
//  GMBookShelf
//
//  Created by Giuseppe Morana on 03/07/15.
//  Copyright (c) 2015 eugenio. All rights reserved.
//

#import "GMBookListViewController.h"
#import "GMHttpClient.h"
#import "GMCell.h"
#import "GMBookDetailViewController.h"
#import "GMActivityIndicatorView.h"
#import "GMCache.h"

#define GM_PAGE_SIZE 25
#define GM_FOOTER_HEIGHT 88.0f

static NSString * const BaseURLString = @"http://assignment.gae.golgek.mobi/api/v1/";

@interface GMBookListViewController () <UIGestureRecognizerDelegate, UIAlertViewDelegate> {
    GMHttpClient *_httpClient;
    NSMutableArray *_bookList;
    GMBook *_selectedBook;
    GMActivityIndicatorView *_actInd;
    BOOL _loading;
    BOOL _lastItemReached;                      // it'll become YES when the HTTP client'll answer with an empty array
    UITapGestureRecognizer *_tapBehindGesture;  // used when detail is presented modally (iPad)
    GMCache *_cache;
    BOOL _isAlertVisible;   // workaround to avoid multiple alerts to be displayed
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet UILabel *noNetworkLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBtnItem;
@end

@implementation GMBookListViewController

- (IBAction)refreshBtnTapped:(id)sender {
    
    self.refreshBtnItem.enabled = NO;
    
    [_bookList removeAllObjects];
    [_cache clear];
    [self.collectionView reloadData];
    [self _loadBookListPage];
}

#pragma mark - controller lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Book list";
    
    _bookList = [[NSMutableArray alloc] init];
    _cache = [GMCache sharedInstance];
    _httpClient = [GMHttpClient sharedInstance];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkStatusChanged:)
                                                 name:NOTIFICATION_NETWORK_STATUS_CHANGED
                                               object:nil];
    
    if ([_httpClient isOnline]) {
        [self _loadBookListPage];
    } else {
        self.noNetworkLabel.hidden = NO;
        self.collectionView.hidden = YES;
    }
}

- (void)networkStatusChanged:(NSNotification *)notification {
    
    GMHttpClientNetworkStatus networkStatus = (GMHttpClientNetworkStatus)[notification.userInfo[@"status"] integerValue];
    if ((networkStatus == GMHttpClientNetworkStatusOnline) && (_bookList.count == 0)) {
        [self _loadBookListPage];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"pushSegue"] ||
        [[segue identifier] isEqualToString:@"modalSegue"]) {
        
        GMBookDetailViewController *destinationViewController = segue.destinationViewController;
        destinationViewController.book = _selectedBook;
        
        [self _addTapBehindGesture];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [self.flowLayout invalidateLayout];
}

- (void)didReceiveMemoryWarning {
    
    [_bookList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GMBook *book = (GMBook *)obj;
        book.image = nil;
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _bookList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"GMCell";
    
    GMBook *currentBook = _bookList[indexPath.row];
    GMCell *cell = (GMCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.hSeparator.hidden = [self _hideHorizontalSeparator:indexPath];
    cell.vSeparator.hidden = [self _hideVerticalSeparator:indexPath];
    
    cell.book = currentBook;
    
    if (![currentBook hasDetails]) {
        
        [_httpClient requestDetailsForBookWithId:currentBook.ID withSuccessBlock:^(GMBook *bookWithDetails) {
            
            if (indexPath.row >= _bookList.count) return;
            
            _bookList[indexPath.row] = bookWithDetails;
            
            if (bookWithDetails.image == nil) {
                
                [_cache loadImageWithUrlString:bookWithDetails.imageUrlString withSuccessBlock:^(UIImage *imageCached) {
                    
                    bookWithDetails.image = imageCached;
                    
                    // because the user could've pressed the 'refresh' item in the meanwhile
                    if (indexPath.row < _bookList.count)
                        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                    
                } failure:^(NSError *error) {
                    
                    [_httpClient requestImageForBook:bookWithDetails withSuccessBlock:^(UIImage *image) {
                        
                        bookWithDetails.image = image;
                        
                        // because the user could've pressed the 'refresh' item in the meanwhile
                        if (indexPath.row < _bookList.count)
                            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                        
                        [_cache saveImage:bookWithDetails.image relatedToUrlString:bookWithDetails.imageUrlString];
                        
                    } failure:^(NSError *error) {
                        
                        NSLog(@"error while trying to fetch image at url: %@", bookWithDetails.imageUrlString);
                    }];
                }];
            }
        } failure:^(NSError *error) {
            
            NSLog(@"error while trying to get details for book: %@", currentBook.ID);
        }];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self _cellSize];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    _selectedBook = _bookList[indexPath.row];
    
    NSString *segue = [self _isPad] ? @"modalSegue" : @"pushSegue";
    
    [self performSegueWithIdentifier:segue sender:self];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *HeaderIdentifier = @"GMFooter";
    
    UICollectionReusableView *reusableview = nil;
    
     if (kind == UICollectionElementKindSectionFooter) {
        
        UICollectionReusableView *footerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:HeaderIdentifier forIndexPath:indexPath];
        
        reusableview = footerView;
    }
    
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    // http://stackoverflow.com/questions/24174456/issues-inserting-into-uicollectionview-section-which-contains-a-footer
    
    if (_bookList.count == 0) return CGSizeMake(0.001f, 0.001f);
    return _loading ? CGSizeMake(0.0f, GM_FOOTER_HEIGHT) : CGSizeMake(0.001f, 0.001f);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (_lastItemReached) return;
    
    CGFloat actualPosition = scrollView.contentOffset.y;
    CGFloat contentHeight = scrollView.contentSize.height - (self.collectionView.bounds.size.height);
    if (actualPosition >= contentHeight) {
        
        [self _loadBookListPage];
    }
}

#pragma mark - UIGestureRecognizer Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}



#pragma mark - utility methods

- (void)_loadBookListPage {
    
    // offline
    
    if (![_httpClient isOnline]) {
        
        if (_bookList.count == 0) {
            self.noNetworkLabel.hidden = NO;
            self.collectionView.hidden = YES;
        }
        return;
    }
    
    // online
    
    if (_loading) return;
    
    _loading = YES;
    _refreshBtnItem.enabled = NO;
    
    [self.flowLayout invalidateLayout]; // reload footer (loading)
    
    if ([_bookList count] == 0) {
        self.noNetworkLabel.hidden = YES;
        [self _showActInd];
    }
    
    [_httpClient requestBookListWithOffset:_bookList.count withCount:GM_PAGE_SIZE withSuccessBlock:^(NSArray *bookList) {
        
        if (bookList.count == 0) {
            _lastItemReached = YES;
        }
        else {
            self.collectionView.hidden = NO;
            self.noNetworkLabel.hidden = YES;
            [self _hideActInd];
            [_bookList addObjectsFromArray:bookList];
            [self.collectionView reloadData];
        }
        
        _loading = NO;
        _refreshBtnItem.enabled = YES;
        
    } failure:^(NSError *error) {
        
        _loading = NO;
        _refreshBtnItem.enabled = YES;
        
        [self _hideActInd];
        
        if (_bookList.count == 0) {
            self.noNetworkLabel.hidden = NO;
            self.collectionView.hidden = YES;
        } else {
            [self.flowLayout invalidateLayout]; // hide "loading" footer
        }
        
        [self _showErrorWithMessage:[error localizedDescription]];
    }];
}

- (void)_showErrorWithMessage:(NSString *)message {
    
    if (!_isAlertVisible) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        _isAlertVisible = YES;
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    _isAlertVisible = NO;
}

- (CGSize)_cellSize {
    
    CGFloat cellWidth;
    
    if (self.view.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
        
        // Compact (e.g. iPhone) - single column
        cellWidth = self.collectionView.frame.size.width;
        
    } else {
        
        // Regular (e.g. iPad) - double columns
        cellWidth = (self.collectionView.frame.size.width - self.flowLayout.minimumInteritemSpacing
                     ) / 2;
    }
    
    return CGSizeMake(cellWidth, 88.0f);
}

- (void)_addTapBehindGesture {
    
    if (![self _isPad]) return;
    
    if (_tapBehindGesture == nil) {
        _tapBehindGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapBehindDetected:)];
        [_tapBehindGesture setNumberOfTapsRequired:1];
        [_tapBehindGesture setCancelsTouchesInView:NO]; //So the user can still interact with controls in the modal view
        [_tapBehindGesture setDelegate:self];
    }
    [self.view.window addGestureRecognizer:_tapBehindGesture];
}

- (void)_removeTapBehindGesture {
    
    [self.view.window removeGestureRecognizer:_tapBehindGesture];
}

- (void)_showActInd {
    if (_actInd == nil) {
        _actInd = [GMActivityIndicatorView createIndicatorForView:self.navigationController.view];
    }
    [_actInd show];
}

- (void)_hideActInd {
    if (_actInd != nil) {
        [_actInd hide];
        _actInd = nil;
    }
}

// http://stackoverflow.com/questions/9102497/dismiss-modal-view-form-sheet-controller-on-outside-tap
// http://stackoverflow.com/questions/25638409/dismiss-modal-form-sheet-view-on-outside-tap-ios-8/25844208#25844208
- (void)_tapBehindDetected:(UITapGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        UIView *rootView = self.view.window.rootViewController.view;
        CGPoint location = [sender locationInView:rootView];
        if (![self.presentedViewController.view pointInside:[self.presentedViewController.view convertPoint:location fromView:rootView] withEvent:nil]) {
            
            [self dismissViewControllerAnimated:YES completion:^{
                [self _removeTapBehindGesture];
            }];
        }
    }
}

- (BOOL)_isPad {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

- (BOOL)_isOdd:(NSInteger)number {
    return ((number % 2) == 1);
}

/// display vertical separator only between two columns
- (BOOL)_hideHorizontalSeparator:(NSIndexPath *)indexPath {
    
    BOOL hide;
    if ([self _isPad]) {
        hide = (indexPath.row == _bookList.count - 1) ||
        ((indexPath.row == (_bookList.count - 2)) && ![self _isOdd:indexPath.row]);
    } else {
        hide = indexPath.row == (_bookList.count - 1);
    }
    return hide;
}

/// hide horizontal separator on the last row
- (BOOL)_hideVerticalSeparator:(NSIndexPath *)indexPath {
    
    BOOL hide;
    if ([self _isPad]) {
        hide = [self _isOdd:indexPath.row];
    } else {
        hide = YES;
    }
    return hide;
}

@end
