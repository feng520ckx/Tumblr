//
//  KXPlayer.m
//  HYNetworking
//
//  Created by caikaixuan on 2018/1/10.
//  Copyright © 2018年 caikaixuan. All rights reserved.
//

#import "KXPlayer.h"
#import <AVFoundation/AVFoundation.h>

static NSString *const kKXPlayerStateLoadedTimeRanges = @"loadedTimeRanges";
static NSString *const kKXPlayerStateStatus = @"status";
static NSString *const kKXPlayerStatePlaybackBufferEmpty = @"playbackBufferEmpty";
static NSString *const kKXPlayerStatePlaybackLikelyToKeepUp = @"playbackLikelyToKeepUp";
static char *const kKXPlayerTimeQueueString = "com.kxplayer.time.queue";

@interface KXPlayer()

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) AVPlayerItem *currentItem;

@property (nonatomic, strong) AVURLAsset *playerAsset;

@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) AVAssetImageGenerator  *imageGenerator;

@property (nonatomic, strong) id                     timeObserve;

@property (nonatomic, strong) dispatch_queue_t timeQueue;


@end

@implementation KXPlayer

- (instancetype)initWithURL:(NSURL *)url{
    if (self =  [super init]) {
        
        [self initPlayerWithURL:url];
        
    }
    return self;
}

- (void)initPlayerWithURL:(NSURL *)url{
    if (self.playerAsset) self.playerAsset=nil;
    if (self.currentItem) self.currentItem=nil;
    if (self.player) self.player=nil;
    if (self.playerLayer) self.playerLayer=nil;
    if (self.imageGenerator) self.imageGenerator=nil;

    self.playerAsset = [AVURLAsset assetWithURL:url];
    self.currentItem = [[AVPlayerItem alloc]initWithAsset:self.playerAsset];
    self.player = [[AVPlayer alloc]initWithPlayerItem:self.currentItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.playerAsset];
    [self.imageGenerator cancelAllCGImageGeneration];
    self.imageGenerator.appliesPreferredTrackTransform = YES;
    self.imageGenerator.maximumSize = CGSizeMake(100, 56);
    
    [self initPlayerTimer];
}

- (void)initPlayerTimer{
    __weak typeof(self) weakSelf = self;
    self.timeQueue = dispatch_queue_create(kKXPlayerTimeQueueString, NULL);
    self.timeObserve =  [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1,1) queue:self.timeQueue usingBlock:^(CMTime time) {
        AVPlayerItem *currentItem = weakSelf.currentItem;
        NSArray *loadedRanges = currentItem.seekableTimeRanges;
        if (loadedRanges.count > 0 && currentItem.duration.timescale != 0) {
            KTime time;
            NSInteger currentTime = (NSInteger)CMTimeGetSeconds([currentItem currentTime]);
            weakSelf.currentTime = currentTime;
            time.currentTime=currentTime;
            CGFloat totalTime     = (CGFloat)currentItem.duration.value / currentItem.duration.timescale;
            time.duration=totalTime;
            time.value = (time.currentTime/time.duration);
            if (weakSelf.delegate&&[weakSelf.delegate respondsToSelector:@selector(player:slideTimeChange:)]) {
                [weakSelf.delegate player:weakSelf slideTimeChange:time];
            }
        }
    }];
}

- (void)releasePlayer{
    [self.player removeTimeObserver:self.timeObserve];
    [self.player pause];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    @try{
        [self.currentItem removeObserver:self forKeyPath:kKXPlayerStateStatus];
        [self.currentItem removeObserver:self forKeyPath:kKXPlayerStateLoadedTimeRanges];
        [self.currentItem removeObserver:self forKeyPath:kKXPlayerStatePlaybackBufferEmpty];
        [self.currentItem removeObserver:self forKeyPath:kKXPlayerStatePlaybackLikelyToKeepUp];
    }
    @catch(NSException *exction){
        NSLog(@"捕捉到异常--%@",exction);
    }
    self.player = nil;
    self.currentItem=nil;
    
}

- (void)dealloc
{
   if(self.player) {
      [self releasePlayer];
   }
}

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if (object == self.currentItem) {
        if ([keyPath isEqualToString:kKXPlayerStateStatus]) {//开始播放
            AVPlayerStatus status=[change[NSKeyValueChangeNewKey]intValue];
            switch (status) {
                case AVPlayerStatusUnknown:
                    self.playerState = KXPlayerStateUnKnow;
                    break;
                case AVPlayerStatusReadyToPlay:
                {
                    if (self.isAutoPlay) {
                        self.playerState = KXPlayerStatePlaying;
                        [self.player play];
                    }
                    else{
                        if (self.player.rate==0) {
                            self.playerState = KXPlayerStateKeepUp;
                        }
                    }
                }
                    break;
                case AVPlayerStatusFailed:
                    self.playerState = KXPlayerStateError;
                    break;
            }
        }
        else if([keyPath isEqualToString:kKXPlayerStateLoadedTimeRanges]){//缓冲进度
            
            CMTimeRange timeRange     = [[change[NSKeyValueChangeNewKey]firstObject] CMTimeRangeValue];
            KTime time;
            float startSeconds        = CMTimeGetSeconds(timeRange.start);
            float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
            time.currentTime = startSeconds + durationSeconds;
            time.duration = CMTimeGetSeconds(self.currentItem.duration);
            time.value = (time.currentTime/time.duration);
            if (self.delegate&&[self.delegate respondsToSelector:@selector(player:cacheTimeChange:)]) {
                [self.delegate player:self cacheTimeChange:time];
            }
        }
        else if([keyPath isEqualToString:kKXPlayerStatePlaybackBufferEmpty]){//菊花开始转
            if (self.currentItem.playbackBufferEmpty) {
                self.playerState = KXPlayerStateLoading;
            }
        }
        else if([keyPath isEqualToString:kKXPlayerStatePlaybackLikelyToKeepUp]){//可以播放
            if (self.duration == 0) {//
                self.duration = CMTimeGetSeconds(self.currentItem.duration);
            }
            if (self.playerState==KXPlayerStateLoading&&self.currentItem.playbackLikelyToKeepUp) {
                self.playerState = KXPlayerStateKeepUp;
            }
        }
    }
}


