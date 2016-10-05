
%Input data folder and runs on all .off files in folder


currentFolder = pwd;

folder_dep=[currentFolder,'\Dependencies\'];
addpath(genpath(folder_dep))

folder_data=[currentFolder,'\Data\'];
Files_model=dir(fullfile(folder_data)) ;
Files_model=Files_model(3:end);


% Parameters
connected=1;
sizen=100;
perturb=0;
maxvn=5000;
hier=0;
n=100;
pl_gim=1;


% Loop over all files
for ii=1:length(Files_model)
    
    %Read files
    filename=[folder_data,Files_model(ii).name,'/model.obj'];
    [V,F] = readOBJ(filename);
    trimesh(F,V(:,1),V(:,2),V(:,3));
    
    V=V(:,[1,3,2]);  %change coordinate axis
    axis equal
    
    object_name_check=[filename(1:end-4),'_gim.mat'];
    
    if ~(exist(object_name_check,'file')==2)
        
        % Function to make mesh accurate and genus zero
        [k_final,Points,facen,vertn,vert_idx,genus,k_org,change_gen]=voxelelize_genus(V,F,sizen,connected,perturb);
        
        % Spherical parametrization 
        if size(vertn,2)>0
            sph_verts=DeepLearning_param(vertn,facen,maxvn,hier,n);
        else
            sph_verts=[];
        end
        
        %saving
        object_name=[filename(1:end-4),'_gim'];
        Isave_top(object_name,k_final,sph_verts,vertn,facen,genus,k_org,vert_idx,change_gen,Points);
        
        
        % This is demo for plotting function 
        if size(vertn,2)>0
            trimesh(facen,vertn(:,1),vertn(:,2),vertn(:,3));
            hold on
            scatter3(vertn(~vert_idx,1),vertn(~vert_idx,2),vertn(~vert_idx,3),'r','filled');
            hold off
            axis equal;
            im = getframe(gcf);
            im = imresize(im.cdata, [480 640]);
            image_name=[filename(1:end-4),'_sph_com.jpg'];
            imwrite(im,image_name,'jpg');
            if pl_gim
                
                %Performs spherical parametrization to geometry image
                gim = perform_sgim_sampling(vertn', sph_verts', facen', sizen);
                C = ones(size(gim(:,:,1)))*0.8;
                surf(gim(:,:,1), gim(:,:,2), gim(:,:,3), C );
                shading interp;
                lighting phong;
                camlight local;
                camlight infinit;
                material dull;
                material shiny;
                camproj('perspective');
                axis square;
                axis off;
                cameramenu;
                view(-170, 55);
                axis tight;
                axis equal;
                F = getframe;
                [X,~] = frame2im(F);
                img = imresize(X, [480 640]);
                image_name=[filename(1:end-4),'_gim.jpg'];
                imwrite(img,image_name,'jpg');
            end
            
        end
    end
    
    
    
end
