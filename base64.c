  
#include <string.h>
#include <stdio.h>
  
static const char BaseTable[] =
                           "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                           "abcdefghijklmnopqrstuvwxyz"
                           "0123456789+/";


void benc( char *dst, char *s )
{
   int n = strlen( s );
   int n3byt      = n / 3; 
   int k          = n3byt * 3; 
   int nrest      = n % 3;
   int i          = 0;
   int dstlen     = 0;

   while ( i < k )
   {
      dst[dstlen++] = BaseTable[(char)(( s[i]   & 0xFC) >> 2)];
      dst[dstlen++] = BaseTable[(char)(((s[i]   & 0x03) << 4) | ((s[i+1] & 0xF0) >> 4))];
      dst[dstlen++] = BaseTable[(char)(((s[i+1] & 0x0F) << 2) | ((s[i+2] & 0xC0) >> 6))];
      dst[dstlen++] = BaseTable[(char)(  s[i+2] & 0x3F)];

      i += 3;
   }
        
   if (nrest==2)
   {
      dst[dstlen++] = BaseTable[(char)(( s[k] & 0xFC)   >> 2)];
      dst[dstlen++] = BaseTable[(char)(((s[k] & 0x03)   << 4) | ((s[k+1] & 0xF0) >> 4))];
      dst[dstlen++] = BaseTable[(char)(( s[k+1] & 0x0F) << 2)]; 
   }
   else if (nrest==1)
   {
      dst[dstlen++] = BaseTable[(char)((s[k] & 0xFC) >> 2)];
      dst[dstlen++] = BaseTable[(char)((s[k] & 0x03) << 4)];
   }

   while (dstlen%3)
         dst[dstlen++] = '=';

   dst[dstlen] = '\0';
}

void encbasic( char *d, const char *u, const char *p )
{
   char _buf[4*1024];
   
   strcpy( _buf, u );
   strcat( _buf, ":" );
   strcat( _buf, p );
   benc( d, _buf );
}

main(int argc, char *argv[] )
{
   char buf[4096];
   
   encbasic ( buf, argv[1], argv[2] );
   printf( "%s\n", buf ); 
}
