function [vec_dot] = dynamics_ECI(t, vec, et0, flags, A, m, bodies)
%DYNAMICS_ECI calculates the time derivative of a
%state vector given in cartesian coordinates in an inertial frame about the
%central body. Can take drag and solar radiation pressure into account.
% 
% [vec_dot] = dynamics_ECI(t, vec, flags, A, m)
% 
% Inputs:   t [sec] (scalar) time used by ode45, ode113 etc...
%           vec [km;km/s;NON] (42x1) cartesian state vector
%           flags [] (3x1) flags = [flag_drag; flag_SRP; flag_TB];
%           A = [m^2] (scalar) cross-sectional area
%           m = [kg] (scalar) mass of meteoroid
%           options (struct)
%               central_body (struct) central gravitational body
%               meteor (struct) object/spacecraft
%               flag_j2 (bool) indicator of j2 {0}
%               flag_3BP (bool) indicator of third body {0}
%               flag_drag (bool) indicator that we are using atmospheric drag {0}
%               flag_srp (bool) indicator that we are using solar radiation pressure {0}
%               flag_poynt (bool) indicator of poynting-robertson effect {0}
%               flag_YORP (bool) indicator of Yarkovsky ORP effect {0}
%               flag_lorentz (bool) indicator of lorentz forces {0}
% 
% Outputs:  vec_dot [km/s;km/s^2;NON] (42x1) d/dt of cartesian state vector
% 
% See also: 

% Author: Jared Blanchard 	Date: 2022/01/28 13:58:56 	Revision: 0.1 $

if isrow(vec);    vec = vec';                     end

et = et0 + t; % [sec] ephemeris time
gm = cspice_bodvrd( 'EARTH', 'GM', 1 );

x_ECI = vec(1:6); % [km;km/s] state vector
r_ECI = vec(1:3); % [km] position vector
v_ECI = vec(4:6); % [km/s] velocity vector
a_ECI = (-gm/(norm(r_ECI)^3))*r_ECI; % [km/s^2] acceleration vector

a_tot = a_ECI;
dadr_tot = zeros(3);
dadv_tot = zeros(3);

if flags(1)
    [a_drag, dadr_drag, dadv_drag] = acc_drag(x_ECI, A, m); % [km/s^2]
    a_tot = a_tot + a_drag;
    dadr_tot = dadr_tot + dadr_drag;
    dadv_tot = dadv_tot + dadv_drag;
end

if flags(2)
    r_earth_ECI = cspice_spkpos('EARTH', et, 'J2000', 'NONE', 'SUN'); 
    [a_SRP, dadr_SRP, dadv_SRP] = acc_SRP(r_ECI + r_earth_ECI, A, m); % [km/s^2]
    a_tot = a_tot + a_SRP;
    dadr_tot = dadr_tot + dadr_SRP;
    dadv_tot = dadv_tot + dadv_SRP;
end

if flags(3)
    [a_TB, dadr_TB, dadv_TB] = acc_TB_ECI(r_ECI, et, bodies);
    a_tot = a_tot + a_TB;
    dadr_tot = dadr_tot + dadr_TB;
    dadv_tot = dadv_tot + dadv_TB;
end

try 
    if flags(4)
        [a_J2, dadr_J2, dadv_J2] = acc_J2(x_ECI);
        a_tot = a_tot + a_J2;
        dadr_tot = dadr_tot + dadr_J2;
        dadv_tot = dadv_tot + dadv_J2;
    end
catch
end
        

vec_dot = zeros(6,1);
vec_dot(1:3) = v_ECI;
vec_dot(4:6) = a_tot;

if length(vec) == 42
    PHI = reshape(vec(7:42),6,6);

    % partials from central gravity field (so I don't have to compute this
    % when there is no STM
    dadr_tot = dadr_tot + gm/(norm(r_ECI)^5)*...
       [3*r_ECI(1)^2 - norm(r_ECI)^2, 3*r_ECI(1)*r_ECI(2), 3*r_ECI(1)*r_ECI(3);
        3*r_ECI(1)*r_ECI(2), 3*r_ECI(2)^2 - norm(r_ECI)^2, 3*r_ECI(2)*r_ECI(3);
        3*r_ECI(1)*r_ECI(3), 3*r_ECI(2)*r_ECI(3), 3*r_ECI(3)^2 - norm(r_ECI)^2];
    
    % variational equations
    PHI_dot = [zeros(3),   eye(3);
               dadr_tot, dadv_tot]*PHI;
    vec_dot(7:42) = reshape(PHI_dot,36,1);
elseif length(vec) == 6
else
    warning("input vector should be 6x1 or 42x1")
end

end