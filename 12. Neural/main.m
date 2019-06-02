clear all;
close all;
clc;

high = 50;                     % jaka wysokosc obrazow testowych ustawiamy
width = 50;                    % jaka szerokosc obrazow testowych ustawiamy
ile_testowych_obrazow = 27;    % ilosc elementow w folderze z obrazami do nauki

neural_1 = 35;                 % wartosc roznicy gradientow - ustawiamy sami <- dokladnosc detekcji krawedzi dla proby - parm.1 (5 - 55)
neural_2 = 1/150;               % wartosc detekcji wzorca - parm.2 (1/255 - 1/20) 
neural_3 = 40;                 % parametr okreslajacy jak dokladnie ma szukac krawedzie w obrazie badanym - parm.3 (10 - 50)
filtracja = true;               % parametr okreslajacy czy chcemy filtrowac wzorzec
neural_4_1 = 50;                % parametr okreslajacy filtracje wzorca od gory - parm.4.1 (150 - 220)
neural_4_2 = 50;               % parametr okreslajacy filtracje wzorca od dolu - parm.4.2   (50 - 150)
neural_5 = 250;                 % parametr okreslajacy roznice miedzy obrazem badanym a wzorcem - parm.5 ( 5 - 40 ) 

neural_6 = 50;                  % parametr szukaj?cy optymalnego rozmiaru wzorca - parm.6 ( 5 - 40 ) 
step_neural_6 = 5;              % skok szukania optymalnego rozmiaru szer
neural_7 = 50;
step_neural_7 = 5;              % wysokosc

neural_8 = 50;                  % parametr okreslajacy dokladnosc szukania - im wieksza tym mniej dokladne szukanie i wiecej wynikow

neural_10 = 0.3;

minHigh = 40;
minWidth = 40;

[Img_badany,map] = imread('image005.jpg');    % wczytywanie obrazu do detekcji obiektu

%wgrywanie obrazow do matlaba ------- 1
for i= 1 : ile_testowych_obrazow
    if(i<10)
    	c{i}=imread(sprintf('baza/00%d.jpg',i));
    else
        c{i}=imread(sprintf('baza/0%d.jpg',i));        
    end   
end

% glowna petla UCZENIA ------------- 2
for k = 1 : ile_testowych_obrazow

    J_krawedzie = zeros(high,width);    % macierz wynikowa detekcji krawedzi

    I = c{k};                          % wybor aktualnego obrazu do obrobki
    I = imresize(I,[high width]);
    I = rgb2gray(I);

    template_value = 0;                 % zmienna pomocnicza

    % wykrywanie krawedzi <- dla proby 
    for j = 1 : (high-1)
        for i = 1 : (width-1)
            template_value = ( I(j,i) - I(j+1,i+1) ) + ( I(j,i+1) - I(j+1, i) );
            template_value = abs(template_value);
    
            if( template_value > neural_1 )
                J_krawedzie(j,i) = 255;
            else
                J_krawedzie(j,i) = 0;
            end
        end
    end

%----------------------------------------------------------------------------------------------------------
figure(1);
subplot(5,6,k);
imshow(J_krawedzie);

% zapisywanie obrazow do folderu
if (k < 10)
    imwrite(J_krawedzie, sprintf('krawedzie/00%d.jpg',k));
else
    imwrite(J_krawedzie, sprintf('krawedzie/0%d.jpg',k));
end

end 
%---------------------------------------------------------
%szukanie wzorca ----------- 3
wzorzec = zeros(high,width);    % macierz wzorca butelki

%wczytywanie obrazow
for i= 1 : ile_testowych_obrazow
    if(i<10)
    	c{i}=imread(sprintf('krawedzie/00%d.jpg',i));
    else
        c{i}=imread(sprintf('krawedzie/0%d.jpg',i));        
    end   
end

