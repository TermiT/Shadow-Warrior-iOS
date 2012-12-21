void SDL_WM_SetCaption(const char *caption) {}
void ws_setapptitle(char *s) {}
int startwin_settitle(const char *s) { return 0; }
int startwin_idle(void *s) { return 0; }
int startwin_open(void) { return 0; }
int startwin_close(void) { return 0; }
int startwin_puts(const char *s) { return 0; }
int startwin_run(void) { return 1; }
