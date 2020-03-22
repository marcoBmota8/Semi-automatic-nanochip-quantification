# Semi-automatic-nanochip-quantification
This file is a user friendly MATLAB image analysis algortithm. 
It uses as input the bright field and the corresponding fluorescence image of an only-nanochips fluorescence/confocal microscopy Fielf of View (FOV).
It is able to automatically select the nanochips facing upwards to avoid inlclusion of saturated (titled) chips.
It only needs of user input about each FOV-case on the area range that is required to get rid of tilted chips, and it automatically substracts background contribution and averages noise, to obtain coherent results and get rid of acquisition-day conditions of the instrument . 
Then, it calculates the nanochips individual fluorescence level as well as an image average and maximum for further statistical analysis. 
The main advantage is that it it does not require the user to manually draw the ROIs on the bright field image, allowing for a fast analaysis of a plethora of nanaochips.
