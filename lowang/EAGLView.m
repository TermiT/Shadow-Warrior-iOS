#import "EAGLView.h"
#import <QuartzCore/QuartzCore.h>
#include "sys_iphone.h"

EAGLView *eaglview;
EAGLContext *eaglcontext;
int displaywidth;
int displayheight;

@implementation EAGLView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

CAEAGLLayer *eaglLayer;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    eaglview = self;
    eaglLayer = (CAEAGLLayer*)self.layer;
    eaglLayer.opaque = YES;
    
    NSString *colorFormat = is_hiEnd ? kEAGLColorFormatRGBA8 : kEAGLColorFormatRGB565;
    
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:NO],
                                    kEAGLDrawablePropertyRetainedBacking,
                                    colorFormat,
                                    kEAGLDrawablePropertyColorFormat,
                                    nil];
    
    eaglcontext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    assert(eaglcontext != NULL);
    
    if ( ![EAGLContext setCurrentContext:eaglcontext]) {
        NSLog(@"GL context initialization failed\n");
        [self release];
        return nil;
    }
    
    glGenFramebuffersOES(1, &framebuffer);
    glGenRenderbuffersOES(1, &renderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, framebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, renderbuffer);
    
    [eaglcontext renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, renderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &bufferWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &bufferHeight);
    
    displaywidth = bufferWidth;
    displayheight = bufferHeight;
    
    glGenRenderbuffersOES(1, &depthRenderbuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
    glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, bufferWidth, bufferHeight);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
    
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, renderbuffer);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, framebuffer);
    
    assert(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) == GL_FRAMEBUFFER_COMPLETE_OES);
    
    return self;

}

//- (id)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame:frame];
//}

@end
