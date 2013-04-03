#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import "EAGLView.h"
#include <unistd.h>
#include <pthread.h>
#include "gles_glue.h"
#include "iphone_api.h"
#import "baselayer.h"


#define GL_TEST 0

extern EAGLView *eaglview;
extern EAGLContext *eaglcontext;
extern int displaywidth, displayheight;

static pthread_t game_thread_handle;

static char *sw_argv[] = { "sw"};
static int sw_argc = sizeof(sw_argv)/sizeof(sw_argv[0]);

static char *td_argv[] = { "sw", "/GTD.ZIP"};
static int td_argc = sizeof(td_argv)/sizeof(td_argv[0]);

static char *wd_argv[] = { "sw", "/GWT.GRP"};
static int wd_argc = sizeof(wd_argv)/sizeof(wd_argv[0]);

void VID_SwapBuffers(void) {
    if (!appSuspended) {
        iphone_lock();
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, eaglview->renderbuffer);
        [eaglcontext presentRenderbuffer:GL_RENDERBUFFER_OES];
        iphone_unlock();
    }
}

#if GL_TEST

static
GLfloat v[] = {
    0.0, 0.0, 0.0, 
    1.0, 0.0, 0.0, 
    1.0, 1.0, 0.0, 
};

static
GLubyte c[] = {
    255, 255, 255, 255,
    255, 0, 255, 255,
    0, 255, 255, 255,
};
#endif

#define MAX_LEVELS_REG 29

void resetVars() {
    extern char quitevent;
    quitevent = 0;
    extern BOOL QuitFlag;
    QuitFlag = 0;
    extern BOOL MusicInitialized;
    MusicInitialized = FALSE;
    extern BOOL FxInitialized;
    FxInitialized = FALSE;
    extern BOOL Use_SoundSpriteNum;
    Use_SoundSpriteNum = FALSE;
    extern short SoundSpriteNum;
    SoundSpriteNum= -1;
    
    extern long xyaspect;
    extern long viewingrangerecip;
    extern long pixelaspect;
    extern long widescreen;
    extern long tallscreen;
    xyaspect = 0; viewingrangerecip= 0; pixelaspect = 0; widescreen = 0; tallscreen = 0;
    
    extern long xdim;
    extern long ydim;
    extern long ylookup[1600+1];
    extern long numpages;
    xdim = 0; ydim = 0; numpages = 0;
    for (int i =0; i < 16001; i++) {
        ylookup[i] = 0;
    }
    
    extern long *horizlookup;
    extern long *horizlookup2;
    extern long horizycent;
    horizlookup = NULL;
    horizlookup2 = NULL;
    horizycent = 0;

    extern long oxdimen;
    extern long oviewingrange;
    extern long oxyaspect;
    oxdimen = -1; oviewingrange = -1; oxyaspect = -1;
    
    
    // zip reset
    extern char *kzhashbuf;
    extern long kzhashead[256], kzhashpos, kzlastfnam, kzhashsiz;
    kzhashbuf = 0;
    for (int i =0; i < 256; i++) {
        kzhashead[i] = 0;
    }
    kzhashpos = 0;
    kzlastfnam = 0;
    kzhashsiz = 0;
    
    typedef struct
    {
        char *LevelName;
        char *SongName;
        char *Description;
        char *BestTime;
        char *ParTime;
    }LEVEL_INFO, *LEVEL_INFOp, **LEVEL_INFOpp;
    
    extern LEVEL_INFO LevelInfo[MAX_LEVELS_REG+2];
    LEVEL_INFO NewLevelInfo[MAX_LEVELS_REG+2] = {
        {"title.map",      "theme.mid", " ", " ", " "  },
        {"$bullet.map",    "e1l01.mid", "Seppuku Station", "0 : 55", "5 : 00"  },
        {"$dozer.map",     "e1l03.mid", "Zilla Construction", "4 : 59", "8 : 00"  },
        {"$shrine.map",    "e1l02.mid", "Master Leep's Temple", "3 : 16", "10 : 00"  },
        {"$woods.map",     "e1l04.mid", "Dark Woods of the Serpent", "7 : 06", "16 : 00"  },
        {"$whirl.map",     "yokoha03.mid", "Rising Son", "5 : 30", "10 : 00"   },
        {"$tank.map",      "nippon34.mid", "Killing Fields", "1 : 46", "4 : 00"   },
        {"$boat.map",      "execut11.mid", "Hara-Kiri Harbor", "1 : 56", "4 : 00"   },
        {"$garden.map",    "execut11.mid", "Zilla's Villa", "1 : 06", "2 : 00"   },
        {"$outpost.map",   "sanai.mid",    "Monastery", "1 : 23", "3 : 00"      },
        {"$hidtemp.map",   "kotec2.mid",   "Raider of the Lost Wang", "2 : 05", "4 : 10"     },
        {"$plax1.map",     "kotec2.mid",   "Sumo Sky Palace", "6 : 32", "12 : 00"     },
        {"$bath.map",      "yokoha03.mid", "Bath House", "10 : 00", "10 : 00"   },
        {"$airport.map",   "nippon34.mid", "Unfriendly Skies", "2 : 59", "6 : 00"   },
        {"$refiner.map",   "kotoki12.mid", "Crude Oil", "2 : 40", "5 : 00"   },
        {"$newmine.map",   "hoshia02.mid", "Coolie Mines", "2 : 48", "6 : 00"   },
        {"$subbase.map",   "hoshia02.mid", "Subpen 7", "2 : 02", "4 : 00"   },
        {"$rock.map",      "kotoki12.mid", "The Great Escape", "3 : 18", "6 : 00"   },
        {"$yamato.map",    "sanai.mid",    "Floating Fortress", "11 : 38", "20 : 00"      },
        {"$seabase.map",   "kotec2.mid",   "Water Torture", "5 : 07", "10 : 00"     },
        {"$volcano.map",   "kotec2.mid",   "Stone Rain", "9 : 15", "20 : 00"     },
        {"$shore.map",     "kotec2.mid",   "Shanghai Shipwreck", "3 : 58", "8 : 00"     },
        {"$auto.map",      "kotec2.mid",   "Auto Maul", "4 : 07", "8 : 00"     },
        {"tank.map",       "kotec2.mid",   "Heavy Metal (DM only)", "10 : 00", "10 : 00"     },
        {"$dmwoods.map",   "kotec2.mid",   "Ripper Valley (DM only)", "10 : 00", "10 : 00"     },
        {"$dmshrin.map",   "kotec2.mid",   "House of Wang (DM only)", "10 : 00", "10 : 00"     },
        {"$rush.map",      "kotec2.mid",   "Lo Wang Rally (DM only)", "10 : 00", "10 : 00"     },
        {"shotgun.map",    "kotec2.mid",   "Ruins of the Ronin (CTF)", "10 : 00", "10 : 00"     },
        {"$dmdrop.map",    "kotec2.mid",   "Killing Fields (CTF)", "10 : 00", "10 : 00"     },
        {NULL, NULL, NULL, NULL, NULL}
    };
    
    memcpy(LevelInfo, NewLevelInfo, sizeof(NewLevelInfo));
}


