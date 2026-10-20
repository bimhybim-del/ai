#include <stdio.h>
#include <unistd.h>
#include <sys/socket.h>
#include <errno.h>
#include <string.h>
#include <sys/syscall.h>

int main() {
    // SCTP socket
    errno=0;
    int s1 = socket(2, SOCK_STREAM, 132); // AF_INET, SOCK_STREAM, IPPROTO_SCTP
    printf("socket(SCTP): %s fd=%d e=%d %s\n", s1>=0?"OK":"FAIL", s1, errno, strerror(errno));
    if(s1>=0) close(s1);
    
    // AF_UNIX socket (for CVE-2026-80521)
    errno=0;
    int s2 = socket(1, SOCK_STREAM, 0); // AF_UNIX
    printf("socket(AF_UNIX_STREAM): %s fd=%d\n", s2>=0?"OK":"FAIL", s2);
    if(s2>=0) close(s2);
    
    // Netlink socket
    errno=0;
    int s3 = socket(16, SOCK_RAW, 0); // AF_NETLINK
    printf("socket(NETLINK): %s fd=%d e=%d %s\n", s3>=0?"OK":"FAIL", s3, errno, strerror(errno));
    if(s3>=0) close(s3);
    
    // io_uring
    errno=0;
    int ret = syscall(425, 8, NULL, NULL); // io_uring_setup
    printf("io_uring_setup: %s ret=%d e=%d %s\n", ret>=0?"OK":"FAIL", ret, errno, strerror(errno));
    if(ret>=0) close(ret);
    
    // userfaultfd
    errno=0;
    ret = syscall(323, 0); // userfaultfd
    printf("userfaultfd: %s ret=%d e=%d %s\n", ret>=0?"OK":"FAIL", ret, errno, strerror(errno));
    if(ret>=0) close(ret);
    
    // ptrace
    errno=0;
    ret = syscall(101, 0, 0, 0, 0); // PTRACE_TRACEME
    printf("ptrace: %s ret=%d e=%d %s\n", ret>=0?"OK":"FAIL", ret, errno, strerror(errno));
    
    // perf_event_open
    errno=0;
    ret = syscall(298, NULL, 0, -1, -1, 0);
    printf("perf_event_open: %s ret=%d e=%d %s\n", ret>=0?"OK":"FAIL", ret, errno, strerror(errno));

    // mount (for overlay exploit)
    errno=0;
    ret = syscall(165, "none", "/tmp", "tmpfs", 0, "");
    printf("mount: %s ret=%d e=%d %s\n", ret>=0?"OK":"FAIL", ret, errno, strerror(errno));
    
    return 0;
}
