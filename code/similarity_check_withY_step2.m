% 2013 03 13

function [output,mask]  = similarity_check_withY_step2(input1,input2,mask_virtual,stepSize,threshold_Y)
% mask : the pixel copied from virtual view and also do luminance conpensation
%[output,mask]  = similarity_check_withY_step2(Vnew2_Y,V_virtual_Y,mask_virtual,2,threshold_Y,width, height)
[height,width]=size(input1);
mask=logical(zeros(height,width));
Yshift=double(zeros(100000,1));
Yshift_h=double(zeros(100000,1));
Yshift_v=double(zeros(100000,1));
count=0;

for m = 1+stepSize : stepSize : height-stepSize+1
    for n = 1+stepSize : stepSize : width-stepSize+1
        W_x=double(input1(m-2:m, n-2:n));
        W_y=double(input2(m-2:m, n-2:n));
        W_mask=mask_virtual(m-2:m, n-2:n);
        
         Yshift(count+1,1)=0.25*(W_x(1,1)+W_x(1,3)+W_x(3,1)+W_x(3,3))-0.25*(W_y(1,1)+W_y(1,3)+W_y(3,1)+W_y(3,3));
         Yshift_h(count+1,1)=0.5*((W_x(1,1)-W_y(1,1))+(W_x(1,3)-W_y(1,3)));
         Yshift_v(count+1,1)=0.5*((W_x(1,1)-W_y(1,1))+(W_x(3,1)-W_y(3,1)));
         if Yshift(count+1,1) < threshold_Y & Yshift(count+1,1) > (0-threshold_Y)
                 if W_mask(1,2)==1 & W_mask(2,1)==1 & W_mask(2,2)==1
                        input1(m-2,n-1)=double(input1(m-2,n-1))+Yshift_h(count+1,1);
                        input1(m-1,n-2)=double(input1(m-1,n-2))+Yshift_v(count+1,1);
                        input1(m-1,n-1)=double(input1(m-1,n-1))+Yshift(count+1,1);
                        mask(m-2,n-1)=1;
                        mask(m-1,n-2)=1;
                        mask(m-1,n-1)=1;
                    elseif W_mask(1,2)==1 & W_mask(2,1)==1 & W_mask(2,2)==0
                        input1(m-2,n-1)=double(input1(m-2,n-1))+Yshift_h(count+1,1);
                        input1(m-1,n-2)=double(input1(m-1,n-2))+Yshift_v(count+1,1);
                        %input1(m-1,n-1)=double(input3(m-1,n-1));
                        mask(m-2,n-1)=1;
                        mask(m-1,n-2)=1;
                    elseif W_mask(1,2)==1 & W_mask(2,1)==0 & W_mask(2,2)==0
                        input1(m-2,n-1)=double(input1(m-2,n-1))+Yshift_h(count+1,1);
%                         input1(m-1,n-2)=double(input3(m-1,n-2));
%                         input1(m-1,n-1)=double(input3(m-1,n-1));
                        mask(m-2,n-1)=1;
                    elseif W_mask(1,2)==0 & W_mask(2,1)==1 & W_mask(2,2)==0
                       % input1(m-2,n-1)=double(input3(m-2,n-1));
                        input1(m-1,n-2)=double(input1(m-1,n-2))+Yshift_v(count+1,1);
                        %input1(m-1,n-1)=double(input3(m-1,n-1));
                        mask(m-1,n-2)=1;            
                 elseif W_mask(1,2)==0 & W_mask(2,1)==0 & W_mask(2,2)==0
                        input1(m-2,n-1)=double(input1(m-2,n-1));
                        input1(m-1,n-2)=double(input1(m-1,n-2));
                        input1(m-1,n-1)=double(input1(m-1,n-1));                  
                    elseif W_mask(1,2)==0 & W_mask(2,1)==1 & W_mask(2,2)==1
                      %  input1(m-2,n-1)= double(input3(m-2,n-1));
                        input1(m-1,n-2)=double(input1(m-1,n-2))+Yshift_v(count+1,1);
                        input1(m-1,n-1)=double(input1(m-1,n-1))+Yshift(count+1,1);
                        mask(m-1,n-2)=1;
                        mask(m-1,n-1)=1;
                    elseif W_mask(1,2)==1 & W_mask(2,1)==0 & W_mask(2,2)==1
                        input1(m-2,n-1)=double(input1(m-2,n-1))+Yshift_h(count+1,1);
                        %input1(m-1,n-2)=double(input3(m-1,n-2));
                        input1(m-1,n-1)=double(input1(m-1,n-1))+Yshift(count+1,1);
                        mask(m-2,n-1)=1;
                        mask(m-1,n-1)=1;
                    else %W_mask(1,2)==0 & W_mask(2,1)==0 & W_mask(2,2)==1
                       % input1(m-2,n-1)=double(input3(m-2,n-1));
                       % input1(m-1,n-2)=double(input3(m-1,n-2));
                        input1(m-1,n-1)=double(input1(m-1,n-1))+Yshift(count+1,1);
                        mask(m-1,n-1)=1;
                 end
         end
         count=count+1;
    end
end
output=input1;
end
                    