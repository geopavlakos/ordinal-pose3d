function errorH36M(S,Sgt,imgname)

    % compute error
    E3D = computeError(S,Sgt);
    % print per action results
    printResults(E3D,imgname)
    
end

function dist = computeError(S,Sgt)

    dist = zeros(size(S,1),1);
    for i = 1:size(S,1)
        S1 = squeeze(S(i,:,:)); 
        S2 = squeeze(Sgt(i,:,:));
        % root alignment
        S1 = S1 - repmat(S1(:,1),1,size(S1,2));
        S2 = S2 - repmat(S2(:,1),1,size(S2,2));
        % mean per joint 3D error
        dist(i,1) = mean(sqrt(sum((S1-S2).^2,1)));
    end

end

function printResults(E3D,imgname)

    subject_set = {'S9','S11'};
    motion_set = {'Directions','Discussion','Eating','Greeting','Phoning',...
        'Photo','Posing','Purchases','Sitting','SittingDown',...
        'Smoking','Waiting','WalkDog','Walking','WalkTogether'};

    % per action error
    for i = 1:15
        E3D_all{i,1} = [];
    end
    for img_i = 1:numel(imgname)
        motion = char(regexp(imgname{img_i},'_[a-zA-Z]+','match'));
        motion = motion(2:end);
        for motion_i = 1:numel(motion_set)
            if strcmp(motion, motion_set{motion_i})
                E3D_all{motion_i} =[E3D_all{motion_i}; E3D(img_i)];
                break
            end
        end
    end

    % print results
    fid = fopen('results.txt','a+');
    fprintf(fid,'\n');
    fprintf(fid,datestr(now));
    fprintf(fid,'  %s ',subject_set{:});
    fprintf(fid,'\n');
    fprintf(fid,'%12s','Motion ');
    for i = 1:length(motion_set)
        fprintf(fid,'& %12s ',motion_set{i});
    end
    fprintf(fid,'& %12s','Average');
    fprintf(fid,'\\\\\n');
    fprintf(fid,'%12s','Final ');
    for i = 1:length(E3D_all)
        if ~isempty(E3D_all{i})
            fprintf(fid,'& %12s ',sprintf('%.2f',mean(E3D_all{i})));
        else
            fprintf(fid,'& %12s ','NaN');
        end
    end
    fprintf(fid,'& %12s ',sprintf('%.2f',mean(mean(cell2mat(E3D_all)))));
    fprintf(fid,'\\\\\n');
    fclose(fid);
    
end