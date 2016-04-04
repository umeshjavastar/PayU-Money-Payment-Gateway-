//
//  PayUViewController.h
//  PayUDemo
//
//  Created by indianmesh on 1/25/16.
//  Copyright © 2016 indianmesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaymentStatusViewController.h"

@interface PayUViewController : UIViewController<UIWebViewDelegate>
{
    NSTimer *timer;
    NSURL *url ;
}
@property(nonatomic,retain)NSURL *url;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityind;
@property (weak, nonatomic) IBOutlet UIWebView *web_view_PayU;
@end
