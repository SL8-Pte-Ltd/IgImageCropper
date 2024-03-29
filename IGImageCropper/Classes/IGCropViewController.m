//
//  IGCropViewController.m
//  IGImageCropper
//
//  Created by arshad tp on 15/09/21.
//

#import "IGCropViewController.h"
#import "UIImage+ImageLoad.h"


typedef NS_ENUM(NSInteger, ZoomScale) {
    ZoomScaleMinimum,
    ZoomScaleSquare,
};

static NSString * const _Nonnull FrameworkBundleId = @"org.cocoapods.IGImageCropper";

@interface IGCropViewController () {
    
    ZoomScale activeZoomScale;
    CGFloat initialScale;

}

@property (nonatomic) CGFloat minimumPortraitWidth;
@property (nonatomic) CGFloat minimumLandScapeHeight;
@property (nonatomic, strong) UIImage *image;
@property (weak, nonatomic) IBOutlet UIView *scrollViewContainer;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *adjustZoomScaleButton;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *cropMask;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *chooseButton;
@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;
@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *imageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *borderView;

@end

@implementation IGCropViewController


- (instancetype) initWithImage: (UIImage *) image minimumPortraitWidth: (CGFloat) minimumPortraitWidth minimumLandScapeHeight: (CGFloat) minimumLandScapeHeight  {
    
    self.minimumPortraitWidth = minimumPortraitWidth;
    self.minimumLandScapeHeight = minimumLandScapeHeight;
    self.image = image;
    initialScale = 1.0;
    activeZoomScale = ZoomScaleSquare;
    self = [super initWithNibName:@"IGCropViewController" bundle:[NSBundle bundleWithIdentifier:FrameworkBundleId]];
    return self;
    
}


#pragma mark - Life Cycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
    [self setImageToCrop];
}


#pragma mark - Util Methods

- (BOOL) isPortraitImage {
    return _image.size.width <= _image.size.height;
}

- (CGFloat) minZoomScale {
    if ([self isPortraitImage]) {
        CGFloat minHeight = UIScreen.mainScreen.bounds.size.width;
        CGFloat minWidth = (_image.size.width/_image.size.height) * minHeight;
        
        minWidth = minWidth < _minimumPortraitWidth ? _minimumPortraitWidth : minWidth;

        return minWidth/minHeight;
    }

    CGFloat minWidth = UIScreen.mainScreen.bounds.size.width;
    CGFloat minHeight = (_image.size.height/_image.size.width) * minWidth;
    
    minHeight = minHeight < _minimumLandScapeHeight ? _minimumLandScapeHeight : minHeight;

    return minHeight/minWidth;
}

- (UIImage *) cropImage {
    
    CGFloat zoomScale = _scrollView.zoomScale;
    CGFloat scale = 1/zoomScale * 1/initialScale;
    
    CGFloat x =  _scrollView.contentOffset.x * scale;
    CGFloat y = _scrollView.contentOffset.y * scale;
    CGFloat width = _scrollView.frame.size.width  * scale;
    CGFloat height = _scrollView.frame.size.height * scale;
    
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(_imageView.image.CGImage, CGRectMake(x, y, width, height));
    
    UIImage *croppedImage = [[UIImage alloc] initWithCGImage:imageRef];

    return croppedImage;
}

- (void) animateMaskViewToAlpha: (CGFloat) alpha {
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:1.5 animations:^{
        for (UIView *view in weakSelf.cropMask) {
            view.alpha = alpha;
        }
    }];
}

#pragma mark - Configs
- (void) configureView {
    
    [_adjustZoomScaleButton setImage:[UIImage bundledImageNamed:@"shrink" bundleId:FrameworkBundleId] forState:UIControlStateNormal];
    [_adjustZoomScaleButton setImage:[UIImage bundledImageNamed:@"expand" bundleId:FrameworkBundleId] forState:UIControlStateNormal];
    if(_isGif) {
        [_adjustZoomScaleButton setHidden:YES];
        _borderView.hidden = YES;
    }
    if (_chooseButtonTitle != NULL) {
        [_chooseButton setTitle:_chooseButtonTitle];
    }
    if (_cancelButtonTitle != NULL) {
        [_cancelButton setTitle:_cancelButtonTitle];
    }
    
    if (_chooseButtonColor != NULL) {
        [_chooseButton setTintColor:_chooseButtonColor];
    }
    if (_cancelButtonColor != NULL) {
        [_cancelButton setTintColor:_cancelButtonColor];
    }
    if (_cancelButtonTitle != NULL) {
        [_cancelButton setTitle:_cancelButtonTitle];
    }
    

    _borderView.layer.borderColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1].CGColor;
    _borderView.layer.borderWidth = 1;
}

