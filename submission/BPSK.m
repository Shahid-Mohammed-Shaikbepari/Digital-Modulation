function [BER,SER,EVM,Packet_loss] = BPSK(snr, number_of_packets, packet_size)
    bpskModulator = comm.BPSKModulator;
    bpskDemodulator = comm.BPSKDemodulator;
    
    errorRate = comm.ErrorRate;
    totalBits = packet_size*8;
    numOfBitsPerSybmol = 1;
    nSymErrors = 0;
    lossPackets = 0;
    %generation of binary data (bits)
    for n = 1: number_of_packets
        tx_data = randi([0 1],totalBits,1);
        modSig = bpskModulator(tx_data);        % Modulate
        tx_time_domain = ifft(modSig);
        zoom on;
        figure(1);
        plot(1:length(tx_time_domain), tx_time_domain);
        title('TX Waveform');
        %rxSig = awgn(modSig, snr);                % Pass through AWGN
        rxSig = awgn(tx_time_domain, snr, 'measured');
        %plot(1:length(rx_time_domain), rx_time_domain);
        rx_time_domain = fft(rxSig);
        figure(2);
        plot(1:length(rxSig), rxSig);
        title('RX Waveform');
        rxData = bpskDemodulator(rx_time_domain);       % Demodulate
        %constDiagram(rxData)
        errorStats = errorRate(tx_data,rxData); % Collect error stats
        tempSymError = 0;
        tempSymError = symerr(tx_data,rxData);
        if tempSymError > 0
            lossPackets = lossPackets + 1;
        end 
        nSymErrors = nSymErrors + tempSymError;

        h = scatterplot(rx_time_domain);
        hold on
        scatterplot(modSig,[],[],'ro',h)
        title('TX and RX Constellation');
        grid
        legend('Receiver', 'Transmitter');
        hold off

    end
    BER = errorStats(1);
    SER = nSymErrors/(totalBits*number_of_packets);
    %evm = lteEVM(modSig,rxSig);
    evm = lteEVM(rxSig, modSig);
    EVM = evm.RMS*100;
    Packet_loss = lossPackets/number_of_packets*100;
    
    fprintf('Bit Error rate = %f\n', BER);
    fprintf('Symbol Error rate = %f\n', SER);
    fprintf('EVM = %f\n', EVM);
    fprintf('Packet Loss = %f\n', Packet_loss);
end

