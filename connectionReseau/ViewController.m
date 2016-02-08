//
//  ViewController.m
//  connectionReseau
//
//  Created by xavier on 05/02/2016.
//  Copyright © 2016 xavier. All rights reserved.
//

#import "ViewController.h"
#import "displayPictureViewController.h"

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


- (void)viewDidLoad {
    [super viewDidLoad];
    
    photoTitles = [NSMutableArray new];
    photoSmallImageData = [NSMutableArray new];
    photoURLsLargeImage = [NSMutableArray new];
    smallPhotosURL = [NSMutableArray new];
    largePhotosURL = [NSMutableArray new];
    smallPhotosData = [NSMutableDictionary new];
    
    

    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.center =self.view.center;
    
    
    self.popUpImage.hidden = YES;
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
        
        NSLog(@"Succeeded! Receives %d bytes of data", [_receivedData length]);
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
    self.popUpImage.hidden = NO;
    self.popUpImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[largePhotosURL objectAtIndex:indexPath.row]]]];
   
    
   /* self.popUpImage.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.popUpImage addGestureRecognizer:tap];*/
    
}

- (IBAction)tapGesture:(id)sender{
    self.popUpImage.hidden = YES;
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

/*
 * Prepare for segue
 */
/*- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"monSegue"]){
        
        displayPictureViewController * displayVC = segue.destinationViewController;
        NSIndexPath *ip = [self.tableView indexPathForSelectedRow];

        displayVC.largeImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[largePhotosURL objectAtIndex:ip.row]]]];
        
    }
}*/



/*- (void)toto{
    [UIView animateWithDuration:1.5
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         [myLabel setAlpha:0.0];
                     }
                     completion:nil];
}*/


@end
