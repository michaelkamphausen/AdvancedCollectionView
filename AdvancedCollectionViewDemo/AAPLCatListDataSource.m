/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  A basic data source that either fetches the list of all available cats.
  
 */

#import "AAPLCatListDataSource.h"
#import "AAPLCat.h"

#import "AAPLDataAccessManager.h"

@interface AAPLCatListDataSource ()
@end

@implementation AAPLCatListDataSource

- (void)registerReusableViewsWithCollectionView:(UICollectionView *)collectionView
{
    [super registerReusableViewsWithCollectionView:collectionView];
    [collectionView registerClass:[AAPLBasicCell class] forCellWithReuseIdentifier:NSStringFromClass([AAPLBasicCell class])];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AAPLCat *cat = [self itemAtIndexPath:indexPath];
    AAPLBasicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([AAPLBasicCell class]) forIndexPath:indexPath];
    cell.style = AAPLBasicCellStyleSubtitle;
    cell.primaryLabel.text = cat.name;
    cell.primaryLabel.font = [UIFont systemFontOfSize:14];
    cell.secondaryLabel.text = cat.shortDescription;
    cell.secondaryLabel.font = [UIFont systemFontOfSize:10];

    return cell;
}

- (void)setReversed:(BOOL)reversed
{
    if (reversed == _reversed)
        return;
    
    _reversed = reversed;
    [self resetContent];
    [self setNeedsLoadContent];
}

- (void)loadContent
{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        void (^handler)(NSArray *cats, NSError *error) = ^(NSArray *cats, NSError *error) {
            // Check to make certain a more recent call to load content hasn't superceded this one…
            if (!loading.current) {
                [loading ignore];
                return;
            }

            if (error) {
                [loading updateWithError:error];
                return;
            }

            if (cats.count)
                [loading updateWithContent:^(AAPLCatListDataSource *me) {
                    me.items = cats;
                }];
            else
                [loading updateWithNoContent:^(AAPLCatListDataSource *me) {
                    me.items = @[];
                }];
        };
        
        [[AAPLDataAccessManager manager] fetchCatListReversed:self.reversed withCompletionHandler:handler];
    }];
}

@end
