//
//  HorizontalScrollCell.m
//  MoviePicker
//
//  Created by Muratcan Celayir on 28.01.2015.
//  Copyright (c) 2015 Muratcan Celayir. All rights reserved.
//

#import "HorizontalScrollCell.h"


@implementation HorizontalScrollCell

- (void)awakeFromNib {
    // Initialization code
 
}

-(void)setUpCellWithArray:(NSArray *)array
{
    CGFloat xbase = 10;
    
    [self.scroll setScrollEnabled:YES];
    [self.scroll setShowsHorizontalScrollIndicator:NO];
    
    for(int i = 0; i < [array count]; i++)
    {
        UIImage *image = [array objectAtIndex:i];
        CGFloat width = 200*(image.size.width/image.size.height);
        UIView *custom = [self createCustomViewWithImage: image];
        [self.scroll addSubview:custom];
        [custom setFrame:CGRectMake(xbase, 7, width, 200)];
        xbase += 10 + width;
        
        
    }
    
    [self.scroll setContentSize:CGSizeMake(xbase, self.scroll.frame.size.height)];
    
    self.scroll.delegate = self;
}

-(UIView *)createCustomViewWithImage:(UIImage *)image
{
    CGFloat width = 200*(image.size.width/image.size.height);
    UIView *custom = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, 200)];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width, 200)];
    [imageView setImage:image];
    
    [custom addSubview:imageView];
    [custom setBackgroundColor:[UIColor whiteColor]];
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [custom addGestureRecognizer:singleFingerTap];
    
    return custom;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate

{
    [self containingScrollViewDidEndDragging:scrollView];
    
}

- (void)containingScrollViewDidEndDragging:(UIScrollView *)containingScrollView
{
    CGFloat minOffsetToTriggerRefresh = 25.0f;
    
    NSLog(@"%.2f",containingScrollView.contentOffset.x);
    
    NSLog(@"%.2f",self.scroll.contentSize.width);
    
    if (containingScrollView.contentOffset.x <= -50)
    {
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(-50 , 7, 100, 150)];
        
        UIActivityIndicatorView *acc = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        acc.hidesWhenStopped = YES;
        [view addSubview:acc];
        
        [acc setFrame:CGRectMake(view.center.x - 25, view.center.y - 25, 50, 50)];
        
        [view setBackgroundColor:[UIColor clearColor]];
        
        [self.scroll addSubview:view];
        
        [acc startAnimating];
        
        [UIView animateWithDuration: 0.3
         
                              delay: 0.0
         
                            options: UIViewAnimationOptionCurveEaseOut
         
                         animations:^{
                             
                             [containingScrollView setContentInset:UIEdgeInsetsMake(0, 100, 0, 0)];
                             
                         }
                         completion:nil];
        //[containingScrollView setContentInset:UIEdgeInsetsMake(0, 100, 0, 0)];
        
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"Started");
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                //Do whatever you want.
                
                NSLog(@"Refreshing");
                
               [NSThread sleepForTimeInterval:3.0];
                
                NSLog(@"refresh end");
                
                [UIView animateWithDuration: 0.3
                
                                      delay: 0.0
                
                                    options: UIViewAnimationOptionCurveEaseIn
                
                                 animations:^{
                
                                     [containingScrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
                
                                 }
                                                completion:nil];
            });
            
        });
        
    }
}

- (UIImage*) imageWithUIView:(UIView*) view{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(view.bounds.size);
    CGContextRef currnetContext = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:currnetContext];
    // 从当前context中创建一个改变大小后的图片
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    return image;
}

//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    NSLog(@"clicked");
    
    UIView *selectedView = (UIView *)recognizer.view;
    
    UIImage *image = [self imageWithUIView:selectedView];
    
    if([_cellDelegate respondsToSelector:@selector(cellSelected:)])
    {
        NSLog(@"ok");
        [_cellDelegate cellSelected:image];
        
    }
    
    //Do stuff here...
    
}

@end
