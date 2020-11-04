function [BER, SER, EVM, Packet_loss] = run(modulation_scheme,SNR, number_of_packets, packet_size)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if modulation_scheme == "16QAM"
    [BER, SER, EVM, Packet_loss] = QAM16(SNR, number_of_packets, packet_size);
elseif modulation_scheme == "64QAM"
    [BER,SER,EVM,Packet_loss] = QAM64(SNR, number_of_packets, packet_size);
elseif modulation_scheme == "BPSK"
    [BER,SER,EVM,Packet_loss] = BPSK(SNR, number_of_packets, packet_size);

elseif modulation_scheme == "QPSK"
    [BER,SER,EVM,Packet_loss] = QPSK(SNR, number_of_packets, packet_size);
else
    fprinf('Enter valid argument\n')
end

end