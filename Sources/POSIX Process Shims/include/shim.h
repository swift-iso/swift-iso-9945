#ifndef CPOSIX_PROCESS_SHIM_H
#define CPOSIX_PROCESS_SHIM_H

#if defined(__APPLE__) || defined(__linux__)

#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <errno.h>

#if defined(__APPLE__)
#include <TargetConditionals.h>
#if TARGET_OS_OSX || TARGET_OS_IOS || TARGET_OS_VISION
#define CPOSIX_PROCESS_SPAWN_UNAVAILABLE 0
#else
#define CPOSIX_PROCESS_SPAWN_UNAVAILABLE 1
#endif
#else
#define CPOSIX_PROCESS_SPAWN_UNAVAILABLE 0
#endif

#if defined(__APPLE__)
static inline pid_t swift_fork(void) {
#if CPOSIX_PROCESS_SPAWN_UNAVAILABLE
    errno = ENOSYS;
    return -1;
#else
    return fork();
#endif
}
#endif

static inline int swift_WIFEXITED(int status) {
    return WIFEXITED(status);
}

static inline int swift_WEXITSTATUS(int status) {
    return WEXITSTATUS(status);
}

static inline int swift_WIFSIGNALED(int status) {
    return WIFSIGNALED(status);
}

static inline int swift_WTERMSIG(int status) {
    return WTERMSIG(status);
}

static inline int swift_WIFSTOPPED(int status) {
    return WIFSTOPPED(status);
}

static inline int swift_WSTOPSIG(int status) {
    return WSTOPSIG(status);
}

static inline int swift_WIFCONTINUED(int status) {
    return WIFCONTINUED(status);
}

#ifdef WCOREDUMP
static inline int swift_WCOREDUMP(int status) {
    return WCOREDUMP(status);
}
#endif

#if defined(__linux__)

extern int execve(const char *__path, char *const __argv[], char *const __envp[]) __attribute__((__nothrow__, __leaf__));
#else
#include <unistd.h>
#endif

static inline int swift_execve(
    const char * _Nonnull path,
    const char * _Nullable const * _Nonnull argv,
    const char * _Nullable const * _Nonnull envp
) {
#if CPOSIX_PROCESS_SPAWN_UNAVAILABLE
    (void)path;
    (void)argv;
    (void)envp;
    errno = ENOSYS;
    return -1;
#else

    return execve(path, (char *const *)argv, (char *const *)envp);
#endif
}

#include <spawn.h>
#include <stdlib.h>
#include <errno.h>

static inline int swift_posix_spawn(
    pid_t * _Nonnull pid,
    const char * _Nonnull path,
    const void * _Nullable file_actions,
    const void * _Nullable attrp,
    const char * _Nullable const * _Nonnull argv,
    const char * _Nullable const * _Nonnull envp
) {
#if CPOSIX_PROCESS_SPAWN_UNAVAILABLE
    (void)pid;
    (void)path;
    (void)file_actions;
    (void)attrp;
    (void)argv;
    (void)envp;
    return ENOSYS;
#else
    return posix_spawn(
        pid,
        path,
        (const posix_spawn_file_actions_t *)file_actions,
        (const posix_spawnattr_t *)attrp,
        (char *const *)argv,
        (char *const *)envp
    );
#endif
}

static inline void * _Nullable swift_posix_spawn_file_actions_init(int * _Nonnull result) {
#if CPOSIX_PROCESS_SPAWN_UNAVAILABLE
    *result = ENOSYS;
    return NULL;
#else
    posix_spawn_file_actions_t *actions =
        (posix_spawn_file_actions_t *)malloc(sizeof(posix_spawn_file_actions_t));
    if (actions == NULL) {
        *result = ENOMEM;
        return NULL;
    }
    int rc = posix_spawn_file_actions_init(actions);
    if (rc != 0) {
        free(actions);
        *result = rc;
        return NULL;
    }
    *result = 0;
    return actions;
#endif
}

static inline int swift_posix_spawn_file_actions_destroy(void * _Nonnull handle) {
#if CPOSIX_PROCESS_SPAWN_UNAVAILABLE
    (void)handle;
    return ENOSYS;
#else
    posix_spawn_file_actions_t *actions = (posix_spawn_file_actions_t *)handle;
    int rc = posix_spawn_file_actions_destroy(actions);
    free(actions);
    return rc;
#endif
}

static inline int swift_posix_spawn_file_actions_addopen(
    void * _Nonnull handle,
    int fildes,
    const char * _Nonnull path,
    int oflag,
    mode_t mode
) {
#if CPOSIX_PROCESS_SPAWN_UNAVAILABLE
    (void)handle;
    (void)fildes;
    (void)path;
    (void)oflag;
    (void)mode;
    return ENOSYS;
#else
    posix_spawn_file_actions_t *actions = (posix_spawn_file_actions_t *)handle;
    return posix_spawn_file_actions_addopen(actions, fildes, path, oflag, mode);
#endif
}

static inline int swift_posix_spawn_file_actions_adddup2(
    void * _Nonnull handle,
    int fildes,
    int newfildes
) {
#if CPOSIX_PROCESS_SPAWN_UNAVAILABLE
    (void)handle;
    (void)fildes;
    (void)newfildes;
    return ENOSYS;
#else
    posix_spawn_file_actions_t *actions = (posix_spawn_file_actions_t *)handle;
    return posix_spawn_file_actions_adddup2(actions, fildes, newfildes);
#endif
}

static inline int swift_posix_spawn_file_actions_addclose(
    void * _Nonnull handle,
    int fildes
) {
#if CPOSIX_PROCESS_SPAWN_UNAVAILABLE
    (void)handle;
    (void)fildes;
    return ENOSYS;
#else
    posix_spawn_file_actions_t *actions = (posix_spawn_file_actions_t *)handle;
    return posix_spawn_file_actions_addclose(actions, fildes);
#endif
}

#if defined(__linux__)
extern int posix_spawn_file_actions_addchdir_np(
    posix_spawn_file_actions_t *file_actions,
    const char *path
);
#endif

static inline int swift_posix_spawn_file_actions_addchdir(
    void * _Nonnull handle,
    const char * _Nonnull path
) {
#if defined(__APPLE__) && !TARGET_OS_OSX

    (void)handle;
    (void)path;
    return ENOSYS;
#else
    posix_spawn_file_actions_t *actions = (posix_spawn_file_actions_t *)handle;
#if defined(__APPLE__) && defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && (__MAC_OS_X_VERSION_MIN_REQUIRED >= 260000)
    return posix_spawn_file_actions_addchdir(actions, path);
#else
    return posix_spawn_file_actions_addchdir_np(actions, path);
#endif
#endif
}

#endif

#endif
