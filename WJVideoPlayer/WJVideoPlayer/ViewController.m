//
//  ViewController.m
//  WJVideoPlayer
//
//  Created by WJ on 16/6/17.
//  Copyright © 2016年 WJ. All rights reserved.
//

#import "ViewController.h"
#import "WJVideoPlayerController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 100, 150, 80);
    button.center = self.view.center;
    button.backgroundColor = [UIColor orangeColor];
    [button setTitle:@"播放视频" forState:UIControlStateNormal];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(PlayerVideo:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)PlayerVideo:(UIButton *)sender {
    [self.navigationController pushViewController:[[WJVideoPlayerController alloc] init] animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
