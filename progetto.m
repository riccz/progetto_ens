close all; clear all; clc;
warning('off', 'MATLAB:audiovideo:wavread:functionToBeRemoved');
warning('off', 'MATLAB:audiovideo:wavwrite:functionToBeRemoved');

[y, Fs, nbits] = wavread('segnale_134.wav');

% Dati per i grafici
b_all = 1;
a_all = 1;
plot_data = [];

dft_ampl_thresh = 10; % Ampiezza relativa della DFT per rilevare un rumore
q_notch = 10; % Fattore di merito dei filtri notch
q_noise_params = 400; % Fattore di merito dei filtri per selezionare i rumori
noise_start_thresh = 10; % Ampiezza relativa per rilevare l'inizio del rumore

y_filt = y;
% Filtra un rumore alla volta da y_filt
while true
    f_0 = find_noise(y_filt, Fs, dft_ampl_thresh);
    if isnan(f_0)
        break;
    end
    fprintf('Trovato un rumore a frequenza %f\n', f_0);
    
    A = find_noise_amplitude(y, f_0, Fs);
    fprintf('Ampiezza %f\n', A);
    
    n_0 = find_noise_start(y, f_0, Fs, q_noise_params, noise_start_thresh);
    t_0 = n_0 / Fs;
    fprintf('Inizia al campione %d (%f s)\n', n_0, t_0);
    
    fprintf('\n');
    
    [b, a] = notch_filter(f_0, Fs, q_notch);
    y_filt = filter(b, a, y_filt);
    
    % Dati per i grafici
    b_all = conv(b_all, b);
    a_all = conv(a_all, a);
    pd.f_0 = f_0;
    pd.t_0 = t_0;
    pd.n_0 = n_0;
    pd.A = A;
    plot_data = [plot_data pd];
end

wavwrite(y_filt, Fs, 'zanol_riccardo.wav');

% Ordina i rumori per t_0
[sorted_t0, sorted_i] = sort([plot_data.t_0]);
old_pd = plot_data;
for i=1:length(plot_data)
    plot_data(i) = old_pd(sorted_i(i));
end

% Parametri dei filtri
for i=1:length(plot_data)
    f_0 = plot_data(i).f_0;
    bw = f_0/q_notch;
    r = 1 - 2*pi*bw/Fs;
    fprintf('Filtro notch %d: f_0 = %f, bw = %f, r = %f\n', i, f_0, bw, r);
end
% Grafico della trasf. di Fourier del segnale
figure(1);
Y = 1/Fs * fft(y);
f = linspace(0, Fs, length(y));
plot(f / 1000, 20*log10(abs(Y)));
xlim([0, 24]);
xlabel('KHz');
ylabel('|Y| [dB]');
grid on;
print('y_dft', '-depsc');

% Risposta in freq. del filtro complessivo
figure(2);
[H, w] = freqz(b_all, a_all, 2048, 'whole');
subplot(2, 1, 1);
plot(w/(2*pi)*Fs / 1000, 20*log10(abs(H)));
xlabel('KHz');
ylabel('|H1| [dB]');
xlim([0, 24]);
grid on;
subplot(2, 1, 2);
plot(w/(2*pi)*Fs / 1000, angle(H)/pi);
xlabel('KHz');
ylabel('arg(H1) / \pi');
xlim([0, 24]);
grid on;
print('H1', '-depsc');

% DFT del segnale filtrato
figure(3);
Y = 1/Fs * fft(y_filt);
f = linspace(0, Fs, length(y));
plot(f / 1000, 20*log10(abs(Y)));
xlim([0, 24]);
xlabel('KHz');
ylabel('|Y| [dB]');
grid on;
print('y_dft_out', '-depsc');

% DFT di y con i rumori segnati
figure(1);
hold all;
for i=1:length(plot_data)
    f_0 = plot_data(i).f_0;
    h(i) = plot([f_0, f_0] / 1000, ylim, 'LineWidth', 1.5);
    legend_text{i} = ['f' num2str(i) ' = ' num2str(f_0/1000) ' KHz'];
end
legend(h, legend_text, 'Location', 'southeast');
print('y_dft_w_noises', '-depsc');

% y con i rumori segnati
figure(5);
hold all;
t = (0:length(y)-1) / Fs;
plot(t, y);
xlabel('t');
ylabel('y');
grid on;
x = xlim;
for i=1:length(plot_data)
    t_0 = plot_data(i).t_0;
    A = plot_data(i).A;
    h(i) = plot([t_0 - 1/Fs, t_0, x(2)], [0, A, A], 'LineWidth', 1.5);
    plot([t_0 - 1/Fs, t_0, x(2)], -[0, A, A], 'LineWidth', 1.5, 'Color', h(i).Color);
    ax = gca;
    ax.ColorOrderIndex = ax.ColorOrderIndex - 1;
    legend_text{i} = ['t' num2str(i) ' = ' num2str(t_0) ' s, A' num2str(i) ' = ' num2str(A)];
end
sum_noises = zeros(1, length(y));
for i=1:length(plot_data)
    n_0 = plot_data(i).n_0;
    A = plot_data(i).A;
    sum_noises(n_0 + 1 : length(y)) = A + sum_noises(n_0);
end
h_s = plot(t, sum_noises, 'LineWidth', 1.5);
plot(t, -sum_noises, 'LineWidth', 1.5, 'Color', h_s.Color);
legend([h_s h], [{'\SigmaAi'} legend_text], 'Location', 'southeast');
print('y_w_noise', '-depsc');

% Risposta in freq. di un filtro selettivo ( per f1 )
figure(6);
[b, a] = single_freq_filter(plot_data(1).f_0, Fs, q_noise_params);
[H, w] = freqz(b, a, 2048, 'whole');
subplot(2, 1, 1);
plot(w/(2*pi)*Fs / 1000, 20*log10(abs(H)));
xlabel('KHz');
ylabel('|H2| [dB]');
xlim([0, 24]);
grid on;
subplot(2, 1, 2);
plot(w/(2*pi)*Fs / 1000, angle(H)/pi);
xlabel('KHz');
ylabel('arg(H2) / \pi');
xlim([0, 24]);
grid on;
print('H2', '-depsc');
