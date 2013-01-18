/* $Id: findrecord.c,v 1.1 2005/10/09 21:06:38 fabian Exp $ */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <math.h>
#include <time.h>
#include <mat.h>
#include <matrix.h>
#include <mex.h>

/* function to find the records that contain a field value nearest */
/* to the requested value  - for sorted fields only!! */
/* input: file name, values, field info, record_offset, record_size*/
/* output: indices */

#define MAXSTRING 512

int8_t compare_uint8(const void *key, const void *val)
{
  if ( ( *(uint8_t*)key ) < ( *(uint8_t*)val ) )
    return -1;
  else if ( ( *(uint8_t*)key ) > ( *(uint8_t*)val ) )
    return 1;
  else
    return 0;
}

int8_t compare_double(const void *key, const void *val)
{
  if ( ( *(double*)key ) < ( *(double*)val ) )
    return -1;
  else if ( ( *(double*)key ) > ( *(double*)val ) )
    return 1;
  else
    return 0;
}

int8_t compare_float(const void *key, const void *val)
{
  if ( ( *(float*)key ) < ( *(float*)val ) )
    return -1;
  else if ( ( *(float*)key ) > ( *(float*)val ) )
    return 1;
  else
    return 0;
}

int8_t compare_int8(const void *key, const void *val)
{
  if ( ( *(int8_t*)key ) < ( *(int8_t*)val ) )
    return -1;
  else if ( ( *(int8_t*)key ) > ( *(int8_t*)val ) )
    return 1;
  else
    return 0;
}

int8_t compare_int16(const void *key, const void *val)
{
  if ( ( *(int16_t*)key ) < ( *(int16_t*)val ) )
    return -1;
  else if ( ( *(int16_t*)key ) > ( *(int16_t*)val ) )
    return 1;
  else
    return 0;
}

int8_t compare_uint16(const void *key, const void *val)
{
  if ( ( *(uint16_t*)key ) < ( *(uint16_t*)val ) )
    return -1;
  else if ( ( *(uint16_t*)key ) > ( *(uint16_t*)val ) )
    return 1;
  else
    return 0;
}

int8_t compare_int32(const void *key, const void *val)
{
  if ( ( *(int32_t*)key ) < ( *(int32_t*)val ) )
    return -1;
  else if ( ( *(int32_t*)key ) > ( *(int32_t*)val ) )
    return 1;
  else
    return 0;
}

int8_t compare_uint32(const void *key, const void *val)
{
  if ( ( *(uint32_t*)key ) < ( *(uint32_t*)val ) )
    return -1;
  else if ( ( *(uint32_t*)key ) > ( *(uint32_t*)val ) )
    return 1;
  else
    return 0;
}

int8_t compare_int64(const void *key, const void *val)
{
  if ( ( *(int64_t*)key ) < ( *(int64_t*)val ) )
    return -1;
  else if ( ( *(int64_t*)key ) > ( *(int64_t*)val ) )
    return 1;
  else
    return 0;
}

int8_t compare_uint64(const void *key, const void *val)
{
  if ( ( *(uint64_t*)key ) < ( *(uint64_t*)val ) )
    return -1;
  else if ( ( *(uint64_t*)key ) > ( *(uint64_t*)val ) )
    return 1;
  else
    return 0;
}

void bsearch_range_file(FILE *fid, int64_t offset, uint16_t membsize, int64_t stride, int64_t nmemb, void *keystart, void *keyend, int8_t (*compar)(const void *, const void *), int64_t *result)
{
  /* offset = byte offset in the file where data starts */
  /* membsize = size of data type */
  /* stride = size of stride in bytes */

  char *tval;
  int64_t low, high, i;
  char found_start=0, found_end=0;
  int8_t cmp0, cmp1;

  result[0] = -1;
  result[1] = -1;

  tval =  calloc(1, membsize);

  /* compare range with first record */
  fseek(fid, offset, 0);
  fread(tval, 1, membsize, fid);

  cmp0 = compar(keystart, tval);
  cmp1 = compar(keyend, tval);
    
  if (cmp1 < 0) {
    /* end of range is before start of file, return [-1,-1] */
    found_end = 0;
    return;
  } else if (cmp0 <= 0) {
    /* start of range is before or on start of file */
    result[0] = 0;
    found_start = 1;
    if (cmp1 == 0) {
      /* end of range is beginning of file */
      result[1] = 0;
      found_end = 1;
      return;
    }
  }
  
  /* compare range with last record */
  fseek(fid, offset + (nmemb-1)*stride, 0);
  fread(tval, 1, membsize, fid);

  cmp0 = compar(keystart, tval);
  cmp1 = compar(keyend, tval);

  if (cmp0 > 0) {
    /* start of range is beyond end of file */
    found_start = 0;
    return;
  } else if (cmp1 >= 0) {
    /* end of range is beyond end of file */
    result[1] = nmemb-1;
    found_end = 1;
    if (cmp0 == 0) {
      /* start of range is end of file */
      result[0] = nmemb-1;
      found_start = 1;
      return;
    }      
  }

  if (!found_start) {
    for (low=-1, high=nmemb; high-low>1;) {
      i = (high+low)/2;
      fseek(fid, offset + i*stride, 0);
      fread(tval, 1, membsize, fid);

      cmp0 = compar(keystart, tval);

      if (cmp0 <= 0)
	high=i;
      else
	low=i;
    }
    result[0] = high;
    found_start = 1;
  }

  if (!found_end) {
    for (low=-1, high=nmemb; high-low>1;) {
      i = (high+low)/2;
      fseek(fid, offset + i*stride, 0);
      fread(tval, 1, membsize, fid);

      cmp1 = compar(keyend, tval);
  
      if (cmp1 <= 0)
	high=i;
      else
	low=i;
    }
    
    fseek(fid, offset + high*stride, 0);
    fread(tval, 1, membsize, fid);

    cmp1 = compar(keyend, tval);

    if (cmp1 == 0)
      result[1] = high;
    else
      result[1] = low;

    found_end = 1;
  }

  free(tval);
  return;
  
}


