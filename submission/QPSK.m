function [BER,SER,EVM,Packet_loss] = QPSK(snr, number_of_packets, packet_size)
qpskModulator = comm.QPSKModulator();
qpskDemodulator = comm.QPSKDemodulator();

errorRate = comm.ErrorRate;

% Generate  input data frames, apply QPSK modulation, pass the signal through an AWGN channel, demodulate the received data, and compile the error statistics.

totalBits_per_packet = packet_size*8;
numOfBitsPerSybmol = 2;
total_symbols_per_packet = totalBits_per_packet/numOfBitsPerSybmol;
nSymErrors = 0;
lossPackets = 0;
%generation of binary data (bits)
total_error_bits = 0;

for n = 1: number_of_packets
    isPacketLost = false;
    %symbols array generation
    %tx_data = randi([0 1], totalBits_per_packet, 1);
    tx_data = randi([0 3], total_symbols_per_packet, 1);
    %conversion into binaray matrix
    tx_bit_data = de2bi(tx_data);
    tx1 = tx_bit_data(:);
    
    modSig = qpskModulator(tx_data);        % Modulate
    tx_time_domain = ifft(modSig);
    zoom on;
    figure(1);
    plot(1:length(tx_time_domain), tx_time_domain);
    title('TX Waveform');
    %snr1 = snr + 10*log10(numOfBitsPerSybmol);
    rxSig = awgn(tx_time_domain, snr, 'measured');                % Pass through AWGN
    rx_time_domain = fft(rxSig);
    figure(2);
    plot(1:length(rxSig), rxSig);
    title('RX Waveform');
    rxData = qpskDemodulator(rx_time_domain);       % Demodulate
    rx_bit_data = de2bi(rxData);
    rx1 = rx_bit_data(:);
    for j = 1:size(rx1, 1) 
        if tx1(j)~= rx1(j)
            total_error_bits = total_error_bits + 1;
        end
    end
    %[tempSymError, ber] = biterr(tx_data,rxData);
    %ber_total = ber_total + ber;
%     [tempSymError, ber] = biterr(tx1,rx1);
    for i = 1:size(rxData, 1)
        if rxData(i) ~= tx_data(i)
            nSymErrors = nSymErrors + 1;
            if ~isPacketLost
                lossPackets = lossPackets + 1;
                isPacketLost = true;
            end
        end
    end

    h = scatterplot(rx_time_domain);
    hold on
    scatterplot(modSig,[],[],'ro',h);
    title('TX and RX Constellation');
    grid
    legend('Receiver', 'Transmitter');
    hold off

end
SER = nSymErrors/(total_symbols_per_packet*number_of_packets);
BER = total_error_bits/(totalBits_per_packet*number_of_packets);
evm = lteEVM(rxSig,modSig);
EVM = evm.RMS*100;
Packet_loss = lossPackets/number_of_packets*100;

fprintf('EVM = %f\n', evm.RMS*100);
fprintf('Packet Loss = %f\n', Packet_loss);
fprintf('Bit Error rate = %f\n', BER);
fprintf('Symbol Error rate = %f\n', SER);
end

