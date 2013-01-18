function fb = appendData(fb, data)

if nargin<2 || isempty(data)
  return;
end

if ~strcmp( get(fb, 'mode'), 'append' )
    error('mwlboundfile:appendData:invalidMode', 'Cannot append data if not in append mode')
end

if ~isstruct(data) || ~all( ismember( {'bounds'}, fieldnames(data) ) ) || ~all( cellfun( @(x) isstruct(x) & all( ismember( {'projections', 'projection_names', 'vertices'}, fieldnames(x) ) ), {data.bounds} ) )
    error('mwlboundfile:appendData:invalidData', 'Invalid data')
end

try
    
    nclusters = numel( data );
    
    s = cell( nclusters*6, 1 );
    
    for k=1:nclusters
        
        nbounds = numel( data(k).bounds );
        
        for b=1:nbounds
            
            idx = (k-1)*6;
            
            s{idx+1} = '';
            s{idx+2} = num2str( k );
            s{idx+3} = sprintf( '%d\t%d', data(k).bounds(b).projections );
            s{idx+4} = sprintf( '%s\n%s', data(k).bounds(b).projection_names{:} );
            s{idx+5} = num2str( size( data(k).bounds(b).vertices, 1) );
            s{idx+6} = sprintf( '%f\t%f\n', data(k).bounds(b).vertices' );
            
        end
        
    end

catch ME
    error( 'mwlboundfile:appendData:writeError', 'Error writing data to file - transaction aborted')
end


fid = fopen(fullfile(fb), 'a');

fprintf( fid, '%s\n', s{:} );

fclose(fid);

fb = reopen(fb);