void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] )
{
  
  char strFileName[MAXSTRING];
  char *tval = NULL;
  char found_start=0, found_end=0;
  char *rangestart, *rangeend;

  double *pvalue=NULL;
  double range[2];
  double *pfield=NULL;
  double *ptemp;

  mxClassID field_type;

  int64_t byte_offset;
  int64_t num_elements;
  int64_t record_size;

  FILE *fid=NULL;

  int64_t record_offset;
  int64_t file_size;

  int64_t n_values;
  int64_t n_records;

  int64_t result[2];

  mxArray *output_array=NULL;

  if (nrhs!=5)
    mexErrMsgTxt("Incorrect number of input arguments");

  if (!mxIsChar(prhs[0]))
    mexErrMsgTxt("First argument should be a string");

  if (!mxIsDouble(prhs[1]))
    mexErrMsgTxt("Second argument should be a double vector");

  pvalue = mxGetPr(prhs[1]);
  n_values = (int64_t) mxGetM(prhs[1]) * mxGetN(prhs[1]);

  if (n_values<1 || n_values>2)
    mexErrMsgTxt("Second argument should be scalar or two-element vector");

  range[0] = pvalue[0];
  range[n_values-1] = pvalue[n_values-1];

  if (!mxIsCell(prhs[2]))
    mexErrMsgTxt("Third argument should be a cell matrix of field descriptions");

  /*pfield = mxGetPr(prhs[2]);*/

  if (mxGetM(prhs[2])*mxGetN(prhs[2])!=3)
    mexErrMsgTxt("Error in field description");

  byte_offset = (int64_t) mxGetScalar( mxGetCell( prhs[2], 0 ) );
  field_type = (mxClassID) mxGetScalar( mxGetCell( prhs[2], 1 ) );
  num_elements = (int64_t) mxGetScalar( mxGetCell( prhs[2], 2 ) );

  if ( (num_elements>1) || mxGetNumberOfElements( mxGetCell( prhs[2], 2 ) )>1 )
    mexErrMsgTxt("Only fields with one element supported");

  if (!mxIsDouble(prhs[3]) || mxGetM(prhs[3])!=1 || mxGetN(prhs[3])!=1)
    mexErrMsgTxt("Fourth argument should be scalar");

  if (!mxIsDouble(prhs[4]) || mxGetM(prhs[4])!=1 || mxGetN(prhs[4])!=1)
    mexErrMsgTxt("Fifth argument should be scalar");

  record_offset = (int64_t) mxGetScalar(prhs[3]);
  record_size = (int64_t) mxGetScalar(prhs[4]);

  mxGetString(prhs[0], strFileName, MAXSTRING);
  if ( (fid = fopen(strFileName, "rb")) == NULL )
    mexErrMsgTxt("Unable to open file");

  fseek(fid, 0, 2); /* end of file */
  file_size = (int64_t) ftell(fid);
  n_records = (int64_t) ( (file_size - record_offset) / record_size );

  /* construct output cell array */
  output_array = mxCreateDoubleMatrix(n_values, 1, mxREAL);

  ptemp = mxGetPr(output_array);

  switch (field_type) {

  case mxCHAR_CLASS: /* char, will never be the case! */
    rangestart = mxCalloc(sizeof(char), 1);
    *((char*)rangestart) = (char) range[0];
    rangeend = mxCalloc(sizeof(char), 1);
    *((char*)rangeend) = (char) range[1];
    bsearch_range_file(fid, record_offset + byte_offset, sizeof(char), record_size, n_records, rangestart, rangeend, compare_uint8, result);
    break;
  case mxDOUBLE_CLASS: /* double */
    rangestart = mxCalloc(sizeof(double), 1);
    *((double*)rangestart) = (double) range[0];
    rangeend = mxCalloc(sizeof(double), 1);
    *((double*)rangeend) = (double) range[1];
    bsearch_range_file(fid, record_offset + byte_offset, sizeof(double), record_size, n_records, rangestart, rangeend, compare_double, result);
    break;
  case mxSINGLE_CLASS: /* float */
    rangestart = mxCalloc(sizeof(float), 1);
    *((float*)rangestart) = (float) range[0];
    rangeend = mxCalloc(sizeof(float), 1);
    *((float*)rangeend) = (float) range[1];
    bsearch_range_file(fid, record_offset + byte_offset, sizeof(float), record_size, n_records, rangestart, rangeend, compare_float, result);
    break;
  case mxINT8_CLASS: /* int8 */
    rangestart = mxCalloc(sizeof(int8_t), 1);
    *((int8_t*)rangestart) = (int8_t) range[0];
    rangeend = mxCalloc(sizeof(int8_t), 1);
    *((int8_t*)rangeend) = (int8_t) range[1];
    bsearch_range_file(fid, record_offset + byte_offset, sizeof(int8_t), record_size, n_records, rangestart, rangeend, compare_int8, result);
    break;
  case mxUINT8_CLASS: /* uint8 */
    rangestart = mxCalloc(sizeof(uint8_t), 1);
    *((uint8_t*)rangestart) = (uint8_t) range[0];
    rangeend = mxCalloc(sizeof(uint8_t), 1);
    *((uint8_t*)rangeend) = (uint8_t) range[1];
    bsearch_range_file(fid, record_offset + byte_offset, sizeof(uint8_t), record_size, n_records, rangestart, rangeend, compare_uint8, result);
    break;
  case mxINT16_CLASS: /* int16 */
    rangestart = mxCalloc(sizeof(int16_t), 1);
    *((int16_t*)rangestart) = (int16_t) range[0];
    rangeend = mxCalloc(sizeof(int16_t), 1);
    *((int16_t*)rangeend) = (int16_t) range[1];
    bsearch_range_file(fid, record_offset + byte_offset, sizeof(int16_t), record_size, n_records, rangestart, rangeend, compare_int16, result);
    break;
  case mxUINT16_CLASS: /* uint16 */
    rangestart = mxCalloc(sizeof(uint16_t), 1);
    *((uint16_t*)rangestart) = (uint16_t) range[0];
    rangeend = mxCalloc(sizeof(uint16_t), 1);
    *((uint16_t*)rangeend) = (uint16_t) range[1];
    bsearch_range_file(fid, record_offset + byte_offset, sizeof(uint16_t), record_size, n_records, rangestart, rangeend, compare_uint16, result);
    break;
  case mxINT32_CLASS: /* int32 */
    rangestart = mxCalloc(sizeof(int32_t), 1);
    *((int32_t*)rangestart) = (int32_t) range[0];
    rangeend = mxCalloc(sizeof(int32_t), 1);
    *((int32_t*)rangeend) = (int32_t) range[1];
    bsearch_range_file(fid, record_offset + byte_offset, sizeof(int32_t), record_size, n_records, rangestart, rangeend, compare_int32, result);
    break;
  case mxUINT32_CLASS: /* uint32 */
    rangestart = mxCalloc(sizeof(uint32_t), 1);
    *((uint32_t*)rangestart) = (uint32_t) range[0];
    rangeend = mxCalloc(sizeof(uint32_t), 1);
    *((uint32_t*)rangeend) = (uint32_t) range[1];
    bsearch_range_file(fid, record_offset + byte_offset, sizeof(uint32_t), record_size, n_records, rangestart, rangeend, compare_uint32, result);
    break;
  case mxINT64_CLASS: /* int64 */
    rangestart = mxCalloc(sizeof(int64_t), 1);
    *((int64_t*)rangestart) = (int64_t) range[0];
    rangeend = mxCalloc(sizeof(int64_t), 1);
    *((int64_t*)rangeend) = (int64_t) range[1];
    bsearch_range_file(fid, record_offset + byte_offset, sizeof(int64_t), record_size, n_records, rangestart, rangeend, compare_int64, result);
    break;
  case mxUINT64_CLASS: /* uint64 */
    rangestart = mxCalloc(sizeof(uint64_t), 1);
    *((uint64_t*)rangestart) = (uint64_t) range[0];
    rangeend = mxCalloc(sizeof(uint64_t), 1);
    *((uint64_t*)rangeend) = (uint64_t) range[1];
    bsearch_range_file(fid, record_offset + byte_offset, sizeof(uint64_t), record_size, n_records, rangestart, rangeend, compare_uint64, result);
    break;
  }

  ptemp[0] = (double) result[0];
  ptemp[1] = (double) result[1];

  mxFree(tval);
  mxFree(rangestart);
  mxFree(rangeend);


  fclose(fid);
  plhs[0] = output_array;
}


/* $Log: findrecord.c,v $
/* Revision 1.1  2005/10/09 21:06:38  fabian
/* *** empty log message ***
/* */
