function [Knumerical,ThetaInc,xCr] = KcalJint(xCr,...
    type_elem,enrdomain,elem_crk,enrich_node,xVertex,...
    vertex_elem,pos,u,ipas,delta_inc,Knumerical,ThetaInc,tip_elem,split_elem)

global node element elemType
global E nu C sigmato
global Jint iMethod

% Knumerical = [] ;
% ThetaInc = [] ;
for kk = 1:size(xCr,2) %what's the crack?
    disp([num2str(toc),'      Crack n. ',num2str(kk)])
    xCr(kk).coornew1 = [];
    xCr(kk).coornew2 = [];
    tip = find(type_elem(:,kk) == 1);
    split = find(type_elem(:,kk) == 2);
    %find out the element containing the...
    for ii=1:size(enrdomain,1)
        iel = enrdomain(ii) ;
        sctr=element(iel,:);
        vv = node(sctr,:);
        flag1 = inhull(xCr(kk).coor(1,:),vv,[],1e-8); % left tip!
        if flag1 == 1
            seg   = xCr(kk).coor(1,:) - xCr(kk).coor(2,:);
            alpha = atan2(seg(2),seg(1));
            [Knum,theta_inc] = SIF(C,iel,elem_crk,xCr,type_elem,...
                enrich_node,xVertex,pos,u,kk,alpha,tip_elem,split_elem,vertex_elem) ;

            Knumerical = [Knumerical Knum] ;
            ThetaInc = [ThetaInc theta_inc] ;
            inc_x = xCr(kk).coor(1,1) + delta_inc * (cos(theta_inc)*cos(alpha) - sin(theta_inc)*sin(alpha));
            [a,b] = find(node(:,1) == inc_x);
            inc_y = xCr(kk).coor(1,2) + delta_inc * (cos(theta_inc)*sin(alpha) + sin(theta_inc)*cos(alpha));
            [a] = find(node(a,2) == inc_y);
            % if a crack increment passes exaclty througha node, let's give
            % a small perturbation...
            if size(a,1) > 0
                theta_inc = theta_inc + 0.01;
                inc_x = xCr(kk).coor(1,1) + delta_inc * cos(theta_inc+alpha);
            end
            xCr(kk).coornew1= [inc_x inc_y]; %
        end
        flag2 = inhull(xCr(kk).coor(size(xCr(kk).coor,1),:),vv,[],1e-8); % and the right tip!
        if flag2 == 1
            seg   = xCr(kk).coor(size(xCr(kk).coor,1),:) - xCr(kk).coor(size(xCr(kk).coor,1)-1,:);
            alpha = atan2(seg(2),seg(1)) ;

            [Knum,theta_inc] = SIF(C,iel,elem_crk,xCr,type_elem,...
                enrich_node,xVertex,pos,u,kk,alpha,tip_elem,split_elem,vertex_elem) ;
            Knumerical = [Knumerical Knum] ;
            ThetaInc = [ThetaInc theta_inc] ;
            inc_x = xCr(kk).coor(size(xCr(kk).coor,1),1) + delta_inc * (cos(theta_inc)*cos(alpha) - sin(theta_inc)*sin(alpha));
            [a,b] = find(node(:,1) == inc_x);
            inc_y = xCr(kk).coor(size(xCr(kk).coor,1),2) + delta_inc * (cos(theta_inc)*sin(alpha) + sin(theta_inc)*cos(alpha));
            [a] = find(node(a,2) == inc_y);
            if size(a,1) > 0
                theta_inc = theta_inc + 0.01;
                inc_x = xCr(kk).coor(1,1) + delta_inc * cos(theta_inc+alpha);
            end
            xCr(kk).coornew2 = [inc_x inc_y]; %right tip
        end
    end
    xCr(kk).coor = [xCr(kk).coornew1;xCr(kk).coor;xCr(kk).coornew2] ;
end %kk
