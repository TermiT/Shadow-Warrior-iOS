#if defined DYNAMIC_OPENGL && defined USE_OPENGL

#include "platformdef.h"

#include "glbuild.h"
#include "baselayer.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#ifdef RENDERTYPESDL

#if defined(__APPLE__)
#   if LOWANG_IOS
#       include <OpenGLES/ES1/gl.h>
#   else
#       include <GLES/gl.h>
#   endif
#   include "gles_glue.h"
#else
# include <SDL.h>
#endif


#endif

//#define CHECKED_GL

#ifdef CHECKED_GL
#include "CheckedGL.h"
#endif

void (APIENTRY * bglClearColor)( GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha );
void (APIENTRY * bglClear)( GLbitfield mask );
void (APIENTRY * bglColorMask)( GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha );
void (APIENTRY * bglAlphaFunc)( GLenum func, GLclampf ref );
void (APIENTRY * bglBlendFunc)( GLenum sfactor, GLenum dfactor );
void (APIENTRY * bglCullFace)( GLenum mode );
void (APIENTRY * bglFrontFace)( GLenum mode );
void (APIENTRY * bglPolygonOffset)( GLfloat factor, GLfloat units );
void (APIENTRY * bglPolygonMode)( GLenum face, GLenum mode );
void (APIENTRY * bglEnable)( GLenum cap );
void (APIENTRY * bglDisable)( GLenum cap );
void (APIENTRY * bglGetFloatv)( GLenum pname, GLfloat *params );
void (APIENTRY * bglGetIntegerv)( GLenum pname, GLint *params );
void (APIENTRY * bglPushAttrib)( GLbitfield mask );
void (APIENTRY * bglPopAttrib)( void );
GLenum (APIENTRY * bglGetError)( void );
const GLubyte* (APIENTRY * bglGetString)( GLenum name );
void (APIENTRY * bglHint)( GLenum target, GLenum mode );

// Depth
void (APIENTRY * bglDepthFunc)( GLenum func );
void (APIENTRY * bglDepthMask)( GLboolean flag );
void (APIENTRY * bglDepthRange)( GLclampf near_val, GLclampf far_val );

// Matrix
void (APIENTRY * bglMatrixMode)( GLenum mode );
void (APIENTRY * bglOrthof)( GLfloat left, GLfloat right, GLfloat bottom, GLfloat top, GLfloat near_val, GLfloat far_val );
void (APIENTRY * bglFrustum)( GLfloat left, GLfloat right, GLfloat bottom, GLfloat top, GLfloat near_val, GLfloat far_val );
void (APIENTRY * bglViewport)( GLint x, GLint y, GLsizei width, GLsizei height );
void (APIENTRY * bglPushMatrix)( void );
void (APIENTRY * bglPopMatrix)( void );
void (APIENTRY * bglLoadIdentity)( void );
void (APIENTRY * bglLoadMatrixf)( const GLfloat *m );

// Drawing
void (APIENTRY * bglBegin)( GLenum mode );
void (APIENTRY * bglEnd)( void );
void (APIENTRY * bglVertex2f)( GLfloat x, GLfloat y );
void (APIENTRY * bglVertex3f)( GLfloat x, GLfloat y, GLfloat z );
void (APIENTRY * bglVertex2i)( GLint x, GLint y );
void (APIENTRY * bglVertex3fv)( const GLfloat *v );
void (APIENTRY * bglColor4f)( GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha );
void (APIENTRY * bglColor4ub)( GLubyte red, GLubyte green, GLubyte blue, GLubyte alpha );
void (APIENTRY * bglTexCoord2f)( GLfloat s, GLfloat t );

// Lighting
void (APIENTRY * bglShadeModel)( GLenum mode );

// Raster funcs
void (APIENTRY * bglReadPixels)( GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, GLvoid *pixels );

// Texture mapping
void (APIENTRY * bglTexEnvf)( GLenum target, GLenum pname, GLfloat param );
void (APIENTRY * bglGenTextures)( GLsizei n, GLuint *textures );	// 1.1
void (APIENTRY * bglDeleteTextures)( GLsizei n, const GLuint *textures);	// 1.1
void (APIENTRY * bglBindTexture)( GLenum target, GLuint texture );	// 1.1
void (APIENTRY * bglTexImage2D)( GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid *pixels );
void (APIENTRY * bglTexSubImage2D)( GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid *pixels );	// 1.1
void (APIENTRY * bglTexParameterf)( GLenum target, GLenum pname, GLfloat param );
void (APIENTRY * bglTexParameteri)( GLenum target, GLenum pname, GLint param );
void (APIENTRY * bglGetTexLevelParameteriv)( GLenum target, GLint level, GLenum pname, GLint *params );
void (APIENTRY * bglCompressedTexImage2DARB)(GLenum, GLint, GLenum, GLsizei, GLsizei, GLint, GLsizei, const GLvoid *);
void (APIENTRY * bglGetCompressedTexImageARB)(GLenum, GLint, GLvoid *);

