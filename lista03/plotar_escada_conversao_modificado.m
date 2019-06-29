%-------------------------------------------------%
% Based on the code
% APPLICATION NOTE 2085
% Histogram Testing Determines DNL and INL Errors
% http://www.maxim-ic.com/
% Thiago Brito
%-------------------------------------------------%

clear all
close all
clc

%Faixa de tensao total do conversor
V = 4.902344;

%Carregando os dados para a geracao do grafico

% saida = csvread('simulacao_metadecap_somadorfinal_5bits_320.csv', 1, 0);

% saida = csvread('teste_verilog8.csv', 1, 0);
saida = csvread('micro.csv', 1, 0);

nbit = 8;
%amostras?????????????? minha dúvida!!
amostras = 4;

passos = V/((2^nbit));

%Montando as linhas de cada grafico

[l c] = size(saida);

%Percorrer a matrix saida

for i = 1:l
    %Percorre a linha recolhendo os valores para tensoes diferentes na
    %entrada
    for k = 2:c
        if saida(i,k) > 3
            aux = 2^((k-1)-1);
        else
            aux = 0;
        end
        if (k<=2)
            grafico(i)= aux;
        else
            grafico(i) = grafico(i) + aux;
        end
    end
end


t(1) = 0;
for i=1:l
    t(i) = saida(i,1);
%     t(i+1) = t(i) + passos;
%     grafico(i) = grafico(i)-4;
%     if(t(i)>0.064)
%         grafico(i) = grafico(i) + 1;
%     end
end

figure,plot(t,grafico(1,1:l))
axis([0 t(l) 0 (2^nbit)])
xlabel('Entrada analogica')
ylabel('Saida digital')
grid
hold on

j=0;
aux = passos;
for i=1:l
    if (saida(i)>aux)
        j=j+1;
        aux=aux+passos;
    end
    teste(i) = j;
end
% Metadecap

%original: teste = [ teste(5:end) 31 31 31 31 31];
teste = [ teste(8:end) 255 255 255 255 255 255 255 255];
plot(t,teste(1,1:l),'-r')

%Calculo DNL

Vlsb = V/(2^nbit);
DNL = 0;
% DNL = |[(VD+1- VD)/VLSB-IDEAL - 1] | , where 0 < D < 2N - 2.
% VD is the physical value corresponding to the digital output code D, N is
% the ADC resolution, and VLSB-IDEAL is the ideal spacing for two adjacent 
% digital codes.

aux = hist(grafico,2^nbit);

dnl = (aux./amostras)-1;
% dnl = [0.1 dnl(2:31) 0.1];
dnl = [0.1 dnl(2:255) 0.1];
figure;
plot([1:2^nbit],dnl);
grid on;
title('DNL');
xlabel('Codigo da saida digital');
ylabel('DNL (LSB)');


DNL = sort(dnl);
[i, j] = size(DNL);
str = sprintf('O pior DNL negativo do conversor eh %d LSB e o pior caso positivo eh %d LSB', DNL(i), DNL(j));
disp(str);


%Calculo INL

INL = 0;

% INL = | [(VD - VZERO)/VLSB-IDEAL] - D | , where 0 < D < 2N-1.
% VD is the analog value represented by the digital output code D, N is the
% ADC's resolution, VZERO is the minimum analog input corresponding to an 
% all-zero output code, and VLSB-IDEAL is the ideal spacing for two adjacent 
% output codes.

inl = zeros(1,2^nbit);
for i=1:2^nbit
    inl(i) = sum(dnl(1:i));
end

%INL with end-points fit, i.e. INL=0 at end-points the straight line joining
%the 2 end points
%[p,S]=polyfit([1,2^numbit-2],[inl(1),inl(2^numbit-2)],1);
%the best-fit straight line
[p,S]=polyfit([1:2^nbit],inl,1);
inl=inl-p(1)*[1:2^nbit]-p(2);

figure;
plot([1:2^nbit],inl);
grid on;
title('INL (BEST END-POINT FIT)');
xlabel('Codigo da saida digital');
ylabel('INL(LSB)');

INL = sort(inl);
[i, j] = size(INL);
str = sprintf('O pior INL negativo do conversor eh %d LSB e o pior caso positivo eh %d LSB', INL(i), INL(j));
disp(str);

