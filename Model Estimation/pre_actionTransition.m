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


function Qd = pre_actionTransition(d,n,S)

global QFValue
% deterministic state transition matrix

% (1) indicator of free chapter
QF = zeros(n.S,n.S);
QF(1:2:n.S,1:2:n.S) = QFValue(1);
QF(2:2:n.S,1:2:n.S) = QFValue(2);
QF(1:2:n.S,2:2:n.S) = 1-QFValue(1);
QF(2:2:n.S,2:2:n.S) = 1-QFValue(2);

% (2) subscription indicator
% sub'=1 if sub 1 or d = 2;
if d == 3
    QSub = ones(n.S,n.S);
    QSub(:,1:4:n.S) = 0;
    QSub(:,2:4:n.S) = 0;
else
    QSub = zeros(n.S,n.S);
    QSub(3:4:n.S,3:4:n.S) = 1;
    QSub(4:4:n.S,4:4:n.S) = 1;
    QSub(1:4:n.S,1:4:n.S) = 1;
    QSub(2:4:n.S,2:4:n.S) = 1;
    
    QSub(3:4:n.S,4:4:n.S) = 1;
    QSub(4:4:n.S,3:4:n.S) = 1;
    QSub(1:4:n.S,2:4:n.S) = 1;
    QSub(2:4:n.S,1:4:n.S) = 1;
end

% (3) X: popular, fictionInd, casualInd
QX = zeros(n.S,n.S);
for i = 1:1:n.S
    for j = 1:1:n.S
        P1 = S(i,3);
        G1 = S(i,4);
        P2 = S(j,3);
        G2 = S(j,4);
        %given i, the probability of j
        if P1 == 0
            tmpP = QFValue(3)*(1-P2)+(1-QFValue(3))*P2;
        else
            tmpP = QFValue(4)*(1-P2) + (1-QFValue(4))*P2;
        end 
        
        if G1 == 1
            tmpG = QFValue(5)*(G2==1)+QFValue(6)*(G2==2)+(1-QFValue(5)-QFValue(6))*(G2==3);
        end
        
        if G1 == 2
            tmpG = QFValue(7)*(G2==1) + QFValue(8)*(G2==2) + (1-QFValue(7)-QFValue(8))*(G2==3);
        end
        if G1 == 3
            tmpG = QFValue(9)*(G2==1) + QFValue(10)*(G2==2) + (1-QFValue(9)-QFValue(10))*(G2==3);           
        end
        
        D1 = S(i,5);
        D2 = S(j,5);
        W1 = S(i,6);
        W2 = S(i,6);
        if D1 == 0
            tmpD = QFValue(11)*(1-D2)+(1-QFValue(11))*D2;
        else
            tmpD = QFValue(12)*(1-D2) + (1-QFValue(12))*D2;
        end 
        
        if W1 == 0
            tmpW = QFValue(13)*(1-W2)+(1-QFValue(13))*W2;
        else
            tmpW = QFValue(14)*(1-W2) + (1-QFValue(14))*W2;
        end 

        QX(i,j) = tmpG*tmpP*tmpD*tmpW;      
    end
end


Qd = QF.*QSub.*QX;