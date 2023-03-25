classdef Material
    %MATERIAL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        E = 0
        G = 0;
        rho = 0;
        nu = 0;
        Name = "";
    end
    
    methods
        function obj = Material(E,nu,rho)
            obj.E = E;
            obj.nu = nu;
            obj.rho = rho;
            obj.G  = E / (2 * (1 + nu));
        end
    end
    methods(Static)
        function obj = Aluminium()
            obj = baff.Material(97e9,0.3,2710);
            obj.Name = "Aluminium";
        end
        function obj = Stainless304()
            obj = baff.Material(193e9,0.29,7930);
            obj.Name = "Stainless304";
        end
        function obj = Stainless400()
            obj = baff.Material(200e9,0.282,7720);
            obj.Name = "Stainless400";
        end
        function obj = Stiff()
            obj = baff.Material(inf,0,0);
            obj.Name = "Stiff";
        end
    end
end

