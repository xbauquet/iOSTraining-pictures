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

/*- (id)init{
    if(self = [super init]){
        photoTitles = [NSMutableArray new];
        photoSmallImageData = [NSMutableArray new];
        photoURLsLargeImage = [NSMutableArray new];
    }
    return self;
}*/


- (void)viewDidLoad {
    [super viewDidLoad];
    
    photoTitles = [NSMutableArray new];
    photoSmallImageData = [NSMutableArray new];
    photoURLsLargeImage = [NSMutableArray new];

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
    NSLog(@"didReceiveReponse: reponseData length(%d)", _receivedData.length);
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(nonnull NSData *)data{
    [_receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(nonnull NSError *)error{
    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection{
    
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
        NSString *title = photo[@"title"];
        [photoTitles addObject:(title.length > 0 ? title : @"Untitled")];
        
        
        NSString *photoURLString = [NSString stringWithFormat:@"https://farm%@.static.flickr.com/%@/%@_%@_s.jpg",[photo objectForKey:@"farm"], [photo objectForKey:@"server"],[photo objectForKey:@"id"], [photo objectForKey:@"secret"]];
        
        NSLog(@"photoURLString: %@", photoURLString);
        
        // The performance (scrolling) of the table will be much better if we
        // build an array of the image data here, and then add this data as
        // the cell.image value (see cellForRowAtIndexPath:)
        [photoSmallImageData addObject:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoURLString]]];
        
        // Build and save the URL to the large image so we can zoom
        // in on the image if requested
        photoURLString =
        [NSString stringWithFormat:@"https://farm%@.static.flickr.com/%@/%@_%@_m.jpg",[photo objectForKey:@"farm"], [photo objectForKey:@"server"],[photo objectForKey:@"id"], [photo objectForKey:@"secret"]];
        [photoURLsLargeImage addObject:[NSURL URLWithString:photoURLString]];
        
        NSLog(@"photoURLsLareImage: %@\n\n", photoURLString);
        
    }
    [self.tableView reloadData];
}

// Methodes delegate TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [photoTitles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"maCellule" forIndexPath:indexPath];
    cell.textLabel.text = [photoTitles objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageWithData:[photoSmallImageData objectAtIndex:indexPath.row]];
    return cell;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"Cancel");
}

- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar{
    NSLog(@"Go");
    [self getPhotos:searchBar.text];
}

- (void)getPhotos:(NSString *) query{
    
    [photoTitles removeAllObjects];
    [photoSmallImageData removeAllObjects];
    [photoURLsLargeImage removeAllObjects];
    
    NSURL *flickrGetURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.flickr.com/services/rest/?method=flickr.photos.search&tags=%@&safe_search=1&per_page=20&format=json&nojsoncallback=1&api_key=efb4fd5e04fb8f0726fbb75c02782023", query]];
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:flickrGetURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
}

- (void)toto{
    [UIView animateWithDuration:1.5
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         [myLabel setAlpha:0.0];
                     }
                     completion:nil];
}

@end
