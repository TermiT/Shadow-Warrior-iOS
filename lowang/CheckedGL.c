#include "CheckedGL.h"
#include <stdio.h>

void ckglTexImage2D(GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid *pixels) {
    GLenum error = GL_NO_ERROR;
    glTexImage2D(target, level, internalformat, width, height, border, format, type, pixels);
    error = glGetError();
    if (error != GL_NO_ERROR) {
        printf("%s error #%d\n", __FUNCTION__, error);
    }
}
