%% This code is corrected  one detal(V12)=0.5((W_x(1,1)-W_y(1,1))+(W_x(1,3)-W_y(1,3)))
%2013 03 13
% this function is only doing similarty check, main to output the mask for
% later on change x11 to 1/2(x11+y11)
function [output,mask1,mask2]  = similarity_check_withY_step1(input1,input2,input3,stepSize,threshold)
% mask1 : the pixel copied from virtual view
% mask2 : the four corner pixels
[height,width]=size(input1);
diff=double(zeros(100000,1));
mask1=logical(zeros(height,width));
mask2=uint8(zeros(height,width));
count=0;

for m = 1+stepSize : stepSize : height-stepSize+1
    for n = 1+stepSize : stepSize : width-stepSize+1
        W_x=double(input1(m-2:m, n-2:n));
        W_y=double(input2(m-2:m, n-2:n));
        % if isempty(find(W_y==0))
        if W_y(1,1)~=0 & W_y(1,3)~=0 &W_y(3,1)~=0 &W_y(3,3)~=0%&W_y(1,2)~=0 & W_y(2,1)~=0 &W_y(2,2)~=0
            diff(count+1,1)=double(abs(W_x(1,1)-W_y(1,1))+abs(W_x(1,3)-W_y(1,3))+abs(W_x(3,1)-W_y(3,1))+abs(W_x(3,3)-W_y(3,3)));
            if diff(count+1,1) < threshold
                mask2(m-2,n-2)=1 +mask2(m-2,n-2);
                mask2(m-2,n)=1 +mask2(m-2,n);
                mask2(m,n-2)=1 +mask2(m,n-2);
                mask2(m,n)=1 +mask2(m,n);
                if input2(m-2,n-1) ~=0 & input2(m-1,n-2)~=0 & input2(m-1,n-1)~=0
                    input1(m-2,n-1)=double(input2(m-2,n-1));
                    input1(m-1,n-2)=double(input2(m-1,n-2));
                    input1(m-1,n-1)=double(input2(m-1,n-1));
                    mask1(m-2,n-1)=1;
                    mask1(m-1,n-2)=1;
                    mask1(m-1,n-1)=1;
                elseif input2(m-2,n-1) ~=0 & input2(m-1,n-2)~=0 & input2(m-1,n-1)==0
                    input1(m-2,n-1)=double(input2(m-2,n-1));
                    input1(m-1,n-2)=double(input2(m-1,n-2));
                    input1(m-1,n-1)=double(input3(m-1,n-1));
                    mask1(m-2,n-1)=1;
                    mask1(m-1,n-2)=1;
                elseif input2(m-2,n-1) ~=0 & input2(m-1,n-2)==0 & input2(m-1,n-1)==0
                    input1(m-2,n-1)=double(input2(m-2,n-1));
                    input1(m-1,n-2)=double(input3(m-1,n-2));
                    input1(m-1,n-1)=double(input3(m-1,n-1));
                    mask1(m-2,n-1)=1;
                elseif input2(m-2,n-1) ==0 & input2(m-1,n-2)~=0 & input2(m-1,n-1)==0
                    input1(m-2,n-1)=double(input3(m-2,n-1));
                    input1(m-1,n-2)=double(input2(m-1,n-2));
                    input1(m-1,n-1)=double(input3(m-1,n-1));
                    mask1(m-1,n-2)=1;
                elseif input2(m-2,n-1) ==0 & input2(m-1,n-2)==0 & input2(m-1,n-1)==0
                    input1(m-2,n-1)=double(input3(m-2,n-1));
                    input1(m-1,n-2)=double(input3(m-1,n-2));
                    input1(m-1,n-1)=double(input3(m-1,n-1));
                elseif  input2(m-2,n-1) ==0 & input2(m-1,n-2)~=0 & input2(m-1,n-1)~=0
                    input1(m-2,n-1)= double(input3(m-2,n-1));
                    input1(m-1,n-2)=double(input2(m-1,n-2));
                    input1(m-1,n-1)=double(input2(m-1,n-1));
                    mask1(m-1,n-2)=1;
                    mask1(m-1,n-1)=1;
                elseif  input2(m-2,n-1) ~=0 & input2(m-1,n-2)==0 & input2(m-1,n-1)~=0
                    input1(m-2,n-1)=double(input2(m-2,n-1));
                    input1(m-1,n-2)=double(input3(m-1,n-2));
                    input1(m-1,n-1)=double(input2(m-1,n-1));
                    mask1(m-2,n-1)=1;
                    mask1(m-1,n-1)=1;
                else % input2(m-2,n-1) ==0 & input2(m-1,n-2)==0 & input2(m-1,n-1)~=0
                    input1(m-2,n-1)=double(input3(m-2,n-1));
                    input1(m-1,n-2)=double(input3(m-1,n-2));
                    input1(m-1,n-1)=double(input2(m-1,n-1));
                    mask1(m-1,n-1)=1;
                end
            end
        end
        count=count+1;
    end
end
output=input1;
end