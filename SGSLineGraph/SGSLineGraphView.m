//
//  SGSLineGraphView
//  
//
//  Created by PJ Gray on 12/9/12.
//  Copyright (c) 2012 Say Goodnight Software. All rights reserved.
//

#import "SGSLineGraphView.h"

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

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        [self setBackgroundColor:[UIColor clearColor]];
        self.interval = 20;
		self.maxValue = 100;
		self.minValue = 0;
		self.yLabelFont = [UIFont boldSystemFontOfSize:14];
		self.xLabelFont = [UIFont boldSystemFontOfSize:12];
		self.valueLabelFont = [UIFont boldSystemFontOfSize:10];
		self.legendFont = [UIFont boldSystemFontOfSize:10];
        self.numYIntervals = 5;
        self.numXIntervals = 1;
        self.sideMargin = 45;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setBackgroundColor:[UIColor clearColor]];
        self.interval = 20;
		self.maxValue = 100;
		self.minValue = 0;
		self.yLabelFont = [UIFont boldSystemFontOfSize:14];
		self.xLabelFont = [UIFont boldSystemFontOfSize:12];
		self.valueLabelFont = [UIFont boldSystemFontOfSize:10];
		self.legendFont = [UIFont boldSystemFontOfSize:10];
        self.numYIntervals = 5;
        self.numXIntervals = 1;
        self.sideMargin = 45;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
 
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(ctx);
    CGContextSetRGBFillColor(ctx, 0.2f, 0.2f, 0.2f, 1.0f);
    
    int n_div;
    float scale_min, scale_max, div_height;
    float top_margin = 35;
    float bottom_margin = 25;
	float x_label_height = 20;
	
    scale_min = self.minValue;
    scale_max = self.maxValue;
    
    n_div = self.numYIntervals+1;
    div_height = (self.frame.size.height-top_margin-bottom_margin-x_label_height)/(n_div-1);
    
    // first loop thru and get the largest width of the y axis labels
    CGFloat largestTextWidth = 0.0f;
    for (int i=0; i<n_div; i++)
    {
        float y_axis = (self.interval*n_div) - i*self.interval;
        NSString* formatString;
        if (self.yAxisLabelFormat) {
            formatString = self.yAxisLabelFormat;
        } else {
            formatString = @"%f";
        }
        
        NSString *text = [NSString stringWithFormat:formatString, y_axis];
        
        CGSize textSize = [text sizeWithFont:self.yLabelFont];
        if (largestTextWidth < textSize.width) {
            largestTextWidth = textSize.width;
        }
    }
    
    if (self.sideMargin < largestTextWidth) {
        self.sideMargin = largestTextWidth + 10.0f;
    }

    // then loop thru and draw everything
    for (int i=0; i<n_div; i++)
    {
        float y_axis = scale_max - i*self.interval;
        
        int y = top_margin + div_height*i;
        
        NSString* formatString;
        if (self.yAxisLabelFormat) {
            formatString = self.yAxisLabelFormat;
        } else {
            formatString = @"%f";
        }

        NSString *text = [NSString stringWithFormat:formatString, y_axis];
        
        CGSize textSize = [text sizeWithFont:self.yLabelFont];
        CGRect textFrame = CGRectMake(0,y-8,textSize.width,textSize.height);
                
        [text drawInRect:textFrame
				withFont:self.yLabelFont
		   lineBreakMode:NSLineBreakByWordWrapping
			   alignment:NSTextAlignmentRight];
		
		// These are "grid" lines
        CGContextSetLineWidth(ctx, 1);
        CGContextSetRGBStrokeColor(ctx, 0.4f, 0.4f, 0.4f, 0.1f);
        CGContextMoveToPoint(ctx, self.sideMargin, y);
        
        // this 40 is the estimated width of the xvalue label
        CGContextAddLineToPoint(ctx, self.frame.size.width-self.sideMargin+40, y);
        CGContextStrokePath(ctx);
    }
        
    float margin = self.sideMargin;
    float div_width;
    if ([self.xLabels count] == 1)
    {
        div_width = 0;
    }
    else
    {
        div_width = (self.frame.size.width-2*margin)/([self.xLabels count]-1);
    }
    
    for (NSUInteger i=0; i<[self.xLabels count]; i++)
    {
        if (i % self.numXIntervals == 1 || self.numXIntervals==1) {
            int x = (int) (margin + div_width * i);
            NSString *x_label = [NSString stringWithFormat:@"%@", [self.xLabels objectAtIndex:i]];
            CGSize textSize = [x_label sizeWithFont:self.xLabelFont];
            CGRect textFrame = CGRectMake(x, self.frame.size.height - x_label_height, textSize.width, x_label_height);
            [x_label drawInRect:textFrame
                       withFont:self.xLabelFont
                  lineBreakMode:NSLineBreakByWordWrapping
                      alignment:NSTextAlignmentCenter];
        };
        
    }

}

- (void) setupGraphPaths {
    
    
    int n_div;
    float scale_min, scale_max, div_height;
    float top_margin = 35;
    float bottom_margin = 25;
	float x_label_height = 20;
	
    scale_min = self.minValue;
    scale_max = self.maxValue;
    
    n_div = self.numYIntervals+1;
    div_height = (self.frame.size.height-top_margin-bottom_margin-x_label_height)/(n_div-1);

    float margin = self.sideMargin;
    float div_width;
    if ([self.xLabels count] == 1)
    {
        div_width = 0;
    }
    else
    {
        div_width = (self.frame.size.width-2*margin)/([self.xLabels count]-1);
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
                
                // don't understand why i had to add this -14
                int y = (top_margin-14) + (scale_max-value)/self.interval*div_height;
                
                CGRect circleRect = CGRectMake(x-circle_diameter/2, y-circle_diameter/2, circle_diameter,circle_diameter);
                CGPoint circleCenter = CGPointMake(circleRect.origin.x + (circleRect.size.width / 2), circleRect.origin.y + (circleRect.size.height / 2));

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
        _pointsPathLayer.strokeEnd = 1.0f;
        _pointsPathLayer.fillColor = _pointsPathLayer.strokeColor;
        _linesPathLayer.strokeEnd = 1.0f;
    }];
    
    [_pointsPathLayer addAnimation:pathAnimation forKey:@"animateStrokeEnd"];
    [_linesPathLayer addAnimation:pathAnimation forKey:@"animateStrokeEnd"];
    [CATransaction commit];
}


@end
