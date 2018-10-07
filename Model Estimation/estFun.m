% Copyright (C) 2018, Yingjie Zhang
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
% 
%     http://www.apache.org/licenses/LICENSE-2.0
% 
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [b,hess,est,FVAL] = estFun()

global n Q CCP

crit = 10;

CCP = zeros(n.S,n.D); % conditional choice probability
CCP(:,1) = rand(n.S,1);
rest = 1-CCP(:,1);
for d = 2:1:n.D-1
    CCP(:,d) = rest.*rand(n.S,1);
    rest = sum(CCP(:,1:d),2);
end
CCP(:,n.D) = 1-rest;


Q = zeros(n.S,n.S); % nonconditional state transition matrix

Q(:,1) = 1;
options = optimoptions(@fminunc,'Display','iter','Algorithm','quasi-newton','TolFun',0.01,'TolX',0.01,'MaxFunEvals',1000);
N = n.E+1+n.XVal*n.E+(n.E-1)*n.E;
b0 = randn(N,1);

while crit > 0.0001
    b0 = b;
    [b,FVAL,EXITFLAG,OUTPUT,GRAD,hess] = fminunc('estLik',b0,options);
    crit = max(abs(b(:)-b0(:)))
end


est.alpha = b(1);
est.omega = b(2:n.E+1);
est.lambda2.delta = b(n.E+1+1:n.E+1+n.XVal*n.E);
est.lambda2.delta = reshape(est.lambda2.delta,n.XVal,n.E);
est.lambda2.h = b(n.E+1+n.XVal*n.E+1:n.E+1+n.XVal*n.E+(n.E-1)*n.E);
est.lambda2.h = reshape(est.lambda2.h,n.E-1,n.E);
for i = 2:1:n.E-1
    est.lambda2.h(i,:) = est.lambda2.h(i-1,:) + est.lambda2.h(i,:).^2;
end
est.tildeOmega(1) = est.omega(1);
for i = 2:1:n.E
    est.tildeOmega(i) = est.tildeOmega(i-1) + exp(est.omega(i));
end



