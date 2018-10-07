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


function obj = estLik(b)

global n Qd_pre S p Q CCP D AggObserved flag
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

Qd = zeros(n.S,n.S,n.D);

QX = zeros(n.S,n.S);
QX(:,:) = actionTransition(n,S,est.lambda2);
for d = 1:1:n.D
    Qd(:,:,d) = Qd_pre(:,:,d).*QX(:,:);
end

utility = zeros(n.S,n.D);   
for k = 1:1:n.E
    utility(n.X*(k-1)+1:1:n.X*k,2) = est.alpha*p.priceCha + est.omega(k);
    utility(n.X*(k-1)+1:1:n.X*k,3) = est.alpha*p.priceSub + est.omega(k);

end


epsilon = 0.577 - log(CCP);
I = eye(n.S,n.S);
Q_new = zeros(n.S,n.S);

tmp = zeros(n.S,1);
for d = 1:1:n.D
    tmp = tmp + CCP(:,d).*(utility(:,d)+epsilon(:,d));
end
V = (I-p.beta*Q(:,:))\tmp;

Vd = zeros(n.S,1,n.D);
for d = 1:1:n.D
    Vd(:,:,d) = utility(:,d) + p.beta*Qd(:,:,d)*V;
end

% Subtract max of v to avoid exp(v) == InF (infinity) problem
max_v	= max(Vd(:));
v_		= Vd - max_v;

tmpSum = sum(exp(v_),3);
for d = 1:1:n.D
    CCP(:,d) = exp(v_(:,:,d))./tmpSum;
end

for d = 1:1:n.D
    Q_new(:,:) = Q_new(:,:) + repmat(CCP(:,d),1,n.S).*Qd(:,:,d);
end

Q = Q_new;

% calculate the initial states
%x = fsolve(@(x) x-x*Q, randn(1,n.S));
%phi = x;
phi = zeros(1,n.S)+1/n.S;

% calculate the likelihood
L = zeros(n.I,1);

for i = 1:40:n.I
    if flag(i) == 1
        continue
    end
    totalT = n.T(i);
    tmp = phi;
    tmpD = cell2mat(D(i));

    for t = 1:1:totalT-1
        a = AggObserved(t,i);
        mQ = zeros(n.S,n.S);
        for k = a:n.X:n.S
            mQ(k,:) = CCP(k,tmpD(t)+1)*Q(k,:);
        end
        tmp = tmp*mQ;
    end
    

    a = AggObserved(totalT,i);
    
    tmpSum = 0;

    for k = a:n.X:n.S
        tmpSum = tmpSum + tmp(k)*CCP(k,tmpD(totalT)+1);
    end
    L(i) = log(tmpSum);

end

obj = -sum(L);

