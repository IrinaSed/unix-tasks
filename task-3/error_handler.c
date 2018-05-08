#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
// https://codereview.stackexchange.com/questions/24911/singly-linked-list-strings-only
#include "linkedlist.c"

void close_files(int *fds) {
    int len = sizeof(fds) / sizeof(int);
    
    for (int i = 0; i < len; i++){
        close(fds[i]);
    }
}

void check_malloc(char* p) {
    if (p == NULL) {
        printf("MALLOC ERROR. \n");
        exit(EXIT_FAILURE);
    }
}
char* substr(char* string, int position, int length) {
    char* substring = (char*) malloc(sizeof(char) * (length + 1));
    
    check_malloc(substring);
    strncpy(substring, string + position, length);
    substring[length] = '\0';
    
    return substring;
}

List* separate_numbers(char* all_data, int all_data_len) {
    List* l = List_create();

    for (int i = 0; i < all_data_len; i++) {
        if (!isdigit(all_data[i]))
            continue;
        
        int len = 0;
        int index = i;
        
        while (i + len < all_data_len && isdigit(all_data[i + len]))
            len++;
        
        if (i > 0 && all_data[i - 1] == '-') {
            index = i - 1;
            len += 1;
        }
        
        List_append(l, substr(all_data, index, len));
        i = index + len - 1;
    }
    
    return l;
}

int cmp_chars(const void* a, const void* b) {
    char* ca = *(char**)a;
    char* cb = *(char**)b;
    
    int signs = ca[0] == '-' && cb[0] != '-' ? -1 : (ca[0] != '-' && cb[0] == '-' ? 1 : 0);
    
    if (signs == 0) {
        int flag = ca[0] == '-' ? -1 : 1;
        
        if (strlen(ca) < strlen(cb))
            return -1 * flag;
        
        if (strlen(ca) > strlen(cb))
            return 1 * flag;
        
        return strcmp(ca, cb) * flag;
    }
    
    return signs;
}

int main(int argc, char *argv[]) {
    if (argc < 3) {
        puts("Sorry, but you did not specify enought files");
        return -1;
    }
    
    int fds[argc - 2];

    for (int i = 1; i < argc - 1; i++) {
        if ((fds[i - 1] = open(argv[i], O_RDONLY)) == -1) {
            printf("Sorry, but can`t open file: %s\n", argv[i]);
            close_files(fds);
            
            return -1;
        }
    }
    
    int fd = open(argv[argc - 1], O_CREAT | O_WRONLY | O_TRUNC, 0644);
    
    if (fd < 0) {
        puts("Sorry, I can't open output file.");
        return 1;
    }

    int step = 2048;
    char buffer[step];
    int all_data_len = 1;
    char* all_data = (char*) malloc(all_data_len);
    check_malloc(all_data);
    
    for (int i = 0; i < argc - 2; i++) {
        int count = read(fds[i], buffer, step);
        
        if (count == -1) { // проверяем количество прочитанных байт
            printf("Sorry, I can't read this file: %s, an error occured\n", argv[i + 1]);
            close_files(fds);
            
            return -1;
        }
        
        while (count != 0) {
            all_data_len += count;
            all_data = (char*) realloc(all_data, all_data_len);
            check_malloc(all_data);
            strncat(all_data, buffer, all_data_len);
            count = read(fds[i], buffer, step);
        }
    }
    
    List* l = separate_numbers(all_data, all_data_len);
    int length = List_length(l);
    
    char* all_numbers[length];
    for (int i = 0; i < length; i++) {
        all_numbers[i] = List_get(l, i);
    }
    
    qsort(all_numbers, length, sizeof(char*), cmp_chars);
    
    for (int i = 0; i < length; i++) {
        write(fd, all_numbers[i], strlen(all_numbers[i]));
        write(fd, "\n", 1);
    }

    return 0;
}
