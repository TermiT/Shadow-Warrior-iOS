/**
 * libsquish bridging interface
 */

#include <assert.h>

#ifdef USE_OPENGL

extern "C" {
#include "glbuild.h"
#include "polymost_priv.h"
}

static int getflags(int format)
{
    assert(0);
	return 0;
}

extern "C" int squish_GetStorageRequirements(int width, int height, int format)
{
    assert(0);
    return -1;
}

extern "C" int squish_CompressImage(coltype * rgba, int width, int height, unsigned char * output, int format)
{
    assert(0);
	return 0;
}

#endif
