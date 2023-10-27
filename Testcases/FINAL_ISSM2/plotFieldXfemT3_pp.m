function [ca,cax,cay] = plotFieldXfem_pp(xCrk,pos,enrich_node,crack_nodes,u,...
    elem_crk,vertex_elem,corner_elem,split_elem,tip_elem,xVertex,xTip,type_elem,ipas,varargin)

%plot stress contour.
%
%Author(s): Sundar, Stephane, Stefano, Phu, David
%Modified: Jan 2009
%--------------------------------------------------------------------

%declare global variables
global node element numnode numelem elemType 
global E C nu P
global typE stressState
global plotmesh
global results_path
global ISSM_yy
global Hidden
global zoom_dim
global fontSize1 fontSize2

stress_pnt =  [ ] ;
stress_xx = [ ] ;
stress_xy = [ ] ;
stress_yy = [ ] ;
stress_val = [ ] ;
stress_val2 = [ ] ;
strain_pnt = [ ] ;
strain_val = [ ] ;
anaStress_val = [ ] ;
fac = 0 ;
ca = []; cax = []; cay = [];
if length(varargin)>0
  ca = varargin{1};
  if length(varargin)>1
    cax = varargin{2};
    if length(varargin)==3
      cay = varargin{3};
    end
  end
end


for iel=1:size(element,1)
    sctr = element(iel,:) ;
    nn = length(sctr) ;
    U = [ ];
    for k = 1:size(xCrk,2)
        U = [U; element_disp(iel,pos(:,k),enrich_node(:,k),u,k)];
    end
    if any(isnan(U))
      warning(['NaN values in enrichments of element ',num2str(iel)])
      U(isnan(U)) = 0;
    end
    %choose Gauss quadrature rules for elements
    [W,Q] = gauss_rule(iel,enrich_node,elem_crk,...
        xTip,xVertex,tip_elem,split_elem,vertex_elem,corner_elem,xCrk) ;
    %[W, Q] = quadrature(1,'TRIANGULAR',2);

    for kk = 1:size(W,1)
    
    B = [ ] ;
    Gpt = Q(kk,:) ;
    [N,dNdxi] = lagrange_basis(elemType,Gpt) ;
    JO = node(sctr,:)'*dNdxi ;
    pt = N' * node(sctr,:);
    Gpnt = N'*node(sctr,:) ;
      
        for k = 1:size(xCrk,2)
            B = [B xfemBmat(Gpt,iel,type_elem,enrich_node(:,k),elem_crk,xVertex,xTip,crack_nodes,k)];
        end

        eps_sub = B*U ;
        
        stress(iel,kk,:) = C*eps_sub ;
        stress_l(kk,:) = C*eps_sub ;
        strain(iel,kk,:) = eps_sub ;
    end
    mstress(iel,:) = mean(stress_l,1);
    stress_issm(iel,:) = f_getstress(iel)'; 
    stress_l = [];
end
%keyboard
tri = element;
TR = triangulation(element,node);
cpos = TR.incenter;

%mstress = mean(stress,2);
%mstress2 = mstress(:,1,:) - stress_issm;
mstress2 = stress_issm;
mstress3 = mstress-stress_issm
vonmises  = sqrt( (mstress(:,1)).^2 +(mstress(:,2)).^2 -(mstress(:,1)).*(mstress(:,2)) + 3*(mstress(:,3).^2) );
vonmises2  = sqrt( (mstress2(:,1)).^2 +(mstress2(:,2)).^2 -(mstress2(:,1)).*(mstress2(:,2)) + 3*(mstress2(:,3).^2) );
vonmises3  = sqrt( (mstress3(:,1)).^2 +(mstress3(:,2)).^2 -(mstress3(:,1)).*(mstress3(:,2)) + 3*(mstress3(:,3).^2) );

vondiff = vonmises-vonmises2;
%figure('visible','off');
if Hidden
  f = figure('visible','off');
  f2 = figure('visible','off');
  f3 = figure('visible','off');
  f4 = figure('visible','off');
  f5 = figure('visible','off');
  f6 = figure('visible','off');
  f7 = figure('visible','off');
  f8 = figure('visible','off');
