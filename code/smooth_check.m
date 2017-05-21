
% Last modification is on 2013 3 14

function [output,mask] = smooth_check(input_enhance,input_base,stepSize,threshold)
%function [output,mask,std_inter,std_new1,std_up, std_inter_sum,std_new1_sum,std_up_sum] = smooth_check(input_enhance,input_base,stepSize,threshold,width, height)

%  V_interpolation_Y{1} = imresize(V_dende_Y{1},scalefactor,'lanczos3');
% stepSize=2;
% input_enhance = V_interpolation_Y{i};
% input_base = V_up_Y{i};
% For example
% V_new_Y{i} = smooth_check(V_interpolation_Y{i},V_up_Y{i},2,1,width, height)
[height,width]=size(input_enhance);
mask = logical(zeros(height,width));
std_inter= zeros(height,width);
%std_up= zeros(height,width);
for m = 1+stepSize : stepSize : height-stepSize+1
    for n = 1+stepSize : stepSize : width-stepSize+1
        %W_z=double(input_base(m-2:2:m, n-2:2:n));
        %W_y=double(input1(m-2:2:m, n-2:2:n));
        W_x=double(input_enhance(m-2:m, n-2:n));
        std_inter(m,n)=std2(W_x);
        % std_up(m,n)=std2(W_y);
        % var=var(W_x(:));
        if std_inter(m,n) < threshold
            input_base(m-2:m,n-1)=input_enhance(m-2:m,n-1);
            input_base(m-1,n-2:n)=input_enhance(m-1,n-2:n);
            mask(m-2,n-1)=1;
            mask(m-1,n-2)=1;
            mask(m-1,n-1)=1;
        end
    end
end
output =input_base;
end




%% for testing and also it is used for enhance the Vnew1 (after window searching)
% clear
% threshold= [0.01, 0.05, 0.1, 0.15, 0.2, 0.25, 0.5, 0.75, 0.9, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75];    %MSE or MAD
% stepSize=3;
% for index =1:length(threshold)
%     clear Vnew1_Y
%     clear V_interpolation_Y
%     load Vnew1_Y
%     load V_interpolation_Y
%     input=V_interpolation_Y{1};
%     for m = stepSize : stepSize : height
%         for n = stepSize : stepSize : width
%             W_x=double(input(m-stepSize+1:m, n-stepSize+1:n));
%             std=std2(W_x);
%             %   var=var(W_x(:));
%             if std < threshold(index)
%                 Vnew1_Y{1}(m-stepSize+1,n-stepSize+2)=V_interpolation_Y{1}(m-stepSize+1,n-stepSize+2);
%                 Vnew1_Y{1}(m-stepSize+2,:)=V_interpolation_Y{1}(m-stepSize+2,:);
%                 Vnew1_Y{1}(m-stepSize+3,n-stepSize+2)=V_interpolation_Y{1}(m-stepSize+3,n-stepSize+2);
%             end
%         end
%     end
%     PSNR_pro_luma111(index) = PSNR(V_full_Y{1},Vnew1_Y{1})
% end