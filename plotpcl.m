function plotpcl(pcl)
  
  kk = pcl(:, :, 6) ~= 0;
  x  = pcl(:, :, 4);
  y  = pcl(:, :, 5);
  z  = pcl(:, :, 6);
  x  = x(kk);
  y  = y(kk);
  z  = z(kk);
  rgbUndistorted = pcl(:,:,1:3)/255;
  [Xim, cm] = rgb2ind(rgbUndistorted, 512);
  Xim = Xim(kk);
  XYZ = [x y z];
  alpha = deg2rad(30);
  R = [1 0 0; 0 cos(alpha) sin(alpha); 0 -sin(alpha) cos(alpha)];
  XYZ = (R*XYZ')';
  figure (1);
  fscatter32(XYZ(:,1), XYZ(:,2), XYZ(:,3), Xim, cm)
  max_z = max(z(:));
  zlim([0.2 max(z(:))])
  ylim([0 1])
  xlim([-.5 .5])
  set(gca,'zdir','reverse')
  
  mean_point = mean(XYZ); % 1x3
  %centering
  point_dev = XYZ - ones(size(XYZ, 1), 1) * mean_point;
  %scatter matrix along XYZ
  scatter = point_dev' * point_dev; % 3x3
  [U,D,V]= svd(scatter);
  %background normal vector, get the vector with lowest eigenvalue
  bg_n = V(:, 3)'; %1x3
  %projection of centered cloud points on the background normal 
  %in other words how far certain point from the background
  norm_prjs = point_dev * bg_n'; % num_points x 1
  %background point project on background normal
  bg_prj_point = prctile(norm_prjs, 50);
  bg_point = mean_point + bg_prj_point * bg_n;% 1x3
  
%   %plotting arrow of background normal
%   arrow_p = bg_point;% 1x3
%   %scale it and invert it for better representation
%   %because z axis is inverted
%   arrow_dir   = -bg_n * max_z/4; 
%   quiver3(arrow_p(1), arrow_p(2), arrow_p(3),...
%           arrow_dir(1)  , arrow_dir(2)  , arrow_dir(3), 'color', 'b');  
        
  %background surface parameters for following equation:
  % n*r=d where n - normal, d - offset along the normal
  d = bg_point *  bg_n'
  threshold_raw = 0.0305;
  %threshold = 0.0125;
  cloud_surf_prjs = XYZ * bg_n'; %number of cloud point x 1
  %background indices
  %bg_ids = (cloud_surf_prjs - d) < -threshold; 
  surf_diff = cloud_surf_prjs - d;
  bg_ids_raw = abs(surf_diff) < threshold_raw; 
  %foreground indices
  fg_ids_raw = ~bg_ids_raw;
  fg_diff = surf_diff(fg_ids_raw);
  threshold = 0.0125;
  norm_is_inverted = fg_diff(1) < 0;
  if norm_is_inverted
   fg_ids = (surf_diff) < -threshold; 
  else
   fg_ids = (surf_diff) > threshold;
  end
  
  figure(4);
%   class = kmeans(XYZ(fg_ids,:),4);
  x = XYZ(fg_ids,1);
  y = XYZ(fg_ids,2);
  z = XYZ(fg_ids,3);
  xyz = XYZ(fg_ids,:);
  % cluster in n categories
  [class, type]=dbscan([XYZ(fg_ids,1),XYZ(fg_ids,2),XYZ(fg_ids,3)],100);
  % What are those unique groups? 
    uniqueGroups = unique(class);
  % RGB values of your favorite colors: 
  colors = brewermap(length(uniqueGroups),'Set1'); 
    % Initialize some axes
    view(3)
    grid on
    hold on
    triples = combnk (uniqueGroups,3);
    prevArea = 0;
    
    for k = 1:size(triples,1)
        groupElement = zeros(3,size(xyz,1),size(xyz,2));
        for group =1:size(triples)
%             meanCl(group,1) = mean(XYZ(ind));
            grupa = triples(group,:);
            area = triangleArea3d(xyz(class==grupa(1)),xyz(class==grupa(2)),xyz(class==grupa(3)));
        end
        
        % Get indices of this particular unique group:
        ind = class==uniqueGroups(k); 
        % Plot only this group: 
        plot3(x(ind),y(ind),z(ind),'.','color',colors(k,:),'markersize',20); 
    end
    % Plot each group individually: 
    for k = 1:length(uniqueGroups)
          % Get indices of this particular unique group:
          ind = class==uniqueGroups(k); 
          % Plot only this group: 
          plot3(x(ind),y(ind),z(ind),'.','color',colors(k,:),'markersize',20); 
    end
    legend('group 1','group 2','group 3','group 4')
%   z = XYZ(fg_ids,3);
%   % call GSCATTER and capture output argument (handles to lines)
%   h = gscatter(XYZ(fg_ids,1), XYZ(fg_ids,2), class);
%   % for each unique group in 'class', set the ZData property appropriately
%   gu = unique(class);
%   for k = 1:numel(gu)
%       set(h(k), 'ZData', z( class == gu(k) ));
%   end
  set(gca,'zdir','reverse')
  zlim([0.2 max(z(:))])
  ylim([0 1])
  xlim([-.5 .5])
  
  
%   fscatter32(XYZ(fg_ids,1), XYZ(fg_ids,2), XYZ(fg_ids,3), Xim(fg_ids), cm)
%   max_z = max(z(:));
%   zlim([0.2 max(z(:))])
%   ylim([0 1])
%   xlim([-.5 .5])
%   set(gca,'zdir','reverse')
  hold on
  %plotting arrow of background normal
  arrow_p = bg_point;% 1x3
  %scale it and invert it for better representation
  %because z axis is inverted
  arrow_dir   = -bg_n * max_z/4; 
  quiver3(arrow_p(1), arrow_p(2), arrow_p(3),...
          arrow_dir(1)  , arrow_dir(2)  , arrow_dir(3), 'color', 'b'); 
  view(3)
  return;%just for easy debug
  % Show colour image
  figure(2)
  image(pcl(:,:,1:3)/255)

  % show depth image
  figure(3)
  [H,W]=size(pcl(:,:,1));
  depth=zeros(H,W);
  for r = 1 : H
    for c = 1 : W
      depth(r,c) = norm(reshape(pcl(r,c,4:6),1,3));
    end
  end
  M = max(max(depth));
  m = min(min(depth));
  depth = (depth - m) / (M-m);
  imshow(depth.^2)
  
end