else
  f = figure();
  f2 = figure();
  f3 = figure();
  f4 = figure();
  f5 = figure();
  f6 = figure();
  f7 = figure();
  f8 = figure();
end
f.Position = [0, 0, 1200, 700 ]
f2.Position = [0, 0, 1200, 700 ]
f3.Position = [0, 0, 1200, 700 ]
f4.Position = [0, 0, 1200, 700 ]
f5.Position = [0, 0, 1200, 700 ]
f6.Position = [0, 0, 1200, 700 ]
f7.Position = [0, 0, 1200, 700 ]
f8.Position = [0, 0, 1200, 700 ]
hold on
figure(f);
patch('faces',tri,'vertices',node,'facevertexcdata',vonmises);
cm = cbrewer2('BuPu', 256);
colormap(cm);
axis equal;
%title('Vonmises','FontSize',fontSize1)
shading flat 
figure(f4);
patch('faces',tri,'vertices',node,'facevertexcdata',vonmises2);
colormap(cm);
axis equal;
shading flat 
figure(f7);
patch('faces',tri,'vertices',node,'facevertexcdata',vondiff);
cm = flipud(cbrewer2('RdBu', 256));
colormap(cm);
axis equal;
%title('Vonmises','FontSize',fontSize1)
shading flat 
figure(f8);
patch('faces',tri,'vertices',node,'facevertexcdata',vonmises3);
cm = flipud(cbrewer2('RdBu', 256));
colormap(cm);
axis equal;
%title('Vonmises','FontSize',fontSize1)
shading flat 
node_vm = zeros(size(node(:,1)));
node_vm2 = zeros(size(node(:,1)));
for i = 1:length(node)
  [els,~] = find(element==i);
  node_vm(i) = mean(vonmises(els));
  node_vm2(i) = mean(vonmises2(els));
end
if isempty(ca)
  try 
    ca = [min(0,quantile(vonmises,0.1)) round(quantile(vonmises,0.995))];
    mi = ca(1);
    ma = ca(2);
  catch 
    mi = min(vonmises(:,1,1));
    ma = max(vonmises(:,1,1));
    sl = (ma-mi);
    if sl == 0
      sl = 1;
    end
    ca = [mi,ma-0.9*sl];
    ca2 = [mi,ma]
  end
else
  mi = ca(1);
  sl = 10*(ca(2)- ca(1));
  ma = ca(1)+sl;
  ca2 = [mi,ma];
end
vl1 = logspace(4,6,50);
vl2 = linspace(0,5e5,51);
figure(f2);
[C_,h] = tricontf(node(:,1),node(:,2),element,node_vm,vl1);
set(h,'edgecolor',[0.1 0.1 0.1]);
set(h,'edgealpha',0.5);
axis equal;
colormap(cm);
caxis([vl1(1),vl1(end)]);
%keyboard
writematrix(vl1,'levels.dat','Delimiter',',')
set(gca,'ColorScale','log');
figure(f3);
[C_,h] = tricontf(node(:,1),node(:,2),element,node_vm,vl2);
set(h,'edgecolor',[0.1 0.1 0.1]);
set(h,'edgealpha',0.5);
colormap(cm);
caxis([vl2(1),vl2(end)]);
%keyboard
axis equal;
%set(gca,'ColorScale','log');

figure(f5);
[C_,h] = tricontf(node(:,1),node(:,2),element,node_vm2,vl1);
set(h,'edgecolor',[0.1 0.1 0.1]);
set(h,'edgealpha',0.5);
axis equal;
colormap(cm);
caxis([vl1(1),vl1(end)]);
%keyboard
writematrix(vl1,'levels.dat','Delimiter',',')
set(gca,'ColorScale','log');
figure(f6);
[C_,h] = tricontf(node(:,1),node(:,2),element,node_vm2,vl2);
set(h,'edgecolor',[0.1 0.1 0.1]);
set(h,'edgealpha',0.5);
colormap(cm);
caxis([vl2(1),vl2(end)]);
%keyboard
axis equal;
set(gca,'ColorScale','log');

