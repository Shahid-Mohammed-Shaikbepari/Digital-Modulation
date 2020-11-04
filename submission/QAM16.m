function [BER,SER,evm,Packet_loss] = QAM16(Eb_No, N_Packets, packet_size)
%% Tranmitter side:

%reference: https://www.mathworks.com/help/comm/gs/examine-16-qam-using-matlab.html

%generating random bits as per the packet size.
N_bits = packet_size * N_Packets * 8;
M_symbols = 16;
bitsPerSymbol = 4;
data_in = randi([0,1], N_bits, 1);

%stem(data_in(1:100),'filled');
% title('Random bits'); xlabel('No of Bits');
% ylabel('Binary value');

%converting 0s and 1s to interger valued data for input to modulation
%format
data_bitsPerSymbol = reshape(data_in, length(data_in)/bitsPerSymbol, bitsPerSymbol);
data_integer = bi2de(data_bitsPerSymbol);

%figure;
%stem((data_integer(1:100)));
% title('Integer representation'); xlabel('No of symbols');
% ylabel('integer value');


%convert to 16QAM complex symbols for tranmission
data_16QAM_gray = qammod(data_integer, M_symbols); 
data_16QAM_sequential = qammod(data_integer, M_symbols, 'bin');  %'bin' used for sequential coding.

%plot(1:length(data_16QAM), data_16QAM);hold on;
%scatterplot(data_16QAM);

%to accumulate all the symbols going to be transmitted, convert them to
%discrete format using ifft().
Tx_vec1 = ifft(data_16QAM_gray); 
figure;
zoom on
plot(1:length(Tx_vec1), Tx_vec1, 'r'); %plot the signal which will be transmitted.
title('Tx waveform');
xlabel('length of Txvec');
ylabel('Tx vector');
Tx_vec2 = ifft(data_16QAM_sequential); %to accumulate all the symbols going to be transmitted, convert them to discrete format.
%plot(1:length(Tx_vec2), Tx_vec2);
%legend('Gray', 'Sequential');

%% Noise addition

SNR_total =  Eb_No + 10*log10(bitsPerSymbol);
add_noiseToGray = awgn(Tx_vec1, SNR_total, 'measured');
add_noiseToSequential = awgn(Tx_vec2, SNR_total, 'measured');

%convert scatter to constelation diagram

%plot actual tranmitted signal with transmitted signal plus awgn noise for
%Gray.
Y1 = fft(add_noiseToGray);
figure;
zoom on
plot(1:length(Y1), Y1, 'b'); 
title('Rx waveform');
xlabel('length of Rx vec');
ylabel('Rx vector');
gFigure1 = scatterplot(Y1,1,0,'r.'); hold on 
scatterplot(data_16QAM_gray,1,0, 'k*',gFigure1);


%plot actual tranmitted signal with transmitted signal plus awgn noise for
%Sequential.
Y2 = fft(add_noiseToSequential);
% sFigure1 = scatterplot(Y2,1,0,'r.'); hold on
% scatterplot(data_16QAM_sequential,1,0, 'k*',sFigure1);

%% Receiver side

%Demodulation

demod_16QAM_gray = qamdemod(Y1, M_symbols);
demod_16QAM_sequential = qamdemod(Y2, M_symbols, 'bin');

%integerToBinary conversion

gray_toBinary = de2bi(demod_16QAM_gray, bitsPerSymbol);
sequential_toBinary = de2bi(demod_16QAM_sequential, bitsPerSymbol);
dataOut1 = gray_toBinary(:);
dataOut2 = sequential_toBinary(:);

%BER
[numErrors_gray,ber_gray] = biterr(data_in,dataOut1);
[numErrors_sequential,ber_sequential] = biterr(data_in,dataOut2);
BER = ber_gray;

%SER
serError1 = 0;
serError2 = 0;
for i = 1:length(data_bitsPerSymbol)
    if gray_toBinary(i) ~=  data_bitsPerSymbol(i)
        serError1 = serError1 + 1;
    end
     if sequential_toBinary(i) ~=  data_bitsPerSymbol(i)
        serError2 = serError2 + 1;
    end
end

ser_gray = serError1/length(data_bitsPerSymbol);
ser_Sequential = serError2/length(data_bitsPerSymbol);

SER = ser_gray;
Packet_loss = serError1;
evm = lteEVM(add_noiseToGray, data_16QAM_gray);
EVM = evm.Peak;
amplitudeRatio = 10^(Eb_No/10);
%% Plots
%plotCurve();


end