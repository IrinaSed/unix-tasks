#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>


//border_w and border_h - indices of the most extreme elements
int get_count_around(char* field, int pos_x, int pos_y, int border_w, int border_h) {
    int count = 0;
    int width = border_w + 1;
    
    int lt = (pos_x > 0 & pos_y > 0) ? field[pos_x - 1 + (pos_y - 1) * width ] - '0' : 0;
    int lm = (pos_x > 0) ? field[pos_x - 1 + pos_y * width ] - '0' : 0;
    int lb = (pos_x > 0 & pos_y < border_h) ? field[pos_x - 1 + (pos_y + 1) * width ] - '0' : 0;
    int rt = (pos_x < border_w & pos_y > 0) ? field[pos_x + 1 + (pos_y - 1) * width ] - '0' : 0;
    int rm = (pos_x < border_w) ? field[pos_x + 1 + pos_y * width ] - '0' : 0;
    int rb = (pos_x < border_w & pos_y < border_h) ? field[pos_x + 1 + (pos_y + 1) * width ] - '0' : 0;
    int mt = (pos_y > 0) ? field[pos_x + (pos_y - 1) * width ] - '0' : 0;
    int mb = (pos_y < border_h) ? field[pos_x + (pos_y + 1) * width ] - '0' : 0;
    
    return lt + lm + lb + rt + rm + rb + mt + mb;
}

int main(int argc,char *argv[])
{
    int width = atoi(argv[2]);
    int height = atoi(argv[3]);
    
    if (argc < 2) {
        puts("Use ./a.out <name_file_with_field> <width> <height>");
        puts("Field contains from '1' - life and '0' - die");
        puts("Maximum file size 4Kb");
        return -1;
    }
    
    char buffer[4096];
    
    int fd = open(argv[1],  O_RDONLY);
    int size_file = read(fd, buffer, 4096);
    if (size_file == -1) {
        puts("Sorry, I can't read this file, an error occurred");
        close(fd);
        return -1;
    }
    
   
    int size_field = width * height;
    char field[size_field], new_field[size_field];
    int i = 0, x = 0, y = 0;
    while (size_file > i && y < height) {
        if (x < width) {
            field[x + y * width] = buffer[i];
        }
        x++;
        
        if (buffer[i] == '\n') {
            y++;
            x = 0;
        }
        
        i++;
    }
    
    int count_around;
    for (int y = 0; y < height; y++) {
        for (x = 0; x < width; x++) {
            count_around = get_count_around(field, x, y, width - 1, height - 1);
            
            if (count_around == 3 || (count_around == 2 && field[x + y * width] == '1')) {
                new_field[x + y * width] = '1';
            } else {
                new_field[x + y * width] = '0';
            }
        }
    }
    
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
           printf("%c" , new_field[x + y * width]);
        }
        
        printf("\n");
    }
}
