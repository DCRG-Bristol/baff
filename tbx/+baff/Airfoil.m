classdef Airfoil
properties
    Name string
    NormArea
    NormPerimeter
    Cl_max
    Etas (:,1) double
    Ys (:,2) double
end
properties(Dependent)
    NEta
end
methods
    function NEta = get.NEta(obj)
        NEta = length(obj.Etas);
    end
end
methods
    function obj = Airfoil(name, normArea, normPerimeter, Cl_max, etas, ys)
        obj.Name = name;
        obj.NormArea = normArea;
        obj.NormPerimeter = normPerimeter;
        obj.Cl_max = Cl_max;
        obj.Etas = etas;
        obj.Ys = ys;
    end
    function val = Hash(obj)
        % A unique number used to sort / indentify unique Airfoils.
        val = zeros(size(obj));
        for i = 1:length(val)
            val(i) = sum(double(char(obj(i).Name))) + obj(i).NormArea + obj(i).NormPerimeter + sum(obj(i).Ys,"all") + obj(i).NEta;
        end
    end
    function val = eq(obj1,obj2)
        if length(obj1)~= length(obj2) || ~isa(obj2,'baff.Airfoil')
            val = false;
            return
        end
        val = true;
        for i = 1:length(obj1)
            val = val && obj1(i).Name == obj2(i).Name;
            val = val && obj1(i).NormArea == obj2(i).NormArea;
            val = val && obj1(i).NormPerimeter == obj2(i).NormPerimeter;
        end
    end
    function ToBaff(obj,filepath,loc)
        %% write mass specific items
        N = length(obj);
        if N == 0
            h5writeatt(filepath,[loc,'/Airfoils/'],'Qty', 0);
            return
        end
    
        h5write(filepath,sprintf('%s/Airfoils/Name',loc),[obj.Name],[1 1],[1 N]);
        h5write(filepath,sprintf('%s/Airfoils/NormArea',loc),[obj.NormArea],[1 1],[1 N]);
        h5write(filepath,sprintf('%s/Airfoils/Cl_max',loc),[obj.Cl_max],[1 1],[1 N]);
        h5write(filepath,sprintf('%s/Airfoils/NormPerimeter',loc),[obj.NormPerimeter],[1 1],[1 N]);
        Etas = zeros(max([obj.NEta]),N)*nan;
        Ys = zeros(max([obj.NEta]),N*2)*nan;
        for i = 1:N
            Etas(1:obj(i).NEta,i) = obj(i).Etas;
            Ys(1:obj(i).NEta,(i*2-1):(i*2)) = obj(i).Ys;
        end
        h5write(filepath,sprintf('%s/Airfoils/Etas',loc),Etas,[1 1],[size(Etas,1) N]);
        h5write(filepath,sprintf('%s/Airfoils/Ys',loc),Ys,[1 1],[size(Etas,1) N*2]);    
        h5writeatt(filepath,[loc,'/Airfoils/'],'Qty', N);
    end
    
    function vals = GetNormArea(obj,cEtas)
        arguments
            obj
            cEtas (1,2) double = [0 1]
        end
        vals = zeros(size(obj));
        for i = 1:length(obj)
            thickness = obj(i).Ys(:,1) - obj(i).Ys(:,2);
            eta = obj(i).Etas;
            idx = eta > cEtas(1) & eta < cEtas(2);
            etas = [cEtas(1);eta(idx);cEtas(2)];
            thickness = [interp1(eta,thickness,cEtas(1));thickness(idx);interp1(eta,thickness,cEtas(2))];
            vals(i) = trapz(etas,thickness);
        end
    end
end
methods(Static)
    function obj = FromBaff(filepath,loc)
        %FROMBAFF Summary of this function goes here
        %   Detailed explanation goes here
        Qty = h5readatt(filepath,[loc,'/Airfoils/'],'Qty');
        obj = baff.Airfoil.empty;
        if Qty == 0    
            return;
        end
        %% create aerostations
        Names = h5read(filepath,sprintf('%s/Airfoils/Name',loc));
        iNormArea = h5read(filepath,sprintf('%s/Airfoils/NormArea',loc));
        iCl_max = h5read(filepath,sprintf('%s/Airfoils/Cl_max',loc));
        iNormPerimeter = h5read(filepath,sprintf('%s/Airfoils/NormPerimeter',loc));
        iEtas = h5read(filepath,sprintf('%s/Airfoils/Etas',loc));
        iYs = h5read(filepath,sprintf('%s/Airfoils/Ys',loc));
        for i = 1:Qty
            obj(i) = baff.Airfoil(Names(i),iNormArea(i),iNormPerimeter(i),iCl_max(i),iEtas(:,i),iYs(:,(i*2-1):(i*2)));
        end
    end
    function TemplateHdf5(filepath,loc)
        %create placeholders
        h5create(filepath,sprintf('%s/Airfoils/Name',loc),[1 inf],"Chunksize",[1,10],"Datatype","string");
        h5create(filepath,sprintf('%s/Airfoils/NormArea',loc),[1 inf],"Chunksize",[1,10]);
        h5create(filepath,sprintf('%s/Airfoils/Cl_max',loc),[1 inf],"Chunksize",[1,10]);
        h5create(filepath,sprintf('%s/Airfoils/NormPerimeter',loc),[1 inf],"Chunksize",[1,10]);
        h5create(filepath,sprintf('%s/Airfoils/Etas',loc),[inf inf],"Chunksize",[100,10]);
        h5create(filepath,sprintf('%s/Airfoils/Ys',loc),[inf inf],"Chunksize",[100,10]);
    end
    function obj = NACA(pCamber,pLocCamber)
        % NACA 4-digit airfoil generator
        % pCamber: Camber percentage
        % pLocCamber: Camber location percentage
        % Example: NACA(2,4,12) -> NACA 241
        etas = 0:0.02:1;
        t = 1;
        yt = 5*t*(0.2969*sqrt(etas)-0.126*etas-0.3516*etas.^2+0.2843*etas.^3-0.1015*etas.^4);
        m = pCamber/100;
        p = pLocCamber/10;
        yc = m/p^2*((1-2*p)+2*p*etas-etas.^2);
        yc(etas>=p) = m/(1-p)^2*(1-2*p+2*p*etas(etas>=p)-etas(etas>=p).^2);
        ys = [yt;-yt] + repmat(yc,2,1);
        Area = trapz(etas,yt)*2;
        X = [etas;yt];
        perimeter = sum(abs(vecnorm(X(:,2:end)-X(:,1:end-1))))*2;
        name = sprintf('NACA%.0f%.0f',round(pCamber),round(pLocCamber));
        obj = baff.Airfoil(name,Area,perimeter,1.5,etas',ys');
    end
    function obj = NACA_sym()
        etas = 0:0.02:1;
        t = 1;
        yt = 5*t*(0.2969*sqrt(etas)-0.126*etas-0.3516*etas.^2+0.2843*etas.^3-0.1015*etas.^4);
        ys = [yt;-yt];
        obj = baff.Airfoil('NACA',0.6833,3.04,1.5,etas',ys');
    end
end
end