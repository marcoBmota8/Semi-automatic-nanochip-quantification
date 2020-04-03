%Marco Barbero Mota
%MaxProj chip brightness analyzer
%CIB-CSIC Madrid 29/01/2019
%Laboratory 105 TS
%This program allows you to select a ROI from the opened image
%This ROI should be a cell without a chip inside
%It measures the maximum and average intensity
%then substracts it from the whole original image and measures the average
%and maximum intensities of the modified image at other ROIs of interest
%that now are the chips.
%In this way we are able to obtain the brightness of the chips no matter
%what settings the images were taken with (normalized).
clear all;
clc;
close all;

chipcont=1;
chipcont2=1;
analyzing=1;
cont=1;
cont2=1;

data(1,:)={'name','no background maximum intensity from the cells','no background average intensity from the cells','#cells','#chips','normalized chips total mean intensity','normalized chips total maximum intensity','normalized maximum mean intensity among all chips','normalized mean maximum intensity among all chips'};
dataOUT(1,:)={'name','no background maximum intensity from the cells','no background average intensity from the cells','#cells','#chips','normalized chips total mean intensity','normalized chips total maximum intensity','normalized maximum mean intensity among all chips','normalized mean maximum intensity among all chips'};
cellsdata(1,:)={'name','maximum Difference cells ','average Difference cells'};
chipdata(1,:)={'photo name','normalized total intensity','normalized maximum intensity','normalized average intensity','normalized maximum cell internalized','normalized average cell internalized','normalized cell sum','normalization method used'};
chipdataOUT(1,:)={'photo name','normalized total intensity','normalized maximum intensity','normalized average intensity','normalization method used'};
%Here we correct the image by means of the average value or maximum value
%of the cells we select, as well as we first obtain a main value of the
%background. On the whole, it does two thresholdings to normalize each image
%to its corresponding acquisition parameters, and so we are able to compare

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
    
    figure(1)
    imshow(campoclaro);
    title('campo claro');
    
    disp('Check the information of the image: ');
    fprintf('\n');
    whos image
    fprintf('\n');
    
    %First the fluorescence image is cleared with morphological methods to
    %smooth the limits between objects and background
    %Otsu's method to find out which pixels are background: APPLICATION OF "BACKROUND" THRESHOLD:
    %Not exactly background but this
    %is a ast manner to classify pixels that are low intensity(mostly
    %background) from the ones with a high signal
    
    image255=image(:,:,1);
    se=strel('disk',2);
    for t=1:3
    closed=imclose(image255,se);
    end;
    closed=medfilt2(closed,[2,2]);
    thres=graythresh(closed);
    BW=imbinarize(closed,thres);
    
    figure(2)
    imshowpair(BW,image255,'montage');
    title('median filter closed otsu vs original');
    
    figure(3)
    imshowpair(BW,closed,'montage');
    title('median filter closed otsu vs median filter(12*12)+closing');
    
    invertfinal=~BW;
    background=image(:,:,1);
    background(~invertfinal)=0;
    
    figure(4)
    imshowpair(campoclaro,background,'montage')
    title('campoclaro vs background selected');
    
    figure(5)
    imshowpair(image255,background,'montage');
    title('original fluorescence vs just background selected');
    
    meanBACKGROUND=mean2(background(invertfinal));  
    backgroundcorrect=meanBACKGROUND*ones(length(image(:,:,1)));
    imageminusbackground=imsubtract(image(:,:,1),uint8(backgroundcorrect));
    
    figure(6)
    subplot(1,2,1)
    imshow(image);
    title('Original');
    subplot(1,2,2)
    imshow(imageminusbackground);
    title('Original minus background mean');
    
    disp('Now select cells that are attached to the floor and have no chip inside at campo claro image');
    fprintf('\n');
    numbcells= input('How many cells you desire to segment to normalize the chip analysis?: ');
    fprintf('\n');
    disp('When finished with each ROI righ click on it and select create mask ');
    fprintf('\n');
    disp('you have to do this each time separately for each ROI');
    
    maxvalue=[];
    averagevalue=[];
    close all;
    
    for j = 1:numbcells
        Cell=[];
        Roi=[];
        Roi=roipoly(campoclaro);
        Cell=imageminusbackground;
        maxvalue(j)= max(max(Cell(Roi)));
        averagevalue(j)= mean2(Cell(Roi));
    end;
    
    close;
    
    MAXVALUE = round(max(maxvalue));
    AVERAGEVALUE = round(mean(averagevalue));
    
    values(1)=MAXVALUE;
    values(2)=AVERAGEVALUE;
    values(3)=numbcells;
    
    valuesOUT(1)=MAXVALUE;
    valuesOUT(2)=AVERAGEVALUE;
    valuesOUT(3)=numbcells;
    
    maxnorm = MAXVALUE * ones(length(imageminusbackground));
    averagenorm = AVERAGEVALUE * ones(length(imageminusbackground));
    imnorm{1} = imsubtract(imageminusbackground,uint8(maxnorm));
    imnorm{2} = imsubtract(imageminusbackground,uint8(averagenorm));
    
    figure(7)
    subplot(1,3,1);
    imshow(image);
    title('Original');
    subplot(1,3,2);
    imshow(imnorm{1});
    title('Maximum correction');
    subplot(1,3,3);
    imshow(imnorm{2});
    title('Average correction');
    
    figure(8)
    imshow(imnorm{1});
    title('Maximum correction');
    
    figure (9)
    imshow(imnorm{2});
    title('Average correction');
    
   
    name1 =strcat(name,' maximum correction.jpeg');
    name2 =strcat(name,' average correction.jpeg');
    imwrite(imnorm{1},name1);
    imwrite(imnorm{2},name2);
    
    %Here after treating the images we analyze the chips intensity
    %Using the method of our choice
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
    
    figure (10)
    imshow(campoclaro);
    title('Campo claro image to check the number of chips IN and OUT');
    
    numbchips= input('How many INTERNALLIZED chips you desire to analyze(They must be horizontal and with the plain face upwards?: ');
    fprintf('\n');
    
    numbout= input('How many OUTSIDE chips you desire to analyze(They must be horizontal and with the plain face upwards?: ');
    fprintf('\n');
    
    close all;
    
    chipsinfo=[];
    chipsinfoOUT=[];
    if (numbchips==0) && (numbout==0)
        continue
    end;
    
    if  (numbchips>0)
        disp('Now select first each Internalized chip and then the contour of the cell it is in');
        disp('When finished with each chip and cell righ click on it and select create mask ');
        fprintf('\n');
        disp('you have to do this each time separately for each chip and cell');
        close all;
        clc;
   %%%%%%%%%%%%     
        for l = 1:numbchips
            chipsanalyzed=[];
            ROI=[];
            ROIcells=[];
            cellsint=[];
            
            disp('Select the chip');
            ROI=roipoly(campoclaro);
            chipsanalyzed=imnorm{k};
            clc;
            
            disp('CAREFUL!!!');
            disp('Select the corresponding cell GETTING THE CHIP inside the ROI BUT NTO GETTING OTHER CHIPS INSIDE THE ROI');
            
            ROIcells=roipoly(campoclaro);
            cellsintDIF=imnorm{k};
            cellsint=logical(imsubtract(ROIcells,ROI));
            
            chipcont=chipcont+1;
            
            chipdata(chipcont,1)={name};
            chipdata(chipcont,2)={sum(sum(chipsanalyzed(ROI)))};
            chipsinfo(l,1)=round(mean2(chipsanalyzed(ROI)));
            chipdata(chipcont,4)={chipsinfo(l,1)};
            chipsinfo(l,2)=round(max(max(chipsanalyzed(ROI))));
            chipdata(chipcont,3)={chipsinfo(l,2)};
            chipsinfo(l,3)=round(max(max(cellsintDIF(cellsint))));
            chipdata(chipcont,5)={chipsinfo(l,3)};
            chipsinfo(l,4)=round(mean2(cellsintDIF(cellsint)));
            chipdata(chipcont,6)={chipsinfo(l,4)};
            chipsinfo(l,5)=round((sum(sum(cellsintDIF(cellsint)))));
            chipdata(chipcont,7)={chipsinfo(l,5)};
            %Type of method used
            chipdata(chipcont,8)={answer};
        end;
    end;
    
    close all;
    clc;
    
    if numbout>0
        disp('Now select each OUTSIDE chip ');
        disp('When finished with each OUTSIDE chip righ click on it and select create mask ');
        fprintf('\n');
        disp('you have to do this each time separately for each chip');
        fprintf('\n');
        close all;
        
        for z = 1:numbout
            ROI2 = [];
            chipsOUT=[];
            
            ROI2=roipoly(campoclaro);
            chipcont2=chipcont2+1;
            
            chipdataOUT(chipcont2,1)={name};
            chipdataOUT(chipcont2,2)={sum(sum(imageminusbackground(ROI2)))};
            chipsinfoOUT(z,1)=round(mean2(imageminusbackground(ROI2)));
            chipdataOUT(chipcont2,4)={chipsinfoOUT(z,1)};
            %maximum intensity NORMALIZED(AFTER BACKGROUND FILTER ONLY!!!!)
            chipsinfoOUT(z,2)=max(max(imageminusbackground(ROI2)));
            chipdataOUT(chipcont2,3)={chipsinfoOUT(z,2)};
            %Type of method used
            chipdataOUT(chipcont2,5)={answer};
        end;
    end;
    close all;
    if (numbchips>0)
        chipstotalmean = round(mean2(chipsinfo(:,1)));
        cellsintDIFmean=round(mean2(chipsinfo(:,4)));
        chisptotalmax = max(chipsinfo(:,2));
        cellsintDIFmax=max(chipsinfo(:,3));
        imagemaxmean=max(chipsinfo(:,1));
        imagemeanmax=round(mean(chipsinfo(:,2)));
        values(4)=numbchips;
        values(5)=round(chipstotalmean);
        values(6)=round(chisptotalmax);
        values(7)=round(imagemaxmean);
        values(8)=round(imagemeanmax);
        cont=cont+1;
        data(cont,1)={name};
        cellsdata(cont,1)={name};
        for a = 2:(length(values)+1)
            data(cont,a)={values(a-1)};
        end;
        cellsdata(cont,2)={cellsintDIFmax};
        cellsdata(cont,3)={cellsintDIFmean};
    end;
    if (numbout>0)
        %Total mean intensity NORMALIZED
        chipstotalmeanOUT = round(mean2(chipsinfoOUT(:,1)));
        %Total max intensity NORMALIZED
        chisptotalmaxOUT = max(chipsinfoOUT(:,2));
        %Maximum mean chip intensity in one image NORMALIZED
        imagemaxmeanOUT=max(chipsinfoOUT(:,1));
        %Mean of the maximum chip intensities in one image NORMALIZED
        imagemeanmaxOUT=round(mean2(chipsinfoOUT(:,2)));
        %collect the data inside the vector
        valuesOUT(4)=numbout;
        valuesOUT(5)=round(chipstotalmeanOUT);
        valuesOUT(6)=round(chisptotalmaxOUT);
        valuesOUT(7)=round(imagemaxmeanOUT);
        valuesOUT(8)=round(imagemeanmaxOUT);
        %keep the values from today'analysis in a matrix where the rows are each image
        %and columns are the different values obtained
        %The first row are the names of those values.
        cont2=cont2+1;
        dataOUT(cont2,1)={name};
        for b = 2:(length(valuesOUT)+1)
            dataOUT(cont2,b)={valuesOUT(b-1)};
        end;
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


    
    
    
    
    
  