// Fog
void (APIENTRY * bglFogf)( GLenum pname, GLfloat param );
void (APIENTRY * bglFogi)( GLenum pname, GLint param );
void (APIENTRY * bglFogfv)( GLenum pname, const GLfloat *params );
			
#ifdef RENDERTYPEWIN
// Windows
HGLRC (WINAPI * bwglCreateContext)(HDC);
BOOL (WINAPI * bwglDeleteContext)(HGLRC);
PROC (WINAPI * bwglGetProcAddress)(LPCSTR);
BOOL (WINAPI * bwglMakeCurrent)(HDC,HGLRC);

BOOL (WINAPI * bwglSwapBuffers)(HDC);
int (WINAPI * bwglChoosePixelFormat)(HDC,CONST PIXELFORMATDESCRIPTOR*);
int (WINAPI * bwglDescribePixelFormat)(HDC,int,UINT,LPPIXELFORMATDESCRIPTOR);
int (WINAPI * bwglGetPixelFormat)(HDC);
BOOL (WINAPI * bwglSetPixelFormat)(HDC,int,const PIXELFORMATDESCRIPTOR*);

static HANDLE hGLDLL;
#endif


char *gldriver = NULL;

static void * getproc_(const char *s, int *err, int fatal, int extension)
{
	void *t;
#if defined RENDERTYPESDL
//	t = (void*)SDL_GL_GetProcAddress(s);
//    t = (void*)eglGetProcAddress(s);
    t = NULL;
#elif defined _WIN32
	if (extension) t = (void*)bwglGetProcAddress(s);
	else t = (void*)GetProcAddress(hGLDLL,s);
#else
#error Need a dynamic loader for this platform...
#endif
	if (!t && fatal) {
		initprintf("Failed to find %s in %s\n", s, gldriver);
		*err = 1;
	}
	return t;
}
#define GETPROC(s)        getproc_(s,&err,1,0)
#define GETPROCSOFT(s)    getproc_(s,&err,0,0)
#define GETPROCEXT(s)     getproc_(s,&err,1,1)
#define GETPROCEXTSOFT(s) getproc_(s,&err,0,1)

#define GETPROC2(s)  s

#define GETPROC_CKGL(s) ck ## s

void glPolygonMode(GLenum a, GLenum b) {}

void glPushAttrib(GLbitfield mask) {}
void glPopAttrib(void) {}

#if 0
void glBegin(	GLenum  	mode) {
    printf("glBegin(%d)\n", mode);
}
void glEnd() {}

void glVertex3f(GLfloat x, GLfloat y, GLfloat z) {}
void glVertex2i(GLint x, GLint y) {}
void glTexCoord2f(	GLfloat  	s,
                  GLfloat  	t) {}
#endif

//void glVertex2f(GLfloat x, GLfloat y) {
//    glVertex3f(x, y, 0.0f);
//}

//void glVertex3fv(const GLfloat *v) {
//    glVertex3f(v[0], v[1], v[2]);
//}

//void glColor4f(GLfloat r, GLfloat g, GLfloat b, GLfloat a) {}
//void glColor4ub(GLubyte r, GLubyte g, GLubyte b, GLubyte a) {}

#define TEXTURE_DEBUG 0

#if TEXTURE_DEBUG
void hook_glGenTextures(GLsizei  	n,
                        GLuint *  	textures) {
    glGenTextures(n, textures);
    for (int i = 0; i < n; i++) {
        if (textures[i] == 43) {
            printf("generating texture #43\n");
        }
    }
}

void hook_glTexImage2D( GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid *pixels ) {
    glTexImage2D(target, level, internalFormat, width, height, border, format, type, pixels);
    GLint glpic;
    glGetIntegerv(GL_TEXTURE_BINDING_2D, &glpic);
    if (glpic == 43 && level == 0) {
        printf("uploading texture #%d\n", glpic);
    }
}
#endif


