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
    function obj = SC2_0614()
        % http://airfoiltools.com/airfoil/details?airfoil=sc20614-il
        etas = [0,0.002,0.005,0.01:0.01:1];
        ys = [0	0.0108	0.0166	0.0225	0.0298	0.0349	0.0387	0.0418	0.0445	0.0468	0.0489	0.0508	0.0525	0.0541	0.0555	0.0568	0.058	0.0591	0.0602	0.0612	0.0621	0.0629	0.0637	0.0644	0.0651	0.0657	0.0663	0.0668	0.0673	0.0678	0.0682	0.0686	0.0689	0.0692	0.0694	0.0696	0.0698	0.0699	0.07	0.0701	0.0701	0.0701	0.0701	0.07	0.0699	0.0698	0.0696	0.0694	0.0692	0.069	0.0687	0.0684	0.0681	0.0677	0.0673	0.0669	0.0664	0.0659	0.0653	0.0647	0.064	0.0633	0.0626	0.0618	0.061	0.0601	0.0591	0.0581	0.057	0.0559	0.0547	0.0535	0.0522	0.0509	0.0495	0.0481	0.0466	0.0451	0.0436	0.042	0.0404	0.0387	0.037	0.0352	0.0334	0.0316	0.0297	0.0278	0.0258	0.0238	0.0218	0.0197	0.0176	0.0154	0.0132	0.0109	0.0086	0.0062	0.0038	0.0013	-0.0013	-0.0039	-0.0066;...
                0	-0.0108	-0.0166	-0.0225	-0.0298	-0.0349	-0.0388	-0.0419	-0.0446	-0.0469	-0.049	-0.0509	-0.0526	-0.0542	-0.0557	-0.057	-0.0582	-0.0594	-0.0605	-0.0615	-0.0624	-0.0633	-0.0641	-0.0648	-0.0655	-0.0661	-0.0667	-0.0672	-0.0677	-0.0681	-0.0685	-0.0688	-0.0691	-0.0693	-0.0695	-0.0697	-0.0698	-0.0699	-0.0699	-0.0698	-0.0697	-0.0696	-0.0694	-0.0692	-0.0689	-0.0686	-0.0682	-0.0677	-0.0672	-0.0666	-0.0659	-0.0651	-0.0642	-0.0632	-0.0622	-0.0611	-0.0599	-0.0586	-0.0572	-0.0557	-0.0541	-0.0525	-0.0508	-0.0491	-0.0473	-0.0455	-0.0436	-0.0417	-0.0397	-0.0377	-0.0356	-0.0336	-0.0315	-0.0294	-0.0274	-0.0253	-0.0233	-0.0213	-0.0193	-0.0174	-0.0155	-0.0137	-0.0119	-0.0102	-0.0086	-0.0072	-0.0059	-0.0047	-0.0037	-0.0029	-0.0023	-0.0019	-0.0017	-0.0017	-0.0019	-0.0024	-0.0031	-0.0041	-0.0054	-0.0069	-0.0087	-0.0108	-0.0132];
        ys = ys./max(ys(1,:)-ys(2,:));
        t = ys(1,:)-ys(2,:);
        Area = 0.671417; % Area = trapz(etas,t);
        % get perimeter
        % X = [etas,fliplr(etas);ys(1,:),fliplr(ys(2,:))];
        % perimeter = sum(vecnorm(X(:,2:end)-X(:,1:end-1)));
        perimeter = 3.221506;
        obj = baff.Airfoil('SC2_0614',Area,perimeter,1.5,etas',ys');
    end
end
end