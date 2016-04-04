//
//  PayUViewController.m
//  PayUDemo
//
//  Created by indianmesh on 1/25/16.
//  Copyright © 2016 indianmesh. All rights reserved.
//

#import "PayUViewController.h"
#import <CommonCrypto/CommonDigest.h>
#define Success_URL @"http://www.google.co.in/"
#define Failure_URL @"http://www.bing.com/"
#define Product_Info @"Denim Jeans"
#define Paid_Amount @"1549.00"
#define Payee_Name @"Umesh Verma"

@interface PayUViewController ()
{
    NSString *strMIHPayID;
}
@end

@implementation PayUViewController
@synthesize url;
@synthesize web_view_PayU;
@synthesize activityind;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     [self payUinitialize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)createSHA512:(NSString *)string
{
    const char *cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:string.length];
    uint8_t digest[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(data.bytes, (CC_LONG)data.length, digest);
    NSMutableString* output = [NSMutableString  stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}

-(void)payUinitialize
{
    
    int i = arc4random() % 9999999999;
    NSString *strHash = [self createSHA512:[NSString stringWithFormat:@"%d%@",i,[NSDate date]]];
    strMIHPayID = [strHash substringToIndex:20];
    NSLog(@"tnx1 id %@",strMIHPayID);
    
    NSString *key = @"gtKFFx";
    NSString* salt = @"eCwWELxi";
    
    NSString *amount = Paid_Amount;
    NSString *productInfo = Product_Info;
    NSString *firstname = Payee_Name;
    NSString *email = @"umeshjavastar@gmail.com";
    NSString *phone = @"9598322632";
//     NSString *serviceprovider = @"payu_paisa";
    
    
    
    NSString *hashValue = [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@|||||||||||%@",key,strMIHPayID,amount,productInfo,firstname,email,salt];
    
    
    
    
    
    NSString *hash = [self createSHA512:hashValue];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:strMIHPayID,key,amount,productInfo,firstname,email,phone,Success_URL,Failure_URL,hash, nil] forKeys:[NSArray arrayWithObjects:@"txnid",@"key",@"amount",@"productinfo",@"firstname",@"email",@"phone",@"surl",@"furl",@"hash", nil]];
    
    
    
    
    
    
    __block NSString *post = @"";
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([post isEqualToString:@""]) {
            post = [NSString stringWithFormat:@"%@=%@",key,obj];
        }else{
            post = [NSString stringWithFormat:@"%@&%@=%@",post,key,obj];
        }
        
    }];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://test.payu.in/_payment"]]];
    // change URL for live
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
    [request setHTTPBody:postData];
    
    [web_view_PayU loadRequest:request];
    
}


-(void)webViewDidStartLoad:(UIWebView *)webView{
     NSLog(@"WebView started loading");
    activityind.hidden=FALSE;
    [activityind startAnimating];
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    activityind.hidden=TRUE;
    
    [activityind stopAnimating];
    
    if (web_view_PayU.isLoading)
        return;
    NSURL *requestURL = [[web_view_PayU request] URL];
    NSLog(@"WebView finished loading with requestURL: %@",requestURL);
    NSString *getStringFromUrl = [NSString stringWithFormat:@"%@",requestURL];
    if ([self containsString:getStringFromUrl :Success_URL]) {
        [self performSelector:@selector(delayedDidFinish:) withObject:getStringFromUrl afterDelay:0.0];
    } else if ([self containsString:getStringFromUrl :Failure_URL]) {
        // FAILURE ALERT
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Sorry !!!" message:@"Your transaction failed. Please try again!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        alert.tag = 1;
        [alert show];
    }
    
}



 #pragma UIWebView - Delegate Methods

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
//    [activityIndicatorView stopAnimating];
    NSURL *requestURL = [[web_view_PayU request] URL];
    NSLog(@"WebView failed loading with requestURL: %@ with error: %@ & error code: %ld",requestURL, [error localizedDescription], (long)[error code]);
    if (error.code == -1009 || error.code == -1003 || error.code == -1001 ||error.code == -1005) { //error.code == -999
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops !!!" message:@"Please check your internet connection!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        alert.tag = 1;
        [alert show];
    }
}
- (void)delayedDidFinish:(NSString *)getStringFromUrl {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *mutDictTransactionDetails = [[NSMutableDictionary alloc] init];
        [mutDictTransactionDetails setObject:strMIHPayID forKey:@"Transaction_ID"];
        [mutDictTransactionDetails setObject:@"Success" forKey:@"Transaction_Status"];
        [mutDictTransactionDetails setObject:Payee_Name forKey:@"Payee_Name"];
        [mutDictTransactionDetails setObject:Product_Info forKey:@"Product_Info"];
        [mutDictTransactionDetails setObject:Paid_Amount forKey:@"Paid_Amount"];
        [self navigateToPaymentStatusScreen:mutDictTransactionDetails];
    });
}

 #pragma UIAlertView - Delegate Method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1 && buttonIndex == 0) {
        // Navigate to Payment Status Screen
        NSMutableDictionary *mutDictTransactionDetails = [[NSMutableDictionary alloc] init];
        [mutDictTransactionDetails setObject:Payee_Name forKey:@"Payee_Name"];
        [mutDictTransactionDetails setObject:Product_Info forKey:@"Product_Info"];
        [mutDictTransactionDetails setObject:Paid_Amount forKey:@"Paid_Amount"];
        [mutDictTransactionDetails setObject:strMIHPayID forKey:@"Transaction_ID"];
        [mutDictTransactionDetails setObject:@"Failed" forKey:@"Transaction_Status"];
        [self navigateToPaymentStatusScreen:mutDictTransactionDetails];
    }
}
 
 - (BOOL)containsString: (NSString *)string : (NSString*)substring {
 return [string rangeOfString:substring].location != NSNotFound;
 }
 
- (void)navigateToPaymentStatusScreen: (NSMutableDictionary *)mutDictTransactionDetails {
    dispatch_async(dispatch_get_main_queue(), ^{
        PaymentStatusViewController *paymentStatusViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PaymentStatusViewController"];
        
//        paymentStatusViewController.mutDictTransactionDetails = mutDictTransactionDetails;
        [self.navigationController pushViewController:paymentStatusViewController animated:YES];
    });
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
