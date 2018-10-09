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


% Personalized Mobile Targeting with User Engagement Stages
% Authors: Yingjie Zhang, Beibei Li, Xueming Luo, and Xiaoyi Zhang

% This function is used as a demonstration of policy simulations

function revenue = prob_personal_withCCP(estQE_control,estQE_content,estQE_price)

global n Qd_pre S p  AggObserved est treatmentT

est_promotion = est.price;
estQE_promotion = estQE_price;
n.SNum = 96;
load('CCP.mat');

revenue = 0;

for i = 1:1:n.I
    totalT = n.T(i);
	treatedT = treatmentT(i)
	period = totalT - treatedT
    QE = phi;  % initial state probability
    
    quota = 0;
    
    for t = treatedT:1:totalT-1
        a = AggObserved(t,i);
        idxe = 0;
        
        for k = a:n.SNum:n.S
            idxe = idxe + 1;
            % dynamic engagement-based promotion
            if idxe > 2
                revenue = revenue + (QE(idxe)*CCP(k,3)*p.priceSub + QE(idxe)*CCP(k,2)*p.priceCha)/period;
            else
                revenue = revenue + (QE(idxe)*CCP_promotion(k,3)*p.priceSub + QE(idxe)*CCP_promotion(k,2)*p.priceCha)/period;
                            
                if mod(k,2) == 0
                    quota = quota + QE(idxe)*CCP_promotion(k,2);
                end
            end

            
        end
        tmpQE = QE;
        for k = 1:1:n.E
            % dynamic engagement-based promotion
            if k > 2
                tmpEst = estQE_control(a+n.SNum*(k-1),a:n.SNum:n.S);
                tmpQE(k) = QE*tmpEst';
            else
                tmpEst = estQE_promotion(a+n.SNum*(k-1),a:n.SNum:n.S);
                tmpQE(k) = QE*tmpEst';
            end  
        end
        QE = tmpQE;
    end
	
    revenue = revenue - min(quota,5)*p.priceCha/period;    
end
    







