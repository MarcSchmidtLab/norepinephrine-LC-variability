/*=================================================================

    2-D CROSS-CORRELATION THAT IS ONLY MATCHES ALONG COLUMNS. ARGUMENTS ARE: MATRIX 1, MATRIX 2, MAXIMUM LAG TIME, AND WHETHER
    THE MATCH IS NORMALIZED BY THE NUMBER OF POINTS CALCULATED IN THE MATCH AT A POSITION.
 
 */

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "mex.h"
#include "matrix.h"

void convc(
double	*y,
double  *x,
double *c,
int ycols,
int xcols,
int ccols
)

{
    
    int xind1,yind1,clen,n,ind,xind2,yind2;
    double p;
    
    for (n = 1; n <= ccols; n++) {
        
        xind1 = n - ycols + 1;
        xind1 = xind1 > 1 ? xind1:1;
        
        xind2 = n < xcols ? n:xcols;
        
        clen = xind2 - xind1 + 1;

        yind1 = n - xcols + 1;
        yind1 = yind1 > 1 ? yind1:1;
        
        yind2 = yind1 + clen + 1;
        
        p = 0;
        
        for (ind = 1; ind <= clen; ind++) {
            
            p += *(y+yind2-ind-2) * *(x+xind1+ind-2);
            
        }
        
        *(c+n-1) = p;
        
    }
    
}


void mexFunction( int nlhs, mxArray*plhs[], 
		  int nrhs, const mxArray*prhs[])
     
{ 
    double *x,*y,*c;
    int xcols,ycols,ccols;
    
    y = mxGetPr(prhs[0]);
    x = mxGetPr(prhs[1]);
    
    ycols = mxGetN(prhs[0]);
    xcols = mxGetN(prhs[1]);
    
    ccols = xcols+ycols-1;
    
    /* Create a matrix for the return argument */
    plhs[0] = mxCreateDoubleMatrix(1,ccols,mxREAL);
    c = mxGetPr(plhs[0]);
    
        
    /* Do the actual computations in a subroutine */
   convc(y,x,c,ycols,xcols,ccols); 
    
}


