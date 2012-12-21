#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface EAGLView : UIView <UITextFieldDelegate> {
@public
    GLuint renderbuffer; 
    GLuint framebuffer;
    GLuint depthRenderbuffer;
@private
    GLint bufferWidth;
    GLint bufferHeight;
}

@end