figure(f);
cb = colorbar();
cb.Label.String = 'von Mises stress (Pa)';
cb.FontSize = 16;
ax = gca();
ax.FontSize = 16;
%title('Vonmises','FontSize',fontSize1)
caxis(ca);
%keyboard
yticks(-1300000:100000:-1000000);
ylabel('Northing (km)');
xlabel('Easting (km)');
b = f_publish_fig(f,'t');
figure_name = ['Vonmises_stress_',num2str(ipas)];
print([results_path,'/',figure_name],'-dpng','-r300')

caxis(ax,[0,5e5]);
figure_name = ['Vonmises_stress2_',num2str(ipas)];
print([results_path,'/',figure_name],'-dpng','-r300')
delete(b)

figure(f7);
cb = colorbar();
cb.Label.String = 'von Mises stress (Pa)';
cb.FontSize = 16;
ax = gca();
ax.FontSize = 16;
%title('Vonmises','FontSize',fontSize1)
caxis(ax,[-2e5,2e5]);
%keyboard
yticks(-1300000:100000:-1000000);
ylabel('Northing (km)');
xlabel('Easting (km)');
b = f_publish_fig(f7,'t');
figure_name = ['Vonmises_diff_',num2str(ipas)];
print([results_path,'/',figure_name],'-dpng','-r300')

caxis(ax,[-3e5,3e5]);
figure_name = ['Vonmises_diff2_',num2str(ipas)];
print([results_path,'/',figure_name],'-dpng','-r300')
delete(b)

figure(f8);
cb = colorbar();
cb.Label.String = 'von Mises stress (Pa)';
cb.FontSize = 16;
ax = gca();
ax.FontSize = 16;
%title('Vonmises','FontSize',fontSize1)
caxis(ax,[-2e5,2e5]);
%keyboard
yticks(-1300000:100000:-1000000);
ylabel('Northing (km)');
xlabel('Easting (km)');
b = f_publish_fig(f8,'t');
figure_name = ['Vonmises_sd_',num2str(ipas)];
print([results_path,'/',figure_name],'-dpng','-r300')

caxis(ax,[-3e5,3e5]);
figure_name = ['Vonmises_sd2_',num2str(ipas)];
print([results_path,'/',figure_name],'-dpng','-r300')
delete(b)

figure(f4);
cb = colorbar();
cb.Label.String = 'von Mises source stress (Pa)';
cb.FontSize = 16;
ax = gca();
ax.FontSize = 16;
%title('Vonmises','FontSize',fontSize1)
%keyboard
caxis(ca);
yticks(-1300000:100000:-1000000);
ylabel('Northing (km)');
xlabel('Easting (km)');
b = f_publish_fig(f4,'t');
figure_name = ['Vonmises_source_',num2str(ipas)];
print([results_path,'/',figure_name],'-dpng','-r300')

caxis(ax,[0,5e5]);
figure_name = ['Vonmises_source2_',num2str(ipas)];
print([results_path,'/',figure_name],'-dpng','-r300')
delete(b)

