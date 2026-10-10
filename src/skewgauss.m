function y = skewgauss(p, x)
% 偏高斯函数（常数基线，b1恒为0）
% p = [A, xc, w, s, b0, b1] 其中 b1 恒为0，保留仅为接口统一
A = p(1); xc = p(2); w = p(3); s = p(4); b0 = p(5); b1 = p(6);
z = (x - xc) ./ w;
z_skew = z .* (1 + s * sign(z));
y = A * exp(-4*log(2) * z_skew.^2) + (b0 + b1 * x);
end