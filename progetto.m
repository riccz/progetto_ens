close all; clear all; clc;
warning('off', 'MATLAB:audiovideo:wavread:functionToBeRemoved');
warning('off', 'MATLAB:audiovideo:wavwrite:functionToBeRemoved');

[y, Fc, nbits] = wavread('segnale_134.wav');

% Dati per i grafici
b_all = 1;
a_all = 1;
plot_data = [];

dft_min_thresh = 0.9; % Frazione dell'ampiezza minima della DFT per rilevare un rumore
q_notch = 10; % Fattore di merito dei filtri notch
q_sel = 400; % Fattore di merito dei filtri per selezionare i rumori
start_ampl_thresh = 10; % Ampiezza relativa per rilevare l'inizio del rumore

y_filt = y;
% Filtra un rumore alla volta da y_filt
while true
    fi = find_noise(y_filt, Fc, dft_min_thresh);
    if isnan(fi)
        break;
    end
    fprintf('Trovato un rumore a frequenza %f\n', fi);
    
    Ai = find_noise_amplitude(y, fi, Fc);
    fprintf('Ampiezza %f\n', Ai);
    
    ni = find_noise_start(y, fi, Fc, q_sel, start_ampl_thresh);
    ti = ni / Fc;
    fprintf('Inizia al campione %d (%f s)\n', ni, ti);
    
    fprintf('\n');
    
    [b, a] = notch_filter(fi, Fc, q_notch);
    y_filt = filter(b, a, y_filt);
    
    % Dati per i grafici
    b_all = conv(b_all, b);
    a_all = conv(a_all, a);
    pd.fi = fi;
    pd.ti = ti;
    pd.ni = ni;
    pd.Ai = Ai;
    plot_data = [plot_data pd];
end

wavwrite(y_filt, Fc, 'zanol_riccardo.wav');

% Ordina i rumori per ti
[sorted_ti, sorted_i] = sort([plot_data.ti]);
old_pd = plot_data;
for i=1:length(plot_data)
    plot_data(i) = old_pd(sorted_i(i));
end

% Parametri dei filtri
for i=1:length(plot_data)
    fi = plot_data(i).fi;
    bw = fi/q_notch;
    r = 1 - 2*pi*bw/Fc;
    fprintf('Filtro notch %d: f_0 = %f, bw = %f, r = %f\n', i, fi, bw, r);
end
% Grafico della trasf. di Fourier del segnale
figure(1);
Y = 1/Fc * fft(y);
f = linspace(0, Fc, length(y));
plot(f / 1000, 20*log10(abs(Y)));
xlim([0, 24]);
xlabel('kHz');
ylabel('|Y| [dB]');
grid on;
print('y_dft', '-depsc');

% Risposta in freq. del filtro complessivo
figure(2);
[H, w] = freqz(b_all, a_all, 2048, 'whole');
subplot(2, 1, 1);
plot(w/(2*pi)*Fc / 1000, 20*log10(abs(H)));
xlabel('kHz');
ylabel('|H| [dB]');
xlim([0, 24]);
grid on;
subplot(2, 1, 2);
plot(w/(2*pi)*Fc / 1000, angle(H)/pi);
xlabel('kHz');
ylabel('arg(H) / \pi');
xlim([0, 24]);
grid on;
print('H', '-depsc');

% DFT del segnale filtrato
figure(3);
Y = 1/Fc * fft(y_filt);
f = linspace(0, Fc, length(y));
plot(f / 1000, 20*log10(abs(Y)));
xlim([0, 24]);
xlabel('kHz');
ylabel('|Y| [dB]');
grid on;
print('y_dft_out', '-depsc');

% DFT di y con i rumori segnati
figure(1);
hold all;
for i=1:length(plot_data)
    fi = plot_data(i).fi;
    h(i) = plot([fi, fi] / 1000, ylim, 'LineWidth', 1.5);
    legend_text{i} = ['f' num2str(i) ' = ' num2str(fi/1000) ' kHz'];
end
legend(h, legend_text, 'Location', 'southeast');
print('y_dft_w_noises', '-depsc');

% y con i rumori segnati
figure(5);
hold all;
t = (0:length(y)-1) / Fc;
plot(t, y);
xlabel('t');
ylabel('y');
grid on;
x = xlim;
for i=1:length(plot_data)
    ti = plot_data(i).ti;
    Ai = plot_data(i).Ai;
    h(i) = plot([ti - 1/Fc, ti, x(2)], [0, Ai, Ai], 'LineWidth', 1.5);
    plot([ti - 1/Fc, ti, x(2)], -[0, Ai, Ai], 'LineWidth', 1.5, 'Color', h(i).Color);
    ax = gca;
    ax.ColorOrderIndex = ax.ColorOrderIndex - 1;
    legend_text{i} = ['t' num2str(i) ' = ' num2str(ti) ' s, A' num2str(i) ' = ' num2str(Ai)];
end
sum_noises = zeros(1, length(y));
for i=1:length(plot_data)
    ni = plot_data(i).ni;
    Ai = plot_data(i).Ai;
    sum_noises(ni + 1 : length(y)) = Ai + sum_noises(ni);
end
h_s = plot(t, sum_noises, 'LineWidth', 1.5);
plot(t, -sum_noises, 'LineWidth', 1.5, 'Color', h_s.Color);
legend([h_s h], [{'\SigmaAi'} legend_text], 'Location', 'southeast');
print('y_w_noise', '-depsc');

% Risposta in freq. di un filtro selettivo ( per f1 )
figure(6);
[b, a] = single_freq_filter(plot_data(1).fi, Fc, q_sel);
[H, w] = freqz(b, a, 2048, 'whole');
subplot(2, 1, 1);
plot(w/(2*pi)*Fc / 1000, 20*log10(abs(H)));
xlabel('kHz');
ylabel('|Hsel| [dB]');
xlim([0, 24]);
grid on;
subplot(2, 1, 2);
plot(w/(2*pi)*Fc / 1000, angle(H)/pi);
xlabel('kHz');
ylabel('arg(Hsel) / \pi');
xlim([0, 24]);
grid on;
print('Hsel', '-depsc');