int loadgldriver(const char *driver)
{
	void *t;
	int err=0;
	
#ifdef RENDERTYPEWIN
	if (hGLDLL) return 0;
#endif

	if (!driver) {
#ifdef _WIN32
		driver = "OPENGL32.DLL";
#elif defined __APPLE__
		driver = "/System/Library/Frameworks/OpenGL.framework/OpenGL";
#else
		driver = "libGL.so";
#endif
	}

	initprintf("Loading %s\n",driver);

#if defined RENDERTYPESDL
//	if (SDL_GL_LoadLibrary(driver)) return -1;
#elif defined _WIN32
	hGLDLL = LoadLibrary(driver);
	if (!hGLDLL) return -1;
#endif
	gldriver = strdup(driver);

#ifdef RENDERTYPEWIN
	bwglCreateContext	= GETPROC("wglCreateContext");
	bwglDeleteContext	= GETPROC("wglDeleteContext");
	bwglGetProcAddress	= GETPROC("wglGetProcAddress");
	bwglMakeCurrent		= GETPROC("wglMakeCurrent");

	bwglSwapBuffers		= GETPROC("wglSwapBuffers");
	bwglChoosePixelFormat	= GETPROC("wglChoosePixelFormat");
	bwglDescribePixelFormat	= GETPROC("wglDescribePixelFormat");
	bwglGetPixelFormat	= GETPROC("wglGetPixelFormat");
	bwglSetPixelFormat	= GETPROC("wglSetPixelFormat");
#endif

	bglClearColor		= GETPROC2(glClearColor);
	bglClear		= GETPROC2(glClear);
	bglColorMask		= GETPROC2(glColorMask);
	bglAlphaFunc		= GETPROC2(glAlphaFunc);
	bglBlendFunc		= GETPROC2(glBlendFunc);
	bglCullFace		= GETPROC2(glCullFace);
	bglFrontFace		= GETPROC2(glFrontFace);
	bglPolygonOffset	= GETPROC2(glPolygonOffset);
	bglPolygonMode		= GETPROC2(glPolygonMode);
	bglEnable		= GETPROC2(glEnable);
	bglDisable		= GETPROC2(glDisable);
	bglGetFloatv		= GETPROC2(glGetFloatv);
	bglGetIntegerv		= GETPROC2(glGetIntegerv);
	bglPushAttrib		= GETPROC2(glPushAttrib);
	bglPopAttrib		= GETPROC2(glPopAttrib);
	bglGetError		= GETPROC2(glGetError);
	bglGetString		= GETPROC2(glGetString);
	bglHint			= GETPROC2(glHint);
    
	// Depth
	bglDepthFunc		= GETPROC2(glDepthFunc);
	bglDepthMask		= GETPROC2(glDepthMask);
	bglDepthRange		= GETPROC2(glDepthRangef);
    
	// Matrix
	bglMatrixMode		= GETPROC2(glMatrixMode);
	bglOrthof		= GETPROC2(glOrthof);
	bglFrustum		= GETPROC2(glFrustumf);
	bglViewport		= GETPROC2(glViewport);
	bglPushMatrix		= GETPROC2(glPushMatrix);
	bglPopMatrix		= GETPROC2(glPopMatrix);
	bglLoadIdentity		= GETPROC2(glLoadIdentity);
	bglLoadMatrixf		= GETPROC2(glLoadMatrixf);
    
	// Drawing
	bglBegin		= GETPROC2(glBegin);
	bglEnd			= GETPROC2(glEnd);
	bglVertex2f		= GETPROC2(glVertex2f);
	bglVertex2i		= GETPROC2(glVertex2i);
	bglVertex3fv		= GETPROC2(glVertex3fv);
    bglVertex3f     = GETPROC2(glVertex3f);
	bglColor4f		= GETPROC2(glColor4f);
	bglColor4ub		= GETPROC2(glColor4ub);
	bglTexCoord2f		= GETPROC2(glTexCoord2f);
    
	// Lighting
	bglShadeModel		= GETPROC2(glShadeModel);
    
	// Raster funcs
	bglReadPixels		= GETPROC2(glReadPixels);
    
	// Texture mapping
	bglTexEnvf		= GETPROC2(glTexEnvf);
	bglDeleteTextures	= GETPROC2(glDeleteTextures);
	bglBindTexture		= GETPROC2(glBindTexture);
#if TEXTURE_DEBUG
	bglGenTextures		= GETPROC2(hook_glGenTextures);
	bglTexImage2D		= GETPROC2(hook_glTexImage2D);
#else
    bglGenTextures		= GETPROC2(glGenTextures);
	bglTexImage2D		= GETPROC2(glTexImage2D);
#endif
	bglTexSubImage2D	= GETPROC2(glTexSubImage2D);
	bglTexParameterf	= GETPROC2(glTexParameterf);
	bglTexParameteri	= GETPROC2(glTexParameteri);
//	bglGetTexLevelParameteriv = GETPROC2(glGetTexLevelParameteriv);
    
	// Fog
	bglFogf			= GETPROC2(glFogf);
//	bglFogi			= GETPROC2(glFogi);
	bglFogfv		= GETPROC2(glFogfv);

	loadglextensions();

	if (err) unloadgldriver();
	return err;
}

