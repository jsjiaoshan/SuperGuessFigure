//
//  ViewController.m
//  SuperGuessFigure
//
//  Created by 焦珊 on 2020/2/8.
//  Copyright © 2020 焦珊. All rights reserved.
//
//我们经常看到的@2x（点坐标的大小乘以2），@3x（点坐标大小乘以3）等等是什么意思，为什么同样一张图片要做很多张
//原因1>因为不同的iphone的屏幕大小可能不一样，即便同样大小的屏幕，分辨率也不一样
//所以为了在不同手机上都能正常显示或者说高质量显示，所以对于长的一样的图片要做不同的版本
//原因2>同一个图标在不同的地方显示，并且不同的地方需要的图片的尺寸是不一样的，所以在这种情况下也是需要多个图
//把图片不同尺寸做好放进去，自动适应
//Retina屏幕是值高清视网膜屏幕，分辨率s宽高是标准屏幕分辨的2倍
//点和像素(分辨率)的区别，像素是横纵分成多少份
//点坐标系，写的时候写50，表示是50，表示50个点，然后程序运行的时候苹果根据手机的屏幕材质如果不是
//视网膜屏幕那么就是一个点对应一个像素，视网膜屏幕那么就是一个点对应2个像素或者其它比例

//结论1:在同样一个尺寸的屏幕下由于使用的屏幕不一样（retina和非Retina）所以造成的屏幕分辩率会不同//也就是
//说同样是30*30的像素，在3.5inch大小的屏幕上，如果是非retina会显示大一些，retina屏幕
//显示会小一些
//结论2:所以在开发中使用的是点。比如使用30*30，不是表示30像素而是表示30点，ios系统会
//自动转换成对应的像素。
//1.非retina屏幕一个点表示一个像素
//2.retina屏幕一个点表示2像素
//3.iphone6 plus下一个点表示3像素
//结论3:因为程序中的是点，ios系统会自动把点转换成不同的像素去找图片
//所以图片对应的也要准备多分不同的图片
//@2x。@3x，比如btnlef这张图，在代码中写的时候使用的是btn_left,ios会根据实际的屏幕去查找
//btn_left,png或者是btn_left@2x.png或者btn_left@3xpng
//btn_left@2x.png或者btn_left@3xpng表示给视网膜屏幕用的
//对于开发人员只需要写图片名称即可，其它系统会自动去找
//启动图即使是用的launchscreen.xib歧视是截了一张图片，然后放在沙盒的library文件夹里面，还有一种设置启动图就是在项目里面设置即可
#import "ViewController.h"
#import "QuestionModel.h"
@interface ViewController () <UIAlertViewDelegate>
@property (nonatomic, strong) NSArray *questions;
//记录图片索引
@property(nonatomic, assign) int index;
@property (weak, nonatomic) IBOutlet UILabel *labelIndex;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnScore;
@property (weak, nonatomic) IBOutlet UIButton *btnIcon;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
- (IBAction)btnTip:(id)sender;
@property(nonatomic,assign) CGRect iconFrame;
//用来引用那个阴影按钮的属性
@property(nonatomic,weak) UIButton *cover; // 注意为什么这里用的是weak

@property (weak, nonatomic) IBOutlet UIView *answerBtns;
@property (weak, nonatomic) IBOutlet UIView *backAnswerBtns;

- (IBAction)btnBigImage:(id)sender;

- (IBAction)btnNextClick:(id)sender;
- (IBAction)HeaderImageChange:(id)sender;

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

#pragma mark --放大图片
- (IBAction)btnBigImage:(id)sender {
        //记录原始的frame
        self.iconFrame = self.btnIcon.frame;
        //1.创建一个与大小和self.view相同的按钮把这个按钮作为阴影
       UIButton  *btnCover = [[UIButton alloc] init];
        //2.设置阴影的大小，因为和view大小一样因此设置view的bounds大小即可
        btnCover.frame = self.view.bounds;
        //3.设置按钮背景色
        btnCover.backgroundColor = [UIColor blackColor];
       //添加点击阴影部分,把这个方法添加到这个控制器里面，由这个控制器监听
        [btnCover addTarget:self action:@selector(smallImage) forControlEvents:UIControlEventTouchUpInside];
        //5.把按钮添加到view上
        [self.view addSubview:btnCover];
        //6.把图片放置在阴影上面
        [self.view bringSubviewToFront:self.btnIcon];
        self.cover = btnCover;
        
        //动画让图片放大，放大到图片的宽和高相等，其中宽是屏幕的宽
        CGFloat iconWidth = self.view.frame.size.width;
        CGFloat iconHeight = iconWidth;
        CGFloat iconX = 0;
        CGFloat iconY = (self.view.frame.size.height - iconWidth)*0.5;
        
        [UIView animateWithDuration:0.7 animations:^{
            self.btnIcon.frame = CGRectMake(iconX, iconY,iconWidth, iconHeight);
            //4.设置阴影透明度
               btnCover.alpha = 0.6;
        }];
    
}
#pragma mark --缩小图片
- (void)smallImage{
    [UIView animateWithDuration:0.7 animations:^{
        //1.设置图片按钮的frame还原，因此我们需要一个变量保存原始的frame
           self.btnIcon.frame = self.iconFrame;
            //2.让阴影按钮的透明度变成
           self.cover.alpha = 0;
    } completion:^(BOOL finished) {
        //3.移除阴影按钮
        if(finished){
              [self.cover removeFromSuperview];
               self.cover = nil;
      //      /Users/jiaoshan/Desktop/网盘/second/SuperGuessFigure/SuperGuessFigure/Assets.xcassets
        }
    }];
}

