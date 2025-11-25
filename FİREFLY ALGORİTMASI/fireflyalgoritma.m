% ====== PARAMETRELER ======
n = 15;               % Jeneratör sayısı
PD = 2630;            % Toplam talep gücü (MW)
max_iter = 1000;      % Maks iterasyon sayısı
NP = 50;              % Popülasyon büyüklüğü
alpha = 0.2;          % Rastgelelik katsayısı
beta0 = 1;            % Başlangıç çekim katsayısı
gamma = 1;            % Mesafe azalım katsayısı

% Jeneratör Verileri [c b a Pmin Pmax]
gen = [
    0.000299, 10.1, 671, 150, 455;
    0.000183, 10.2, 574, 150, 455;
    0.001126, 8.8, 374, 20, 130;
    0.001126, 8.8, 374, 20, 130;
    0.000205, 10.4, 461, 150, 470;
    0.000301, 10.1, 630, 135, 460;
    0.000364, 9.8, 548, 135, 465;
    0.000338, 11.2, 227, 60, 300;
    0.000807, 11.2, 173, 25, 162;
    0.001203, 10.7, 175, 25, 160;
    0.003586, 10.2, 186, 20, 80;
    0.005513, 9.9, 230, 20, 80;
    0.000371, 13.1, 225, 25, 85;
    0.001929, 12.1, 309, 15, 55;
    0.004447, 12.4, 323, 15, 55
];

% B Matrisleri
B = 1e-5 * [ 1.4  1.2  0.7 -0.1 -0.3 -0.1 -0.1 -0.1 -0.3 -0.5 -0.3 -0.2  0.4  0.3 -0.1;
              1.2  1.5  1.3  0.0 -0.5 -0.2  0.0  0.1 -0.2 -0.4 -0.4  0.0  0.4  1.0 -0.2;
              0.7  1.3  7.6 -0.1 -1.3 -0.9 -0.1  0.0 -0.8 -1.2 -1.7  0.0 -2.6 11.1 -2.8;
             -0.1  0.0 -0.1  3.4 -0.7 -0.4  1.1  5.0  2.9  3.2 -1.1  0.0  0.1  0.1 -2.6;
             -0.3 -0.5 -1.3 -0.7  9.0  1.4 -0.3 -1.2 -1.0 -1.3  0.7 -0.2 -0.2 -2.4 -0.3;
             -0.1 -0.2 -0.9 -0.4  1.4  1.6  0.0 -0.6 -0.5 -0.8  1.1 -0.1 -0.2 -1.7  0.3;
             -0.1  0.0 -0.1  1.1 -0.3  0.0  1.5  1.7  1.5  0.9 -0.5  0.7  0.0 -0.2 -0.8;
             -0.1  0.1  0.0  5.0 -1.2 -0.6  1.7 16.8  8.2  7.9 -2.3 -3.6  0.1  0.5 -7.8;
             -0.3 -0.2 -0.8  2.9 -1.0 -0.5  1.5  8.2 12.9 11.6 -2.1 -2.5  0.7 -1.2 -7.2;
             -0.5 -0.4 -1.2  3.2 -1.3 -0.8  0.9  7.9 11.6 20.0 -2.7 -3.4  0.9 -1.1 -8.8;
             -0.3 -0.4 -1.7 -1.1  0.7  1.1 -0.5 -2.3 -2.1 -2.7 14.0  0.1  0.4 -3.8 16.8;
             -0.2  0.0  0.0  0.0 -0.2 -0.1  0.7 -3.6 -2.5 -3.4  0.1  5.4 -0.1 -0.4  2.8;
              0.4  0.4 -2.6  0.1 -0.2 -0.2  0.0  0.1  0.7  0.9  0.4 -0.1 10.3 -10.1  2.8;
              0.3  1.0 11.1  0.1 -2.4 -1.7 -0.2  0.5 -1.2 -1.1 -3.8 -0.4 -10.1  57.8 -9.4;
             -0.1 -0.2 -2.8 -2.6 -0.3  0.3 -0.8 -7.8 -7.2 -8.8 16.8  2.8  2.8 -9.4 128.3];
B0 = 1e-3 * [-0.1; -0.2; 2.8; -0.1; 0.1; -0.3; -0.2; -0.2; 0.6; 3.9; -1.7; 0; -3.2; 6.7; -6.4];
B00 = 0.55;

% ====== Başlangıç Popülasyonu ======
P = zeros(NP,n);
fitness = zeros(NP,1);
for i = 1:NP
    for j = 1:n
        P(i,j) = gen(j,4) + rand() * (gen(j,5) - gen(j,4));
    end
    P(i,:) = denge_duzelt(P(i,:), gen, PD, B, B0, B00);
    fitness(i) = maliyet(P(i,:), gen);
end

[best_fitness, idx] = min(fitness);
best = P(idx,:);

% ====== Firefly Algoritması Ana Döngüsü ======
best_cost_history = zeros(max_iter,1);

