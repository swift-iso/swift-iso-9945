#ifndef CISO9945_SHIM_H
#define CISO9945_SHIM_H

#if defined(__APPLE__) || defined(__linux__) || defined(__OpenBSD__)

#include <sys/ioctl.h>

static inline int iso9945_ioctl_tiocgwinsz(int fd, struct winsize *ws) {
    return ioctl(fd, TIOCGWINSZ, ws);
}

#include <stdint.h>
#include <sys/types.h>
#if defined(__linux__)
#include <sys/sysmacros.h>
#endif

static inline unsigned int iso9945_device_major(uint64_t dev) {
    return (unsigned int)major((dev_t)dev);
}

static inline unsigned int iso9945_device_minor(uint64_t dev) {
    return (unsigned int)minor((dev_t)dev);
}

static inline uint64_t iso9945_device_make(unsigned int major_number, unsigned int minor_number) {
    return (uint64_t)makedev(major_number, minor_number);
}

#include <fnmatch.h>

static inline int iso9945_fnm_pathname(void) { return FNM_PATHNAME; }
static inline int iso9945_fnm_noescape(void) { return FNM_NOESCAPE; }
static inline int iso9945_fnm_period(void)   { return FNM_PERIOD; }

#ifdef FNM_CASEFOLD
static inline int iso9945_fnm_casefold(void) { return FNM_CASEFOLD; }
#elif defined(__GLIBC__)

static inline int iso9945_fnm_casefold(void) { return 1 << 4; }
#else
static inline int iso9945_fnm_casefold(void) { return 0; }
#endif

static inline int iso9945_fnm_nomatch(void) { return FNM_NOMATCH; }

static inline int iso9945_fnmatch(const char *pattern, const char *string, int flags) {
    return fnmatch(pattern, string, flags);
}

#endif

#if defined(__APPLE__)

#include <sys/mman.h>

static inline int iso9945_shm_open(const char *name, int oflag, mode_t mode) {
    return shm_open(name, oflag, mode);
}

#endif

#endif
