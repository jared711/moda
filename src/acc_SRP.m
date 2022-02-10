function [a_SRP, d_dr, d_drdot] = acc_SRP(r_sun, A, m, c_srp)
%ACC_SRP Summary of this function goes here
% 
% [a_SRP, d_dr, d_drdot] = ACC_SRP(r_sun, options)
% 
% Inputs: r_sun [km] (3x1) vector pointing from sun to object
% 
% Outputs: 
% 
% See also: 

% Author: Jared Blanchard 	Date: 2022/02/03 09:20:00 	Revision: 0.1 $

if nargin < 4;  c_srp = 1;  end

d = norm(r_sun); % [km] distance to sun
% A = options.A; % [m^2] cross sectional area
% m = options.m/1000; % [kg] mass of meteor
% c_srp = options.c_srp; % [] absoption + reflection % TODO find good values of c_srp for meteoroids
a_SRP = p_srp(d)*c_srp*(A/m)*unit(r_sun); % [m/s^2]
a_SRP = a_SRP/1000; % [km/s^2]

d_dr = p_srp(d)*c_srp*(A/m)*(eye(3)/norm(r_sun)^3 - 3*(r_sun*r_sun')/norm(r_sun)^5);
d_drdot = zeros(3);

end
