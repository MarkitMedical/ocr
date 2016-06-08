//
//  textDetect.hpp
//  IPDFCameraViewControllerDemo
//
//  Created by incer on 16/6/3.
//  Copyright © 2016年 Maximilian Mackh. All rights reserved.
//

#ifndef textDetect_hpp
#define textDetect_hpp

#include <stdio.h>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>

using namespace cv;
using namespace std;

class textDetect{

public:
    vector<Mat> textdetect(Mat *image);

};
#endif /* textDetect_hpp */