- (void) setImageToCrop {
    
    if (_isGif) {
        UIImage* mygif = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:_sourcURL]];
        _imageView.image = mygif;
        _scrollView.minimumZoomScale = [self minZoomScale];
        _scrollView.maximumZoomScale = 5.0;
        _scrollView.contentSize = _imageView.frame.size;
        _scrollView.delegate = self;

    } else {
        _imageView.image = _image;
        if ([self isPortraitImage]) {
            // For portait image make width maximum as screen width and adjust the height accordingly
            CGFloat width = UIScreen.mainScreen.bounds.size.width;
            initialScale = width/_image.size.width;

            _imageViewWidthConstraint.constant = width;
            _imageViewHeightConstraint.constant = _image.size.height * initialScale;
        } else {
            // For portait image make height maximum as screen width and adjust the width accordingly
            CGFloat height = UIScreen.mainScreen.bounds.size.width; // first showing in square crop where width = screen width
            initialScale = height/_image.size.height;
            
            _imageViewWidthConstraint.constant = _image.size.width * initialScale;
            _imageViewHeightConstraint.constant = height;
            
        }
        _scrollView.minimumZoomScale = [self minZoomScale];
        _scrollView.maximumZoomScale = 5.0;
        _scrollView.contentSize = _imageView.frame.size;
        _scrollView.delegate = self;
    }
    
    
    
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - IBActions

- (IBAction)adjustZoomScaleAction:(id)sender {
    
    if (activeZoomScale == ZoomScaleSquare) {
        
        activeZoomScale = ZoomScaleMinimum;
        [_adjustZoomScaleButton setSelected: YES];
        [_scrollView setZoomScale:[self minZoomScale] animated:YES];
    } else {
        
        activeZoomScale = ZoomScaleSquare;
        [_adjustZoomScaleButton setSelected: NO];

        [_scrollView setZoomScale:1 animated:YES];
    }
}

- (IBAction)cancelAction:(id)sender {
    
    [self.delegate cropViewController:self didFinishCancelled:YES];
}
- (IBAction)chooseButtonAction:(id)sender {
    
    UIImage *croppedImage = self.image;

    if(!_isGif) {
        croppedImage = [self cropImage];
    }
    
    [self.delegate cropViewController:self didCropToImage:croppedImage withRect:CGRectMake(0, 0, croppedImage.size.width, croppedImage.size.height)];
}


#pragma mark - ScrollView Delegates

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
//    if ([self isPortraitImage]) {
//
//        CGFloat h =  (UIScreen.mainScreen.bounds.size.width - _imageView.frame.size.width) / 2;
//        _scrollView.contentInset = UIEdgeInsetsMake(0, h < 0 ? 0 : h, 0, 0);
//    } else {
//
//        CGFloat v =  (UIScreen.mainScreen.bounds.size.width - _imageView.frame.size.height) / 2;
//        _scrollView.contentInset = UIEdgeInsetsMake(v < 0 ? 0 : v, 0, 0, 0);
//
//    }
    
    CGFloat h =  (UIScreen.mainScreen.bounds.size.width - _imageView.frame.size.width) / 2;
    CGFloat v =  (UIScreen.mainScreen.bounds.size.width - _imageView.frame.size.height) / 2;
    _scrollView.contentInset = UIEdgeInsetsMake(v < 0 ? 0 : v, h < 0 ? 0 : h, 0, 0);



}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self animateMaskViewToAlpha:0.4];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    [self animateMaskViewToAlpha:1.0];
}

@end
