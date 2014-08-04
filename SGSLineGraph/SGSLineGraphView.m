//
//  SGSLineGraphView
//  
//
//  Created by PJ Gray on 12/9/12.
//  Copyright (c) 2012 Say Goodnight Software. All rights reserved.
//

#import "SGSLineGraphView.h"
#import "ASValuePopUpView.h"

@interface SGSLineGraphView () {
    ASValuePopUpView* _popUpView;
}

@end


@implementation SGSLineGraphViewComponent

- (id)init
{
    self = [super init];
    if (self)
    {
        _labelFormat = @"%.1f%%";
    }
    return self;
}

@end

@implementation SGSLineGraphView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setBackgroundColor:[UIColor clearColor]];
        self.interval = 20;
		self.maxValue = 100;
		self.minValue = 0;
        self.hackValueIDontKnowYouFigureItOutIHateThisArg = 0;
		self.yLabelFont = [UIFont boldSystemFontOfSize:14];
		self.xLabelFont = [UIFont boldSystemFontOfSize:12];
		self.valueLabelFont = [UIFont boldSystemFontOfSize:10];
		self.legendFont = [UIFont boldSystemFontOfSize:10];
        self.numYIntervals = 5;
        self.numXIntervals = 1;
        self.sideMargin = 45;
        
        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:singleTap];

        _popUpView = [[ASValuePopUpView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        self.popUpViewColor = [UIColor colorWithHue:0.6 saturation:0.6 brightness:0.5 alpha:0.8];
        _popUpView.alpha = 0.0;
        [self addSubview:_popUpView];

    }
    return self;
}

- (NSString*) shortFormCurrencyWithNumber:(NSNumber*) number withFormatter:(NSNumberFormatter*) nformat {
    
    double doubleValue = [number doubleValue];
    
    if (doubleValue < 1000) {
        NSString* stringValue = [NSString stringWithFormat: @"%@", [nformat stringFromNumber:number] ];
        if ( [stringValue hasSuffix:@".00"] )
            stringValue = [stringValue substringWithRange: NSMakeRange(0, [stringValue length]-3)];
        return stringValue;
    }
    
    NSString *stringValue = nil;
    
    [nformat setMaximumFractionDigits:0];
    
    NSArray *abbrevations = [NSArray arrayWithObjects:@"k", @"m", @"b", @"t", nil] ;
    
    for (NSString *s in abbrevations)
    {
        doubleValue /= 1000.0 ;
        if ( doubleValue < 1000.0 )
        {
            if ( (long long)doubleValue % (long long) 100 == 0 ) {
                [nformat setMaximumFractionDigits:0];
            } else {
                [nformat setMaximumFractionDigits:2];
            }
            
            stringValue = [NSString stringWithFormat: @"%@", [nformat stringFromNumber: [NSNumber numberWithDouble: doubleValue]] ];
            NSUInteger stringLen = [stringValue length];
            
            if ( [stringValue hasSuffix:@".00"] )
            {
                // Remove suffix
                stringValue = [stringValue substringWithRange: NSMakeRange(0, stringLen-3)];
            } else if ( [stringValue hasSuffix:@".0"] ) {
                
                // Remove suffix
                stringValue = [stringValue substringWithRange: NSMakeRange(0, stringLen-2)];
                
            }
            
            // Add the letter suffix at the end of it
            stringValue = [stringValue stringByAppendingString: s];
            
            break ;
        }
    }
    
    return stringValue;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
 
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(ctx);
    CGContextSetRGBFillColor(ctx, 0.2f, 0.2f, 0.2f, 1.0f);
    
    unsigned long n_div;
    float scale_min, scale_max, div_height;
    float top_margin = 35;
    float bottom_margin = 25;
	float x_label_height = 20;
	
    scale_min = self.minValue;
    scale_max = self.maxValue;
    
    n_div = self.numYIntervals+1;
    div_height = (self.frame.size.height-top_margin-bottom_margin-x_label_height)/(n_div-1);
    
    // first loop thru and get the largest width of the y axis labels
//    CGFloat largestTextWidth = 0.0f;
//    for (int i=0; i<n_div; i++)
//    {
//        float y_axis = (self.interval*n_div) - i*self.interval;
//        NSString* formatString;
//        if (self.yAxisLabelFormat) {
//            formatString = self.yAxisLabelFormat;
//        } else {
//            formatString = @"%f";
//        }
//        
//        NSString *text = [NSString stringWithFormat:formatString, y_axis];
//        
//        CGSize textSize = [text sizeWithFont:self.yLabelFont];
//        if (largestTextWidth < textSize.width) {
//            largestTextWidth = textSize.width;
//        }
//    }
    
//    if (self.sideMargin < largestTextWidth) {
//        self.sideMargin = largestTextWidth + 10.0f;
//    }

    // then loop thru and draw everything
    for (int i=0; i<n_div; i++)
    {
        float y_axis = scale_max - i*self.interval;
        
        int y = top_margin + div_height*i;
        
        NSString *text;
        if (self.yAxisLabelFormat) {
            text = [NSString stringWithFormat:self.yAxisLabelFormat, y_axis];
        } else if (self.yAxisFormatter) {
            text = [self shortFormCurrencyWithNumber:@(y_axis) withFormatter:self.yAxisFormatter];
        } else {
            text = [NSString stringWithFormat:@"%f", y_axis];
        }
        
        CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName:self.yLabelFont}];
        CGRect textFrame = CGRectMake(0,y-8,textSize.width,textSize.height);
        
        NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        textStyle.lineBreakMode = NSLineBreakByWordWrapping;
        textStyle.alignment = NSTextAlignmentRight;
        [text drawInRect:textFrame withAttributes:@{NSFontAttributeName:self.yLabelFont, NSParagraphStyleAttributeName:textStyle}];

		// These are "grid" lines
        CGContextSetLineWidth(ctx, 1);
        CGContextSetRGBStrokeColor(ctx, 0.4f, 0.4f, 0.4f, 0.1f);
        CGContextMoveToPoint(ctx, self.sideMargin, y);
        
        // this 40 is the estimated width of the xvalue label
        CGContextAddLineToPoint(ctx, self.frame.size.width, y);
        CGContextStrokePath(ctx);
    }
        
    float margin = self.sideMargin + 5;
    float div_width;
    if ([self.xLabels count] == 1)
    {
        div_width = 0;
    }
    else
    {
        div_width = (self.frame.size.width-margin-30)/([self.xLabels count]-1);
    }
    
    for (NSUInteger i=0; i<[self.xLabels count]; i++)
    {
        if (i % self.numXIntervals == 1 || self.numXIntervals==1) {
            int x = (int) (margin + div_width * i);
            NSString *x_label = [NSString stringWithFormat:@"%@", [self.xLabels objectAtIndex:i]];
            CGSize textSize = [x_label sizeWithAttributes:@{NSFontAttributeName:self.xLabelFont}];
            CGRect textFrame = CGRectMake(x, self.frame.size.height - x_label_height, textSize.width, x_label_height);
            NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            textStyle.lineBreakMode = NSLineBreakByWordWrapping;
            textStyle.alignment = NSTextAlignmentCenter;
            [x_label drawInRect:textFrame withAttributes:@{NSFontAttributeName:self.xLabelFont, NSParagraphStyleAttributeName:textStyle}];
        };
        
    }

}

