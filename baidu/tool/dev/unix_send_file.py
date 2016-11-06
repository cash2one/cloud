import sys
import socket               # Import socket module
import time
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import subprocess

#DEFAULT_HOST = "cq01-hj-lh-frontend-07.epc.baidu.com";
DEFAULT_HOST = "tc-bravo-tech00.epc.baidu.com";
DEFAULT_PORT = 8989
ready_file_count = 1 # two file change will send the file
ready_timeout = 1 # 5 second to copy file

file_list = {}

def send_tar():
    # check count
    if (0 == len(file_list)):
        return
    
    command  = "tar cf /tmp/tmp_send_file.tar.gz "
    for i in file_list:
        tmp = i+" "
        command += tmp
    subprocess.call(command, shell=True)
    
    s = socket.socket()
    host = DEFAULT_HOST
    port = DEFAULT_PORT        
    filename = "/tmp/tmp_send_file.tar.gz"
    buf_size = 4096*4096;
    
    s.connect((host, port))
    f = open(filename,'rb')
    
    l = f.read(buf_size)
    while (l):
        s.send(l)
        l = f.read(buf_size)
        f.close()
        #print "Done sending..."
    s.shutdown(socket.SHUT_WR)
    s.close
    file_list.clear()

class myEventHandler(FileSystemEventHandler):
    def on_modified(self, event):
        file_list[event.src_path] = 1
        if (ready_file_count <= len(file_list)):
            send_tar()

if __name__ == "__main__":
    path = sys.argv[1] if len(sys.argv) > 1 else '.'
    event_handler = myEventHandler()
    observer = Observer()
    observer.schedule(event_handler, path, recursive=True)
    observer.start()
    #print "Start watching..."
    try:
        while True:
            time.sleep(ready_timeout)
            send_tar()
    except KeyboardInterrupt:
        observer.stop()
    observer.join()