if ~isempty(zoom_dim)
  figure(f2);
  xlim(zoom_dim(1,:))
  ylim(zoom_dim(2,:))
  cb = colorbar();
  cb.Label.String = 'von Mises stress (Pa)';
  cb.FontSize = 16;
  ax = gca();
  ax.FontSize = 16;
  ylabel('Northing (km)');
  xlabel('Easting (km)');
  yticks(-1170000:10000:-1100000);
  xticks(-20000:10000:100000);
  b = f_publish_fig(f2,'s');
  figure_name = ['ContourVM_stress_log1_zoom',num2str(ipas)];
  print([results_path,'/',figure_name],'-dpng');
  %saveas(f2,[results_path,'/',figure_name],'epsc');
  %[C_,h] = tricont(node(:,1),node(:,2),element,node_vm,vl1);
  %clabel(C);
  %xlim([zoom_dim(1,1)-10000,zoom_dim(1,2)+10000])
  %ylim([zoom_dim(2,1)-10000,zoom_dim(2,2)+10000])
  %figure_name = ['ContourVM_labels1_zoom',num2str(ipas)]; 
  %print([results_path,'/',figure_name],'-dpng','-r500');


  figure(f3);
  xlim(zoom_dim(1,:))
  ylim(zoom_dim(2,:))
  cb = colorbar();
  cb.Label.String = 'von Mises stress (Pa)';
  cb.FontSize = 16;
  ax = gca();
  ax.FontSize = 16;
  yticks(-1170000:10000:-1100000);
  xticks(-20000:10000:100000);
  ylabel('Northing (km)');
  xlabel('Easting (km)');
  b = f_publish_fig(f3,'s');
  figure_name = ['ContourVM_stress_log2_zoom',num2str(ipas)];
  print([results_path,'/',figure_name],'-dpng');
  %saveas(f3,[results_path,'/',figure_name],'epsc');
  %[C,h] = tricont(node(:,1),node(:,2),element,node_vm,vl2);
  %clabel(C);
  %xlim([zoom_dim(1,1)-10000,zoom_dim(1,2)+10000])
  %ylim([zoom_dim(2,1)-10000,zoom_dim(2,2)+10000])
  %figure_name = ['ContourVM_labels2_zoom',num2str(ipas)]; 
  %print([results_path,'/',figure_name],'-dpng','-r500');

  figure(f5);
  xlim(zoom_dim(1,:))
  ylim(zoom_dim(2,:))
  cb = colorbar();
  cb.Label.String = 'von Mises of source stress (Pa)';
  cb.FontSize = 16;
  ax = gca();
  ax.FontSize = 16;
  ylabel('Northing (km)');
  xlabel('Easting (km)');
  yticks(-1170000:10000:-1100000);
  xticks(-20000:10000:100000);
  b = f_publish_fig(f5,'s');
  figure_name = ['ContourVM_source_log1_zoom',num2str(ipas)];
  print([results_path,'/',figure_name],'-dpng');
  %saveas(f2,[results_path,'/',figure_name],'epsc');
  %[C_,h] = tricont(node(:,1),node(:,2),element,node_vm,vl1);
  %clabel(C);
  %xlim([zoom_dim(1,1)-10000,zoom_dim(1,2)+10000])
  %ylim([zoom_dim(2,1)-10000,zoom_dim(2,2)+10000])
  %figure_name = ['ContourVM_labels1_zoom',num2str(ipas)]; 
  %print([results_path,'/',figure_name],'-dpng','-r500');


  figure(f6);
  xlim(zoom_dim(1,:))
  ylim(zoom_dim(2,:))
  cb = colorbar();
  cb.Label.String = 'von Mises of source stress (Pa)';
  cb.FontSize = 16;
  ax = gca();
  ax.FontSize = 16;
  yticks(-1170000:10000:-1100000);
  xticks(-20000:10000:100000);
  ylabel('Northing (km)');
  xlabel('Easting (km)');
  b = f_publish_fig(f6,'s');
  figure_name = ['ContourVM_source_log2_zoom',num2str(ipas)];
  print([results_path,'/',figure_name],'-dpng');
end

close(f2);
close(f3);

figure(f);
clf();
hold on
patch('faces',tri,'vertices',node,'facevertexcdata',mstress(:,1));
view(2);
%title('Stress XX','FontSize',fontSize1)
shading flat 
cb = colorbar();
cb.Label.String = 'stress';
cm = cbrewer2('RdYlBu', 256);
colormap(cm);
cax = [-2e5,2e5];
caxis(cax);
axis equal;
cb.FontSize = 16;
ax = gca();
ax.FontSize = 16;
ylabel('Northing (km)');
xlabel('Easting (km)');
yticks(-1300000:100000:-1000000);
f_publish_fig(f,'t');
figure_name = ['Stress_xx_',num2str(ipas)];
print([results_path,'/',figure_name],'-dpng')

figure(f);
clf();
hold on
patch('faces',tri,'vertices',node,'facevertexcdata',mstress(:,2));
view(2);
%title('Stress YY','FontSize',fontSize1)
shading flat 
colorbar
cm = cbrewer2('RdYlGn', 256);
colormap(cm);
cay = [-2e5,2e5];
caxis(cay);
cb = colorbar();
cb.Label.String = 'stress';
axis equal;
cb.FontSize = 16;
ax = gca();
ax.FontSize = 16;
ylabel('Northing (km)');
xlabel('Easting (km)');
yticks(-1300000:100000:-1000000);
f_publish_fig(f,'t');
figure_name = ['Stress_yy_',num2str(ipas)];
print([results_path,'/',figure_name],'-dpng')
clf(f); close(f);