for z = 1 : ile_testowych_obrazow
    I1 = c{z};   
    for x = 1 : ile_testowych_obrazow    
        tozsamosc = 0;
        proba = 0;
        I2 = c{x};
        
        if(x ~= z)
            % czesc sprawdzania tozsamosci i ustalanie wzorca ----- 3.1.
            for j = 2 : (high-1)
                for i = 2 : (width-1)
                    if( I1(j,i) == 255 )    %jezeli jest krawedz to szukaj piksela w tozsamym obrazie
                        proba = proba + 1;
                        if( I2(j-1,i-1) == 255 || I2(j,i-1) == 255 || I2(j+1,i-1) == 255 || I2(j,i-1) == 255 || I2(j,i) == 255 || I2(j,i+1) == 255 || I2(j+1,i-1) == 255 ||I2(j+1,i) == 255 ||I2(j+1,i+1) == 255)
                            tozsamosc = tozsamosc + 1;
                            wzorzec(j,i) = wzorzec(j,i) + neural_2;
                        end            
                    end
                end
            end
%             proba
%             tozsamosc
        end
    end
end

%--------------------------------------------------------------------------------------------------------------
figure(2);
imshow(wzorzec);
title('Uzyskany idealny wzorzec');

dopasowanie_text = ['Uzyskano wzorzec z probki badanej.'];
disp(dopasowanie_text);

%zapis wzorca
imwrite(wzorzec, 'wzorzec.jpg');

%-----------------------------------------
%dzia?anie sieci - wczytywanie danych --------- 4
wzorzec = imread('wzorzec.jpg');

Img_badany_kolor = [Img_badany,map];
[high_badany, width_badany, lol] = size(Img_badany);
Img_badany = rgb2gray(Img_badany);

I = Img_badany;
% I = imgaussfilt(I,neural_10);

% figure(3);
% imshow(J_krawedzie);
% title('Obraz badany w krawedziach');


najlepsze_dopasowanie = 0;  % najlepsze dopasowanie rozmiaru do detekcji
najlepsze_high = 0;
najlepsze_width = 0;
wzorzec_temp = wzorzec;
tozsamosc = 0;
tozsamosc_max = 0;
x1 = 0;
y1 = 0;

time1 = 0;
time2 = 0;

high = minHigh;                 % ustal. min wzorca
width = minWidth;               % ustal. min wzorca

        J_krawedzie = zeros(high_badany,width_badany);
        % parametr okreslajacy jak dokladnie ma szukac krawedzie w obrazie badanym - parm.3

        % obraz wejsciowy na krawedzie
        for j = 1 : (high_badany - 1)
           for i = 1 : (width_badany - 1)

                template_value = ( I(j,i) - I(j+1,i+1) ) + ( I(j,i+1) - I(j+1, i) );
                template_value = abs(template_value);

                if( template_value > neural_3 )
                    J_krawedzie(j,i) = 255;
                else
                    J_krawedzie(j,i) = 0;
                end

           end
        end
J_krawedzie = imgaussfilt(J_krawedzie,neural_10);
        
figure(5);
imshow(J_krawedzie);
title('Obszar znalezienia obiektu');

dopasowanie_text = ['Trwa poszukiwanie wzorcow na obrazie.'];
disp(dopasowanie_text);

