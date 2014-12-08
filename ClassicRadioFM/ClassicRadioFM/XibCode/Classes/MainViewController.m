//
//  MainViewController.m
//  ClassicRadioFM
//
//  Created by xibic on 12/8/14.
//  Copyright (c) 2014 AppiWork. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController (){

    AudioStreamer *streamer;
    NSString *currentImageName;
    
}

@property (nonatomic, strong)IBOutlet UIButton *playButton;

- (IBAction)playButtonAction:(id)sender;
- (IBAction)fbShareButtonAction:(id)sender;

@end

@implementation MainViewController

@synthesize playButton;

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.playButton = nil;
}


#pragma mark - ViewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setButtonImageNamed:@"playbutton.png"];
}

//Change Button Display based on streaming state
- (void)setButtonImageNamed:(NSString *)imageName{
    
    if (!imageName){
        imageName = @"playbutton.png";
    }
    
    currentImageName = imageName;
    UIImage *image = [UIImage imageNamed:imageName];
    
    [self.playButton.layer removeAllAnimations];
    [self.playButton setImage:image forState:0];
    
    if ([imageName isEqual:@"loadingbutton.png"]){
        [self spinButton];
    }
}

#pragma mark - Button Action
//Play button
- (IBAction)playButtonAction:(id)sender{
    if ([currentImageName isEqual:@"playbutton.png"]){
        [self createStreamer];
        [self setButtonImageNamed:@"loadingbutton.png"];
        [streamer start];
    }
    else{
        [streamer stop];
    }
}


//Share button
- (IBAction)fbShareButtonAction:(id)sender{
}




//
// Shows the spin button when the audio is loading.
//
- (void)spinButton{
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    CGRect frame = [self.playButton frame];
    self.playButton.layer.anchorPoint = CGPointMake(0.5, 0.5);
    self.playButton.layer.position = CGPointMake(frame.origin.x + 0.5 * frame.size.width, frame.origin.y + 0.5 * frame.size.height);
    [CATransaction commit];
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];
    [CATransaction setValue:[NSNumber numberWithFloat:2.0] forKey:kCATransactionAnimationDuration];
    
    CABasicAnimation *animation;
    animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = [NSNumber numberWithFloat:0.0];
    animation.toValue = [NSNumber numberWithFloat:2 * M_PI];
    animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
    animation.delegate = self;
    [self.playButton.layer addAnimation:animation forKey:@"rotationAnimation"];
    
    [CATransaction commit];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished{
    if (finished){
        [self spinButton];
    }
}

#pragma mark - Streaming part
//
// Removes the streamer, the UI update timer and the change notification
//
- (void)destroyStreamer{
    if (streamer){
        [[NSNotificationCenter defaultCenter]
            removeObserver:self
            name:ASStatusChangedNotification
            object:streamer];

        [streamer stop];
        streamer = nil;
    }
}
//
// Creates or recreates the AudioStreamer object.
//
- (void)createStreamer{
    if (streamer) return;
    
    [self destroyStreamer];
    
    NSURL *url = [NSURL URLWithString:@"http://shoutmedia.abc.net.au:10326"];//demo url
    streamer = [[AudioStreamer alloc] initWithURL:url];

    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(playbackStateChanged:)
        name:ASStatusChangedNotification
        object:streamer];
    
}
//
// Invoked when the AudioStreamer
// reports that its playback status has changed.
//
- (void)playbackStateChanged:(NSNotification *)aNotification{
    if ([streamer isWaiting]){
        [self setButtonImageNamed:@"loadingbutton.png"];
    }else if ([streamer isPlaying]){
        [self setButtonImageNamed:@"stopbutton.png"];
    }else if ([streamer isIdle]){
        [self destroyStreamer];
        [self setButtonImageNamed:@"playbutton.png"];
    }
}
/*
//
// Invoked when the AudioStreamer
// reports that its playback progress has changed.
//
- (void)updateProgress:(NSTimer *)updatedTimer{
    
} 
*/
//
// dealloc
//
- (void)dealloc{
    [self destroyStreamer];
}

@end
