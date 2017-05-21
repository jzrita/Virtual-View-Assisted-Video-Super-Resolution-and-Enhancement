%%This demo is for the paper "Virtual-View-Assisted-Video-Super-Resolution-and-Enhancement "
%
%If you have any question, please feel free to contact the author: jinzhi_126@163.com
%
%
%% Sequences Parameters
clear
clc
nFrame=50; % for large testing
QP=[22,27,32,37,42,47];
scalefactor=2;

%========================== Doorflower ==============================
width=1024;
height=768;
threshold1=15.*[5.0493    5.5807    6.5978    8.2752   11.2108   15.1624];%sqrt(mse_VH_down+mse_VL)
threshold_Y=8.*[2.5246    2.7904    3.2989    4.1376    5.6054    7.5812];
threshold2=[0.5 0.1 0.1 0.1 0.1 0.1];
fc=1399.4667;
Znear=23.1759;
Zfar = 54.0772;
tc=1.16;
warping_mode=1; %mode=1 means generate right virtual view, mode=2, means generate left virtual view

%% Variable initialization
V_interpolation_Y=cell(1,nFrame);
Vnew_Y=cell(1,nFrame);
Vnew1_Y=cell(1,nFrame);
Vnew2_Y=cell(1,nFrame);
Vnew3_Y=cell(1,nFrame);
Vnew4_Y=cell(1,nFrame);
V_virtual_Y=cell(1,nFrame);
mask_virtual=cell(length(QP),nFrame);
mask_LC=cell(length(QP),nFrame);
mask_replaced=cell(length(QP),nFrame);
U=cell(1,nFrame);
V=cell(1,nFrame);
R=cell(1,nFrame);
G=cell(1,nFrame);
B=cell(1,nFrame);
PSNR_inter=cell(1,length(QP));
PSNR_withoutY=cell(1,length(QP));
PSNR_new1=cell(1,length(QP)); %only copy the virtual pixel
PSNR_new2=cell(1,length(QP)); %also change the corner pixels
PSNR_new3=cell(1,length(QP)); %after luminance compensation
PSNR_new4=cell(1,length(QP)); %after smooth check
PSNR_new1_Y=zeros(1,nFrame);
PSNR_new2_Y=zeros(1,nFrame);
PSNR_new3_Y=zeros(1,nFrame);
PSNR_new4_Y=zeros(1,nFrame);
PSNR_new_withoutY=zeros(1,nFrame);
PSNR_inter_Y=zeros(1,nFrame);
SSIM_new1_Y=zeros(1,nFrame);
SSIM_new2_Y=zeros(1,nFrame);
SSIM_new3_Y=zeros(1,nFrame);
SSIM_new4_Y=zeros(1,nFrame);
SSIM_new_withoutY=zeros(1,nFrame);
SSIM_inter_Y=zeros(1,nFrame);
SSIM_new1=cell(1,length(QP));
SSIM_new2=cell(1,length(QP));
SSIM_new3=cell(1,length(QP));
SSIM_new4=cell(1,length(QP));
SSIM_inter=cell(1,length(QP));
SSIM_withoutY=cell(1,length(QP));
Bitrate=zeros(1,length(QP));
psnr_ende_v2=zeros(1,length(QP));
psnr_ende_v1=zeros(1,length(QP));
psnr_ende_d1=zeros(1,length(QP));
psnr_ende_v3=zeros(1,length(QP));
%%
your_LR_video_address='/../DoorFlowers_Cam08';
your_HR_video_address='/../DoorFlowers_Cam10';
your_HR_depth_video_address='/../depth_doorflowers_Cam10';
% do downsampling, endcode, decode and upsampling
for j=1:length(QP)
    [V_up_Y,V_interpolation_Y,V_interbicubic_Y, V_full_Y,Bitrate_LR(j),psnr_LR(j)] = down_encod_decod_up_new(your_LR_video_address,width, height, nFrame, scalefactor,QP(j));
    % do encoding and decoding for other three frames
    [filename1,psnr_FR(j), Bitrate_FR(j)]=encod_decod_final(your_HR_video_address, width, height, nFrame,QP(j));
    [filename2,psnr_depth(j), Bitrate_depth(j)]=encod_decod_final(your_HR_depth_video_address, width,height, nFrame, QP(j));
    % generate virtual view
    V_virtual{j}= VirtualViewgeneration(filename1,filename2,width, height, nFrame, fc, Znear, Zfar, tc, warping_mode);
    
    for i=1:nFrame
        R =V_virtual{j}{i}(:,:,1);
        G =V_virtual{j}{i}(:,:,2);
        B =V_virtual{j}{i}(:,:,3);
        [V_virtual_Y{j}{i},~,~] =rgb2yuv(R ,G ,B,'YUV420_8');
        
        % do similarity check, LC and smooth check
        [Vnew_Y{j,i},mask_virtual{j,i},mask_corner]  = similarity_check_withY_step1(V_up_Y{i},V_virtual_Y{j}{i},V_interpolation_Y{i},scalefactor,threshold1(j));
        mask_resthole_Y=Vnew_Y{j,i}~=0;
        Vnew1_Y{j,i} = double(Vnew_Y{j,i})+ double(V_interpolation_Y{i}).*(~mask_resthole_Y);
        virtual_pixels_number=sum(mask_virtual{j,i}(:));
        percentage_of_virtual_pixel_to_whole_frame(j,i)=virtual_pixels_number*100/(width*height);
        percentage_of_virtual_pixel_to_zero_positions(j,i)=virtual_pixels_number*100*2/(width*height);
        Vnew2_Y{j,i}= Vnew1_Y{j,i}.* (1- (mask_corner == 4)) + 0.5*(Vnew1_Y{j,i} + double(V_virtual_Y{j}{i} )).*(mask_corner == 4);
        [Vnew3_Y{j,i},mask_LC{j,i}]  = similarity_check_withY_step2(Vnew2_Y{j,i},V_virtual_Y{j}{i},mask_virtual{j,i},scalefactor,threshold_Y(j));
        [Vnew4_Y{j,i},mask_replaced{j,i}] = smooth_check(V_interpolation_Y{i},Vnew3_Y{j,i},scalefactor,threshold2(j));
      
        
        % calculate the PSNR
        PSNR_new1_Y(i)= PSNR(V_full_Y{i},Vnew1_Y{j,i});
        PSNR_new2_Y(i)= PSNR(V_full_Y{i},Vnew2_Y{j,i});
        PSNR_new3_Y(i)= PSNR(V_full_Y{i},Vnew3_Y{j,i});
        PSNR_new4_Y(i)= PSNR(V_full_Y{i},Vnew4_Y{j,i});
        PSNR_inter_Y(i) = PSNR(V_full_Y{i},V_interpolation_Y{i});
        PSNR_inter_Ycubic(i) = PSNR(V_full_Y{i},V_interbicubic_Y{i});
        % calculate the SSIM
        [SSIM_new1_Y(i), ~] = ssim(V_full_Y{i}, Vnew1_Y{j,i});
        [SSIM_new2_Y(i), ~] = ssim(V_full_Y{i}, Vnew2_Y{j,i});
        [SSIM_new3_Y(i), ~] = ssim(V_full_Y{i}, Vnew3_Y{j,i});
        [SSIM_new4_Y(i), ~] = ssim(V_full_Y{i}, Vnew4_Y{j,i});
        [SSIM_inter_Y(i),~] = ssim(V_full_Y{i}, V_interpolation_Y{i});
        [SSIM_inter_Ycubic(i),~] = ssim(V_full_Y{i}, V_interbicubic_Y{i});
    end
    
    PSNR_new1{j} = PSNR_new1_Y;
    PSNR_new2{j} = PSNR_new2_Y;
    PSNR_new3{j} = PSNR_new3_Y;
    PSNR_new4{j} = PSNR_new4_Y;
    PSNR_inter{j} =PSNR_inter_Y;
    PSNR_inter_cubic{j} =PSNR_inter_Ycubic;
    
    SSIM_new1{j}=SSIM_new1_Y;
    SSIM_new2{j}=SSIM_new2_Y;
    SSIM_new3{j}=SSIM_new3_Y;
    SSIM_new4{j}=SSIM_new4_Y;
    SSIM_inter{j} = SSIM_inter_Y;
    SSIM_inter_cubic{j} = SSIM_inter_Ycubic;
    
end

for i=1:length(QP)
    mean_PSNR_new4(i)=mean(PSNR_new4{i});
    mean_PSNR_new3(i)=mean(PSNR_new3{i});
    mean_PSNR_new2(i)=mean(PSNR_new2{i});
    mean_PSNR_new1(i)=mean(PSNR_new1{i});
    mean_PSNR_inter(i)=mean(PSNR_inter{i});
    mean_PSNR_cubic(i)=mean(PSNR_inter_cubic{i});
    
    mean_SSIM_inter(i)=mean(SSIM_inter{i});
    mean_SSIM_cubic(i)=mean(SSIM_inter_cubic{i});
    mean_SSIM_new4(i)=mean(SSIM_new4{i});
    mean_SSIM_new3(i)=mean(SSIM_new3{i});
    mean_SSIM_new2(i)=mean(SSIM_new2{i});
    mean_SSIM_new1(i)=mean(SSIM_new1{i});
end


