#ifndef CPOSIX_PROCESS_SHIM_H
#define CPOSIX_PROCESS_SHIM_H

#if defined(__APPLE__) || defined(__linux__)

#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

// fork() wrapper - on Darwin, fork() is marked unavailable in Swift's overlay.
// We provide a wrapper to bypass the Swift annotation.

#if defined(__APPLE__)
static inline pid_t swift_fork(void) {
    return fork();
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
    // Cast away const-ness for execve's legacy signature.
    // execve does NOT modify the strings, this is safe.
    return execve(path, (char *const *)argv, (char *const *)envp);
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
    return posix_spawn(
        pid,
        path,
        (const posix_spawn_file_actions_t *)file_actions,
        attrp,
        (char *const *)argv,
        (char *const *)envp
    );
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
}

static inline int swift_posix_spawn_file_actions_destroy(void * _Nonnull handle) {
    posix_spawn_file_actions_t *actions = (posix_spawn_file_actions_t *)handle;
    int rc = posix_spawn_file_actions_destroy(actions);
    free(actions);
    return rc;
}

static inline int swift_posix_spawn_file_actions_addopen(
    void * _Nonnull handle,
    int fildes,
    const char * _Nonnull path,
    int oflag,
    mode_t mode
) {
    posix_spawn_file_actions_t *actions = (posix_spawn_file_actions_t *)handle;
    return posix_spawn_file_actions_addopen(actions, fildes, path, oflag, mode);
}

static inline int swift_posix_spawn_file_actions_adddup2(
    void * _Nonnull handle,
    int fildes,
    int newfildes
) {
    posix_spawn_file_actions_t *actions = (posix_spawn_file_actions_t *)handle;
    return posix_spawn_file_actions_adddup2(actions, fildes, newfildes);
}

static inline int swift_posix_spawn_file_actions_addclose(
    void * _Nonnull handle,
    int fildes
) {
    posix_spawn_file_actions_t *actions = (posix_spawn_file_actions_t *)handle;
    return posix_spawn_file_actions_addclose(actions, fildes);
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
    posix_spawn_file_actions_t *actions = (posix_spawn_file_actions_t *)handle;
#if defined(__APPLE__) && defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && (__MAC_OS_X_VERSION_MIN_REQUIRED >= 260000)
    return posix_spawn_file_actions_addchdir(actions, path);
#else
    return posix_spawn_file_actions_addchdir_np(actions, path);
#endif
}

#endif /* __APPLE__ || __linux__ */

#endif /* CPOSIX_PROCESS_SHIM_H */
