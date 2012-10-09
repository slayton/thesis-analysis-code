function recon = exp_reconstruct(exp, ep, varargin)

args.tau=.25;
args.time_win = exp.(ep).et;
args.structures = {'all'};
args.pbins = [];
args.directional = 1;
args.smooth = 0;
args = parseArgsLite(varargin,args);

for i=1:numel(args.structures)
    

    
    [tc ind] = get_exp_tuning_curves(exp, ep, 'structure', args.structures{i}, 'directional', args.directional);
   
    [pdf tbins] = reconstruct( args.time_win(1), args.time_win(2), ...
                tc,exp.(ep).cl(ind), 't_var', 'st', 'tau', args.tau);
   
    
    dp = exp.(ep).cl(1).tc_bw;
    if isempty(args.pbins)
        pbins = min(exp.(ep).pos.lp):dp:max(exp.(ep).pos.lp);
    else
        pbins = args.pbins;
    end
    
    pdf_c(:,:,1) = pdf(1:numel(pbins),:);
    if ~args.directional
        pdf_c(:,:,1) = pdf;
        pdf_c(:,:,2) = pdf;
        pdf_c(:,:,3) = pdf;       
    else
        n_p = size(pdf,1);        
        div = n_p/size(tc,3);
        
        if size(tc,3)>2
            error('PDFS are not defined for more than 2 directions');
        end
%         for j=1:size(tc,3) %#ok
%             %pdf_c(:,:,3) = pdf(numel(pbins)+(1:numel(pbins)),:);
%             pdf_c(:,:,j) = pdf( (j-1)*div+1 : (j)*div , :);
%         end

        pdf_c(:,:,1) = pdf(1:div,:);
        pdf_c(:,:,3) = pdf(div+1:end,:);
        
    end
    
    if args.smooth
        disp('Smoothing, this make take some time');
        pdf_c = smooth_estimate(pdf_c);
    end

    
    recon(i).tbins = mean(tbins,2);
    recon(i).pbins = pbins;
    recon(i).pdf = pdf_c;
    recon(i).loc = args.structures{i};

end