#ifndef CPOSIX_PROCESS_SHIM_H
#define CPOSIX_PROCESS_SHIM_H

#if defined(__APPLE__) || defined(__linux__)

#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <errno.h>

// Process-spawning availability. tvOS and watchOS mark the entire family
// (fork, execve, posix_spawn, posix_spawn_file_actions_*) unavailable in
// the SDK; the wrappers below compile to ENOSYS stubs there so the L2
// surface stays uniform and the failure is a runtime error code, matching
// POSIX semantics for unsupported operations.

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

// fork() wrapper - on Darwin, fork() is marked unavailable in Swift's overlay.
// We provide a wrapper to bypass the Swift annotation.

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

// POSIX wait status macros - Swift cannot import C macros directly.
// These wrapper functions expose the macros to Swift.

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

// Process management wrapper - execve expects mutable pointers but never modifies them.
// We provide a const-correct wrapper for Swift.

#if defined(__linux__)
// Forward declaration to avoid including <unistd.h> which causes fd_set conflicts on Linux
extern int execve(const char *__path, char *const __argv[], char *const __envp[]) __attribute__((__nothrow__, __leaf__));
#else
#include <unistd.h>
#endif

static inline int swift_execve(
    const char *path,
    const char *const argv[],
    const char *const envp[]
) {
#if CPOSIX_PROCESS_SPAWN_UNAVAILABLE
    (void)path;
    (void)argv;
    (void)envp;
    errno = ENOSYS;
    return -1;
#else
    // Cast away const-ness for execve's legacy signature.
    // execve does NOT modify the strings, this is safe.
    return execve(path, (char *const *)argv, (char *const *)envp);
#endif
}

// posix_spawn wrapper - similar to execve, expects const pointers.
// posix_spawn does NOT modify the strings, this is safe.

#include <spawn.h>
#include <stdlib.h>
#include <errno.h>

static inline int swift_posix_spawn(
    pid_t *pid,
    const char *path,
    const void *file_actions,
    const posix_spawnattr_t *attrp,
    const char *const argv[],
    const char *const envp[]
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
        attrp,
        (char *const *)argv,
        (char *const *)envp
    );
#endif
}

// posix_spawn_file_actions wrappers.
//
// posix_spawn_file_actions_t is a POSIX opaque type whose concrete layout
// differs per platform (a pointer on Darwin, a struct on glibc/Musl). To keep
// that divergence entirely out of Swift, the init wrapper heap-allocates the
// object and hands it back as an opaque `void *`; every other wrapper takes
// the handle back as `void *` and casts to the concrete type internally. Swift
// holds the handle as a plain `UnsafeMutableRawPointer` and never names the
// platform-divergent type — so the L2 spec surface needs no `#if` for it.

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

// addchdir: change the child's working directory before exec.
//
// macOS 26.0 / POSIX.1-2024 standardised the non-suffixed
// `posix_spawn_file_actions_addchdir(3)`. glibc and older Darwin SDKs
// ship only the `_np` variant. We pick the right symbol per platform.
//
// On Linux the declaration is _GNU_SOURCE-gated so we forward-declare
// it locally to avoid forcing _GNU_SOURCE on consumers.

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
    // iOS-family (iOS/tvOS/watchOS/visionOS/Catalyst): both addchdir
    // variants are marked unavailable in the SDK. Process spawning with a
    // working directory does not exist there; report ENOSYS at runtime.
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

#endif /* __APPLE__ || __linux__ */

#endif /* CPOSIX_PROCESS_SHIM_H */
