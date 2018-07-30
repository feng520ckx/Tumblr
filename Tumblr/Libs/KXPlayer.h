//
//  KXPlayer.h
//  HYNetworking
//
//  Created by caikaixuan on 2018/1/10.
//  Copyright © 2018年 caikaixuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,KXPlayerState){
    KXPlayerStatePlaying,            //开始播放
    KXPlayerStateFinish,             //播放完成
    KXPlayerStatePaused,             //暂停播放
    KXPlayerStateKeepUp,             //预播放状态
    KXPlayerStateLoading,            //缓冲中
    KXPlayerStateError,              //播放出错
    KXPlayerStateUnKnow,             //未知错误
};

typedef NS_ENUM(NSInteger,KXPlayerLayerGravity) {
    KXPlayerLayerGravityResizeAspect,     // 等比例填充，直到一个维度到达区域边界 默认
    KXPlayerLayerGravityResizeAspectFill, // 等比例填充，直到填充满整个视图区域，其中一个维度的部分区域会被裁剪
    KXPlayerLayerGravityResize          // 非均匀模式。两个维度完全填充至整个视图区域
};

typedef struct {
    NSTimeInterval currentTime;
    NSTimeInterval duration;
    float value;        //value is currentTime/totalTime
}KTime;

typedef void(^DragSeekBlock)(UIImage *image);
@class KXPlayer;
@protocol KXPlayerDelegate <NSObject>

- (void)player:(KXPlayer *)player stateChange:(KXPlayerState)state;
- (void)player:(KXPlayer *)player slideTimeChange:(KTime)time;
- (void)player:(KXPlayer *)player cacheTimeChange:(KTime)time;

@end

@interface KXPlayer : NSObject

- (instancetype)initWithURL:(NSURL *)url;

@property (nonatomic, retain) UIView *preView;

@property (nonatomic, weak) id<KXPlayerDelegate> delegate;

@property (nonatomic, assign) KXPlayerState playerState;

@property (nonatomic, assign) NSTimeInterval duration;

@property (nonatomic, assign) NSTimeInterval currentTime;

@property (nonatomic, assign) KXPlayerLayerGravity playerLayerGravity;

@property (nonatomic, assign) BOOL isLoop;//是否循环

@property (nonatomic, assign) BOOL isAutoPlay;//是否自动播放 默认不

@property (nonatomic, assign) BOOL isMute;

- (void)play;
- (void)pause;
- (void)shutdown;
- (void)seekToTime:(NSTimeInterval)time;
- (void)switchVideoURL:(NSURL *)url;
- (void)seekToTime:(NSTimeInterval)time imageBlock:(DragSeekBlock)block;


@end
