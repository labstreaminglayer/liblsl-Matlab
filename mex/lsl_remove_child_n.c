#include "lsl_common.h"

/* function lsl_remove_child_n(LibHandle,DescPtr,Name) */

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] ) 
{
    /* handle of the desired field */
    mxArray *field;
    /* temp pointer */
    uintptr_t *pTmp;
    /* function handle */
    lsl_remove_child_n_t func;
    /* input/output variables */
    char str[65536];
    int str_len;
    xml_ptr in;
    
    if (nrhs != 3)
        mexErrMsgTxt("3 input argument(s) required."); 
    if (nlhs != 0)
        mexErrMsgTxt("0 output argument(s) required."); 
    
    /* get function handle */
    field = mxGetField(prhs[0],0,"lsl_remove_child_n");
    if (!field)
        mexErrMsgTxt("The field does not seem to exist.");
    pTmp = (uintptr_t*)mxGetData(field);
    if (!pTmp)
        mexErrMsgTxt("The field seems to be remove_child_n.");
    func = (lsl_remove_child_n_t*)*pTmp;
    
    /* get additional inputs */
    in = (xml_ptr)*(uintptr_t*)mxGetData(prhs[1]);
    str_len = mxGetNumberOfElements(prhs[2]);
    if (str_len+1 > sizeof(str)/sizeof(str[0]))
        mexErrMsgTxt("The given string is too long.");
    mxGetString(prhs[2], str, str_len+1);
    
    /* invoke & return */
    func((xml_ptr)in,str);    
}
