//
//  SGSViewController.m
//  SGSLineGraphSample
//
//  Created by PJ Gray on 12/10/12.
//  Copyright (c) 2012 Say Goodnight Software. All rights reserved.
//

#import "SGSViewController.h"
#import "SGSLineGraphView.h"

@interface SGSViewController ()

@end

@implementation SGSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.lineGraphView.minValue = 0;
    self.lineGraphView.maxValue = 500;
    
    self.lineGraphView.interval = self.lineGraphView.maxValue / self.lineGraphView.numYIntervals;
    
    
    SGSLineGraphViewComponent *component = [[SGSLineGraphViewComponent alloc] init];
    [component setTitle:@""];
    [component setPoints:@[@"100", @"200", @"250", @"300", @"50"]];
    [component setShouldLabelValues:YES];
    [component setLabelFormat:@"$%.0f%"];
    [component setColour:[UIColor colorWithRed:153/255.0 green:204/255.0 blue:51/255.0 alpha:1.0]];
    
    [self.lineGraphView setComponents:[@[component] mutableCopy]];
    [self.lineGraphView setXLabels:[@[@"2007",@"2008",@"2009",@"2010",@"2011"] mutableCopy]];
    
    [self.lineGraphView setupGraphPaths];
    [self.lineGraphView startDrawingAnimation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
