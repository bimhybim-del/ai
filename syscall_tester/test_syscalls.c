#define _GNU_SOURCE
#include <stdio.h>
#include <unistd.h>
#include <sys/syscall.h>
#include <errno.h>
#include <string.h>
#include <sys/socket.h>
#include <fcntl.h>

int main() {
    int ret;
    
    errno = 0;
    int s = socket(38, SOCK_SEQPACKET, 0);
    printf("socket(AF_ALG): %s fd=%d e=%d %s\n", s>=0?"OK":"FAIL", s, errno, strerror(errno));
    if(s>=0) close(s);
    
    errno = 0;
    ret = syscall(248, "user", "test", "data", 4, -2);
    printf("add_key: %s ret=%d e=%d %s\n", ret>=0?"OK":"FAIL", ret, errno, strerror(errno));
    
    errno = 0;
    ret = syscall(250, 0, 0, 0, 0, 0);
    printf("keyctl: %s ret=%d e=%d %s\n", ret>=0?"OK":"FAIL", ret, errno, strerror(errno));
    
    errno = 0;
    ret = syscall(249, "user", "test", NULL, -2);
    printf("request_key: %s ret=%d e=%d %s\n", ret>=0?"OK":"FAIL", ret, errno, strerror(errno));

    errno = 0;
    int rs = socket(33, SOCK_DGRAM, 0);
    printf("socket(AF_RXRPC): %s fd=%d e=%d %s\n", rs>=0?"OK":"FAIL", rs, errno, strerror(errno));
    if(rs>=0) close(rs);

    errno = 0;
    ret = syscall(319, "test", 0);
    printf("memfd_create: %s fd=%d e=%d %s\n", ret>=0?"OK":"FAIL", ret, errno, strerror(errno));
    if(ret>=0) close(ret);

    int pipefd[2];
    pipe(pipefd);
    errno = 0;
    ret = syscall(275, pipefd[0], NULL, pipefd[1], NULL, 1, 0);
    printf("splice: %s ret=%d e=%d %s\n", ret>=0?"OK":"FAIL", ret, errno, strerror(errno));
    close(pipefd[0]); close(pipefd[1]);

    // Test fork
    errno = 0;
    pid_t p = fork();
    if(p == 0) { _exit(0); }
    printf("fork: %s pid=%d e=%d %s\n", p>=0?"OK":"FAIL", p, errno, strerror(errno));

    return 0;
}
