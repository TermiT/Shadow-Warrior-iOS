#ifndef CHECKED_GL_H
#define CHECKED_GL_H

#import <OpenGLES/ES1/gl.h>

void ckglTexImage2D(GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid *pixels);

#endif /* CHECKED_GL_H */
