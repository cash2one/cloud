#include <stdio.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netdb.h>
#include <sys/epoll.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <error.h>
#include <errno.h>
#include <time.h>

#define MAXEVENTS 64 /* max events */
#define MAX_BUF_SIZE 2048*2048 /* file buffer size */
#define DEFAULT_PORT "8989";

static FILE* recv_file = NULL; /* pointer of file */
static unsigned int recv_count = 0; /* counter of recv file */
static FILE* log_file = NULL; /* log file */
static unsigned int is_daemonize = 0; /* default is close */

#define DEFAULT_FILE_PATH "/home/work/orp" /* file path of recv file when untar */
static char* file_path = NULL;

int init() {
    pid_t pid = getpid();
    printf("server started, pid[%d]\n", pid);
    if (NULL == file_path) {
        file_path = strdup(DEFAULT_FILE_PATH);
    }
    log_file = stdout;
    if (0 < is_daemonize) {
        log_file = fopen("recv_log", "w+");
        if (NULL == log_file) {
            fprintf(stderr, "fail to init log file");
            exit(EXIT_FAILURE);
        }
    }
    return 0;
}

int do_accept() {
    pid_t pid = fork();
    if (-1 == pid) {
        perror("fork failed, when do_accept.");
        return -1;
    }
    if (0 == pid) {
        // child process
        log_file = stdout;

        if(0 == access(file_path, F_OK)) {
        } else {
            fprintf(stderr, "Cound not found the dest path\n");
        }

        execlp("tar", "tar", "-xf", "recv_file.tar.gz", "-C", file_path, NULL);
        /* after tar do something */
        // fprintf(log_file, "%s", strcat(file_path, "build.sh"));
        // execlp("sh", "sh", "");
    }
    return 0;
}

int create_and_bind(const char* port) {
    struct addrinfo hints;
    struct addrinfo *result, *rp;
    int ret, sfd;

    memset(&hints, 0, sizeof(struct addrinfo));
    hints.ai_family = AF_UNSPEC;     /* Return IPv4 and IPv6 choices */
    hints.ai_socktype = SOCK_STREAM; /* We want a TCP socket */
    hints.ai_flags = AI_PASSIVE;     /* All interfaces */

    ret = getaddrinfo(NULL, port, &hints, &result);
    if(0 != ret) {
        fprintf(stderr, "getaddrinfo error[%s]", gai_strerror(ret));
    }

    for(rp = result; rp != NULL; rp=rp->ai_next) {
        sfd = socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);
        if(sfd == -1)
            continue;

        ret = bind(sfd, rp->ai_addr, rp->ai_addrlen);
        if(ret == 0) {
            /* We managed to bind successfully! */
            break;
        }

        close(sfd);
    }

    if(rp == NULL) {
        fprintf(stderr, "Could not bind at port [%s]\n", port);
        return -1;
    }

    freeaddrinfo(result); /* there no need anymore */
    return sfd;
}

static int make_socket_non_blocking(int sfd) {
    int flags, ret;

    flags = fcntl(sfd, F_GETFL, 0);
    if(flags == -1) {
        perror("fcntl");
        return -1;
    }

    flags |= O_NONBLOCK;
    ret = fcntl(sfd, F_SETFL, flags); /* write this fd non-block */
    if(ret == -1) {
        perror("fcntl");
        return -1;
    }
    return 0;
}

