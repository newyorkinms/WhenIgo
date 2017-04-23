//
//  LaunchViewController.m
//  BZTimeCheck
//
//  Created by 강문성 on 2017. 4. 23..
//  Copyright © 2017년 강문성. All rights reserved.
//

#import "LaunchViewController.h"
#import "TabViewController.h"
#import <Lottie/Lottie.h>
@interface LaunchViewController ()
@property (nonatomic, strong) NSArray *jsonFiles;
@property (nonatomic, strong) LOTAnimationView *laAnimation;
@end

@implementation LaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self lottiTest];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect lottieRect = CGRectMake(0, 0, self.viewAni.bounds.size.width, self.viewAni.bounds.size.height );
    self.laAnimation.frame = lottieRect;
   

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)lottiTest{
    
    self.jsonFiles = [[NSBundle mainBundle] pathsForResourcesOfType:@"json" inDirectory:nil];
    NSString *fileURL = self.jsonFiles[10];
    NSArray *components = [fileURL componentsSeparatedByString:@"/"];
    NSLog(@" %@ ",components.lastObject);
    [self _loadAnimationNamed:@"clock.json"];
}
- (void)_loadAnimationNamed:(NSString *)named {
    [self.laAnimation removeFromSuperview];
    self.laAnimation = nil;
    NSLog(@"  named call %@ ", named);
    self.laAnimation = [LOTAnimationView animationNamed:named];
    self.laAnimation.contentMode = UIViewContentModeScaleAspectFit;
    [self.viewAni addSubview:self.laAnimation];
    [self.viewAni setNeedsLayout];
    [self playLottie];
}
-(void)playLottie{
    [self.laAnimation playWithCompletion:^(BOOL animationFinished) {
        NSLog(@"##");
        //UITabBarController *vc = [[TabViewController alloc]init];
        UIStoryboard *storyboard = self.storyboard;
        UITabBarController *vc = [storyboard instantiateViewControllerWithIdentifier:@"TabViewController"];
        //[svc createQueue];
        //UIViewController *svc = [storyboard instantiateViewControllerWithIdentifier:@"TabBar"];
        [self presentViewController:vc animated:YES completion:nil];
    }];
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
