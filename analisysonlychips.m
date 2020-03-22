%Marco Barbero Mota
%MaxProj chip brightness analyzer FOR CHIPS ALONE
%CIB-CSIC Madrid 29/01/2019
%Laboratory 105 TS
%This program selects the chips when they are alone in the 
%picture by image analysis methods
%and filters them by area so that we calculate only
%the features of those plain facing upwards
clear all;
clc;
close all;
chipcont=1;
chipcont2=1;
analyzing=1;
cont=1;
cont2=1;
dataOUT(1,:)={'name','BackgroundI maximum','mean Background I','mean Background II','#chips','normalized chips total mean intensity','normalized chips total maximum intensity','normalized maximum mean intensity among all chips','normalized mean maximum intensity among all chips'};
chipdataOUT(1,:)={'photo name','normalized total intensity','normalized maximum intensity','normalized average intensity'};
while analyzing==1
    error2=1;
    values=[];
    valuesOUT=[];
    name = input('What image to analyze(file name without the extension): ','s');
    fprintf('\n');
    extension=input('What image extension/format is it? (example:.tif,.jpeg,...): ','s');
    fprintf('\n');
    namecomp= strcat(name,extension);
    image = imread(namecomp);
    nombre=strcat(name,'-','campoclaro',extension);
    campoclaro= imread(nombre);
    figure(2)
    imshow(campoclaro);
    title('campo claro');
    disp('Check the information of the image: ');
    fprintf('\n');
    whos image
    fprintf('\n');
    fprintf('\n');
    image255=image(:,:,1);
    
    %Here obtain the mask of the chips
    %Thus,the backround too
    
    BW = edge(campoclaro);
    se1 = strel('disk',1);
    se2 = strel('octagon',3);
    closed = imclose(BW,se2);
    opened = imopen(closed,se1);
    closedII=opened;
    for f = 1:3
       closedII= imclose(closedII,se2);
    end;
    final = imclose(closedII,se1);
    final = imfill(final,'holes');
    labelmatrix = bwlabel(final);
    s  = regionprops(final, 'centroid', 'area');
          centroids = cat(1, s.Centroid);
          areas= cat(1,s.Area);
          campoclaromodified=insertText(campoclaro,centroids,areas,'FontSize',15);