for Parm_7 = 1 : step_neural_7 : neural_7   % wysokosc
    
    time2 = time2 + 1;
    
    for Parm_6 = 1 : step_neural_6 : neural_6   % szerokosc

        time1 = time1 + 1;
        
        high = minHigh + Parm_7 - 1;                       % skalowanie wzorca
        width = minWidth + Parm_6 - 1;                    % skalowanie wzorca   
        wzorzec = wzorzec_temp;
        wzorzec = imresize(wzorzec,[high width]);

        %filtracja wzorca ------- 5
        if ( filtracja == true )   
            % parametr okreslajacy filtracje wzorca <100;220> - parm.4
            for y = 1 : high
                for x = 1 : width
                    if(wzorzec(y,x) > neural_4_1 )
                        wzorzec(y,x) = wzorzec(y,x);
                    end

                    if(wzorzec(y,x) < neural_4_2) 
                        wzorzec(y,x) = 0;
                    end
                end
            end
            
        % figure(4);
        % imshow(wzorzec);
        % title('Wzorzec po filtracji');
                wzorzec = imgaussfilt(wzorzec, neural_10);
        end

        %--------------------------------------------------------------------------------
        % szukanie obrazu ------- 6
        % parametr okreslajacy roznice miedzy obrazem badanym a wzorcem - parm.5

        % Convert double to uint8
        imwrite(J_krawedzie, 'temp.jpg');
        J_krawedzie = imread('temp.jpg');

        tozsamosc_wzorca = 0;
        for j = 1 : high
            for i = 1 : width
                if ( double( wzorzec(j,i) > 50 ))
                    tozsamosc_wzorca = tozsamosc_wzorca + 1;
                end
            end
        end

        tozsamosc_max = 0;
        
        for j = 1 : 4 : (high_badany - high)
            for i = 1 : 4 : (width_badany - width) 

                template_value = 0;
                tozsamosc = 0;
        
                for y = 1 : high
                   for x = 1 : width

                       temp_y = (y+j)-1;
                       temp_x = (x+i)-1;

                        if( double ( J_krawedzie(temp_y,temp_x) ) > 50 && double( wzorzec(y,x)) > 50)

                            template_value = double( J_krawedzie(temp_y,temp_x) ) -  double ( wzorzec(y,x) );
                            template_value = abs(template_value);

                            if( template_value < neural_5)
                            	tozsamosc = tozsamosc + 1; 
                            end
                        end
                   end
                end

                if(tozsamosc_max < tozsamosc)
                    tozsamosc_max = tozsamosc;
                    x1 = i;
                    y1 = j;
                end

                tozsamosc = 0;
            end    
        end

        val = ( tozsamosc_max/tozsamosc_wzorca ) * 100;
        dopasowanie(time2, time1) = val;

        if ( dopasowanie(time2, time1) > najlepsze_dopasowanie)
            najlepsze_dopasowanie = dopasowanie(time2, time1);
            najlepsze_high = high;
            najlepsze_width = width;
        end  
        
        % wyswietl obszar znalezienia
        if( dopasowanie(time2,time1) > neural_8 )
            for j = y1 : (y1+najlepsze_high)
                for i = x1 : (x1+najlepsze_width)
                    hold on;
                    if(i==x1 || i == x1+najlepsze_width)
                        plot(i,j,'.');
                    end

                    if(j==y1 || j== y1+najlepsze_high)
                        plot(i,j,'.');
                    end
                end
            end
        end
        
        
    end
end

% INFORMACJE O DZIALANIU SIECI

dopasowanie_text = ['Optymalna wysokosc wzorca to: ',num2str(najlepsze_high),'. Optymalna dlugosc wzorca to: ',num2str(najlepsze_width),' dopasowanie na poziomie: ', num2str(najlepsze_dopasowanie),'.'];
disp(dopasowanie_text);
dopasowanie_text = ['Najlepsze x1: ',num2str(x1),'. Najlepsze y1: ',num2str(y1),'.'];
disp(dopasowanie_text);

nowy1 = zeros(najlepsze_high,najlepsze_width);
% Convert double to unit8
imwrite(nowy1, 'temp.jpg');
nowy1 = imread('temp.jpg');

nowy2 = zeros(najlepsze_high,najlepsze_width);
% Convert double to unit8
imwrite(nowy2, 'temp.jpg');
nowy2 = imread('temp.jpg');

for j = 1 : najlepsze_high
    for i = 1 : najlepsze_width
        
        temp_y = (y1+j)-1;
        temp_x = (x1+i)-1;
               
        nowy1(j,i) = J_krawedzie( temp_y , temp_x );    
        nowy2(j,i) = Img_badany_kolor( temp_y, temp_x);
    end
end

figure(6);
subplot(2,2,1);
imshow(nowy1);
title('wynik szukania');

subplot(2,2,2);
imshow(wzorzec);
title('wzorzec - po filtracji');

subplot(2,2,3);
imshow(nowy2);
title('wynik szukania - skala szarosci');

figure(7);

for Parm_7 = 1 : time2
    for Parm_6 = 1 : time1

        plot(Parm_6 , dopasowanie(Parm_7, Parm_6), 'x');
        hold on;

    end
end

imwrite(nowy1, 'temp.jpg');

%---------------------------------------------------------------------------------------------------
% wycinamy co najwazniejsze z nowego zdjecia i tworzymy nowy wzorzec

nowy1 = imread('temp.jpg');





