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


- (IBAction)tapGesture:(UITapGestureRecognizer *)sender;
- (IBAction)pinchGesture:(UIPinchGestureRecognizer *)sender;
- (IBAction)rotationGesture:(UIRotationGestureRecognizer *)sender;
- (IBAction)panGesture:(UIPanGestureRecognizer *)sender;
- (IBAction)longPressGesture:(UILongPressGestureRecognizer *)sender;

@end