int loadglextensions(void)
{
	int err = 0;
#ifdef RENDERTYPEWIN
	if (!hGLDLL) return 0;
#endif

	bglCompressedTexImage2DARB  = GETPROCEXTSOFT("glCompressedTexImage2DARB");
	bglGetCompressedTexImageARB = GETPROCEXTSOFT("glGetCompressedTexImageARB");

	return err;
}

int unloadgldriver(void)
{
#ifdef RENDERTYPEWIN
	if (!hGLDLL) return 0;
#endif

	free(gldriver);
	gldriver = NULL;
	
#ifdef RENDERTYPEWIN
	FreeLibrary(hGLDLL);
	hGLDLL = NULL;
#endif
	
	bglClearColor		= NULL;
	bglClear		= NULL;
	bglColorMask		= NULL;
	bglAlphaFunc		= NULL;
	bglBlendFunc		= NULL;
	bglCullFace		= NULL;
	bglFrontFace		= NULL;
	bglPolygonOffset	= NULL;
	bglPolygonMode   = NULL;
	bglEnable		= NULL;
	bglDisable		= NULL;
	bglGetFloatv		= NULL;
	bglGetIntegerv		= NULL;
	bglPushAttrib		= NULL;
	bglPopAttrib		= NULL;
	bglGetError		= NULL;
	bglGetString		= NULL;
	bglHint			= NULL;

	// Depth
	bglDepthFunc		= NULL;
	bglDepthMask		= NULL;
	bglDepthRange		= NULL;

	// Matrix
	bglMatrixMode		= NULL;
	bglOrthof		= NULL;
	bglFrustum		= NULL;
	bglViewport		= NULL;
	bglPushMatrix		= NULL;
	bglPopMatrix		= NULL;
	bglLoadIdentity		= NULL;
	bglLoadMatrixf		= NULL;

	// Drawing
	bglBegin		= NULL;
	bglEnd			= NULL;
	bglVertex2f		= NULL;
	bglVertex2i		= NULL;
	bglVertex3fv		= NULL;
	bglColor4f		= NULL;
	bglColor4ub		= NULL;
	bglTexCoord2f		= NULL;

	// Lighting
	bglShadeModel		= NULL;

	// Raster funcs
	bglReadPixels		= NULL;

	// Texture mapping
	bglTexEnvf		= NULL;
	bglGenTextures		= NULL;
	bglDeleteTextures	= NULL;
	bglBindTexture		= NULL;
	bglTexImage2D		= NULL;
	bglTexSubImage2D	= NULL;
	bglTexParameterf	= NULL;
	bglTexParameteri	= NULL;
	bglGetTexLevelParameteriv   = NULL;
	bglCompressedTexImage2DARB  = NULL;
	bglGetCompressedTexImageARB = NULL;

	// Fog
	bglFogf			= NULL;
	bglFogi			= NULL;
	bglFogfv		= NULL;
			
#ifdef RENDERTYPEWIN
	bwglCreateContext	= NULL;
	bwglDeleteContext	= NULL;
	bwglGetProcAddress	= NULL;
	bwglMakeCurrent		= NULL;

	bwglSwapBuffers		= NULL;
	bwglChoosePixelFormat	= NULL;
	bwglDescribePixelFormat	= NULL;
	bwglGetPixelFormat	= NULL;
	bwglSetPixelFormat	= NULL;
#endif

	return 0;
}

#else

char *gldriver = "<statically linked>";

int loadgldriver(const char *a) { return 0; }
int unloadgldriver(void) { return 0; }

#endif

