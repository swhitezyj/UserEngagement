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

function QE = actionTransition(n,S,lambda2)
% calculate action-specific transition matrix

QE = zeros(n.S,n.S);
delta = lambda2.delta; % n.XVal*n.E;
h = lambda2.h; %nE-1*nE

for i = 1:1:n.S
    for j = 1:1:n.S
        tmpG = S(i,4);
        if tmpG == 1
            fiction = 1;
            casual = 0;
        else if tmpG == 2
                fiction = 0;
                casual = 1;
            else
                fiction = 0;
                casual = 0;
            end
        end
        tmpX = [S(i,3) fiction casual S(i,5:6)];
        if S(j,7) == 1
            QE(i,j) = exp(h(1,S(i,7))-tmpX*delta(:,S(i,7)))...
                /(1+exp(h(1,S(i,7))-tmpX*delta(:,S(i,7))));
        else if S(j,7) == n.E
                QE(i,j) = 1-exp(h(n.E-1,S(i,7))-tmpX*delta(:,S(i,7)))...
                /(1+exp(h(n.E-1,S(i,7))-tmpX*delta(:,S(i,7))));
            else
                QE(i,j) = exp(h(S(j,7),S(i,7))-tmpX*delta(:,S(i,7)))...
                /(1+exp(h(S(j,7),S(i,7))-tmpX*delta(:,S(i,7)))) ...
            - exp(h(S(j,7)-1,S(i,7))-tmpX*delta(:,S(i,7)))...
                /(1+exp(h(S(j,7)-1,S(i,7))-tmpX*delta(:,S(i,7))));
            end
        end
    end
end



