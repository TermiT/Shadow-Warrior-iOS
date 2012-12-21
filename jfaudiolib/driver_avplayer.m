//
//  driver_avplayer.m
//  lowang
//
//  Created by termit on 10/20/12.
//
//

#include <stdio.h>
#include "driver_avplayer.h"
#include "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

#ifdef __OBJC__

enum {
    CD_METHOD_INIT,
    CD_METHOD_SHUTDOWN,
    CD_METHOD_PLAY,
    CD_METHOD_STOP,
    CD_METHOD_PAUSE,
    CD_METHOD_IS_PLAYING,
    CD_METHOD_SET_VOLUME,
};

@interface CD_Player : NSObject

@property (assign, nonatomic) int method_id;
@property (readonly) int *args;
@property (assign, nonatomic) int retval;
@property (retain, nonatomic) AVAudioPlayer *cdplayer;

@end


#endif

static CD_Player *cd_player_instance = nil;

@implementation CD_Player {
    int method_id;
    int _args[5];
    int retval;
}

@synthesize method_id, retval, cdplayer;

- (int*)args { return &_args[0]; }

+ (CD_Player*)sharedInstance {
    if (cd_player_instance == nil) {
        cd_player_instance = [[CD_Player alloc] init];
    }
    return cd_player_instance;
}


- (int) CD_Init {
    return 0;
}

- (void) CD_Shutdown {
    //[cdplayer release];
}

- (int) CD_Play:(int)track loop:(int)loop {

    if (track < 2) {
        return 0;
    }
    
    [cdplayer release];
    
    
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *trackPath = [resourcePath stringByAppendingPathComponent:[NSString stringWithFormat:@"gamedata/music/track%02d.mp3", track]];
    NSURL *url = [NSURL fileURLWithPath:trackPath];
    NSError *error = nil;
    
    cdplayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (loop) {
        cdplayer.numberOfLoops = -1;
    } else {
        cdplayer.numberOfLoops = 0;
    }
    
    if (cdplayer == nil) {
        NSLog(@"CD_Play: could not create player");
        NSLog(@"CD_Play: %@", error.localizedDescription);
        return 0;
    }
    
    if (error != nil) {
        NSLog(@"CD_Play: %@", error.localizedDescription);
        return 0;
    }
    
    [cdplayer play];
    return 0;
}

- (void) CD_Stop {
    [cdplayer stop];
    [cdplayer release];
    cdplayer = nil;
}

- (void) CD_Pause:(int)pauseon {
    if (pauseon) {
        [cdplayer pause];
    } else {
        [cdplayer play];
    }
}

- (int) CD_IsPlaying {
    if (cdplayer == nil) {
        return 0;
    }
    return [cdplayer isPlaying];
}

- (void) CD_SetVolume:(int)volume {
    printf("*** CD_SetVolume(%d) ***\n", volume);
    printf("Not Implemented Yet");
}

- (void)invoke {
    switch (method_id) {
        case CD_METHOD_INIT:
            retval = [self CD_Init];
            break;
        case CD_METHOD_SHUTDOWN:
            [self CD_Shutdown];
            break;
        case CD_METHOD_PLAY:
            retval = [self CD_Play:_args[0] loop:_args[1]];
            break;
        case CD_METHOD_STOP:
            [self CD_Stop];
            break;
        case CD_METHOD_PAUSE:
            [self CD_Pause:_args[0]];
            break;
        case CD_METHOD_IS_PLAYING:
            retval = [self CD_IsPlaying];
            break;
        case CD_METHOD_SET_VOLUME:
            [self CD_SetVolume:_args[0]];
            break;
        default:
            break;
    }
}

- (void)dealloc {
    [cdplayer release];
    [super dealloc];
}

@end

int AVPlayer_CD_Init(void) {
    printf("*** CD_Init() ***\n");
    CD_Player *m = [CD_Player sharedInstance];
    m.method_id = CD_METHOD_INIT;
    [m performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:YES];
    return m.retval;
}

void AVPlayer_CD_Shutdown(void) {
    CD_Player *m = [CD_Player sharedInstance];
    m.method_id = CD_METHOD_SHUTDOWN;
    [m performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:YES];
}

int AVPlayer_CD_Play(int track, int loop) {
    printf("*** CD_Play(%d,%d) ***\n", track, loop);
    CD_Player *m = [CD_Player sharedInstance];
    m.method_id = CD_METHOD_PLAY;
    m.args[0] = track;
    m.args[1] = loop;
    [m performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:YES];
    return m.retval;
}

void AVPlayer_CD_Stop(void) {
    printf("*** CD_Stop() ***\n");
    CD_Player *m = [CD_Player sharedInstance];
    m.method_id = CD_METHOD_STOP;
    [m performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:YES];
}

void AVPlayer_CD_Pause(int pauseon) {
    CD_Player *m = [CD_Player sharedInstance];
    m.method_id = CD_METHOD_PAUSE;
    m.args[0] = pauseon;
    [m performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:YES];

}

int AVPlayer_CD_IsPlaying(void) {
    CD_Player *m = [CD_Player sharedInstance];
    m.method_id = CD_METHOD_IS_PLAYING;
    [m performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:YES];
    return m.retval;
}

void AVPlayer_CD_SetVolume(int volume) {
    CD_Player *m = [CD_Player sharedInstance];
    m.method_id = CD_METHOD_SET_VOLUME;
    m.args[0] = volume;
    [m performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:YES];
}
