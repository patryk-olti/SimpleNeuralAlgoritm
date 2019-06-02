clear all;
close all;
clc;

for k = 1 : 20

    wzorzec = imread('temp2.jpg');
    kanwa_wzorzec = imread('temp3.jpg');



    for j = 1 : 65
       for i = 1 : 60

           if( double(wzorzec(j,i)) > 220 )

                if( double(kanwa_wzorzec(j,i)) > 200)
                   wzorzec(j,i) = ( wzorzec(j,i) * kanwa_wzorzec(j,i) / 255); 
                end
           end

           if( double(wzorzec(j,i)) < 50 )
              wzorzec(j,i) = 0; 
           end
       end
    end

    figure(9);
    imshow(wzorzec);

    imwrite(wzorzec, 'temp2.jpg');
    
end
