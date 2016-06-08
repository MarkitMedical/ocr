//
//  ViewController.m
//  IPDFCameraViewController
//
//  Created by Maximilian Mackh on 11/01/15.
//  Copyright (c) 2015 Maximilian Mackh. All rights reserved.
//

#import "ViewController.h"

#import "IPDFCameraViewController.h"
#import "HorizontalScrollCell.h"
#import "textDetect.hpp"



@interface ViewController ()<HorizontalScrollCellDelegate>
{
    NSArray *images;
    NSMutableArray *tmp;
}
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet IPDFCameraViewController *cameraViewController;
@property (weak, nonatomic) IBOutlet UIImageView *focusIndicator;
- (IBAction)focusGesture:(id)sender;

- (IBAction)captureButton:(id)sender;

@end

@implementation ViewController

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.cameraViewController setupCameraView];
    [self.cameraViewController setEnableBorderDetection:YES];
    [self updateTitleLabel];
    tmp = [[NSMutableArray alloc]init];
    //[self prepareImages:NULL];
    [self setUpCollection];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.cameraViewController start];
}

#pragma mark -
#pragma mark collect view
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews
{
    [self.collection setFrame:CGRectMake(0, 736-200, self.view.frame.size.width, self.view.frame.size.height)];
}

-(void)prepareImages:(UIImage *)image
{
    [tmp addObject:image];
    images = [[NSArray alloc]initWithArray:tmp];
}

-(void)setUpCollection
{
    self.collection.delegate = self;
    self.collection.dataSource = self;
    
    UINib *hsCellNib = [UINib nibWithNibName:@"HorizontalScrollCell" bundle:nil];
    [self.collection registerNib:hsCellNib forCellWithReuseIdentifier:@"cvcHsc"];
    
    [self.collection reloadData];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HorizontalScrollCell *hsc =[collectionView dequeueReusableCellWithReuseIdentifier:@"cvcHsc"
                                                                         forIndexPath:indexPath];
    
    [hsc setBackgroundColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.5f]];
    [hsc setUpCellWithArray:images];
    [hsc.scroll setFrame:CGRectMake(hsc.scroll.frame.origin.x, hsc.scroll.frame.origin.y, hsc.frame.size.width, 200)];
    
    hsc.cellDelegate = self;
    
    return hsc;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize retval = CGSizeMake(self.view.frame.size.width - 10, 200);
    
    return retval;
}

-(void)cellSelected:(UIImage *)image
{
    NSLog(@"Selected !!");
    
    G8Tesseract *tesseract = [[G8Tesseract alloc] initWithLanguage:@"eng"];
    tesseract.delegate = self;
    tesseract.charWhitelist = @"0123456789";
    // Optional: Limit the area of the image Tesseract should recognize on to a rectangle
    tesseract.rect = CGRectMake(20, 20, 100, 100);
    
    // Optional: Limit recognition time with a few seconds
    tesseract.maximumRecognitionTime = 2.0;
    
    tesseract.image = [image g8_blackAndWhite];
    // Start the recognition
    [tesseract recognize];
    
    // Retrieve the recognized text
    NSLog(@"%@", [tesseract recognizedText]);
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark -
#pragma mark CameraVC Actions

- (IBAction)focusGesture:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateRecognized)
    {
        CGPoint location = [sender locationInView:self.cameraViewController];
        
        [self focusIndicatorAnimateToPoint:location];
        
        [self.cameraViewController focusAtPoint:location completionHandler:^
         {
             [self focusIndicatorAnimateToPoint:location];
         }];
    }
}

- (void)focusIndicatorAnimateToPoint:(CGPoint)targetPoint
{
    [self.focusIndicator setCenter:targetPoint];
    self.focusIndicator.alpha = 0.0;
    self.focusIndicator.hidden = NO;
    
    [UIView animateWithDuration:0.4 animations:^
    {
         self.focusIndicator.alpha = 1.0;
    }
    completion:^(BOOL finished)
    {
         [UIView animateWithDuration:0.4 animations:^
         {
             self.focusIndicator.alpha = 0.0;
         }];
     }];
}

- (IBAction)borderDetectToggle:(id)sender
{
    BOOL enable = !self.cameraViewController.isBorderDetectionEnabled;
    [self changeButton:sender targetTitle:(enable) ? @"CROP On" : @"CROP Off" toStateEnabled:enable];
    self.cameraViewController.enableBorderDetection = enable;
    [self updateTitleLabel];
}

- (IBAction)filterToggle:(id)sender
{
    [self.cameraViewController setCameraViewType:(self.cameraViewController.cameraViewType == IPDFCameraViewTypeBlackAndWhite) ? IPDFCameraViewTypeNormal : IPDFCameraViewTypeBlackAndWhite];
    [self updateTitleLabel];
}

- (IBAction)torchToggle:(id)sender
{
    BOOL enable = !self.cameraViewController.isTorchEnabled;
    [self changeButton:sender targetTitle:(enable) ? @"FLASH On" : @"FLASH Off" toStateEnabled:enable];
    self.cameraViewController.enableTorch = enable;
}

- (void)updateTitleLabel
{
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    animation.duration = 0.35;
    [self.titleLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];
    
    NSString *filterMode = (self.cameraViewController.cameraViewType == IPDFCameraViewTypeBlackAndWhite) ? @"TEXT FILTER" : @"COLOR FILTER";
    self.titleLabel.text = [filterMode stringByAppendingFormat:@" | %@",(self.cameraViewController.isBorderDetectionEnabled)?@"AUTOCROP On":@"AUTOCROP Off"];
}

- (void)changeButton:(UIButton *)button targetTitle:(NSString *)title toStateEnabled:(BOOL)enabled
{
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:(enabled) ? [UIColor colorWithRed:1 green:0.81 blue:0 alpha:1] : [UIColor whiteColor] forState:UIControlStateNormal];
}


#pragma mark -
#pragma mark CameraVC Capture Image

- (IBAction)captureButton:(id)sender
{
    __weak typeof(self) weakSelf = self;
    
    [self.cameraViewController captureImageWithCompletionHander:^(NSString *imageFilePath)
    {
        UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
        [self prepareImages:image];
        [self.collection reloadData];
        UIImageView *captureImageView = [[UIImageView alloc] initWithImage:image];
        captureImageView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
        captureImageView.frame = CGRectOffset(weakSelf.view.bounds, 0, -weakSelf.view.bounds.size.height);
        captureImageView.alpha = 1.0;
        captureImageView.contentMode = UIViewContentModeScaleAspectFit;
        captureImageView.userInteractionEnabled = YES;
        [weakSelf.view addSubview:captureImageView];
        
        UITapGestureRecognizer *dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:weakSelf action:@selector(dismissPreview:)];
        [captureImageView addGestureRecognizer:dismissTap];
        
        [UIView animateWithDuration:0.7 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:0.7 options:UIViewAnimationOptionAllowUserInteraction animations:^
        {
            captureImageView.frame = weakSelf.view.bounds;
        } completion:nil];
    }];
}

- (void)dismissPreview:(UITapGestureRecognizer *)dismissTap
{
    [UIView animateWithDuration:0.7 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:1.0 options:UIViewAnimationOptionAllowUserInteraction animations:^
    {
        dismissTap.view.frame = CGRectOffset(self.view.bounds, 0, self.view.bounds.size.height);
    }
    completion:^(BOOL finished)
    {
        [dismissTap.view removeFromSuperview];
    }];
}

@end
