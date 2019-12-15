syms p q r M N A B C D E F G H I J K L O P R S
b = [M N A B C D E F G H I J K L O P R S];
c=[A;B;C;D;E;F;G;H;I;J];
c(1) = A / p - q * N / p - r * M / p;
c(1) = expand(c(1));
c(1) = collect(c(1),M);
c(1) = collect(c(1),N);
c(1) = collect(c(1),A);
c(2) = B / p - q * c(1) / p - r * N / p;
c(2) = expand(c(2) );
c(2) = collect(c(2),M);
c(2) = collect(c(2),N);
c(2) = collect(c(2),A);
c(2) = collect(c(2),B);

for i = 3:10		%could generate when 3 : (2^k)+2    k = 2/3/4 
    c(i) = c(i) / p - q * c(i-1) / p - r * c(i-2) / p;
    c(i) = expand(c(i));
    for j = 1:12
        c(i) = collect(c(i),b(j));
    end 
end

c