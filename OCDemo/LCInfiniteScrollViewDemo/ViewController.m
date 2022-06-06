//
//  ViewController.m
//  LCInfiniteScrollViewDemo
//
//  Created by 刘畅 on 2021/1/14.
//

#import "ViewController.h"
#import "LCInfiniteScrollView.h"
@interface ViewController ()<LCInfiniteScrollViewDelegate>
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) LCInfiniteScrollView *scrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.colors = @[UIColor.redColor,UIColor.orangeColor,UIColor.yellowColor];
    LCInfiniteScrollView *v = [[LCInfiniteScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
    v.backgroundColor = UIColor.brownColor;
    v.delegate = self;
    v.autoScroll = YES;
    [self.view addSubview:v];
    self.scrollView = v;
    [v reloadData];
    

    UIButton *clearbutton = [UIButton new];
    clearbutton.frame = CGRectMake(0, 400, 100, 40);
    [clearbutton setTitle:@"清空" forState:(UIControlStateNormal)];
    [clearbutton setTitleColor:UIColor.redColor forState:(UIControlStateNormal)];
    [clearbutton addTarget:self action:@selector(didSelectClear) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:clearbutton];
    
    UIButton *addbutton = [UIButton new];
    addbutton.frame = CGRectMake(self.view.frame.size.width/2-50, 400, 100, 40);
    [addbutton setTitle:@"1条数据" forState:(UIControlStateNormal)];
    [addbutton setTitleColor:UIColor.blueColor forState:(UIControlStateNormal)];
    [addbutton addTarget:self action:@selector(didSelectAdd) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:addbutton];
    
    UIButton *addbutton2 = [UIButton new];
    addbutton2.frame = CGRectMake(self.view.frame.size.width-100, 400, 100, 40);
    [addbutton2 setTitle:@"多条数据" forState:(UIControlStateNormal)];
    [addbutton2 setTitleColor:UIColor.blueColor forState:(UIControlStateNormal)];
    [addbutton2 addTarget:self action:@selector(didSelectAdd2) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:addbutton2];
}

- (void)didSelectClear {
    self.colors = nil;
    [self.scrollView reloadData];
}

- (void)didSelectAdd {
    self.colors = @[UIColor.magentaColor];
    [self.scrollView reloadData];
}

- (void)didSelectAdd2 {
    self.colors = @[UIColor.redColor,UIColor.orangeColor,UIColor.yellowColor];
    [self.scrollView reloadData];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

}
- (NSInteger)numberOfIndexesInInfiniteScrollView:(LCInfiniteScrollView *)infiniteScrollView {
    return self.colors.count;
}

- (void)infiniteScrollView:(LCInfiniteScrollView *)infiniteScrollView displayReusableView:(UIView *)reusableView atIndex:(NSInteger)index {
    UILabel *label = (UILabel *)reusableView;
    label.text = @(index).stringValue;
    label.backgroundColor = (UIColor *)self.colors[index];
}

- (UIView *)reusableViewInInfiniteScrollView:(LCInfiniteScrollView *)infiniteScrollView {
    UILabel *label = [UILabel new];
    label.font = [UIFont boldSystemFontOfSize:30];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (void)infiniteScrollView:(LCInfiniteScrollView *)infiniteScrollView didSelectIndex:(NSInteger)index {
    NSLog(@"%li",index);
}
@end
