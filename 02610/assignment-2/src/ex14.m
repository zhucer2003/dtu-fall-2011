load_ex1;

m = length(d(:,1));
sstars = zeros(1,11);


for i=1:11
    n = 2*i + 1;
    [x, r, A] = NOfit(d(:,1), d(:,2), n);
    sstars(i) = norm(r)/sqrt(m-n);
end

plot(3:2:23, sstars, 'r.', 'MarkerSize', 16);
set(gca, 'FontSize', 16);
xlabel('n');
ylabel('s^*');
title('Estimated standard deviation for different n');
saveeps('../media/ex14-sd.eps');
