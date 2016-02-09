//
//  ViewController.m
//  connectionReseau
//
//  Created by xavier on 05/02/2016.
//  Copyright © 2016 xavier. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    NSMutableData * _receivedData;
    NSMutableArray * photoTitles;
    NSMutableArray * photoSmallImageData;
    NSMutableArray * photoURLsLargeImage;
}
@end

@implementation ViewController

//affichage de la marguerite
UIActivityIndicatorView *activityView;
UIActivityIndicatorView *activityViewTableCell;
NSMutableArray * smallPhotosURL;
NSMutableArray * largePhotosURL;
NSMutableDictionary * smallPhotosData;
NSUInteger currentLargeImageIndex;

CGFloat firstX;
CGFloat firstY;
CGFloat lastRotation;
CGContextRef * myContext;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tap requireGestureRecognizerToFail:self.longPress];
    
    photoTitles = [NSMutableArray new];
    photoSmallImageData = [NSMutableArray new];
    photoURLsLargeImage = [NSMutableArray new];
    smallPhotosURL = [NSMutableArray new];
    largePhotosURL = [NSMutableArray new];
    smallPhotosData = [NSMutableDictionary new];
    
    

    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.center =self.view.center;
    
    
    self.blurView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)connection:(NSConnection*)conn didReceiveResponse:(nonnull NSURLResponse *)response{
    if(!_receivedData){
        _receivedData = [NSMutableData new];
    }
    [_receivedData setLength:0];
    //NSLog(@"didReceiveReponse: reponseData length(%d)", _receivedData.length);
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(nonnull NSData *)data{
    [_receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(nonnull NSError *)error{
    
    [activityView stopAnimating];
    
    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message: [error localizedDescription]delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection{
    
   /* dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{*/
        
        NSLog(@"Succeeded! Receives %lu bytes of data", (unsigned long)[_receivedData length]);
        NSString *stringData = [[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding];
        NSLog(@"Reponse data being called: %@", stringData);
        NSError *error;
        
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:_receivedData options:0 error:&error];
        if(json == nil){
            NSLog(@"NULL");
        }else{
            NSLog(@"WORKED");
        }
        
        NSArray *photos = json[@"photos"][@"photo"];
        
        
        
        for(NSDictionary *photo in photos){
            
            // TITLE
            NSString *title = photo[@"title"];
            [photoTitles addObject:(title.length > 0 ? title : @"Untitled")];
            
            // SMALL IMAGE
            NSString *photoURLString = [NSString stringWithFormat:@"https://farm%@.static.flickr.com/%@/%@_%@_s.jpg",[photo objectForKey:@"farm"], [photo objectForKey:@"server"],[photo objectForKey:@"id"], [photo objectForKey:@"secret"]];
            [smallPhotosURL addObject:photoURLString];
             
            
            // LARGE IMAGE
            photoURLString =
            [NSString stringWithFormat:@"https://farm%@.static.flickr.com/%@/%@_%@.jpg",[photo objectForKey:@"farm"], [photo objectForKey:@"server"],[photo objectForKey:@"id"], [photo objectForKey:@"secret"]];
            [largePhotosURL addObject:photoURLString];
        }
    
    self.navigationItem.title = [NSString stringWithFormat:@"%li photos", (long)[photoTitles count] ];
    
    [self.tableView reloadData];
    
}

/*
 * Methodes delegate TableView
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [photoTitles count];
}

/*
 * Création des cellules du tableau
 */

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"maCellule" forIndexPath:indexPath];
    
    activityViewTableCell = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    cell.accessoryView = activityViewTableCell;
    [activityViewTableCell startAnimating];
    
    
    cell.imageView.image = [UIImage imageNamed:@"Paris-ciel-gris-orage"];
    cell.textLabel.text = [photoTitles objectAtIndex:indexPath.row];
    
    [activityView stopAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        UIImage * smallImg;
        
        NSString * key = [NSString stringWithFormat:@"%li", (long)indexPath.row];
        if([smallPhotosData objectForKey:key]){
            smallImg = [UIImage imageWithData: [smallPhotosData objectForKey:key]];
        } else{
            
            [smallPhotosData setObject:[NSData dataWithContentsOfURL:[NSURL URLWithString:[smallPhotosURL objectAtIndex:indexPath.row]]] forKey:key];
             smallImg = [UIImage imageWithData: [smallPhotosData objectForKey:key]];
        }
            
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            UITableViewCell * maCellule = [tableView cellForRowAtIndexPath:indexPath];
            if(maCellule){
                cell.imageView.image = smallImg;
                cell.accessoryView = nil;
            }
        });
    });

    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.blurView.hidden = NO;
    self.popUpImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[largePhotosURL objectAtIndex:indexPath.row]]]];
    currentLargeImageIndex = indexPath.row;
    // Save the initial position of the popUpImage 
    firstX = [self.popUpImage center].x;
    firstY = [self.popUpImage center].y;
}


