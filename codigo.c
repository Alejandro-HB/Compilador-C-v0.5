/* add.c
 * a simple C program
 */

void printf();
 
int main()
{
    int i, sum = 6;
    double f = 1.5;
    char* c = "\x41";
	
    for( i = 1; i <= LAST; i++ ) {
        sum += i;
    } /*-for-*/
    printf("sum = %d\n", sum);
    return 0;
}
