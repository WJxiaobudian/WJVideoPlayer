//
//  WJVideoPlayerController.m
//  WJVideoPlayer
//
//  Created by WJ on 16/6/17.
//  Copyright © 2016年 WJ. All rights reserved.
//

#import "WJVideoPlayerController.h"
#import "AppDelegate.h"

#import "WJVideoPlayerView.h"

#define NSUrl @"http://v.stu.126.net/mooc-video/nos/mp4/2015/05/08/1534082_sd.mp4?key=6c41d0758a2adcb750df19fc676e233e992f14081da5a13ef55f55c91f6195acfb712b3978ccfb86ed7bd969c6d0c4f8c67828585d0e00dce9fbf66689cf9ff13389d1e4d0884757973a81a0fd01ce17fbc78293fd295082129821b9aafff760ac2d80000c602942fa4509942b9285fbe88c01d51083d19b7f37bb90ce91f584ff95aee726907876d470c935a98ed296b407c478a81499a24006d50e873b5912"

@interface WJVideoPlayerController ()<WJPlayerViewDelegate>

@property (nonatomic, strong) WJVideoPlayerView *WJPlayer;

@end

@implementation WJVideoPlayerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [self initWJPlayer];
//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    appDelegate.isFullScreen = YES;
}

//-(void)viewWillDisappear:(BOOL)animated{
//    [super viewWillDisappear:animated];
//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    appDelegate.isFullScreen = NO;
//}

- (void)initWJPlayer {
    NSURL *url = [NSURL URLWithString:NSUrl];
    self.WJPlayer = [[WJVideoPlayerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300) contentURL:url];
    self.WJPlayer.delegate = self;
    [self.view addSubview:self.WJPlayer];
    [self.WJPlayer play];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return  UIInterfaceOrientationMaskLandscapeLeft;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

    [UIView animateWithDuration:0.5 animations:^{
        if (UIDeviceOrientationIsLandscape((UIDeviceOrientation)toInterfaceOrientation)) {
            self.WJPlayer.frame = CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width);
        } else {
            self.WJPlayer.frame = CGRectMake(0, 0, self.view.frame.size.height, 300);
        }
    } completion:^(BOOL finished) {
        
    }];
}
// 强制横屏
- (void)playerViewFullScreenButtonClicked:(WJVideoPlayerView *)view {
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:@selector(setOrientation:)];
            [invocation setTarget:[UIDevice currentDevice]];
            int val = UIInterfaceOrientationPortrait;
            [invocation setArgument:&val atIndex:2];
            [invocation invoke];
        
    
        } else {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:@selector(setOrientation:)];
            [invocation setTarget:[UIDevice currentDevice]];
            int val = UIInterfaceOrientationLandscapeRight;
            [invocation setArgument:&val  atIndex:2];
            [invocation invoke];
        }
    }

}

- (void)backBtn {
    [self.WJPlayer pause];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
