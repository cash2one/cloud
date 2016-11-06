#define _GNU_SOURCE
#include <fcntl.h>      /* in glibc 2.2 this has the needed
                           values defined */
#include <signal.h>
#include <stdio.h>
#include <unistd.h>

static volatile int event_fd;
static volatile int event_sig;
static volatile void *event_data;

static void handler(int sig, siginfo_t *si, void *data) {
    event_fd = si->si_fd;
    event_sig = sig;
    event_data = data;
}

int main(void) {
    struct sigaction act;
    int fd;

    act.sa_sigaction = handler;
    sigemptyset(&act.sa_mask);
    act.sa_flags = SA_SIGINFO;
    sigaction(SIGRTMIN + 1, &act, NULL);

    fd = open(".", O_RDONLY);
    fcntl(fd, F_SETSIG, SIGRTMIN + 1);
    fcntl(fd, F_NOTIFY, DN_MODIFY|DN_CREATE|DN_RENAME|DN_ATTRIB|DN_MULTISHOT);
    /* file action */
    char buf[1024] = {'\0'};
        char file_path[1024] = {'\0'};
    while (1) {
        pause();
        printf("Got event on fd=%d\n", event_fd);
            snprintf(buf,sizeof(buf), "/proc/self/fd/%d", event_fd);
                readlink(buf,file_path,sizeof(file_path)-1);
                printf("%s", file_path);
    }
}
