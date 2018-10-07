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

function revenue = main
global n Qd_pre S p Q CCP D AggObserved QFValue est treatmentT
load('aggregated_results.mat');

n.F = 2; 			% free content indicator
n.E = 4; 			% number of engagement stages
n.Sub = 2; 			% subscription indicator
n.popular = 2; 		% popularity indicator
n.genre = 3; 		% genre indicator
n.deepsearch = 2; 	% depth search indicator
n.widesearch = 2; 	% breadth search indicator
n.D = 3; 			% number of decision choices
n.X = n.popular*n.genre*n.deepsearch*n.widesearch;
n.XVal = 3+2; 		% number of parameters in transition function
n.S = n.F*n.E*n.Sub*n.X; % number of state variables
n.I = 4586;			% number of individuals


p.priceCha = 0.12;
p.priceSub = 5;
p.beta = .99;


% State variable matrix
Free = [0 1];
Sub = [0 1];
Engage = [1:1:n.E];
popular = [0 1];
genre = [1 2 3];
deepsearch = [0 1];
widesearch = [0 1];
S = combvec(Free,Sub,popular,genre,deepsearch,widesearch,Engage);
S = S';


Qd_pre = zeros(n.S,n.S,n.D);
for d = 1:1:n.D
    Qd_pre(:,:,d) = pre_actionTransition(d,n,S);
end
 
estQE_control = transitionE(n,S,est.control.lambda2);
estQE_content = transitionE(n,S,est.content.lambda2);
estQE_price = transitionE(n,S,est.price.lambda2);

revenue = prob_personal_withCCP(estQE_control,estQE_content,estQE_price);
