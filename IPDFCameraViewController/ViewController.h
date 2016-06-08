//
//  ViewController.h
//  IPDFCameraViewController
//
//  Created by Maximilian Mackh on 11/01/15.
//  Copyright (c) 2015 Maximilian Mackh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TesseractOCR/TesseractOCR.h>
#import <opencv2/highgui/ios.h>

@interface ViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, G8TesseractDelegate>


@property (weak, nonatomic) IBOutlet UICollectionView *collection;

@end

