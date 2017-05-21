%%This code is used for doing encode and decode
%2012 12 10
function [V_up_Y,V_dende_Y, Y,Bitrate,psnr_ende] = down_encod_decod_up_new(filename,width, height, nFrame,factor,QP_num)
% filename - YUV sequence file
% nFrame - number of frames to read
%factor- the down/up sampling factor
%method-'lanczos3' or 'bilinear' or 'bicubic', 'simple'
%simple- even rows and cols are discarded way of downsampling, 4x4 => 2x2
%QP_num- the quantization step

%for example1  [test, test_psnr] = down_encod_decod_up('Vr.yuv',1024, 768, 2, 2, 'lanczos3',22)
%filename='Vr.yuv'; width=1024;  height=768; nFrame=2; factor=2; method='lanczos3';QP_num=22;
%for example2  [test, test_psnr] = down_encod_decod_up('Vr.yuv',1024, 768, 2,'simple', 2,22)
% filename='Vr.yuv'; width=1024;  height=768; nFrame=2; factor=2;QP_num=22;

if (nargin < 5)
    factor=2;
end;
if (nargin < 6)
    QP_num = 22;
end;

[Y,U,V]=yuv_import(filename,[width height],nFrame);
V_d_Y=cell(1,nFrame);
V_d_U=cell(1,nFrame);
V_d_V=cell(1,nFrame);
for i=1:nFrame
    %% Downsampling with M
    V_d_Y{i} = Y{i}(1:factor:height, 1:factor:width);       %V_d is the dowmsampled but not encoded and decoded version of V_full_Y
    V_d_U{i} = imresize(U{i},0.5,'lanczos3');
    V_d_V{i} = imresize(V{i},0.5,'lanczos3');
    [height1,width1]=size(V_d_Y{1});
end
delete('V_d2.yuv');
outfilename= ['V_d',num2str(factor),'.yuv'];
yuv_export(V_d_Y,V_d_U,V_d_V,outfilename,nFrame);

%% encoding and decoding
Squ =  ['V_d',num2str(factor)];
width_tem= num2str(width1);
height_tem = num2str(height1);
QP = num2str(QP_num);
nFrame_str = num2str(nFrame);

[s1,result1]=dos(['lencod.exe -p InputFile=',Squ,'.yuv -p OutputFile=',Squ,'_',QP,'.264 -p FramesToBeEncoded=',nFrame_str,' -p SourceWidth=',width_tem,' -p SourceHeight =',height_tem,'  -p OutputWidth=',width_tem,' -p OutputHeight =',height_tem,' -p QPISlice=',QP,' -p QPPSlice=',QP,],'-echo');
Bitrate = str2double(result1(1,regexp(result1,'Bit rate')+36:regexp(result1,'Bit rate')+43));
[s2,result2]=dos(['ldecod.exe -i ',Squ,'_',QP,'.264 -o ',Squ,'_',QP,'.yuv -r ',Squ,'.yuv'],'-echo');
psnr_ende=str2double(result2(1,regexp(result2,'SNR Y')+22:regexp(result2,'SNR Y')+27));
%% interpolation
V_up_Y=cell(1,nFrame);
V_up_U=cell(1,nFrame);
V_up_V=cell(1,nFrame);

framename=[Squ,'_',QP,'.yuv'];
[V_dende_Y,V_dende_U,V_dende_V]=yuv_import(framename,[width1 height1],nFrame);
for i=1:nFrame
    %V_d1 is the dowmsampled, encoded and decoded version of V_full_Y
    V_up_Y{i}(:,:,1) = (upsample((upsample(V_dende_Y{i},factor))',factor))' ;
    V_up_U{i} = imresize(V_dende_U{i},2,'lanczos3');
    V_up_V{i} = imresize(V_dende_V{i},2,'lanczos3');
end
end

