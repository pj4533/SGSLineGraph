//
//  SGSLineGraphView
//  
//
//  Created by PJ Gray on 12/9/12.
//  Copyright (c) 2012 Say Goodnight Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SGSLineGraphViewComponent : NSObject

@property (nonatomic, assign) BOOL shouldLabelValues;
@property (nonatomic, strong) NSArray *points;
@property (nonatomic, strong) UIColor *colour;
@property (nonatomic, copy) NSString *title, *labelFormat;
@property (nonatomic, strong) NSNumberFormatter* numberFormatter;

@end



@interface SGSLineGraphView : UIView {
    CAShapeLayer* _linesPathLayer;
    CAShapeLayer* _pointsPathLayer;
}

@property (nonatomic, assign) float interval;
@property (nonatomic, assign) float minValue;
@property (nonatomic, assign) float maxValue;

@property (nonatomic, strong) NSMutableArray *components, *xLabels;
@property (nonatomic, strong) UIFont *yLabelFont, *xLabelFont, *valueLabelFont, *legendFont;

// Use these to autoscale the y axis to 'nice' values.
// If used, minValue is ignored (0) and interval computed internally
@property (nonatomic, assign) BOOL autoscaleYAxis;
@property (nonatomic, assign) NSUInteger numYIntervals; // Use n*5 for best results
@property (nonatomic, assign) NSUInteger numXIntervals;

- (void) setupGraphPaths;
- (void) startDrawingAnimation;

@end
