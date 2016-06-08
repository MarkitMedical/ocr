//
//  textDetect.cpp
//  IPDFCameraViewControllerDemo
//
//  Created by incer on 16/6/3.
//  Copyright © 2016年 Maximilian Mackh. All rights reserved.
//

#include "textDetect.hpp"


vector<Mat> textdetect(Mat &large)
{
    vector<Mat> texts;
    Mat rgb;
    // downsample and use it for processing
    pyrDown(large, rgb);
    Mat small;
    cvtColor(rgb, small, CV_BGR2GRAY);
    // morphological gradient
    Mat grad;
    Mat morphKernel = getStructuringElement(MORPH_ELLIPSE, Size(3, 3));
    morphologyEx(small, grad, MORPH_GRADIENT, morphKernel);
    // binarize
    Mat bw;
    threshold(grad, bw, 0.0, 255.0, THRESH_BINARY | THRESH_OTSU);
    // connect horizontally oriented regions
    Mat connected;
    morphKernel = getStructuringElement(MORPH_RECT, Size(9, 1));
    morphologyEx(bw, connected, MORPH_CLOSE, morphKernel);
    // find contours
    Mat mask = Mat::zeros(bw.size(), CV_8UC1);
    std::vector<std::vector<cv::Point>> contours;
    std::vector<cv::Vec4i> hierarchy;
    findContours(connected, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, Point(0, 0));
    // filter contours
    for(int idx = 0; idx >= 0; idx = hierarchy[idx][0])
    {
        Rect rect = boundingRect(contours[idx]);
        Mat maskROI(mask, rect);
        maskROI = Scalar(0, 0, 0);
        // fill the contour
        drawContours(mask, contours, idx, Scalar(255, 255, 255), CV_FILLED);
        // ratio of non-zero pixels in the filled region
        double r = (double)countNonZero(maskROI)/(rect.width*rect.height);
        
        if (r > .45 /* assume at least 45% of the area is filled if it contains text */
            &&
            (rect.height > 8 && rect.width > 8) /* constraints on region size */
            /* these two conditions alone are not very robust. better to use something
             like the number of significant peaks in a horizontal projection as a third condition */
            )
        {
            rectangle(rgb, rect, Scalar(0, 255, 0), 2);
        }
    }
    return texts;
}