/* $Id: posfindtimerange.c,v 1.1 2005/10/09 21:08:57 fabian Exp $ */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <math.h>
#include <time.h>
#include <mat.h>
#include <matrix.h>
#include <mex.h>

/* function to find a time range in raw position file */
/* input: file name, record_offset, range */
/* output: record id range */

#define MAXSTRING 512

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] )
{

  char strFileName[MAXSTRING];
  FILE *fid=NULL;
  double record_offset;
  double *prange=NULL;
  int32_t n_range;
  int32_t file_size;
  unsigned char found_start=0, found_end=0;
  uint32_t timestamp;
  int32_t nrecords=0, start_id=-1, end_id=-1;
  double* pretval=NULL;
  int i;
  char tval[6];
  double range_start, range_end;

  /*create empty outputs*/
  for (i=0; i<nlhs; i++) {
    plhs[i] = mxCreateDoubleMatrix(0,0,mxREAL);
  }

  if (nrhs!=3)
    mexErrMsgTxt("Incorrect number of input arguments.");

  if (!mxIsChar(prhs[0]))
    mexErrMsgTxt("First argument should be a string");

  if (!mxIsDouble(prhs[1]))
    mexErrMsgTxt("Second argument should be a double");

  if (!mxIsDouble(prhs[2]))
    mexErrMsgTxt("Third argument should be a double");

  record_offset = mxGetScalar(prhs[1]);

  prange = mxGetPr(prhs[2]);
  n_range = mxGetM(prhs[2]) * mxGetN(prhs[2]);

  if (n_range!=2)
    mexErrMsgTxt("Second argument should be a two-element vector");

  range_start = prange[0];
  range_end = prange[1];

  if ( range_start > range_end )
    mexErrMsgTxt("Invalid range");

  mxGetString(prhs[0], strFileName, MAXSTRING);
  if ( (fid = fopen(strFileName, "rb")) == NULL )
    mexErrMsgTxt("Unable to open file");

  fseek(fid, 0, 2);
  file_size = ftell(fid);

  if (record_offset > file_size)
    mexErrMsgTxt("Invalid record offset");

  fseek(fid, record_offset, 0);

  while (!found_end) {

    if (fread(tval, 1, 6, fid)==6) {

      timestamp = *((uint32_t*)(&(tval[2])));

      if (!found_start && (timestamp >= range_start) ) {
	found_start = 1;
	start_id = nrecords;
      }

      if (!found_end && (timestamp >= range_end)) {
	found_end = 1;
	end_id = nrecords-1;
      }

      nrecords++;
      fseek(fid, ((unsigned char*)tval)[0] * 3, SEEK_CUR);
    } else {

      if (!found_end) {
	found_end = 1;
	end_id = nrecords-1;
      }

    }

  }

  if (nlhs>0) {
    plhs[0] = mxCreateDoubleMatrix(1,2,mxREAL);
    pretval = mxGetPr(plhs[0]);
    pretval[0] = (double) start_id;
    pretval[1] = (double) end_id;
  }
  
  fclose(fid);

}



/* $Log: posfindtimerange.c,v $
/* Revision 1.1  2005/10/09 21:08:57  fabian
/* *** empty log message ***
/* */
