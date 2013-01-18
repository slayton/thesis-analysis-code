/* $Id: posloadrecordrange.c,v 1.1 2005/10/09 21:09:26 fabian Exp $ */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <math.h>
#include <time.h>
#include <mat.h>
#include <matrix.h>
#include <mex.h>

/* function to load a range of raw position record */
/* input: file name, record_offset, number of records to load, field mask */
/* bit 1 = n items, bit 2 = frame, bit 3 = timestamp, bit 4 = pos */
/* output: n items, frame, timestamp, pos.x,y */

#define MAXSTRING 512
const char *field_names[] = {"nitems", "frame", "timestamp", "pos"};
const char *field_names_pos[] = {"x", "y"};

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] )
{

  double nrecords, record_offset;
  mxArray *output_array;
  mxArray *itemArray, *frameArray, *timestampArray;
  unsigned char *pitem, *pframe;
  uint32_t *ptimestamp;
  int32_t i;
  char strFileName[MAXSTRING];
  FILE *fid=NULL;
  mxArray *posstruct, *xArray, *yArray;
  int16_t *px, *py;
  int j;
  unsigned char y;
  unsigned char fieldmask=0;
  char nfields=0;

  /*create empty outputs*/
  for (i=0; i<nlhs; i++) {
    plhs[i] = mxCreateDoubleMatrix(0,0,mxREAL);
  }

  if (nrhs<3)
    mexErrMsgTxt("Incorrect number of input arguments.");

  if (!mxIsChar(prhs[0]))
    mexErrMsgTxt("First argument should be a string");

  if (!mxIsDouble(prhs[1]))
    mexErrMsgTxt("Second argument should be a double");

  if (!mxIsDouble(prhs[2]))
    mexErrMsgTxt("Third argument should be a double");

  if (nrhs>3) {
    if (!mxIsDouble(prhs[3]))
      mexErrMsgTxt("Fourth argument should be a double");

    fieldmask = (unsigned char) mxGetScalar(prhs[3]);
  } else {
    fieldmask = 15;
  }

  if (fieldmask<1 || fieldmask>15)
    mexErrMsgTxt("Invalid fieldmask");

  mxGetString(prhs[0], strFileName, MAXSTRING);
  if ( (fid = fopen(strFileName, "rb")) == NULL )
    mexErrMsgTxt("Unable to open file");

  nrecords = mxGetScalar(prhs[2]);
  record_offset = mxGetScalar(prhs[1]);

  fseek(fid, record_offset, 0);

  posstruct = mxCreateStructMatrix(nrecords,1,2,field_names_pos);

  itemArray = mxCreateNumericMatrix(nrecords, 1, mxUINT8_CLASS, mxREAL);
  pitem = (unsigned char*) mxGetPr(itemArray);
  frameArray = mxCreateNumericMatrix(nrecords, 1, mxUINT8_CLASS, mxREAL);
  pframe = (unsigned char*)mxGetPr(frameArray);
  timestampArray = mxCreateNumericMatrix(nrecords, 1, mxUINT32_CLASS, mxREAL);
  ptimestamp = (uint32_t*)mxGetPr(timestampArray);

  for (i=0; i<nrecords; i++) {

    fread(&(pitem[i]), sizeof(char), 1, fid);
    fread(&(pframe[i]), sizeof(char), 1, fid);
    fread(&(ptimestamp[i]), sizeof(uint32_t), 1, fid);

    /* only when we want position data...*/
    if (fieldmask & 8) {
      xArray = mxCreateNumericMatrix(pitem[i], 1, mxINT16_CLASS, mxREAL);
      yArray = mxCreateNumericMatrix(pitem[i], 1, mxINT16_CLASS, mxREAL);
      px = (int16_t*)mxGetPr(xArray);
      py = (int16_t*)mxGetPr(yArray);
      
      for (j=0; j<pitem[i]; j++) {
	fread(&(px[j]), sizeof(short), 1, fid);
	fread(&y, sizeof(char), 1, fid);
	py[j] = (int16_t) y;
      }
      
      mxSetFieldByNumber(posstruct, i, 0, xArray);
      mxSetFieldByNumber(posstruct, i, 1, yArray);
    } else
      fseek(fid, pitem[i] * 3, SEEK_CUR);

  }


  /*create output structure*/
  output_array = mxCreateStructMatrix(1,1,0,NULL);

  if (fieldmask & 1) {
    mxAddField(output_array, "nitems");
    mxSetFieldByNumber(output_array, 0, 0, itemArray);
    nfields++;
  }
  if (fieldmask & 2) {
    mxAddField(output_array, "frame");
    mxSetFieldByNumber(output_array, 0, nfields, frameArray);
    nfields++;
  }
  if (fieldmask & 4) {
    mxAddField(output_array, "timestamp");
    mxSetFieldByNumber(output_array, 0, nfields, timestampArray);
    nfields++;
  }
  if (fieldmask & 8) {
    mxAddField(output_array, "pos");
    mxSetFieldByNumber(output_array, 0, nfields, posstruct);
  }

  plhs[0] = output_array;


}


/* $Log: posloadrecordrange.c,v $
/* Revision 1.1  2005/10/09 21:09:26  fabian
/* *** empty log message ***
/* */
