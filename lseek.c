#include <stdio.h>
#include <unistd.h>

int main ()
{
    int position, i, offset;
    
    int step = 3; // читать по однобу байту слишком долго, поэтому читаем по 2 Кбайта
    
    char buffer[step];
    
    int count = read(0, buffer, step);
    
    if (count == -1) { // проверяем количество прочитанных байт
        write(1, "Sorry, I can't read this file, an error occurred", 49);
    }
    
    int status_char = buffer[0] == 0 ? 0 : 1;
    
    while ( count != 0 )
    {
        position = 0;
        offset = 0;
        
        for (i=0; i < count; i++) {
            if (status_char == 1 && buffer[i] == 0) { //меняестся статус - идут нули
                status_char = 0;
                write(1, &buffer[position], offset);
                position += offset;
            }

            if (status_char == 0 && buffer[i] != 0) {//меняестся статус - идут единицы
                status_char = 1;
                lseek(1, offset, position);
                position += offset;
                offset = 0;
            }
            
            offset += 1;
        }
        
        // сменили статус, но, не выполнили write или lseek
        if (status_char == 1) {
            write(1, &buffer[position], offset);
        } else {
            lseek(1, offset, position);
        }
        
        count = read(0, buffer, step);
    }
    
    return 0;
}
