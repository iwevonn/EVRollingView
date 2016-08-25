//
//  ViewController.m
//  EVRollingView
//
//  Created by iwevon on 16/8/15.
//  Copyright © 2016年 iwevon. All rights reserved.
//

#import "ViewController.h"
#import "EVRollingView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    EVRollingView *rollingView = [[EVRollingView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 40)];
    rollingView.titlesGroup = @[@"《千里赴蓉 只为活出个熊样》- 报道的是04年被解救的天津受虐黑熊艾玛，被送往成都治疗的事情。",@"《“徒儿” 休得无礼》- 西安名胜大雁塔南侧有尊高大的玄奘铜像，经常有孩童爬到“唐僧”身上玩耍，周围游客缤纷，这等行为甚是不雅。",@"《上课咋也“缺斤少两”》- 暂无内容"];
    rollingView.clickLableBlock =^(NSInteger index) {
        NSLog(@"点击了第%ld个Tip", index);
    };
    rollingView.titleColor = [UIColor yellowColor];
    rollingView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:rollingView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