%QUEDA Hacer el filtro por area Y CAMBIAR LAS VBARIASBLE SPARA QUITYAR
%ERRORES
    figure(1)
    histogram(areas,'BinWidth',10);
    figure(2)
    imshowpair(campoclaromodified,final,'montage'); 
    title('Check areas');
    figure(3)
    imshowpair(final,campoclaro);
    title('Check algortihms work');
    upperlimit=input('Insert upper area limit: ');
    lowerlimit=input('Insert lower area limit: '); 
    for o = 1:length(areas)
        if (areas(o)>upperlimit) | (areas(o)<lowerlimit)
            final(labelmatrix==o)=0;
    end;
    end;
    figure(4)
    imshowpair(final,campoclaro);
    invertfinal=~final;
    background=image(:,:,1);
    background(~invertfinal)=0;
    figure(5)
    imshowpair(image255,background,'montage');
    title('original vs just background selected');
    %first backround correction
    [row,col,b] = find(background);
    meanBACKGROUND=mean2(b);
    backgroundcorrect=meanBACKGROUND*ones(length(image(:,:,1)));
    imageminusbackgroundI=imsubtract(image(:,:,1),uint8(backgroundcorrect));
    %Second backround correction("cell");
    backgroundII=imageminusbackgroundI;
    background(~invertfinal)=0;
    [row,col,d] = find(backgroundII);
    meanBACKGROUNDII=mean2(d);
    backgroundcorrectII=meanBACKGROUNDII*ones(length(image(:,:,1)));
    imageminusbackgroundII=imsubtract(imageminusbackgroundI,uint8(backgroundcorrectII));
    normalized =  imageminusbackgroundII;
    valuesOUT(1)=max(max(background));%VALOR MAXIMO DEL BACKGROUND INICIAL
    valuesOUT(2)=mean(mean(background));%VALOR medio DEL BACKGROUND INICIAL
    valuesOUT(3)=mean(mean(backgroundII));%VALOR medio DEL BACKGROUND II
    maxnorm = valuesOUT(1)* ones(length(imageminusbackgroundI));
    averagenorm = valuesOUT(3) * ones(length(imageminusbackgroundI));
    imnorm{1} = imsubtract(imageminusbackgroundI,uint8(maxnorm));
    imnorm{2} = normalized;
    figure(6)
    subplot(1,3,1);
    imshow(image);
    title('Original');
    subplot(1,3,2);
    imshow(imnorm{1});
    title('Maximum correction');
    subplot(1,3,3);
    imshow(imnorm{2});
    title('Average correction');
    figure(7)
    imshow(imnorm{1});
    title('Maximum correction');
    figure (8)
    imshow(imnorm{2});
    title('Average correction');
    %Save the images obtained
    name1 =strcat(name,' maximum correction.jpeg');
    name2 =strcat(name,' average correction.jpeg');
    imwrite(imnorm{1},name1);
    imwrite(imnorm{2},name2);
    answer = input('Do you want to use the average or maximum correction?(max or average): ','s');
    error = 1;
    close all;
    while error == 1
        if strcmp(answer,'max')==1
            k=1;
            error = 0;
        elseif  strcmp(answer,'average')==1
            k=2;
            error = 0;
        else
            disp('Incorrect answer try again');
            answer = input('Do you want to use the average or maximum correction?(max or average): ','s');
            error = 1;
        end;
    end; 
    chipsOUT=[];   
    labelmatrixII = bwlabel(final);
    numbchipsused=max(max((labelmatrixII)));
    for z = 1:(numbchipsused)
        chip = [];
        v = [0];
        chipmask=zeros(length(normalized));
        chipmask(labelmatrixII==z)=1;
        notchiplocation=~chipmask;
        chipvalues = normalized; 
        chipvalues(notchiplocation)=0;
        [row1,col1,v] = find(chipvalues);
        if (round(mean2(v))>2) & (round(mean2(v)<180))% anteriormente se ha visto quw ningunm chip tiene menos de 18 pero si el fondo
           %esto permitye hacer un rango de area mas grande y aun asi
           %quitar la gran mayoria de onjetos de fondo con area en el rango
           %que se cuelan
            chipcont2=chipcont2+1;
            chipdataOUT(chipcont2,1)={name};
            chipdataOUT(chipcont2,2)={sum(sum(v))};
            chipdataOUT(chipcont2,4)={round(mean(mean(v)))};
            chipdataOUT(chipcont2,3)={round(max(max(v)))};
        end;
    end;
        %Total mean intensity NORMALIZED
        imagemeanmaxOUT = round(mean2(cell2mat(chipdataOUT(2:chipcont2,3))));
        %Total max intensity NORMALIZED
        imagemaxmeanOUT = round(max(max(cell2mat(chipdataOUT(2:chipcont2,4)))));
        %Maximum mean chip intensity in one image NORMALIZED
        chisptotalmaxOUT = round(max(max(cell2mat(chipdataOUT(2:chipcont2,3)))));
        %Mean of the maximum chip intensities in one image NORMALIZED
        chipstotalmeanOUT = round(mean2(cell2mat(chipdataOUT(2:chipcont2,4))));
        %collect the data inside the vector
        valuesOUT(4)=chipcont2;
        valuesOUT(5)=chipstotalmeanOUT;
        valuesOUT(6)=chisptotalmaxOUT;
        valuesOUT(7)=imagemaxmeanOUT;
        valuesOUT(8)=imagemeanmaxOUT;
        %keep the values from today'analysis in a matrix where the rows are each image
        %and columns are the different values obtained
        %The first row are the names of those values
        cont2=cont2+1;
        dataOUT(cont2,1)={name};
        for b = 2:(length(valuesOUT)+1)
            dataOUT(cont2,b)={round(valuesOUT(b-1))};
        end;
    clc;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    while error2==1
        anotherone = input('Do you want to analyse another image (yes or no): ','s');
        if strcmp(anotherone,'yes')==0 && strcmp(anotherone,'no')==0
            error2=1;
        elseif strcmp(anotherone,'yes')==1
            analyzing =1;
            error2 =0;
        elseif strcmp(anotherone,'no')==1
            analyzing = 0;
            error2 =0;
        end;
    end;
end;
disp('Obtain data from the variables data, dataOUT, chipdataOUT, chipdata and cellsdata at the workspace');
    
    
    
    
    