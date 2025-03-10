#include "lsl_common.h"

/* function [TimeCorrection] = lsl_time_correction(LibHandle,Inlet,Timeout) */

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] ) 
{
    /* handle of the desired field */
    mxArray *field;
    /* temp pointer */
    uintptr_t *pTmp;
    /* function handle */
    lsl_time_correction_t func;
    /* input/output variables */
    uintptr_t in;
    double timeout;
    double result;
    int errcode;
    
    if (nrhs != 3)
        mexErrMsgTxt("3 input argument(s) required."); 
    if (nlhs != 1)
        mexErrMsgTxt("1 output argument(s) required."); 
    
    /* get function handle */
    field = mxGetField(prhs[0],0,"lsl_time_correction");
    if (!field)
        mexErrMsgTxt("The field does not seem to exist.");
    pTmp = (uintptr_t*)mxGetData(field);
    if (!pTmp)
        mexErrMsgTxt("The field seems to be empty.");
    func = (lsl_time_correction_t*)*pTmp;
    
    /* get additional inputs */
    in = *(uintptr_t*)mxGetData(prhs[1]);

    if (mxGetClassID(prhs[2]) != mxDOUBLE_CLASS)
        mexErrMsgTxt("The timeout argument must be passed as a double.");
    timeout = *(double*)mxGetData(prhs[2]);
    
    /* invoke & return */
    result = func((xml_ptr)in,timeout,&errcode);
    if (errcode) {
        if (errcode == lsl_timeout_error)
            mexErrMsgIdAndTxt("lsl:timeout_error","The operation timed out.");
        if (errcode == lsl_lost_error)
            mexErrMsgIdAndTxt("lsl:lost_error","The stream has been lost.");
        if (errcode == lsl_internal_error)
            mexErrMsgIdAndTxt("lsl:internal_error","An internal error occurred.");
        mexErrMsgIdAndTxt("lsl:unknown_error","An unknown error occurred.");
    }
    plhs[0] = mxCreateNumericMatrix(1,1,mxDOUBLE_CLASS,mxREAL); *(double*)mxGetData(plhs[0]) = result;
}
