function Q0 = initial()

    global N
    
    x = linspace(0,1,N);

    Q0 = betapdf(x, 2, 10) * 1e4;

end
