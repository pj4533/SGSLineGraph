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
    int power;
    float scale_min, scale_max, div_height;
    float top_margin = 35;
    float bottom_margin = 25;
	float x_label_height = 20;
	
    if (self.autoscaleYAxis) {
        scale_min = 0;
        power = floor(log10(self.maxValue/5));
        float increment = self.maxValue / (5 * pow(10,power));
        increment = (increment <= 5) ? ceil(increment) : 10;
        increment = increment * pow(10,power);
        scale_max = 5 * increment;
        self.interval = scale_max / self.numYIntervals;
    } else {
        scale_min = self.minValue;
        scale_max = self.maxValue;
    }
    n_div = (scale_max-scale_min)/self.interval + 1;
    div_height = (self.frame.size.height-top_margin-bottom_margin-x_label_height)/(n_div-1);
    
    for (int i=0; i<n_div; i++)
    {
        float y_axis = scale_max - i*self.interval;
        
        int y = top_margin + div_height*i;
        CGRect textFrame = CGRectMake(0,y-8,55,20);
        
        //        NSString *text = [NSString stringWithFormat:@"%.0f", y_axis];
        //        NSLog(@">>>>%@", text);
        
        NSString *formatString = [NSString stringWithFormat:@"%%.%if", (power < 0) ? -power : 0];
        NSString *text = [NSString stringWithFormat:formatString, y_axis];
        
        [text drawInRect:textFrame
				withFont:self.yLabelFont
		   lineBreakMode:NSLineBreakByWordWrapping
			   alignment:NSTextAlignmentRight];
		
		// These are "grid" lines
        CGContextSetLineWidth(ctx, 1);
        CGContextSetRGBStrokeColor(ctx, 0.4f, 0.4f, 0.4f, 0.1f);
        CGContextMoveToPoint(ctx, 30, y);
        CGContextAddLineToPoint(ctx, self.frame.size.width-30, y);
        CGContextStrokePath(ctx);
    }
    
    float margin = 45;
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
            CGRect textFrame = CGRectMake(x - 100, self.frame.size.height - x_label_height, 200, x_label_height);
            [x_label drawInRect:textFrame
                       withFont:self.xLabelFont
                  lineBreakMode:NSLineBreakByWordWrapping
                      alignment:NSTextAlignmentCenter];
        };
        
    }

}


- (void) addTextLayers {
    int n_div;
    int power;
    float scale_min, scale_max, div_height;
    float top_margin = 35;
    float bottom_margin = 25;
	float x_label_height = 20;
	
    if (self.autoscaleYAxis) {
        scale_min = 0.0;
        power = floor(log10(self.maxValue/5));
        float increment = self.maxValue / (5 * pow(10,power));
        increment = (increment <= 5) ? ceil(increment) : 10;
        increment = increment * pow(10,power);
        scale_max = 5 * increment;
        self.interval = scale_max / self.numYIntervals;
    } else {
        scale_min = self.minValue;
        scale_max = self.maxValue;
    }
    n_div = (scale_max-scale_min)/self.interval + 1;
    div_height = (self.frame.size.height-top_margin-bottom_margin-x_label_height)/(n_div-1);
    
    float margin = 45;
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

    for (int i=0; i<[self.xLabels count]; i++)
    {
        int y_level = top_margin;
		
        for (int j=0; j<[self.components count]; j++)
        {
			NSArray *items = [[self.components objectAtIndex:j] points];
            id object = [items objectAtIndex:i];
            if (object!=[NSNull null] && object)
            {
                float value = [object floatValue];
                int x = margin + div_width*i;
                int y = top_margin + (scale_max-value)/self.interval*div_height;
                int y1 = y - circle_diameter/2 - self.valueLabelFont.pointSize;
                int y2 = y + circle_diameter/2;
                
				if ([[self.components objectAtIndex:j] shouldLabelValues]) {
                    CATextLayer *textLayer = [CATextLayer layer];
                    textLayer.frame = CGRectMake(0,0, 50, 20);
                    SGSLineGraphViewComponent* thisComponent = self.components[j];
                    if (thisComponent.numberFormatter) {
                        NSNumber* numberValue = [NSNumber numberWithFloat:value];
                        textLayer.string = [thisComponent.numberFormatter stringFromNumber:numberValue];
                    } else {
                        textLayer.string = [NSString stringWithFormat:thisComponent.labelFormat, value];
                    }
                    textLayer.font = CGFontCreateWithFontName((__bridge CFStringRef)self.valueLabelFont.fontName);
                    textLayer.fontSize = self.valueLabelFont.pointSize;
                    textLayer.foregroundColor = [UIColor blackColor].CGColor;
                    textLayer.backgroundColor = [UIColor clearColor].CGColor;
                    textLayer.wrapped = NO;
                    textLayer.contentsScale = [[UIScreen mainScreen] scale];
                    [self.layer addSublayer:textLayer];
                    y_level = y2 + 20;

                    
                    // this is all gross code to make labels avoid graphs and being cut off the screen
					if (y1 > y_level) {
                        textLayer.position = CGPointMake(x+15, y1);
					} else if (y2 < y_level+20 && y2 < self.frame.size.height-top_margin-bottom_margin) {
                        if ((x+40+50) > self.frame.size.width)
                            textLayer.position = CGPointMake(x+10, y2);
                        else
                            textLayer.position = CGPointMake(x+40, y2);
					} else {
                        textLayer.position = CGPointMake(x, y-10);
					}
                }
                if (y+circle_diameter/2>y_level) y_level = y+circle_diameter/2;
            }
            
        }
    }

}

- (void) setupGraphPaths {
    
    
    int n_div;
    int power;
    float scale_min, scale_max, div_height;
    float top_margin = 35;
    float bottom_margin = 25;
	float x_label_height = 20;
	
    if (self.autoscaleYAxis) {
        scale_min = 0.0;
        power = floor(log10(self.maxValue/5));
        float increment = self.maxValue / (5 * pow(10,power));
        increment = (increment <= 5) ? ceil(increment) : 10;
        increment = increment * pow(10,power);
        scale_max = 5 * increment;
        self.interval = scale_max / self.numYIntervals;
    } else {
        scale_min = self.minValue;
        scale_max = self.maxValue;
    }
    n_div = (scale_max-scale_min)/self.interval + 1;
    div_height = (self.frame.size.height-top_margin-bottom_margin-x_label_height)/(n_div-1);

    float margin = 45;
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
				
                int x = 44+div_width*x_axis_index;
                
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
                
				
//                if (x_axis_index==[component.points count]-1)
//                {
//                    NSMutableDictionary *info = [NSMutableDictionary dictionary];
//                    if (component.title)
//                    {
//                        [info setObject:component.title forKey:@"title"];
//                    }
//                    [info setObject:[NSNumber numberWithFloat:x+circle_diameter/2+15] forKey:@"x"];
//                    [info setObject:[NSNumber numberWithFloat:y-10] forKey:@"y"];
//					[info setObject:component.colour forKey:@"colour"];
//                    [legends addObject:info];
//				}
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
        
        [self addTextLayers];
    }];
    
    [_pointsPathLayer addAnimation:pathAnimation forKey:@"animateStrokeEnd"];
    [_linesPathLayer addAnimation:pathAnimation forKey:@"animateStrokeEnd"];
    [CATransaction commit];
}


@end