int main(int argc, char *argv[]) {
    pid_t pid;
    int sfd, ret;
    int efd;
    struct epoll_event event;
    struct epoll_event *events;
    char* c;
    char* port = DEFAULT_PORT;

    /* read opt */
    int argc_index = 1;
    for (; argc_index<argc; argc_index++) {
        c = argv[argc_index];
        c++;
        if (0 ==  strcmp("-port", c)) {
            argc_index++;
            size_t tmp_i = (size_t)atoi(argv[argc_index]);
            if (0 < tmp_i) {
                port = argv[argc_index];
            }
        } else if (0 == strcmp("h", c) || 0 ==  strcmp("-help", c)) {
            printf("Usage : \n\t-h --help : get help\n\t--port : use specific port\n\t--path : specific the untar path\n");
            exit(EXIT_SUCCESS);
        } else if (0 == strcmp("d", c) || 0 ==  strcmp("-daemonize", c)) {
            is_daemonize = 1;
        } else if (0 ==  strcmp("-path", c)) {
            argc_index++;
            if (argc_index >= argc) {
                fprintf(stderr, "you do not input path, please check!\n");
                exit(EXIT_FAILURE);
            }
            file_path = strdup(argv[argc_index]);
            if (access(file_path, 0)) {
                fprintf(stderr, "invalid path\n");
                exit(EXIT_FAILURE);
            }
        } else {
        }
    }

    init();

    sfd = create_and_bind(port);
    if(sfd == -1)
        return -1;;

    if (0 < is_daemonize) {
        pid = fork();
        if (-1 == pid) {
            perror("fork failed\n");
            exit(EXIT_FAILURE);
        }
        if (0 < pid) {
            // main process
            fprintf(log_file, "daemonize mode start : Receiving file @%s, everything ready, main process exit\n", port);
            // buneng zhijie guile
            exit(EXIT_SUCCESS);
        }
    } else {
        fprintf(log_file, "foreground mode: Receiving file @%s, everything ready\n", port);
    }

    ret = make_socket_non_blocking(sfd);
    if(ret == -1)
        return -1;;

    ret = listen(sfd, SOMAXCONN);
    if(ret == -1) {
        perror("listen failed");
        return -1;;
    }

    efd = epoll_create(1);
    if(efd == -1) {
        perror("epoll_create");
        return -1;;
    }

    event.data.fd = sfd;
    event.events = EPOLLIN | EPOLLET;
    ret = epoll_ctl(efd, EPOLL_CTL_ADD, sfd, &event); /* add socket to event queue */
    if(ret == -1) {
        perror("epoll_ctl");
        return -1;;
    }

    /* Buffer where events are returned */
    events = calloc(MAXEVENTS, sizeof event);

    /* The event loop */
    while(1) {
        int n, i;

        n = epoll_wait(efd, events, MAXEVENTS, -1);
        if (recv_count % 5 == 0) {
            fflush(log_file);
        }

        /* blocking return ready fd */
        for(i = 0; i < n; i++) {
            if((events[i].events & EPOLLERR) ||
                    (events[i].events & EPOLLHUP) ||
                    (!(events[i].events & EPOLLIN))) {
                /* An error has occured on this fd, or the socket is not
                 * ready for reading(why were we notified then?) */
                fprintf(stderr, "epoll error\n");
                close(events[i].data.fd);
                continue;
            } else if(sfd == events[i].data.fd) {
                while(1) {
                    struct sockaddr in_addr;
                    socklen_t in_len;
                    int infd;
                    char hbuf[NI_MAXHOST], sbuf[NI_MAXSERV];

                    in_len = sizeof in_addr;
                    infd = accept(sfd, &in_addr, &in_len);
                    if(infd == -1) {
                        if((errno == EAGAIN) || (errno == EWOULDBLOCK)) {
                            break;
                        } else {
                            perror("accept error");
                            break;
                        }
                    }

                    ret = getnameinfo(&in_addr, in_len, hbuf, sizeof hbuf, sbuf, sizeof sbuf, NI_NUMERICHOST | NI_NUMERICSERV);
                    if(ret == 0) {
                        fprintf(log_file, "Accepted connection, (host=%s, port=%s), recv_count[%d]\n", hbuf, sbuf, recv_count);
                    }

                    /* Make the incoming socket non-blocking and add it to the
                     * list of fds to monitor. */
                    ret = make_socket_non_blocking(infd);
                    if(ret == -1)
                        return -1;;

                    event.data.fd = infd;
                    event.events = EPOLLIN | EPOLLET;
                    ret = epoll_ctl(efd, EPOLL_CTL_ADD, infd, &event);
                    if(ret == -1) {
                        perror("epoll_ctl");
                        return -1;;
                    }
                }
                continue;
            } else {
                int done = 0;
                int error = 0;
                while(1) {
                    ssize_t count;
                    char buf[MAX_BUF_SIZE];

                    count = read(events[i].data.fd, buf, sizeof buf);
                    if(count == -1) {
                        if(errno != EAGAIN) {
                            fprintf(log_file, "read to buf failed!");
                            error = 1;
                            done = 1;
                        }
                        break;
                    }
                    else if(count == 0) {
                        /* file read over */
                        done = 1;
                        break;
                    }
                    if (NULL == recv_file) {
                        recv_file = fopen("recv_file.tar.gz", "wb");
                        if (recv_file == NULL) {
                            fprintf(log_file, "fail to open file when ready to write!");
                            break;
                        }
                    }

                    // write(1, buf, count);
                    ret = fwrite(buf, 1, count, recv_file);
                    if(ret == -1) {
                        fprintf(log_file, "fail to write file!");
                        return -1;;
                    }
                }

                if(done) {
                    //printf("Closed connection on descriptor %d\n", events[i].data.fd);
                    if (NULL == recv_file) {
                    } else {
                        fclose(recv_file);
                    }
                    recv_file = NULL;
                    close(events[i].data.fd);
                    recv_count++;
                    if (0 < error) {
                    } else {
                        do_accept();
                    }
                }
            }
        }
    }

    free(file_path);
    free(events);
    close(sfd);
    return EXIT_SUCCESS;
}
