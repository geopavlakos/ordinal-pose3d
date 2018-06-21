function bbox = getHGbbox(center,scale)

    % get the bounding box of the image that was used as input to the
    % hourglass network

    ul = transform([1,1],center,scale,[256 256],1);
    br = transform([257,257],center,scale,[256 256],1);
    bbox = [ul(1), ul(2), br(1), br(2)];

end    
    
% mostly rewriting torch code in matlab

function new_pt = transform(pt,center,scale,res,invert)

    t = get_transform(center,scale,res);
    if invert
        t = inv(t);
    end
    new_pt = [pt(1)-1;pt(2)-1;1];
    new_pt = t*new_pt;
    new_pt = round(new_pt(1:2) + 0.0001) + 1;
    
end
    
function t = get_transform(center,scale,res)

    h = 200*scale;
    t = eye(3,3);
    t(1,1) = res(2)/h;
    t(2,2) = res(1)/h;
    t(1,3) = res(2)*(-center(1)/h + 0.5);
    t(2,3) = res(1)*(-center(2)/h + 0.5);
    t(3,3) = 1;
    
end