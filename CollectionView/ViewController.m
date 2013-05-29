/*
     File: ViewController.m
 Abstract: The primary view controller for this app.
 
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 */

#import "ViewController.h"
#import "Cell.h"
#import "AFHTTPRequestOperation.h"

NSString *kDetailedViewControllerID = @"DetailView";    // view controller storyboard id
NSString *kCellID = @"cellID";                          // UICollectionViewCell storyboard id

@implementation ViewController {
    NSOperationQueue *_downloadOperationQueue;
    NSString *_urlString;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _urlString = @"http://www.ubuntu.com/start-download?distro=desktop&bits=32&release=lts";
    
    UIBarButtonItem *afButton = [[UIBarButtonItem alloc] initWithTitle:@"AF" style:UIBarButtonItemStyleBordered target:self action:@selector(startAFDownload:)];
    UIBarButtonItem *blockButton = [[UIBarButtonItem alloc] initWithTitle:@"Block" style:UIBarButtonItemStyleBordered target:self action:@selector(startBlockDownload:)];
    self.navigationItem.rightBarButtonItem = afButton;
    self.navigationItem.leftBarButtonItem = blockButton;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return 364;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    // we're going to use a custom UICollectionViewCell, which will hold an image and its label
    //
    Cell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    
    return cell;
}

- (void)startAFDownload:(id)sender
{
    NSLog(@"starting AF download");
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_urlString]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setThreadPriority:0.1];
    
    //operation.runLoopModes = [NSSet setWithObject:NSDefaultRunLoopMode];
    
    
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"ubuntu-%f.iso", [NSDate timeIntervalSinceReferenceDate]]] append:NO];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully downloaded file!");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Download failed: %@", error);
    }];
    
    [[self downloadOperationQueue] addOperation:operation];
}

- (void)startBlockDownload:(id)sender
{
    NSLog(@"starting block download");
    
    dispatch_queue_t defQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    void (^downloadBlock) (void);
    
    downloadBlock = ^{
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_urlString]];
        NSURLResponse *response = nil;
        NSError *error = nil;
        
        NSData* result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
        
        NSLog(@"block request done");
    };
    
    dispatch_async(defQueue, downloadBlock);
}

- (NSOperationQueue *)downloadOperationQueue
{
    if (!_downloadOperationQueue) {
        _downloadOperationQueue = [[NSOperationQueue alloc] init];
        [_downloadOperationQueue setMaxConcurrentOperationCount:5];
    }
    
    return _downloadOperationQueue;
}

@end
