#include "stdlib.h"
#include "stdio.h"
#include "stdbool.h"

char normalize_to_lower_case(char string){
    if (string >= 'A' && string <= 'Z') {
        return string + 32;
    }
    return string;
}

int main(void)
{
    const char* word = "Grav ned den varg";
    int length = 0;
    for (int i = 0; ; i++){
        if (word[i] == '\0'){break;}
        length = i;
    }
    printf("Length: %d\n", length);

    char *start = word;
    char *end = word + (length);

    bool check = 1;

    while (start < end){
        char temp_start = normalize_to_lower_case(*start);
        char temp_end = normalize_to_lower_case(*end);
        while (temp_start == ' ') {
            start++;
            temp_start = normalize_to_lower_case(*start);
            length--;
        }

        while (temp_end == ' ') {
            end--;
            temp_end = normalize_to_lower_case(*end);
            length--;
        }
        if (((temp_start == temp_end) || (*start == '#') || (*end == '#') || (*start == '?') || (*end == '?')) && (length >= 0)){
            start++;
            end--;
            printf("Same letter\n");
            length--;
        }
        else{
            printf("Not same letter\n");
            check = 0;
        }
    }
    if (check == 1){
        printf("Palindrome detected");
    }
    else if(check == 0){
        printf("Word is not a palindrome");
    }
}