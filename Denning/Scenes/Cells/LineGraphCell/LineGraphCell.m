//
//  LineGraphCell.m
//  Denning
//
//  Created by Ho Thong Mee on 25/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "LineGraphCell.h"
#import "PNChartDelegate.h"
#import "PNChart.h"

@interface LineGraphCell()<PNChartDelegate>
@property (nonatomic) PNLineChart * lineChart;
@end

@implementation LineGraphCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)createLineGraph:(UIView*) view withGraphModel:(GraphModel*) graph
{
    self.graphCaption.text = graph.graphName;
    self.xLedgend.text = graph.xLegend;
    _yLedgend.text = graph.yLegend;
    
    self.lineChart.backgroundColor = [UIColor whiteColor];
    self.lineChart.yGridLinesColor = [UIColor grayColor];
    [self.lineChart.chartData enumerateObjectsUsingBlock:^(PNLineChartData *obj, NSUInteger idx, BOOL *stop) {
        obj.pointLabelColor = [UIColor blackColor];
    }];
    
    self.lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-20, 200.0)];
    self.lineChart.showCoordinateAxis = YES;
    self.lineChart.yLabelFormat = @"%1.2f";
    self.lineChart.xLabelFont = [UIFont fontWithName:@"Helvetica-Light" size:8.0];
    [self.lineChart setXLabels:graph.xValue];
    self.lineChart.yLabelColor = [UIColor blackColor];
    self.lineChart.xLabelColor = [UIColor blackColor];
    self.lineChart.showGenYLabels = NO;
    self.lineChart.showYGridLines = YES;
    
//    NSMutableArray* sortedArray = [NSMutableArray new];
//    for (NSString *val in graph.yValue) {
//        [sortedArray addObject:[NSNumber numberWithFloat:[val floatValue]]];
//    }
    
    //Use yFixedValueMax and yFixedValueMin to Fix the Max and Min Y Value
    //Only if you needed
//    self.lineChart.yFixedValueMax = 300.0;
//    self.lineChart.yFixedValueMin = 0.0;
//    
//    [self.lineChart setYLabels:graph.yValue
//     ];
    // Line Chart #1
    NSArray *data01Array = graph.yValue;
    data01Array = [[data01Array reverseObjectEnumerator] allObjects];
    PNLineChartData *data01 = [PNLineChartData new];
    
//    data01.dataTitle = @"Alpha";
    data01.color = [UIColor redColor];
    data01.pointLabelColor = [UIColor blackColor];
    data01.alpha = 0.3f;
    data01.showPointLabel = YES;
    data01.pointLabelFont = [UIFont fontWithName:@"Helvetica-Light" size:9.0];
    data01.itemCount = data01Array.count;
    data01.inflexionPointColor = [UIColor redColor];
    data01.inflexionPointStyle = PNLineChartPointStyleCircle;
    data01.getData = ^(NSUInteger index) {
        CGFloat yValue = [data01Array[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    self.lineChart.chartData = @[data01];
    [self.lineChart.chartData enumerateObjectsUsingBlock:^(PNLineChartData *obj, NSUInteger idx, BOOL *stop) {
        obj.pointLabelColor = [UIColor blackColor];
    }];
    
    [self.lineChart strokeChart];
    self.lineChart.delegate = self;
    
    [self.graphView addSubview:self.lineChart];
    
//    self.lineChart.legendStyle = PNLegendItemStyleStacked;
//    self.lineChart.legendFont = [UIFont boldSystemFontOfSize:12.0f];
//    self.lineChart.legendFontColor = [UIColor redColor];
//    
//    UIView *legend = [self.lineChart getLegendWithMaxWidth:320];
//    [legend setFrame:CGRectMake(30, 340, legend.frame.size.width, legend.frame.size.width)];
//    [self.graphView addSubview:legend];
}
@end
