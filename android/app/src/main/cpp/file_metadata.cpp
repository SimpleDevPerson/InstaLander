#include <jni.h>
#include <fcntl.h>
#include <linux/stat.h>
#include <sys/syscall.h>
#include <unistd.h>

extern "C" JNIEXPORT jlong JNICALL
Java_com_simpledevperson_instalander_FileCreationDate_readBirthTime(
    JNIEnv*, jobject, jint fd) {
    // stat/ctime is the metadata-change time, not the file's creation time.
    // Request birth time explicitly and let unsupported filesystems fall back
    // to the calendar instead of substituting modification or copy dates.
#ifdef __NR_statx
    struct statx metadata = {};
    if (syscall(__NR_statx, fd, "", AT_EMPTY_PATH, STATX_BTIME, &metadata) == 0 &&
        (metadata.stx_mask & STATX_BTIME) != 0 &&
        metadata.stx_btime.tv_sec > 0) {
        return metadata.stx_btime.tv_sec * 1000LL +
               metadata.stx_btime.tv_nsec / 1000000;
    }
#endif
    return 0;
}
