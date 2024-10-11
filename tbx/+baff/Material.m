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
        function val = ne(obj1,obj2)
            val = ~(obj1.eq(obj2));
        end
        function obj = ZeroDensity(obj)
            obj.rho = 0;
        end
        function val = eq(obj1,obj2)
            if length(obj1)~= length(obj2) || ~isa(obj2,'baff.Material')
                val = false;
                return
            end
            val = true;
            for i = 1:length(obj1)
                val = val && obj1(i).E == obj2(i).E;
                val = val && obj1(i).G == obj2(i).G;
                val = val && obj1(i).rho == obj2(i).rho;
                val = val && obj1(i).nu == obj2(i).nu;
            end
        end
        function obj = Material(E,nu,rho,Name)
            arguments
                E
                nu
                rho
                Name = "";
            end
            obj.E = E;
            obj.nu = nu;
            obj.rho = rho;
            obj.G  = E / (2 * (1 + nu));
            obj.Name = Name;
        end
    end
    methods(Static)
        function obj = Aluminium()
            obj = baff.Material(71.7e9,0.33,2810);
            obj.Name = "Aluminium7075";
        end
        function obj = Stainless304()
            obj = baff.Material(193e9,0.29,7930);
            obj.Name = "Stainless304";
        end
        function obj = Stainless316()
            obj = baff.Material(193e9,0.27,8000);
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
        function obj = Unity()
            obj = baff.Material(1,-0.5,1);
            obj.Name = "Unity";
        end
    end
end

