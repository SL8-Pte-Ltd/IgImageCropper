//
//  IGCropViewController.h
//  IGImageCropper
//
//  Created by arshad tp on 15/09/21.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN
@class IGCropViewController;
@protocol IGCropViewControllerDelegate <NSObject>

- (void)cropViewController:(IGCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect;
- (void)cropViewController:(IGCropViewController *)cropViewController didFinishCancelled:(BOOL)cancelled;

@end

@interface IGCropViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) NSString *_Nullable chooseButtonTitle;
@property (nonatomic, strong) NSString *_Nullable cancelButtonTitle;
@property (nonatomic, strong) UIColor *_Nullable chooseButtonColor;
@property (nonatomic, strong) UIColor *_Nullable cancelButtonColor;
@property (nonatomic) BOOL  isGif;

@property (nonatomic, strong) NSString *_Nullable sourcURL;

@property (nullable, nonatomic, weak) id<IGCropViewControllerDelegate> delegate;


- (instancetype) initWithImage: (UIImage *) image minimumPortraitWidth: (CGFloat) minimumPortraitWidth minimumLandScapeHeight: (CGFloat) minimumLandScapeHeight;
@end



NS_ASSUME_NONNULL_END