for iter = 1:max_iter
    for i = 1:NP
        for j = 1:NP
            if fitness(j) < fitness(i)
                r = norm(P(i,:) - P(j,:)); % İki firefly arası uzaklık
                beta = beta0 * exp(-gamma * r^2); % Çekim gücü
                
                % Hareket denklemi
                rand_vec = alpha * (rand(1,n) - 0.5);
                P_new = P(i,:) + beta * (P(j,:) - P(i,:)) + rand_vec;
                
                % Sınır kontrolü
                for k = 1:n
                    P_new(k) = max(min(P_new(k), gen(k,5)), gen(k,4));
                end
                
                % Denge ve uygunluk
                P_new = denge_duzelt(P_new, gen, PD, B, B0, B00);
                fit_new = maliyet(P_new, gen);
                
                % Güncelleme
                if fit_new < fitness(i)
                    P(i,:) = P_new;
                    fitness(i) = fit_new;
                    
                    if fit_new < best_fitness
                        best = P_new;
                        best_fitness = fit_new;
                    end
                end
            end
        end
    end
    best_cost_history(iter) = best_fitness;
    
    % İstersen iterasyon başına bilgi yazdırabilirsin
    if mod(iter,100) == 0
        fprintf('İterasyon %d, En iyi maliyet: %.4f $\n', iter, best_fitness);
    end
end

% ====== Sonuçlar ======
toplam_uretim = sum(best);
kayip = best * B * best' + sum(B0' .* best) + B00;
toplam_guc = PD + kayip;

fprintf('\n==== Firefly Algoritması Optimizasyon Sonuçları ====\n');
fprintf('Toplam Üretim Gücü  : %.2f MW\n', toplam_uretim);
fprintf('Toplam Güç Kaybı    : %.2f MW\n', kayip);
fprintf('Talep + Kayıp       : %.2f MW\n', toplam_guc);
fprintf('Toplam Maliyet      : %.2f $\n', best_fitness);

% En düşük maliyet hangi iterasyonda bulundu?
[best_cost, best_iter] = min(best_cost_history);
fprintf('En düşük maliyet    : %.2f $ (%d. iterasyonda)\n', best_cost, best_iter);

disp("⛳ Optimum Güç Dağılımı (MW):");
disp(best');

disp("💰 Toplam Üretim Maliyeti ($):");
disp(best_fitness);

% ====== Grafikler ======

% Maliyet Eğrisi
figure;
plot(1:max_iter, best_cost_history, 'r-', 'LineWidth', 2);
title('Toplam Maliyet Eğrisi');
xlabel('İterasyon');
ylabel('Maliyet ($)');
xlim([1 max_iter]);
grid on;

% Üretim Dağılımı (bar grafiği)
figure;
bar(best);
title("Jeneratörlere Dağıtılan Güç (MW)");
xlabel("Jeneratör No"); ylabel("Güç (MW)");
grid on;

% Jeneratör Başına Maliyet Katkısı
cost_contrib = arrayfun(@(i) gen(i,1)*best(i)^2 + gen(i,2)*best(i) + gen(i,3), 1:n);
figure;
bar(cost_contrib);
title("Jeneratör Başına Maliyet Katkısı");
xlabel("Jeneratör No"); ylabel("Maliyet ($)");
grid on;

% Üretim - Talep - Kayıp Karşılaştırması
Ploss = best * B * best' + sum(B0' .* best) + B00;
total_gen = sum(best);
figure;
bar([total_gen, PD, Ploss]);
set(gca,'xticklabel',{'Toplam Üretim','Talep','Kayıp'});
title("Üretim - Talep - Kayıp Karşılaştırması");
ylabel("Güç (MW)");
grid on;

% Jeneratör Bazında İletim Kayıpları (yaklaşık katkı)
loss_contrib = best * B;
loss_per_gen = loss_contrib .* best;
figure;
bar(loss_per_gen);
title("Jeneratör Bazında İletim Kayıpları Katkısı");
xlabel("Jeneratör No"); ylabel("Kayıp (MW)");
grid on;

% ====== Yardımcı Fonksiyonlar ======

function f = maliyet(P, gen)
    % Toplam üretim maliyeti hesapla
    f = sum(gen(:,1)'.*P.^2 + gen(:,2)'.*P + gen(:,3)');
end

function P_adj = denge_duzelt(P, gen, PD, B, B0, B00)
    % Güç dengesi sağlamak için iteratif düzeltme
    max_iter = 50; alpha = 0.5;
    for k = 1:max_iter
        Ploss = P * B * P' + sum(B0' .* P) + B00;
        mismatch = sum(P) - (PD + Ploss);
        P = P - alpha * mismatch / length(P);
        for j = 1:length(P)
            P(j) = max(min(P(j), gen(j,5)), gen(j,4));
        end
        if abs(mismatch) < 1e-3, break; end
    end
    P_adj = P;
end

