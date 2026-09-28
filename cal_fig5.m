function cal_fig5()

    control();

    parameter();
    
    global md par N
    
    Q0 = initial();

    T = -md.tau:md.h:md.end_Time;

    u = linspace(0, 1, N);

    %% No macrophage role
    par.lambda_beta = 0;
    par.lambda_mu = 0;
    par.varepsilon_1 = 0;
    par.varepsilon_2 = 0;
    
    Q = solve(Q0, T); Q = to_dist(Q);

    writematrix(Q, 'data/fix_mac/no_mac.dat');

    control();

    parameter();

    %% only I
    M_I = betapdf(u, 2, 10);

    Q = solve1(Q0, T, M_I); Q = to_dist(Q);

    writematrix(Q, 'data/fix_mac/mac_I.dat');
    
    %% only II 
    M_II = betapdf(u, 10, 2);

    Q = solve1(Q0, T, M_II);Q = to_dist(Q);

    writematrix(Q, 'data/fix_mac/mac_II.dat');
    
    %% only mix
    M_mix = betapdf(u, 6, 6);

    Q = solve1(Q0, T, M_mix);Q = to_dist(Q);

    writematrix(Q, 'data/fix_mac/mac_mix.dat');

end








%% fix 
function Q = solve1(Q0, T, M_I)
    
    global md N

    M = length(T);

    Q = zeros(M, N);

    index = find(T == 0);

    for i = 1:index
        Q(i,:) = Q0;
    end
    
    %% Euler 
    for i = index + 1 : M

        dQdt = fun1(Q(i-1,:), Q(i-index,:), T(i-1), M_I);

        Q(i,:) = Q(i-1,:) + md.h * dQdt;
        
    end

end


function dQdt = fun1(Q, Q_tau, t, M_I)
    
    global md N
    
    M = M_I;

    M_tau = M_I;

    [beta, kappa, mu, beta_tau] = Dynamic(Q, Q_tau, M, M_tau);
    
    P = Inherit(M_tau);
    
    Value = zeros(N, N);
    
    value = beta_tau .* Q_tau;

    value = value * exp(-mu* md.tau);
    
    for i = 1:N
        Value(i, :) = P(i, :) .* value;
    end
    
    int = Integral(Value);

    int = int';
    
    dQdt = -(beta + kappa) .* Q + 2 * int;

end


function Q_pic = to_dist(Q)

    [m,~] = size(Q);
    
    for i = 1:m
        Q_pic(i,:) = Q(i,:)/sum(Q(i,:));
    end

end