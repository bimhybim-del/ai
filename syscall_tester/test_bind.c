#define _GNU_SOURCE
#include <stdio.h>
#include <unistd.h>
#include <sys/socket.h>
#include <string.h>
#include <errno.h>

struct sockaddr_alg {
    unsigned short salg_family;
    unsigned char salg_type[14];
    unsigned int salg_feat;
    unsigned int salg_mask;
    unsigned char salg_name[64];
};

int main() {
    // Test berbagai AEAD template
    const char *templates[] = {
        "authencesn(hmac(sha256),cbc(aes))",
        "authenc(hmac(sha256),cbc(aes))",
        "gcm(aes)",
        "rfc4106(gcm(aes))",
        "ccm(aes)",
        "rfc4309(ccm(aes))",
        NULL
    };
    
    for(int i=0; templates[i]; i++) {
        int fd = socket(38, SOCK_SEQPACKET, 0);
        if(fd < 0) { printf("socket fail\n"); continue; }
        
        struct sockaddr_alg sa;
        memset(&sa, 0, sizeof(sa));
        sa.salg_family = 38;
        strcpy((char*)sa.salg_type, "aead");
        strncpy((char*)sa.salg_name, templates[i], 63);
        
        errno = 0;
        int ret = bind(fd, (struct sockaddr*)&sa, sizeof(sa));
        printf("bind(%s): %s (errno=%d %s)\n", templates[i], ret==0?"OK":"FAIL", errno, strerror(errno));
        close(fd);
    }
    
    // Test skcipher type too
    const char *skciphers[] = {"cbc(aes)", "xts(aes)", "ecb(aes)", NULL};
    for(int i=0; skciphers[i]; i++) {
        int fd = socket(38, SOCK_SEQPACKET, 0);
        struct sockaddr_alg sa;
        memset(&sa, 0, sizeof(sa));
        sa.salg_family = 38;
        strcpy((char*)sa.salg_type, "skcipher");
        strncpy((char*)sa.salg_name, skciphers[i], 63);
        errno = 0;
        int ret = bind(fd, (struct sockaddr*)&sa, sizeof(sa));
        printf("skcipher(%s): %s (errno=%d %s)\n", skciphers[i], ret==0?"OK":"FAIL", errno, strerror(errno));
        close(fd);
    }
    
    return 0;
}
