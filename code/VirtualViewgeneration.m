function virtual_view = VirtualViewgeneration(V1,D1,width, height,nFrame, focal,MinZ,MaxZ,tc,mode)
%
%V1- the input texture view
%D1-the input depth map
%mode =1 the input view will be treated as left view and generate right view
%mode =2 the input view will be treated as right view and generate left view
%
% For example
% testVirtualview= VirtualViewgeneration('Vl.yuv','Dl.yuv',1024,768,2,1399.4667,23.1759,54.0772,1.16,1)
%  MinZ = 23.1759; MaxZ = 54.0772;  focal = 1399.4667;  tc= 1.16;mode=1;




for i=1:nFrame
     [Yv,Uv,Vv]=yuv_import(V1,[width height],nFrame);
     [Yd,Ud,Vd]=yuv_import(D1,[width height],nFrame);
    if mode==1 %generate right view
        Vl_f{i}=yuv2rgb(Yv{i},Uv{i},Vv{i});
        Dl{i}=yuv2rgb(Yd{i},Ud{i},Vd{i});
        Dl_gray{i}  = rgb2gray(Dl{i});
        Dl_gray{i} = double(Dl_gray{i});
        
        % calculate depth value
        Dl_depth{i} = 1.0 ./((Dl_gray{i} ./ 255.0).*(1.0/MinZ - 1.0/MaxZ)+1.0/MaxZ);
        Dl_disp{i} = (focal * tc) ./ Dl_depth{i};
        %Zc=(MinZ+MaxZ)/2;
        % Dl_disp{i} = (focal.* tc) ./ (2 * Dl_depth{i}) - (focal .* tc) / (2 * Zc);
        % Generation of virtual view
        Vvirtual_r= cell(1,nFrame);
        Dvirtual_r= cell(1,nFrame);
        Vvirtual_r{i}= zeros(height,width,3);
        Dvirtual_r{i}= zeros(height,width,3);
        for k=1:height
            for j=1:width
                %for the right view,Vvirtual_r
                if(j-round(Dl_disp{i}(k,j))>=1 && j-round(Dl_disp{i}(k,j))<=width)
                    Vvirtual_r{i}(k, j - round(Dl_disp{i}(k,j)),:) = Vl_f{i}(k,j,:);
                    Dvirtual_r{i}(k, j - round(Dl_disp{i}(k,j))) = Dl_depth{i}(k,j);
                end
            end
        end
        virtual_view{i}=double(Vvirtual_r{i});
    elseif mode==2
        Vr_f{i}=yuv2rgb(Yv{i},Uv{i},Vv{i});
        Dr{i}=yuv2rgb(Yd{i},Ud{i},Vd{i});
        Dr_gray{i}  = rgb2gray(Dr{i});
        Dr_gray{i} = double(Dr_gray{i});
        
        % calculate depth value
        Dr_depth{i} = 1.0 ./((Dr_gray{i} ./ 255.0)*(1.0/MinZ - 1.0/MaxZ)+1.0/MaxZ);
        Dr_disp{i} = (focal * tc) ./ Dr_depth{i};
        % Generation of virtual view
        Vvirtual_l= cell(1,nFrame);
        Dvirtual_l= cell(1,nFrame);
        Vvirtual_l{i}= zeros(height,width,3);
        Dvirtual_l{i}= zeros(height,width,3);
        for k=1:height
            for j=1:width
                % for the left view Vvirtual_l
                xt=width-j+1;
                if(xt+round(Dr_disp{i}(k,xt))>=1 && xt+round(Dr_disp{i}(k,xt))<=width)
                    Vvirtual_l{i}(k, xt + round(Dr_disp{i}(k,xt)),:) = Vr_f{i}(k,xt,:);
                    Dvirtual_l{i}(k, xt + round(Dr_disp{i}(k,xt))) = Dr_depth{i}(k,xt);
                end
            end
        end
         virtual_view{i}=double(Vvirtual_l{i});
    end
end
end








