//
//  driver_avplayer.h
//  lowang
//
//  Created by termit on 10/20/12.
//
//

#ifndef lowang_driver_avplayer_h
#define lowang_driver_avplayer_h

int AVPlayer_CD_Init(void);
void AVPlayer_CD_Shutdown(void);
int AVPlayer_CD_Play(int track, int loop);
void AVPlayer_CD_Stop(void);
void AVPlayer_CD_Pause(int pauseon);
int AVPlayer_CD_IsPlaying(void);
void AVPlayer_CD_SetVolume(int volume);


#endif
