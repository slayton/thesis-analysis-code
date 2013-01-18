% @MWLFIELD
%
% Creation
%   mwlfield     - mwlfield constructor
%
% Field information
%   byteoffset   - byte offsets for fields
%   code         - return the field type code
%   elementsize  - return the size of a field element
%   length       - return the number of elements
%   matcode      - return matlab type code
%   mexcode      - mex data type code
%   name         - field names
%   size         - field dimensions
%   type         - field type
%
% Conversions
%   formatstr    - convert fields to format string for use with textscan and fprintf
%   mex_fielddef - mex type definitions
%   print        - print mwlfield information in mwl header format
%
% Misc
%   display      - show mwlfield object information
%   eq           - equality test for mwlfield objects
%   ismember     - true if set member
%   bytesize     - return the total field size in bytes
%   subsasgn     - subscripted assignment
