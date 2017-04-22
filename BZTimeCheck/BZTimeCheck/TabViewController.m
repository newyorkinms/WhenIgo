//
//  TabViewController.m
//  BZTimeCheck
//
//  Created by 강문성 on 2017. 4. 22..
//  Copyright © 2017년 강문성. All rights reserved.
//

#import "TabViewController.h"

@interface TabViewController ()

@end

@implementation TabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
    self.tabBar.tintColor = [UIColor orangeColor];
    self.tabBar.barTintColor = [UIColor whiteColor];
    
    
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
- (BOOL)tabBarController:(UITabBarController *)aTabBar
shouldSelectViewController:(UIViewController *)viewController
{
    if ( [aTabBar.viewControllers objectAtIndex:1] == viewController ){
        NSLog(@"###");
    }
    if ((viewController != [aTabBar.viewControllers objectAtIndex:0]) )
    {
        // Disable all but the first tab.
        return YES;
    }
    return YES;
}

@end