- (void) setupGraphPaths {
    
    self.graphedPoints = @[].mutableCopy;
    
    unsigned long n_div;
    float scale_min, scale_max, div_height;
    float top_margin = 35;
    float bottom_margin = 25 + self.frame.origin.y;
	float x_label_height = 20;
	
    scale_min = self.minValue;
    scale_max = self.maxValue;
    
    n_div = self.numYIntervals+1;
    div_height = (self.frame.size.height-top_margin-bottom_margin-x_label_height)/(n_div-1);

    float margin = self.sideMargin + 20;
    float div_width;
    if ([self.xLabels count] == 1)
    {
        div_width = 0;
    }
    else
    {
        div_width = (self.frame.size.width-margin-20)/([self.xLabels count]-1);
    }

    float circle_diameter = 10;
    float circle_stroke_width = 3;
    float line_width = 4;
    
    for (SGSLineGraphViewComponent *component in self.components)
    {
        UIBezierPath *linesPath = [UIBezierPath bezierPath];
        _linesPathLayer = [CAShapeLayer layer];
        _linesPathLayer.frame = self.frame;
        _linesPathLayer.strokeColor = [component.colour CGColor];
        _linesPathLayer.fillColor = nil;
        _linesPathLayer.lineWidth = line_width;

        UIBezierPath *pointsPath = [UIBezierPath bezierPath];
        _pointsPathLayer = [CAShapeLayer layer];
        _pointsPathLayer.frame = self.frame;
        _pointsPathLayer.strokeColor = [component.colour CGColor];
        _pointsPathLayer.fillColor = nil;//[component.colour CGColor];
        _pointsPathLayer.lineWidth = circle_stroke_width;
        
        int last_x = 0;
        int last_y = 0;
        BOOL firstPoint = YES;
		for (int x_axis_index=0; x_axis_index<[component.points count]; x_axis_index++)
        {
            id object = [component.points objectAtIndex:x_axis_index];
			
            if (object!=[NSNull null] && object)
            {
                float value = [object floatValue];
				
                int x = margin+div_width*x_axis_index;
                
                // don't understand why i had to do this, someone needs to write a GOOD charting pod or something.  this sucks.
                int y = (top_margin+self.hackValueIDontKnowYouFigureItOutIHateThisArg) + (scale_max-value)/self.interval*div_height;
                
                CGRect circleRect = CGRectMake(x-circle_diameter/2, y-circle_diameter/2, circle_diameter,circle_diameter);
                CGPoint circleCenter = CGPointMake(circleRect.origin.x + (circleRect.size.width / 2), circleRect.origin.y + (circleRect.size.height / 2));

                [self.graphedPoints addObject:[NSValue valueWithCGPoint:circleCenter]];
                
                [pointsPath moveToPoint:CGPointMake(circleCenter.x+(circle_diameter/2), circleCenter.y)];
                [pointsPath addArcWithCenter:circleCenter radius:circle_diameter/2 startAngle:0 endAngle:2*M_PI clockwise:YES];

                if (!firstPoint)
                {
                    float distance = sqrt( pow(x-last_x, 2) + pow(y-last_y,2) );
                    float last_x1 = last_x + (circle_diameter/2) / distance * (x-last_x);
                    float last_y1 = last_y + (circle_diameter/2) / distance * (y-last_y);
                    float x1 = x - (circle_diameter/2) / distance * (x-last_x);
                    float y1 = y - (circle_diameter/2) / distance * (y-last_y);

                    [linesPath moveToPoint:CGPointMake(last_x1, last_y1)];
                    [linesPath addLineToPoint:CGPointMake(x1, y1)];
                }
				
                firstPoint = NO;
                last_x = x;
                last_y = y;
            }
            
        }
        
        _pointsPathLayer.path = pointsPath.CGPath;
        _linesPathLayer.path = linesPath.CGPath;
        
        [self.layer addSublayer:_linesPathLayer];
        [self.layer addSublayer:_pointsPathLayer];
        
    }
}

