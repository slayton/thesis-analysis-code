#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <math.h>
#include <time.h>
#include <mat.h>
#include <matrix.h>
#include <mex.h>

#define MAXSTRING 512

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] )
{

  int i,j,k;
  int ncells;
  int nrows;
  int *ncol;
  mxClassID *data_type;
  int *element_size;
  int *col_offset;
  int matrix_width = 0;
  char *celldata;
  char *tmp;
  char strFileName[MAXSTRING];
  FILE *fid=NULL;
  mxArray *cell;
  int inputtype;

  /* create default empty matrices for each output variable */
  for (i=0; i<nlhs; i++) {
    plhs[i] = mxCreateDoubleMatrix(0,0,mxREAL);
  }

  if (nrhs!=3)
    mexErrMsgTxt("Incorrect number of input arguments");

  if (!mxIsChar(prhs[0]))
    mexErrMsgTxt("First argument should be a string");

  if (mxIsCell(prhs[1]))
    inputtype=1;
  else if (mxIsStruct(prhs[1]))
    inputtype=2;
  else
    mexErrMsgTxt("Second argument should be a cell array");

  if (!mxIsNumeric(prhs[2]))
    mexErrMsgTxt("Third argument should be a scalar");

  mxGetString(prhs[0], strFileName, MAXSTRING);
  if ( (fid = fopen(strFileName, "ab")) == NULL )
    mexErrMsgTxt("Unable to open file");

  if (inputtype==1) { /* cell */
    ncells = mxGetM(prhs[1]) * mxGetN(prhs[1]);
  } else {
    ncells = mxGetNumberOfFields(prhs[1]);   
  }
  nrows = mxGetScalar(prhs[2]);

  ncol = (int*) calloc(ncells, sizeof(int));
  data_type = (mxClassID*) calloc(ncells, sizeof(mxClassID));
  element_size = (int*) calloc(ncells, sizeof(int));
  col_offset = (int*) calloc(ncells, sizeof(int));

  for(i=0; i<ncells; i++) {
    if (inputtype==1) /* cell */
      cell = mxGetCell(prhs[1], i);
    else
      cell = mxGetFieldByNumber(prhs[1], 0, i);

    ncol[i] = (int) ( mxGetNumberOfElements(cell) / nrows );
    data_type[i] = (mxClassID) mxGetClassID(cell);
    if (data_type[i]==mxCHAR_CLASS) {
        element_size[i] = 1;
    }
    else {
        element_size[i] = (int) mxGetElementSize(cell);
    }

    if (i>0) {
      col_offset[i] = col_offset[i-1] + ncol[i-1]*element_size[i-1];
    }
    matrix_width += ncol[i]*element_size[i];
    /*mexPrintf("%d - ncol: %d, element_size: %d, col_offset: %d, matrix_width: %d\n", i, ncol[i], element_size[i], col_offset[i], matrix_width);*/
  }


/*   /\* create temporary matrix with data *\/ */
/*   tmp = (char*) calloc(nrows, matrix_width); */
/*   /\*mexPrintf("ncells: %d, matrix_width: %d\n", ncells, matrix_width);*\/ */
/*   for(i=0; i<ncells; i++) { */
/*     if (inputtype==1) /\* cell *\/ */
/*       cell = mxGetCell(prhs[1], i); */
/*     else */
/*       cell = mxGetFieldByNumber(prhs[1], 0, i); */

/*     celldata = (char*) mxGetPr(cell); */
/*     for(j=0;j<ncol[i];j++) { */
/*       for(k=0;k<nrows;k++) { */
/* 	memcpy(&tmp[k*matrix_width + col_offset[i] + j*element_size[i]], &celldata[(j*nrows+k)*element_size[i]], element_size[i]); */
/*       } */
/*     } */
/*   } */

  /* create temporary matrix with data */
  tmp = (char*) calloc(nrows, matrix_width);
  /*mexPrintf("ncells: %d, matrix_width: %d\n", ncells, matrix_width);*/
  for(i=0; i<ncells; i++) {
    if (inputtype==1) /* cell */
      cell = mxGetCell(prhs[1], i);
    else
      cell = mxGetFieldByNumber(prhs[1], 0, i);

    celldata = (char*) mxGetPr(cell);

    for (k=0;k<nrows;k++) {
      memcpy(&tmp[k*matrix_width + col_offset[i]], &celldata[k*ncol[i]*element_size[i]], ncol[i]*element_size[i]);
    }

  }

  /* write to file */
  fwrite(tmp, sizeof(char), matrix_width * nrows, fid);

  fclose(fid);

  free(tmp);
  free(ncol);
  free(data_type);
  free(element_size);
  free(col_offset);

}
