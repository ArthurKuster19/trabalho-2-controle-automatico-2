%% ARTHUR KUSTER SIQUEIRA – A = 18

clear; close all; clc; s = tf('s');

A = 18;
G = 820 / ((s + A)*(s + 2*A));

%% 2) Bode sem controlador
figure('Name','Bode – Sem Controlador');
margin(G); grid on;
title('Diagrama de Bode – Planta sem controlador');

%% ==============================
% 3) CONTROLADOR DE AVANÇO 
% ==============================
z_lead = 60;
p_lead = 20;
Lead = (s + z_lead)/(s + p_lead);

% Malha aberta com avanço
G_lead = Lead * G;

figure('Name','Bode – Com Controlador de Avanço');
margin(G_lead); grid on;
title('Bode – Controlador de Avanço (Lead)');

% Malha fechada
T_lead = feedback(G_lead, 1);

figure('Name','Degrau – Com Avanço');
step(T_lead); grid on;
title('Resposta ao degrau – Controlador de Avanço');

%% ==============================
% 4) CONTROLADOR DE ATRASO
% ==============================

% Atraso melhora baixa frequência sem mexer na fase alta
z_lag = 1;
p_lag = 0.1;
Lag = (s + z_lag)/(s + p_lag);

% Malha aberta com atraso
G_lag = Lag * G;

figure('Name','Bode – Com Controlador de Atraso');
margin(G_lag); grid on;
title('Bode – Controlador de Atraso (Lag)');

% Malha fechada
T_lag = feedback(G_lag, 1);

figure('Name','Degrau – Com Atraso');
step(T_lag); grid on;
title('Resposta ao degrau – Controlador de Atraso');

%% ==============================
% 5) COMPARAÇÃO FINAL (BODE + DEGRAD)
% ==============================

% Comparando Bode
figure('Name','Comparação Bode – Planta vs Lead vs Lag');
bodemag(G, G_lead, G_lag);
legend('Planta','Lead','Lag','Location','Best');
title('Comparação da Magnitude – Planta x Avanço x Atraso'); grid on;

% Comparação no tempo
figure('Name','Comparação de Respostas ao Degrau');
step(feedback(G,1),'k', T_lead,'b', T_lag,'r');
legend('Sem Controlador','Com Avanço','Com Atraso','Location','Best');
title('Comparação – Degrau (MF)'); grid on;

%% ==============================
% 6) RESULTADOS – TABELA PARA RELATÓRIO
% ==============================

fprintf('\n=============================================\n');
fprintf('          RESULTADOS – RESPOSTA EM FREQUÊNCIA\n');
fprintf('=============================================\n\n');

%% Função auxiliar de margem
getMargins = @(Ga) ...
    struct( ...
        'GM',  mag2db(Gm(Ga)), ...
        'PM',  Pm(Ga), ...
        'Wcg', Wcg(Ga), ...
        'Wcp', Wcp(Ga) ...
    );

%% Margens da planta
[GMp, PMp, Wcgp, Wcpp] = margin(G);
mPlanta = struct('GM', mag2db(GMp), 'PM', PMp, 'Wcg', Wcgp, 'Wcp', Wcpp);

%% Margens avance
[GMa, PMa, Wcga, Wcpa] = margin(G_lead);
mLead = struct('GM', mag2db(GMa), 'PM', PMa, 'Wcg', Wcga, 'Wcp', Wcpa);

%% Margens atraso
[GMl, PMl, Wcgl, Wcpl] = margin(G_lag);
mLag = struct('GM', mag2db(GMl), 'PM', PMl, 'Wcg', Wcgl, 'Wcp', Wcpl);

%% Tempos de acomodação e overshoot
infoP    = stepinfo(feedback(G,1));
infoLead = stepinfo(T_lead);
infoLag  = stepinfo(T_lag);

%% Erros estacionários
essP    = abs(1 - dcgain(feedback(G,1)));
essLead = abs(1 - dcgain(T_lead));
essLag  = abs(1 - dcgain(T_lag));

%% Impressão formatada

fprintf('--- Planta Original ---\n');
fprintf('Margem de ganho (GM):       %.2f dB\n', mPlanta.GM);
fprintf('Margem de fase (PM):        %.2f deg\n', mPlanta.PM);
fprintf('Freq cruz. ganho (Wcg):     %.2f rad/s\n', mPlanta.Wcg);
fprintf('Freq cruz. fase (Wcp):      %.2f rad/s\n\n', mPlanta.Wcp);
fprintf('Ts = %.4f s | Mp = %.2f %% | Ess = %.4f\n\n', ...
    infoP.SettlingTime, infoP.Overshoot, essP);

fprintf('--- Controlador de Avanço (Lead) ---\n');
fprintf('Margem de ganho (GM):       %.2f dB\n', mLead.GM);
fprintf('Margem de fase (PM):        %.2f deg\n', mLead.PM);
fprintf('Freq cruz. ganho (Wcg):     %.2f rad/s\n', mLead.Wcg);
fprintf('Freq cruz. fase (Wcp):      %.2f rad/s\n\n', mLead.Wcp);
fprintf('Ts = %.4f s | Mp = %.2f %% | Ess = %.4f\n\n', ...
    infoLead.SettlingTime, infoLead.Overshoot, essLead);

fprintf('--- Controlador de Atraso (Lag) ---\n');
fprintf('Margem de ganho (GM):       %.2f dB\n', mLag.GM);
fprintf('Margem de fase (PM):        %.2f deg\n', mLag.PM);
fprintf('Freq cruz. ganho (Wcg):     %.2f rad/s\n', mLag.Wcg);
fprintf('Freq cruz. fase (Wcp):      %.2f rad/s\n\n', mLag.Wcp);
fprintf('Ts = %.4f s | Mp = %.2f %% | Ess = %.4f\n\n', ...
    infoLag.SettlingTime, infoLag.Overshoot, essLag);

