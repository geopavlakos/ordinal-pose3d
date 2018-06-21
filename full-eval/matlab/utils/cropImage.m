function im1 = cropImage(im,bbox)

    w = bbox(3)-bbox(1)+1;
    h = bbox(4)-bbox(2)+1;
    padsize = round([w,h]);
    im = padarray(im,padsize,0);
    im1 = imcrop(im,[bbox(1:2)+padsize,[w,h]]);
    im1 = imresize(im1,[200,200]);
    
end