#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <sys/socket.h>
#include <linux/netlink.h>
#include <linux/xfrm.h>

int main() {
    // Test 1: NETLINK_XFRM socket
    errno = 0;
    int fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_XFRM);
    printf("NETLINK_XFRM: %s fd=%d e=%d %s\n", fd>=0?"OK":"FAIL", fd, errno, strerror(errno));
    
    if (fd >= 0) {
        // Test 2: Bind
        struct sockaddr_nl sa = { .nl_family = AF_NETLINK, .nl_pid = getpid() };
        errno = 0;
        int r = bind(fd, (struct sockaddr*)&sa, sizeof(sa));
        printf("bind: %s r=%d e=%d %s\n", r==0?"OK":"FAIL", r, errno, strerror(errno));
        
        // Test 3: Send XFRM_MSG_NEWSA (create Security Association)
        // This is what DirtyFrag ESP needs!
        struct {
            struct nlmsghdr nh;
            struct xfrm_usersa_info sa;
        } req;
        memset(&req, 0, sizeof(req));
        req.nh.nlmsg_len = sizeof(req);
        req.nh.nlmsg_type = XFRM_MSG_NEWSA;
        req.nh.nlmsg_flags = NLM_F_REQUEST | NLM_F_ACK;
        req.sa.family = AF_INET6;
        req.sa.mode = XFRM_MODE_TRANSPORT;
        req.sa.id.proto = 50;
        req.sa.id.daddr.a6[15] = 1;
        req.sa.saddr.a6[15] = 1;
        req.sa.lft.soft_byte_limit = XFRM_INF;
        req.sa.lft.hard_byte_limit = XFRM_INF;
        req.sa.lft.soft_packet_limit = XFRM_INF;
        req.sa.lft.hard_packet_limit = XFRM_INF;
        
        struct sockaddr_nl dest = { .nl_family = AF_NETLINK };
        errno = 0;
        int s = sendto(fd, &req, sizeof(req), 0, (struct sockaddr*)&dest, sizeof(dest));
        printf("XFRM_MSG_NEWSA sendto: %s s=%d e=%d %s\n", s>0?"OK":"FAIL", s, errno, strerror(errno));
        
        // Read response
        char buf[4096];
        errno = 0;
        int n = recv(fd, buf, sizeof(buf), MSG_DONTWAIT);
        if (n > 0) {
            struct nlmsghdr *resp = (struct nlmsghdr*)buf;
            printf("response: type=%d len=%d ", resp->nlmsg_type, resp->nlmsg_len);
            if (resp->nlmsg_type == NLMSG_ERROR) {
                struct nlmsgerr *err = (struct nlmsgerr*)(resp + 1);
                printf("error=%d (%s)\n", err->error, strerror(-err->error));
            } else {
                printf("(not error)\n");
            }
        } else {
            printf("recv: n=%d e=%d %s\n", n, errno, strerror(errno));
        }
        
        close(fd);
    }
    
    return 0;
}
