#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>

int main (int argc,char *aa[])
{
    char* filename = "new_file";
    
    if(aa[1]){
        filename = aa[1];
    }
    
    int fd = open(filename, O_CREAT | O_WRONLY, S_IRUSR | S_IWUSR);
    
    if (fd == -1)
    {
        fputs("Sorry, can not open file for writing", stdout);
        return -1;
    }
    
    int position, i, offset;
    
    int step = 2048; // читать по однобу байту слишком долго, поэтому читаем по 2 Кбайта
    
    char buffer[step];
    
    int count = read(0, buffer, step);
    
    if (count == -1) { // проверяем количество прочитанных байт
        fputs("Sorry, I can't read this file, an error occurred", stdout);
        close(fd);
        return -1;
    }
    
    int status_char = buffer[0] == 0 ? 0 : 1;
    
    while ( count != 0 )
    {
        position = 0;
        offset = 0;
        
        for (i=0; i < count; i++) {
            if (status_char == 1 && buffer[i] == 0) { //меняестся статус - идут нули
                status_char = 0;
                write(fd, &buffer[position], offset);
                position += offset;
            }

            if (status_char == 0 && buffer[i] != 0) {//меняестся статус - идут единицы
                status_char = 1;
                lseek(fd, offset, position);
                position += offset;
                offset = 0;
            }
            
            offset += 1;
        }
        
        // сменили статус, но, не выполнили write или lseek
        if (status_char == 1) {
            write(fd, &buffer[position], offset);
        } else {
            lseek(1, offset, position);
        }
        
        count = read(0, buffer, step);
    }
    
    close(fd);
    
    return 0;
}
