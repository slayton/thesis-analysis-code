/* $Id: mwlio.c,v 1.1 2005/10/09 21:07:28 fabian Exp $ */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <math.h>
#include <time.h>
#include <mat.h>
#include <matrix.h>
#include <mex.h>

/* function to load a field from a file containing records - random access */
/* input: file name, indices, field info, record_offset, record_size*/
/* output: cell array of data*/

#define MAXSTRING 512

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] )
{

  char strFileName[MAXSTRING];
  char *record_data;
  char **pdatatemp = NULL;

  FILE *fid=NULL;

  int64_t n_id;
  int64_t record_offset;
  int64_t file_size;
  int64_t n_records;
  int64_t record_size;

  int i;
  int *n_dim, *dims;
  int subs;
  int id2d[2];

  double *pid, *ptemp;
  double *pfield;

  int array_type;

  size_t n_fields;

  int j;
  int64_t *num_elements, *num_bytes, *byte_offset;

  mxClassID *field_type;


  mxArray *output_array = NULL;
  mxArray *tempArray = NULL;

  if (nrhs!=5)
    mexErrMsgTxt("Incorrect number of input arguments");

  if (!mxIsChar(prhs[0]))
    mexErrMsgTxt("First argument should be a string");

  if (!mxIsDouble(prhs[1]))
    mexErrMsgTxt("Second argument should be a vector of indices");

  pid = mxGetPr(prhs[1]);

  if (!mxIsCell(prhs[2]))
    mexErrMsgTxt("Third argument should be a cell matrix of field descriptions");

  n_fields = (int32_t) mxGetM(prhs[2]);
  pfield = mxGetPr(prhs[2]);

  if (n_fields<1 || mxGetN(prhs[2])!=3)
    mexErrMsgTxt("Error in field descriptions");

  /* sanity checks on field descriptions */
  /* field descriptor = [ byte offset, type, number of elements ] */
  /* still to do... */

  byte_offset = (int64_t*) mxCalloc(n_fields, sizeof(int64_t));
  field_type = (mxClassID*) mxCalloc(n_fields, sizeof(mxClassID));
  num_elements = (int64_t*) mxCalloc(n_fields, sizeof(int64_t));
  num_bytes = (int64_t*) mxCalloc(n_fields, sizeof(int64_t));
  n_dim = (int*) mxCalloc(n_fields, sizeof(int));
  
  for (i=0; i<n_fields; i++) {
    id2d[0]=i;
    id2d[1] = 0;
    subs = mxCalcSingleSubscript(prhs[2], 2, id2d);
    byte_offset[i] = (int64_t) mxGetScalar(mxGetCell(prhs[2], subs) );
    id2d[1] = 1;
    subs = mxCalcSingleSubscript(prhs[2], 2, id2d);
    field_type[i] = (mxClassID) mxGetScalar(mxGetCell(prhs[2], subs) );
    id2d[1] = 2;
    subs = mxCalcSingleSubscript(prhs[2], 2, id2d);
    n_dim[i] = mxGetNumberOfElements(mxGetCell(prhs[2], subs));
    ptemp = mxGetPr( mxGetCell(prhs[2], subs) );
    num_elements[i] = 1;
    for( j=0; j<n_dim[i];j++) {
        num_elements[i] *= ptemp[j];
    }
      switch (field_type[i]) {
	
      case mxCHAR_CLASS:
          num_bytes[i] = num_elements[i] * sizeof(char);
	break;
      case mxDOUBLE_CLASS:
          num_bytes[i] = num_elements[i] * sizeof(double);
	break;
      case mxSINGLE_CLASS:
          num_bytes[i] = num_elements[i] * sizeof(float);
	break;
      case mxINT8_CLASS:
         num_bytes[i] = num_elements[i] * sizeof(int8_t); 
	break;
      case mxUINT8_CLASS:
          num_bytes[i] = num_elements[i] * sizeof(uint8_t);
	break;
      case mxINT16_CLASS:
          num_bytes[i] = num_elements[i] * sizeof(int16_t);
	break;
      case mxUINT16_CLASS:
          num_bytes[i] = num_elements[i] * sizeof(uint16_t);
	break;
      case mxINT32_CLASS:
          num_bytes[i] = num_elements[i] * sizeof(int32_t);
	break;
      case mxUINT32_CLASS:
          num_bytes[i] = num_elements[i] * sizeof(uint32_t);
	break;
      case mxINT64_CLASS:
          num_bytes[i] = num_elements[i] * sizeof(int64_t);
	break;
      case mxUINT64_CLASS:
          num_bytes[i] = num_elements[i] * sizeof(uint64_t);
	break;
      }    
  }

  if (!mxIsDouble(prhs[3]) || mxGetM(prhs[3])!=1 || mxGetN(prhs[3])!=1)
    mexErrMsgTxt("Fourth argument should be scalar");

  if (!mxIsDouble(prhs[4]) || mxGetM(prhs[4])!=1 || mxGetN(prhs[4])!=1)
    mexErrMsgTxt("Fifth argument should be scalar");
  
  n_id = mxGetM(prhs[1]) * mxGetN(prhs[1]);

  record_offset = (int64_t) mxGetScalar(prhs[3]);
  record_size = (int64_t) mxGetScalar(prhs[4]);

  mxGetString(prhs[0], strFileName, MAXSTRING);
  if ( (fid = fopen(strFileName, "rb")) == NULL )
    mexErrMsgTxt("Unable to open file");

  fseek(fid, 0, 2); /* end of file */
  file_size = (int64_t) ftell(fid);
  n_records = (int64_t) ( (file_size - record_offset) / record_size );

  /*mexPrintf("n_id: %ld, record_offset: %ld, record_size: %d, file_size: %ld, n_records: %d\n", n_id, record_offset, record_size, file_size, n_records);*/

  /* check indices */
  for (i=0; i<n_id; i++) {
    if (pid[i]<0 || pid[i]>n_records-1){
      fclose(fid);
      mxErrMsgTxt("Index out of bounds");
    }
  }

  /* construct output cell array */
  output_array = mxCreateCellMatrix((int) n_fields, 1);

  pdatatemp = (char **) mxCalloc(n_fields, sizeof(char*));

  /* construct arrays for each field */
  for(i=0; i<n_fields; i++) {
    /*create dims array*/
    dims = (int*) mxCalloc(n_dim[i]+1, sizeof(int));
    id2d[0]=i;
    id2d[1] = 2;
    subs = mxCalcSingleSubscript(prhs[2], 2, id2d);
    ptemp = mxGetPr( mxGetCell(prhs[2], subs) );    
    
    /*if ( (n_dim[i]==1) && ptemp[0]==1 ) {*/
    /*    dims[0] = n_id;*/
    /*    dims[1] = 1;     */   
    /*} else {*/
        for (j=0;j<n_dim[i];j++) {
            dims[j] = (int) ptemp[j];
        }
    
        dims[n_dim[i]] = n_id;
    /*}*/
    
    /* mxSetCell(output_array, i, mxCreateNumericMatrix(num_elements[i], n_id, field_type[i], mxREAL)); */
    mxSetCell(output_array, i, mxCreateNumericArray(n_dim[i]+1, dims, field_type[i], mxREAL));
    pdatatemp[i] = (char *) mxGetPr( mxGetCell(output_array, i) );

    mxFree(dims);
  }

  /*loop though index vector and retrieve records */

  record_data = (char *) mxCalloc(record_size, sizeof(char));

  for (i=0; i<n_id; i++) {

    fseek(fid, record_offset+pid[i]*record_size, 0);
    fread(record_data, 1, record_size, fid);

    /* unpack data */
    for (j=0; j<n_fields; j++) {

	memcpy(&(pdatatemp[j][i*num_bytes[j]]), &(record_data[byte_offset[j]]), num_bytes[j]);

    }

  }

  mxFree(record_data);
  mxFree(byte_offset);
  mxFree(field_type);
  mxFree(num_elements);
  mxFree(n_dim);
  mxFree(pdatatemp);

  fclose(fid);

  plhs[0] = output_array;
}



/* $Log: mwlio.c,v $
/* Revision 1.1  2005/10/09 21:07:28  fabian
/* *** empty log message ***
/* */
