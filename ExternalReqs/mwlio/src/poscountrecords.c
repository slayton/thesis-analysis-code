/* $Id: poscountrecords.c,v 1.1 2005/10/09 21:07:56 fabian Exp $ */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include <mat.h>
#include <matrix.h>
#include <mex.h>

/* function to find a raw position record */
/* input: file name, record_offset, record id */
/* output: record id, record offset, timestamp */

#define MAXSTRING 512

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] )
{
  
  char strFileName[MAXSTRING];
  double record_offset;
  unsigned long file_size;
  FILE *fid=NULL;
  unsigned long nrecords = 0;
  char tval[6];
  double recid;
  unsigned long timestamp = 0;
  int i;

  /* create empty outputs */
  for (i=0; i<nlhs; i++) {  
    plhs[i] = mxCreateDoubleMatrix(0,0,mxREAL);
  }

  if (nrhs!=3)
    mexErrMsgTxt("Incorrect number of input arguments.");

  if (nlhs!=3)
    mexErrMsgTxt("Incorrect number of output arguments.");

  if (!mxIsChar(prhs[0]))
    mexErrMsgTxt("First argument should be a string");

  if (!mxIsDouble(prhs[1]))
    mexErrMsgTxt("Second argument should be a double");

  if (!mxIsDouble(prhs[2]))
    mexErrMsgTxt("Third argument should be a double");

  mxGetString(prhs[0], strFileName, MAXSTRING);
  if ( (fid = fopen(strFileName, "rb")) == NULL )
    mexErrMsgTxt("Unable to open file");

/*   recid = mxGetScalar(prhs[2]); */
/*   record_offset = mxGetScalar(prhs[1]); */

/*   fseek(fid, 0, 2); */
/*   file_size = ftell(fid); */

/*   if (record_offset > file_size) */
/*     mexErrMsgTxt("Invalid record offset"); */

/*   fseek(fid, record_offset, 0); */

/*   nrecords = 0; */
  /*find the number of records in the file and store offsets*/
/*   while (1) { */

/*     if (fread(tval, 1, 6, fid)==6) { */
/*       nrecords++; */
/*       if (mxIsInf(recid)==0 && (nrecords == recid)) { */
/* 	  timestamp = *((unsigned long*)(&(tval[2]))); */
/* 	  break; */
/*       } */
/*       fseek(fid, ((unsigned char*)tval)[0] * 3, SEEK_CUR); */
/*     } else { */
/*       timestamp = 0; */
/*       break; */
/*     } */
/*   } */

/*   plhs[0] = mxCreateScalarDouble( nrecords ); */
/*   plhs[1] = mxCreateScalarDouble( ftell(fid)-6 ); */
/*   plhs[2] = mxCreateScalarDouble( timestamp ); */

  fclose(fid);

}



/* $Log: poscountrecords.c,v $
/* Revision 1.1  2005/10/09 21:07:56  fabian
/* *** empty log message ***
/* */
