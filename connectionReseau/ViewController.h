//
//  ViewController.h
//  connectionReseau
//
//  Created by xavier on 05/02/2016.
//  Copyright © 2016 xavier. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <NSURLConnectionDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *popUpImage;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIPinchGestureRecognizer *pinch;
@property (strong, nonatomic) IBOutlet UIRotationGestureRecognizer *rotation;
//@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *pan;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tap;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPress;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeRight;

@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeLeft;


- (IBAction)tapGesture:(UITapGestureRecognizer *)sender;
//- (IBAction)panGesture:(UIPanGestureRecognizer *)sender;
- (IBAction)longPressGesture:(UILongPressGestureRecognizer *)sender;
- (IBAction)swipeGestureRight:(UISwipeGestureRecognizer *)sender;
- (IBAction)swipeGestureLeft:(UISwipeGestureRecognizer *)sender;
- (IBAction)pinchAndRotationGesture:(UIGestureRecognizer *)sender;

@end

