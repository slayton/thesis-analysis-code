function w = calc_waveform_width(wave)

    mw = squeeze(mean(wave));
    [mx mxind] = max( mw(5:12,:) );
    mxind = mxind + 4;
    [mx mnind] = min(mw(13:end,:));
    mnind = mnind + 12;

    w = (mnind - mxind);% * 3.2e-5;
    
end