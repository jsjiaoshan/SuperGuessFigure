//
//  ViewController.m
//  SuperGuessFigure
//
//  Created by 焦珊 on 2020/2/8.
//  Copyright © 2020 焦珊. All rights reserved.
//

#import "ViewController.h"
#import "QuestionModel.h"
@interface ViewController ()
@property (nonatomic, strong) NSArray *questions;
//记录图片索引
@property(nonatomic, assign) int index;
@property (weak, nonatomic) IBOutlet UILabel *labelIndex;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnScore;
@property (weak, nonatomic) IBOutlet UIButton *btnIcon;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;

- (IBAction)btnNextClick:(id)sender;

@end

@implementation ViewController
//状态栏是由d控制器管理，当前显示的是哪个控制器就由哪个控制器管理，以后还有其他的方面

//把状态栏的颜色改为浅色
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}
//懒加载数据
- (NSArray *)questions{
    if(_questions == nil){
        NSString *path = [[NSBundle mainBundle] pathForResource:@"questions.plist" ofType:nil];
        NSArray *arrayDIct = [NSArray arrayWithContentsOfFile:path];
        NSMutableArray *arrayModels = [NSMutableArray array];
        for(NSDictionary *dict in arrayDIct){
            QuestionModel *model = [QuestionModel QuestionWithDict:dict];
            [arrayModels addObject:model];
        }
        _questions = arrayModels;
    }
    return _questions;
}
//隐藏状态栏
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化处于第一张图
    self.index = -1;
    [self nextQuestion];
    // Do any additional setup after loading the view.
}


- (IBAction)btnNextClick:(id)sender {
    [self nextQuestion];
}

- (void)nextQuestion{
    //1.点击下一题的时候索引加一
    self.index ++;
    //2.h根据索引获取模型
    QuestionModel *model = self.questions[self.index];
    
    //3.根据获取的模型赋值
    self.labelIndex .text = [NSString stringWithFormat:@"%d / %ld",(self.index+1),self.questions.count];
    self.labelTitle.text = model.title;
    [self.btnIcon setImage:[UIImage imageNamed:model.icon] forState:UIControlStateNormal];
    
    //当索引到最后一张图的时候禁用按钮
    self.btnNext.enabled = ( self.index != self.questions.count - 1);
    
}
@end

