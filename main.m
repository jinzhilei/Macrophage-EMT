function main()
% to get fig1 and fig2 required data

    control();

    parameter();
    
    global md 
    
    Q0 = initial();
    
    T = -md.tau:md.h:md.end_Time;
    
    Q = solve(Q0, T);
    
    writematrix(Q, 'data/basic/tumor.dat');

end