#pragma Gestures
/*
 * Gestures
 */


// TAP - CLOSE BLUR VIEW
- (IBAction)tapGesture:(UITapGestureRecognizer *)sender{
    self.blurView.hidden = YES;
    [self resetPositionAndSizeImage];
}


- (IBAction)pinchAndRotationGesture:(UIGestureRecognizer *)sender {

    CGAffineTransform transform;
    
    // Rotation
    transform = CGAffineTransformMakeRotation(self.rotation.rotation);
    
    // Zoom +/-
    transform = CGAffineTransformScale(transform,self.pinch.scale, self.pinch.scale);
    self.popUpImage.transform = transform;
}

// MOVE IMAGE
/*- (IBAction)panGesture:(UIPanGestureRecognizer *)sender {

    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
    
    translatedPoint = CGPointMake(firstX+translatedPoint.x, firstY+translatedPoint.y);
    
    [self.popUpImage setCenter:translatedPoint];
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        
        CGFloat finalX = translatedPoint.x + (0*[(UIPanGestureRecognizer*)sender velocityInView:self.popUpImage].x);
        CGFloat finalY = translatedPoint.y + (0*[(UIPanGestureRecognizer*)sender velocityInView:self.popUpImage].y);
        
        [self.popUpImage setCenter:CGPointMake(finalX, finalY)];
    }
}*/


// RESET POSITION AND SIZE
- (IBAction)longPressGesture:(UILongPressGestureRecognizer *)sender {
    [self resetPositionAndSizeImage];
}

// SWIPE - CHANGE IMAGE
- (IBAction)swipeGestureRight:(UISwipeGestureRecognizer *)sender {
    if (currentLargeImageIndex != 0){
        self.popUpImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[largePhotosURL objectAtIndex:--currentLargeImageIndex]]]];
        [self resetPositionAndSizeImage];
    }
}

// SWIPE - CHANGE IMAGE
- (IBAction)swipeGestureLeft:(UISwipeGestureRecognizer *)sender {
    NSUInteger index = ++currentLargeImageIndex;
    if (index < [photoTitles count]){
        self.popUpImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[largePhotosURL objectAtIndex:index]]]];
        [self resetPositionAndSizeImage];
    }
}

// reset position and size method
- (void)resetPositionAndSizeImage{
    // annule déplacement
    [self.popUpImage setCenter:CGPointMake(firstX, firstY)];
    
    // annule rotations et zoom
    self.popUpImage.transform = CGAffineTransformIdentity;
    
}

// ALLOW MULTI SIMULTANEOUS GESTURES
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

/*
 * Bar de recherche
 */

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"Cancel");
}

- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar{
    NSLog(@"Go");
    [self getPhotos:searchBar.text];
    [searchBar resignFirstResponder];
}

- (void)getPhotos:(NSString *) query{
    
    
    [self.view addSubview:activityView];
    [activityView startAnimating];
    
    [photoTitles removeAllObjects];
    [photoSmallImageData removeAllObjects];
    [photoURLsLargeImage removeAllObjects];
    [smallPhotosURL removeAllObjects];
    [largePhotosURL removeAllObjects];
    [smallPhotosData removeAllObjects];
    
    NSURL *flickrGetURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.flickr.com/services/rest/?method=flickr.photos.search&tags=%@&safe_search=1&per_page=3000&format=json&nojsoncallback=1&api_key=efb4fd5e04fb8f0726fbb75c02782023", query]];
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:flickrGetURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
}

@end