#pragma mark Video State methods

//播放结束
- (void)moviePlayDidEnd:(NSNotification *)notification{
    self.playerState = KXPlayerStateFinish;
    if (self.isLoop) {
        [self seekToTime:0];
        self.playerState = KXPlayerStatePlaying;
        [self.player play];
    }
}

//播放失败
- (void)moviePlayError:(NSNotification *)notification{
    self.playerState = KXPlayerStateError;
}

#pragma mark public methods

- (void)play{
    self.playerState = KXPlayerStatePlaying;
    [self.player play];
    
}
- (void)pause{
    if (self.playerState!=KXPlayerStatePaused) {
        [self.player pause];
        self.playerState = KXPlayerStatePaused;
    }
}
- (void)shutdown{
    
    [self releasePlayer];
}
- (void)seekToTime:(NSTimeInterval)time{
    [self.player pause];
    CMTime dragedCMTime = CMTimeMake(time, 1); //kCMTimeZero
    __weak typeof(self) weakSelf = self;
    [self.player seekToTime:dragedCMTime toleranceBefore:CMTimeMake(1,1) toleranceAfter:CMTimeMake(1,1) completionHandler:^(BOOL finished) {
        [weakSelf.player play];
    }];
}

- (void)switchVideoURL:(NSURL *)url{
    [self pause];
    self.playerAsset = [AVURLAsset assetWithURL:url];
    self.currentItem = [[AVPlayerItem alloc]initWithAsset:self.playerAsset];
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.playerAsset];
    [self.player replaceCurrentItemWithPlayerItem:self.currentItem];
    [self play];
    
    
}

- (void)seekToTime:(NSTimeInterval)time imageBlock:(DragSeekBlock)block{
    CMTime dragedCMTime   = CMTimeMake(time, 1);
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result != AVAssetImageGeneratorSucceeded) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(nil);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                block([UIImage imageWithCGImage:im]);
            });
        }
    };
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:dragedCMTime]] completionHandler:handler];
}

#pragma mark private methods


#pragma mark setter methods

- (void)setPlayerState:(KXPlayerState)playerState{
    _playerState=playerState;
    if (self.delegate&&[self.delegate respondsToSelector:@selector(player:stateChange:)]) {
        [self.delegate player:self stateChange:playerState];
    }
}

- (void)setPlayerLayerGravity:(KXPlayerLayerGravity)playerLayerGravity{
    _playerLayerGravity = playerLayerGravity;
    switch (playerLayerGravity) {
        case KXPlayerLayerGravityResizeAspect:
            self.playerLayer.videoGravity=AVLayerVideoGravityResizeAspect;
            break;
        case KXPlayerLayerGravityResizeAspectFill:
            self.playerLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;
            break;
        case KXPlayerLayerGravityResize:
            self.playerLayer.videoGravity=AVLayerVideoGravityResize;
            break;
    }
}

- (void)setPreView:(UIView *)preView{
    _preView=preView;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.playerLayer.frame=preView.bounds;
    [preView.layer addSublayer:self.playerLayer];
    self.playerState = KXPlayerStateLoading;
    if (self.isAutoPlay) {
        [self.player play];
    }
   
}

- (void)setIsMute:(BOOL)isMute{
    _isMute=isMute;
    [self.player setMuted:isMute];
    
}
- (void)setCurrentItem:(AVPlayerItem *)currentItem{
    if (_currentItem == currentItem ||(!currentItem))return;

    if (_currentItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [_currentItem removeObserver:self forKeyPath:kKXPlayerStateStatus];
        [_currentItem removeObserver:self forKeyPath:kKXPlayerStateLoadedTimeRanges];
        [_currentItem removeObserver:self forKeyPath:kKXPlayerStatePlaybackBufferEmpty];
        [_currentItem removeObserver:self forKeyPath:kKXPlayerStatePlaybackLikelyToKeepUp];
    }
    _currentItem = currentItem;
    if (currentItem) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:currentItem];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayError:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:currentItem];
        [self.currentItem addObserver:self forKeyPath:kKXPlayerStateStatus options:NSKeyValueObservingOptionNew context:nil];
        [self.currentItem addObserver:self forKeyPath:kKXPlayerStateLoadedTimeRanges options:NSKeyValueObservingOptionNew context:nil];
        [self.currentItem addObserver:self forKeyPath:kKXPlayerStatePlaybackBufferEmpty options:NSKeyValueObservingOptionNew context:nil];
        [self.currentItem addObserver:self forKeyPath:kKXPlayerStatePlaybackLikelyToKeepUp options:NSKeyValueObservingOptionNew context:nil];
    }
}



@end
