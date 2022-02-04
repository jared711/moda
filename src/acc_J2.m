function [a_J2, d_dr, d_drdot] = acc_J2(x_ECI)
%ACC_J2 Summary of this function goes here
% 
% [OUTPUTARGS] = ACC_J2(INPUTARGS)
% 
% Inputs: 
% 
% Outputs: 
% 
% See also: 

% Author: Jared Blanchard 	Date: 2022/02/03 08:45:14 	Revision: 0.1 $

R_E = cspice_bodvrd( 'EARTH', 'RADII', 3 ); 
gm_earth = cspice_bodvrd( 'EARTH', 'GM', 1 );    
J2 = cspice_bodvrd( 'EARTH', 'J2', 1 );

r_ECI = x_ECI(1:3);
v_ECI = x_ECI(4:6);

[~,~,i,~,omega,nu] = cart2oe(x_ECI, gm_earth);
u = omega + nu;

f_RTN = -3*gm_earth*J2*R_E(1)^2/(2*norm(r_ECI)^4)*[  1-3*sind(i)^2*sind(u)^2;...
                                             sind(i)^2*sind(u)*cosd(u);...
                                               sind(i)*cosd(i)*sind(u)]; % AA279A notes 9
r_unit = unit(r_ECI);
n_unit = unit(cross(r_ECI,v_ECI));
t_unit = cross(n_unit,r_unit);
R = [r_unit, t_unit, n_unit]; % rotation matrix from RTN to ECI
a_J2 = R*f_RTN;

d_dr = zeros(3);
d_drdot = zeros(3);

end
