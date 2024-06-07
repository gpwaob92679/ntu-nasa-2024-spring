#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <dirent.h>

void init(){
    setvbuf(stdin, NULL, _IONBF, 0);
    setvbuf(stdout, NULL, _IONBF, 0);
    setvbuf(stderr, NULL, _IONBF, 0);
}

void print_banner(){
    printf("Welcome to my comic server!\n I have a lot of comic for you to read. Enjoy!\n");
}

void talk_to_root(){
    printf("Hi, did you enjoy our comic server? Remember you can submit your comic to us. We will review it and publish it to our database if it is good.\n");
}

void list_choice(){
    printf("Please select your action: \n");
    printf("1. List all comic\n");
    printf("2. Read a comic\n");
    printf("3. Submit a comic\n");
    printf("4. Talk to root\n");
    printf("5. Exit\n");
}

void read_comic(){
    char comic_name[100];
    memset(comic_name, 0, 100);
    printf("Please enter the comic name: ");
    scanf("%100s", comic_name);
    char path[100] = "/root/comic-server/comic/";
    strcat(path, comic_name);
    int fd = open(path, O_RDONLY);
    if(fd < 0){
        printf("Comic not found\n");
        return;
    }
    char comic_content[100000];
    memset(comic_content, 0, 100000);
    read(fd, comic_content, 100000);
    write(STDOUT_FILENO, comic_content, 100000);
    close(fd);
}

void write_comic(){
    char comic_name[100];
    char comic_content[1000];
    memset(comic_name, 0, 100);
    memset(comic_content, 0, 1000);
    printf("Please enter the comic name: ");
    scanf("%100s", comic_name);
    printf("Please enter the comic content: ");
    read(STDIN_FILENO, comic_content, 1000);
    char path[100] = "/root/comic-server/comic/";
    strcat(path, comic_name);
    // check the path is exists first, if exists then return
    int fd = open(path, O_RDONLY);
    if(fd >= 0){
        close(fd);
        printf("Comic already exists\n");
        return;
    }
    fd = open(path, O_WRONLY | O_CREAT, 0644);
    write(fd, comic_content, strlen(comic_content));
    printf("Comic submitted\n");
    close(fd);
}


void list_comic(){
    DIR *dir;
    struct dirent *entry;

    dir = opendir("/root/comic-server/comic/");
    if (dir == NULL) {
        printf("Failed to open directory\n");
        return;
    }
    int i = 1;
    while ((entry = readdir(dir)) != NULL) {
        if (entry->d_type == DT_REG) {
            printf("%d: %s\n", i, entry->d_name);
            i++;
        }
    }

    closedir(dir);
}

int main(void){
    alarm(300);
    init();
    print_banner();

    while(1){
        list_choice();
        int choice;
        scanf("%d", &choice);
        if( choice == 1 ){
            list_comic();
        } else if( choice == 2 ){
            read_comic();
        } else if( choice == 3 ){
            write_comic();
        } else if( choice == 4 ){
            talk_to_root();
        } else if( choice == 5 ){
            exit(0);
        } else {
            printf("Invalid choice\n");
        }
    }
}