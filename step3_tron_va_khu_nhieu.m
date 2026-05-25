% ========================================================================
% BƯỚC 3 (ĐÃ SỬA): MÔ PHỎNG TRỘN NHIỄU CÓ CẤU TRÚC VÀ THỰC NGHIỆM LỌC SỐ
%
% VẤN ĐỀ CŨ: Nhiễu trắng (white noise) trải đều mọi tần số
%   → Phần lớn vẫn nằm trong băng thông 300–3400 Hz → bộ lọc không loại bỏ được
%   → Kết quả: tín hiệu trước/sau lọc nhìn và nghe giống nhau.
%
% GIẢI PHÁP: Dùng nhiễu CÓ CẤU TRÚC TẦN SỐ rõ ràng ngoài băng thông:
%   - Tiếng vo ve điện nguồn 50 Hz  (bị cắt bởi highpass f_low=300 Hz)
%   - Gai tần số cao 3700 + 3900 Hz (bị cắt bởi lowpass  f_high=3400 Hz)
%   - Thêm chút nhiễu trắng nhẹ để mô phỏng thực tế
% ========================================================================
clear all; close all; clc;
 
load('voice_raw.mat');
load('filter_coefficients.mat');
 
fprintf('--- Trộn nhiễu CÓ CẤU TRÚC và tiến hành lọc số ---\n');
fprintf('Tần số lấy mẫu: %d Hz\n', fs);
fprintf('Băng thông bộ lọc: 300 – 3400 Hz\n\n');
 
% --- TẠO VECTOR THỜI GIAN ---
N_samples = length(voice);
t = (0:N_samples-1)' / fs;   % Cột, đồng chiều với voice
 
% -----------------------------------------------------------------------
% THÀNH PHẦN NHIỄU (tất cả đều nằm NGOÀI băng thông 300–3400 Hz)
% -----------------------------------------------------------------------
% 1) Tiếng vo ve điện (50 Hz) – dưới 300 Hz → bộ lọc highpass cắt bỏ
noise_hum  = 0.35 * sin(2*pi*50*t);
 
% 2) Gai siêu âm (3700 Hz + 3900 Hz) – trên 3400 Hz → bộ lọc lowpass cắt bỏ
noise_hf   = 0.25 * sin(2*pi*3700*t) + 0.20 * sin(2*pi*3900*t);
 
% 3) Nhiễu trắng nhẹ (biên độ rất thấp, chỉ mô phỏng nền)
noise_white = 0.04 * randn(N_samples, 1);
 
% --- TỔNG HỢP ---
nhieu = noise_hum + noise_hf + noise_white;
voice_nhieu = voice + nhieu;
 
% Clip nhẹ để tránh vượt ±1 khi lưu âm
voice_nhieu = max(min(voice_nhieu, 0.99), -0.99);
 
fprintf('Biên độ RMS nhiễu  : %.4f\n', rms(nhieu));
fprintf('Biên độ RMS tín hiệu gốc: %.4f\n', rms(voice));
fprintf('SNR đầu vào ước tính : %.1f dB\n', 20*log10(rms(voice)/rms(nhieu)));
 
% -----------------------------------------------------------------------
% LỌC SỐ bằng cấu trúc nối tiếp SOS (Cascade Second-Order Sections)
% -----------------------------------------------------------------------
voice_sach = sosfilt(sos, voice_nhieu) * g;
 
% --- In kết quả đo lường so sánh ---
fprintf('\n[SO SÁNH SAU LỌC]:\n');
fprintf('SNR sau lọc ước tính : %.1f dB\n', ...
    20*log10(rms(voice_sach) / rms(voice_sach - voice)));
 
% Lưu vào file để bước 4 dùng
save('voice_clean.mat', 'voice_sach', 'fs');
 