static
void* GameThreadProc(void *arg) {
    if (![EAGLContext setCurrentContext:eaglcontext]) {
        NSLog(@"Failed to set current context for game thread\n");
        return 0;
    }
    NSLog(@"Game thread is up and running\n");
#if GL_TEST
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    glVertexPointer(3, GL_FLOAT, 0, v);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, c);
    while (1) {
        usleep(1000);
        glClearColor(0.1, 0.4, 0.2, 1.0);
        glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
        glViewport(0, 0, displaywidth, displayheight);
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        glDrawArrays(GL_TRIANGLES, 0, 3);
        VID_SwapBuffers();
    }
#endif
    InitImmediateModeGL();
    int app_main(int argc, char *argv[]);
    void iphone_initRunLoop();
    iphone_initRunLoop();
    char **argv;
    int argc;
    while (game_type != GAME_QUIT) {
        switch (game_type) {
            case GAME_TWIN_DRAGON:
                printf("*** Starting Twin Dragon ***\n");
                argv = &td_argv[0];
                argc = td_argc;
                break;
            case GAME_WANTON_DESTRUCTION:
                printf("*** Starting Wanton Destruction ***\n");
                argv = &wd_argv[0];
                argc = wd_argc;
                break;
            default:
                printf("*** Starting Shadow Warrior ***\n");
                argv = &sw_argv[0];
                argc = sw_argc;
                break;
        }

        printf("Working directory: %s\n", [NSFileManager defaultManager].currentDirectoryPath.UTF8String);        
        resetVars();
        app_main(argc, argv);
        printf("*** Game Quit ***\n");
    }
    return 0;
}

void GameThread_Run(void) {
    if (pthread_create(&game_thread_handle, NULL, &GameThreadProc, NULL) != 0) {
        NSLog(@"Failed to start game thread\n");
    }
}
