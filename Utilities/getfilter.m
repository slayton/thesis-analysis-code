function [b, s] = getfilter(Fs, band, method, varargin)
%GETFILTER return coefficients for eeg filter
%
%  Syntax
%
%      [b, s] = getfilter( Fs, band, method )
%
%  Description
%
%    This function returns the coefficients for a FIR filter. Band
%    specifies the frequency band of interest and can be one of: 'theta',
%    'ripple', 'slow', 'spindle', 'gamma'. The filter is created using one
%    of three methods: 'win', 'ls' or 'pm'. Optionally, a string containing
%    the filter definition is returned.
%


args.band = [0 0];
args = parseArgsLite(varargin,args);

switch band
    
    case 'theta'
        
        if nargin<3 || isempty(method)
            method = 'win';
        end
        
        %Filter order is the the first even integer > Fs
        s = 'N = ceil(Fs); N = N + mod(N,2); ';
        
        switch method
            case 'win'
                s = [s 'b = fir1( N, 2.*[6 12]./Fs );'];
            case 'ls'
                s = [s 'b = firls( N, 2.*[0 5 6 12 14 0.5*Fs]./Fs, [0 0 1 1 0 0], [100 1 10] );'];
            case 'pm'
                s = [s 'b = firpm( N, 2.*[0 5 6 12 14 0.5*Fs]./Fs, [0 0 1 1 0 0], [10 1 10] );'];
            otherwise
                error('Invalid method')
        end
        
        eval(s);
        
    case 'ripple'

        if nargin<3 || isempty(method)
            method = 'win';
        end
        
        %Filter order is the the first even integer > Fs
        s = 'N = ceil(Fs./4); N = N + mod(N,2); ';
        
        switch method
            case 'win'
                s = [s 'b = fir1( N, 2.*[140 240]./Fs );'];
            otherwise
                error('Invalid method')
        end
        
        eval(s);        
        
    case 'slow-ripple'

        if nargin<3 || isempty(method)
            method = 'win';
        end
        
        %Filter order is the the first even integer > Fs
        s = 'N = ceil(Fs./4); N = N + mod(N,2); ';
        
        switch method
            case 'win'
                s = [s 'b = fir1( N, 2.*[80 240]./Fs );'];
            otherwise
                error('Invalid method')
        end
        
        eval(s); 
   case 'wide-ripple'

        if nargin<3 || isempty(method)
            method = 'win';
        end
        
        %Filter order is the the first even integer > Fs
        s = 'N = ceil(Fs./4); N = N + mod(N,2); ';
        
        switch method
            case 'win'
                s = [s 'b = fir1( N, 2.*[80 360]./Fs );'];
            otherwise
                error('Invalid method')
        end
        
        eval(s);      
        
    case 'slow'
        
        if nargin<3 || isempty(method)
            method = 'win';
        end
        
        %Filter order is the the first even integer > Fs
        s = 'N = ceil(Fs.*1.5); N = N + mod(N,2); ';
        
        switch method
            case 'win'
                s = [s 'b = fir1( N, 2.*[4]./Fs );'];
            otherwise
                error('Invalid method')
        end
        
        eval(s);   
        
    case 'spindle'
         %Filter order is the the first even integer > Fs
        s = 'N = ceil(Fs); N = N + mod(N,2); ';
        
        switch method
            case 'win'
                s = [s 'b = fir1( N, 2.*[8 16]./Fs );'];
            
            otherwise
                error('Invalid method')
        end
        
        eval(s);
    
    case 'spindle2'
         %Filter order is the the first even integer > Fs
         s = 'N = ceil(Fs./4); N = N + mod(N,2); ';
        
        switch method
            case 'win'
                s = [s 'b = fir1( N, 2.*[10 20]./Fs );'];
            otherwise
                error('Invalid method')
        end
        
        eval(s);
    case 'gamma'
        
        if nargin<3 || isempty(method)
            method = 'win';
        end
        
        %Filter order is the the first even integer > Fs
        s = 'N = ceil(Fs./4); N = N + mod(N,2); ';
        
        switch method
            case 'win'
                s = [s 'b = fir1( N, 2.*[30 100]./Fs );'];
            otherwise
                error('Invalid method')
        end
        
        eval(s);
        
    case 'beta'
        
         if nargin<3 || isempty(method)
            method = 'win';
        end
        
        %Filter order is the the first even integer > Fs
        s = 'N = ceil(Fs./4); N = N + mod(N,2); ';
        
        switch method
            case 'win'
                s = [s 'b = fir1( N, 2.*[15 40]./Fs );'];
            otherwise
                error('Invalid method')
        end
        
        eval(s);       
        
    case 'custom'
        if sum(args.band)==0 || ~ismonotonic(args.band) || any(sign(args.band) == -1)
            error('Invalid band specified');
        end
        if nargin<3 || isempty(method)
                method = 'win';
            end

            %Filter order is the the first even integer > Fs
            s = 'N = ceil(Fs./4); N = N + mod(N,2); ';

            switch method
                case 'win'
                    s = [s 'b = fir1( N, 2.*[', num2str(args.band(1)), ' ', num2str(args.band(2)),']./Fs );'];
                otherwise
                    error('Invalid method')
            end

            eval(s);      
    otherwise
        error('Invalid Band specified');

end