% Xuất file âm thanh để nghe thử từng bước
audiowrite('voice_noisy_output.wav',  voice_nhieu, fs);
audiowrite('voice_filtered_output.wav', voice_sach, fs);
fprintf('\n=> Đã lưu: voice_noisy_output.wav  (tín hiệu có nhiễu)\n');
fprintf('=> Đã lưu: voice_filtered_output.wav (sau khi lọc)\n');
 
% -----------------------------------------------------------------------
% ĐỒ THỊ SO SÁNH 3 LỚP
% -----------------------------------------------------------------------
figure(3);
% Chọn đoạn đầu tín hiệu (nơi voice có nội dung rõ nhất)
seg_start = round(0.35 * N_samples);
seg_end   = seg_start + round(fs * 0.06);   % Quan sát 60 ms
seg = seg_start:seg_end;
 
subplot(3,1,1);
plot(t(seg), voice(seg), 'b-', 'LineWidth', 1.2); grid on;
ylabel('Biên độ'); ylim([-0.8 0.8]);
title('Hình 3.3a: Tín hiệu gốc từ file x[n]');
 
subplot(3,1,2);
plot(t(seg), voice_nhieu(seg), 'r-', 'LineWidth', 1); grid on;
ylabel('Biên độ'); ylim([-0.8 0.8]);
title('Hình 3.3b: Tín hiệu bị nhiễu – vo ve 50 Hz + gai 3700/3900 Hz');
 
subplot(3,1,3);
plot(t(seg), voice_sach(seg), 'k-', 'LineWidth', 1.2); grid on;
xlabel('Thời gian (giây)'); ylabel('Biên độ'); ylim([-0.8 0.8]);
title('Hình 3.3c: Tín hiệu khôi phục sau bộ lọc FIR Cascade SOS');
 
print('-dpng', '-r300', 'waveform_comparison.png');
disp('=> Đã xuất ảnh waveform_comparison.png');
 
% -----------------------------------------------------------------------
% ĐỒ THỊ PHỔ TẦN SỐ (FFT) – để thấy rõ nhiễu bị loại bỏ
% -----------------------------------------------------------------------
figure(5);
NFFT = 2048;
f_axis = (0:NFFT/2) * fs / NFFT;
 
S_orig  = abs(fft(voice,       NFFT)); S_orig  = S_orig(1:NFFT/2+1);
S_noisy = abs(fft(voice_nhieu, NFFT)); S_noisy = S_noisy(1:NFFT/2+1);
S_clean = abs(fft(voice_sach,  NFFT)); S_clean = S_clean(1:NFFT/2+1);
 
eps_val = 1e-10;
subplot(3,1,1);
plot(f_axis, 20*log10(S_orig + eps_val), 'b'); grid on; xlim([0 fs/2]); ylim([-60 60]);
ylabel('dB'); title('Phổ FFT – Tín hiệu gốc');
xline(300,'--k','300 Hz'); xline(3400,'--k','3400 Hz');
 
subplot(3,1,2);
plot(f_axis, 20*log10(S_noisy + eps_val), 'r'); grid on; xlim([0 fs/2]); ylim([-60 60]);
ylabel('dB'); title('Phổ FFT – Tín hiệu có nhiễu (thấy rõ gai 50 Hz, 3700, 3900 Hz)');
xline(300,'--k','300 Hz'); xline(3400,'--k','3400 Hz');
xline(50,'--m','50Hz'); xline(3700,'--m','3700Hz'); xline(3900,'--m','3900Hz');
 
subplot(3,1,3);
plot(f_axis, 20*log10(S_clean + eps_val), 'k'); grid on; xlim([0 fs/2]); ylim([-60 60]);
xlabel('Tần số (Hz)'); ylabel('dB');
title('Phổ FFT – Sau lọc (nhiễu ngoài băng đã bị loại bỏ)');
xline(300,'--k','300 Hz'); xline(3400,'--k','3400 Hz');
 
print('-dpng', '-r300', 'spectrum_comparison.png');
disp('=> Đã xuất ảnh spectrum_comparison.png');