- (void) startDrawingAnimation {
    [self.layer removeAllAnimations];
    
    [CATransaction begin];
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 0.75;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    [CATransaction setCompletionBlock:^{
        self->_pointsPathLayer.strokeEnd = 1.0f;
        self->_pointsPathLayer.fillColor = self->_pointsPathLayer.strokeColor;
        self->_linesPathLayer.strokeEnd = 1.0f;
    }];
    
    [_pointsPathLayer addAnimation:pathAnimation forKey:@"animateStrokeEnd"];
    [_linesPathLayer addAnimation:pathAnimation forKey:@"animateStrokeEnd"];
    [CATransaction commit];
}

#pragma mark - taps

-(void) handleSingleTap:(UITapGestureRecognizer *)gr {
    [_popUpView hide];
    
    CGPoint tapPoint = [gr locationInView:self];
    
    NSInteger currentIndex = 0;
    CGPoint tappedIndexPoint;
    BOOL tappedIndex = NO;
    for (NSValue* pointValue in self.graphedPoints) {
        CGPoint point = pointValue.CGPointValue;
        if (
            (tapPoint.x > (point.x-22.0f)) &&
            (tapPoint.x < (point.x+22.0f)) &&
            (tapPoint.y > (point.y-22.0f)) &&
            (tapPoint.y < (point.y+22.0f))
            ) {
            tappedIndexPoint = point;
            tappedIndex = YES;
            break;
        } else {
            currentIndex++;
        }
    }
    if (tappedIndex) {
        
        CGRect thumbRect = CGRectMake(tappedIndexPoint.x, tappedIndexPoint.y - 10.0f, 1.0f, 1.0f);
        CGFloat thumbW = thumbRect.size.width;
        CGFloat thumbH = thumbRect.size.height;
        
        CGFloat width = 100.0f;
        CGFloat height = 44.0f;
        
        CGRect popUpRect = CGRectInset(thumbRect, (thumbW - width)/2, (thumbH - height)/2);
        popUpRect.origin.y = thumbRect.origin.y - height;
        
        // determine if popUpRect extends beyond the frame of the UISlider
        // if so adjust frame and set the center offset of the PopUpView's arrow
        CGFloat minOffsetX = CGRectGetMinX(popUpRect);
        CGFloat maxOffsetX = CGRectGetMaxX(popUpRect) - self.bounds.size.width;
        
        CGFloat offset = minOffsetX < 0.0 ? minOffsetX : (maxOffsetX > 0.0 ? maxOffsetX : 0.0);
        popUpRect.origin.x -= offset;
        
        [_popUpView setTextColor:[UIColor whiteColor]];
        [_popUpView setFont:[UIFont boldSystemFontOfSize:22.0f]];
        [_popUpView setCornerRadius:4.0f];
        [_popUpView setColor:self.popUpViewColor];
        [_popUpView setArrowCenterOffset:offset];
        _popUpView.frame = CGRectIntegral(popUpRect);
        
        
        SGSLineGraphViewComponent* firstComponent = self.components[0];
        NSString* stringToPopUp = [self shortFormCurrencyWithNumber:firstComponent.points[currentIndex] withFormatter:self.yAxisFormatter];
        [_popUpView setString:stringToPopUp];
        [_popUpView setAnimationOffset:0];
        
        [_popUpView show];
        
        NSLog(@"Tapped index: %ld (%@)",(long) currentIndex, NSStringFromCGPoint(tapPoint));
    }
}



@end