- (IBAction)btnNextClick:(id)sender {
    [self nextQuestion];
}
#pragma mark --点击头像变大变小
- (IBAction)HeaderImageChange:(id)sender {
    if(self.cover == nil){
        [self btnBigImage:nil];
    }else{
        [self smallImage];
    }
}
//代理是一种设计模式给我们带来什么好处，实现事件机制，通知机制，解除耦合

#pragma mark --下一题
- (void)nextQuestion{
    //1.点击下一题的时候索引加一
    self.index ++;
    //判断是否越界，如果索引越界则提示用户
    if(self.index == self.questions.count){
        //我想要这个当前的控制器作为代理，因此我们当前的代理为当前控制器所以delegate那里传的是self,那么控制器必须遵守你的代理协议
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"操作提示" message:@"恭喜过关" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView  show];
        return;
    }
    //2.h根据索引获取模型
    QuestionModel *model = self.questions[self.index];
    
    //3.根据获取的模型赋值
    self.labelIndex .text = [NSString stringWithFormat:@"%d / %ld",(self.index+1),self.questions.count];
    self.labelTitle.text = model.title;
    [self.btnIcon setImage:[UIImage imageNamed:model.icon] forState:UIControlStateNormal];
    
    //当索引到最后一张图的时候禁用按钮
    self.btnNext.enabled = ( self.index != self.questions.count - 1);
    

    //生成待选项按钮模块
    [self settingData:model];
    
    //创建答案按钮
      [self settingAnswerData:model];
}
#pragma mark --实现uiAlertView的代理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0){
        self.index = -1;
        [self nextQuestion];
    }
}
#pragma mark -- 创建待选答案按钮
- (void) settingData:( QuestionModel *)model{
    //1.清除待选按钮的view
    [self.backAnswerBtns.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //2.获取当前问题的所有待选答案的数据
    NSArray *options = model.options;
    //3.动态创建循环创建所有待选按钮
    for(int i = 0; i < options.count ; i++){
        //创建按钮
        UIButton *btn = [[UIButton alloc] init];
        btn.tag = i;
        //设置按钮背景图
        [btn setBackgroundImage:  [UIImage imageNamed:@"btn_option"]   forState:UIControlStateNormal];
        [btn setBackgroundImage: [UIImage imageNamed:@"btn_option_highlighted"] forState:UIControlStateHighlighted];
        
        [btn setTitle:options[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //设置按钮的frame
        CGFloat width = 35;
        CGFloat height = 35;
        CGFloat margin = 13;
        int columns = 7;
        CGFloat marginLeft =( self.view.frame.size.width - columns*width - (columns-1)*margin)*0.5;
        //计算行列索引
        int colIdx = i%columns;
        int rowIdx = i /columns;
        CGFloat optionX = marginLeft + colIdx*(width+margin);
        CGFloat optionY = 0 + rowIdx * (height + margin);
        
        //   CGFloat btnX = (self.view.frame.size.width - (len-1)*10-len*width)*0.5 + i*(width+10);
        btn.frame = CGRectMake(optionX, optionY, 35, 35);
        [self.backAnswerBtns addSubview:btn];
        
        //创建单机事件为单选按钮
        [btn addTarget:self action:@selector(optionClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}
//待选按钮事件,因为有文字要传送，所以我们要有一个参数，点哪个按钮sender就指哪个按钮
- (void)optionClick:(UIButton *)sender{
    //要注意当所有的答案都被填满后，让其它的按钮都停止交互
       //1.隐藏按钮
       sender.hidden = YES;
       //2.获取按钮的文字,按钮获取文字要根据指定状态获取
    //   NSString *text = [sender titleForState:UIControlStateNormal];
       //3.获取当前状态下的文字
       NSString *text = sender.currentTitle;
       //把文字显示在答案按钮上
       for(UIButton *btn in self.answerBtns.subviews){
           if(btn.currentTitle == nil){
               //把这个的tag值也设置
               [btn setTitle:text forState:UIControlStateNormal];
               btn.tag = sender.tag;
               break;
           }
       }
    
    //假设一开始答案是满的
    BOOL isFull = YES;
    NSMutableString *userInput = [NSMutableString string];
    for(UIButton *btn in self.answerBtns.subviews){
        if(btn.currentTitle == nil){
            isFull = NO;
            break;
        }else{
            //把字符串拼接起来
            [userInput appendString:btn.currentTitle];
        }
    }

    //判断答案按钮是否已满，如果已满那么就是s剩余的制止交互
    if(isFull){
        //禁止单选按钮被点击
        self.backAnswerBtns.userInteractionEnabled = NO;
        //获取正确答案
     QuestionModel *anModel =   self.questions[self.index];
    //如果答案按钮被填满了那么久判断用户点击输入的答案是否与标准答案一致，如果一致就设置答案按钮的颜色为蓝色同时在0.5秒内跳转下一题，如果答案错误
        //设置答案按钮的文字颜色为红色
        if([anModel.answer isEqualToString:userInput]){
            [self setAnswerButtonTitleColor:[UIColor blueColor]];
            //加分
            [self addScore:100];
            //延迟0.5秒执行下一题
            [self performSelector:@selector(nextQuestion) withObject:nil afterDelay:0.5];
        }else{
            [self setAnswerButtonTitleColor:[UIColor redColor]];
             [self addScore:-100];
        }
    }
        
}
#pragma mark --答对或答错加减分
- (void)addScore:(int)score{
    //1.获取按钮上现在的分值
    NSString *str = self.btnScore.currentTitle;
    //2.把分值转换成数值类型
    int currerntScore = str.intValue;
    //3.对这个分数进行操作
    currerntScore = currerntScore + score;
    //4.把新的分数设置给按钮
    [self.btnScore setTitle:[NSString stringWithFormat:@"%d",currerntScore] forState:UIControlStateNormal];
}
- (void)setAnswerButtonTitleColor:(UIColor *)color{
    for(UIButton *btnAnswer in self.answerBtns.subviews){
        [btnAnswer setTitleColor:color forState:UIControlStateNormal];
    }
}

#pragma mark -- 创建答案按钮
- (void) settingAnswerData:( QuestionModel *)model{
    //记得要清除答案这些内容,让之前的答案数据中的每个答案按钮移除从父视图中
    [self.answerBtns.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //4.获取答案，根据答案的个数循环创建按钮
    NSUInteger len = model.answer.length;
    //根据答案的长度创建按钮
    for(int i = 0;i < len;i++){
        //创建按钮
        UIButton *btn = [[UIButton alloc] init];
        //设置按钮背景图
        [btn setBackgroundImage:  [UIImage imageNamed:@"btn_answer"]   forState:UIControlStateNormal];
        [btn setBackgroundImage: [UIImage imageNamed:@"btn_answer_highlighted"] forState:UIControlStateHighlighted];
        [btn setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
        //设置按钮的frame
        CGFloat width = 35;
        CGFloat height = 35;
        CGFloat btnY = 0;
        CGFloat btnX = (self.view.frame.size.width - (len-1)*10-len*width)*0.5 + i*(width+10);
        btn.frame = CGRectMake(btnX, btnY, width, height);
        [self.answerBtns addSubview:btn];
        
        //为答案按钮创建事件
        [btn addTarget:self action:@selector(btnAnswer:) forControlEvents:UIControlEventTouchUpInside];
    }
}
- (void)btnAnswer:(UIButton *)sender{
    self.backAnswerBtns.userInteractionEnabled = YES;
    [self setAnswerButtonTitleColor:[UIColor blueColor]];
    //启用之前待选a答案中被禁用e的
    self.backAnswerBtns.userInteractionEnabled = YES;
       //1.在"待选按钮"中找到与当前被点击的答案按钮文字相同待选按钮然后将其显示,画如果判断文j字会有相同文字时有bug
    //因此给tga值比较好
    for (UIButton *optBtn in self.backAnswerBtns.subviews) {
//        if([sender.currentTitle isEqualToString:optBtn.currentTitle ]){
//            optBtn.hidden = NO;
//            break;
//        }
        if(optBtn.tag == sender.tag){
            optBtn.hidden = NO;
              break;
        }
    }
    //清空当前被点击的答案文字
    [sender setTitle:nil forState:UIControlStateNormal];
    
}
- (IBAction)btnTip:(id)sender {
    //1.减分
    [self addScore:-1000];
    //2.把所有的答案按钮清空，
    for(UIButton *answerBtn in self.answerBtns.subviews){
        [self btnAnswer:answerBtn];
    }
    //3.根据当前的索引，从数据数组中找到对应的数据模型，从数据模型中获取正确答案的第一个字符，
    //把待选按钮中和这个字符相等的那个按钮点击一下
    QuestionModel *model = self.questions[self.index];
    //截取x正确答案的第一个字符串
    NSString *firstChar = [model.answer substringToIndex:1];
    //接下来根据这个字符，在option按钮中找到对应的option按钮让这个按钮点击一下
    for(UIButton *btn in self.backAnswerBtns.subviews){
        if([btn.currentTitle isEqualToString:firstChar]){
            [self optionClick:btn];
            break;
        }
    }
}
@end

