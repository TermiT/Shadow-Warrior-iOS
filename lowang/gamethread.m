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

static char *sw_argv[] = { "sw" };
static int sw_argc = sizeof(sw_argv)/sizeof(sw_argv[0]);

static char *td_argv[] = { "sw" };
static int td_argc = sizeof(td_argv)/sizeof(td_argv[0]);

static char *wd_argv[] = { "sw", "/GWT.GRP" };
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
