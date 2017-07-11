function [points,D] = farthest_point_sampling_mesh( vertex,faces, points, nbr_iter, options )

% farthest_point_sampling - samples points using farthest seeding strategy
%
% [points,D] = farthest_point_sampling_mesh( vertex,faces, points, nbr_iter, options );
%
%   points can be [] or can be a (nb.points,1) matrix of already computed 
%       sampling locations.
%   
%   Copyright (c) 2005 Gabriel Peyr?

options.null = 0;
if nargin<3
    nb_iter = 1;
end

if size(vertex,1)>size(vertex,2)
    vertex = vertex';
end
if size(faces,1)>size(faces,2)
    faces = faces';
end

n = size(vertex,2);

if isfield(options, 'constraint_map')
    L1 = options.constraint_map;
else
    L1 = zeros(n,1) + Inf;
end

if nargin<2 || isempty(points)
    % initialize farthest points at random
    points = round(rand(1,1)*(n-1))+1;
    % replace by farthest point
    [points,L] = farthest_point_sampling_mesh( vertex,faces, points, 1, options );
    points = points(end);
    nbr_iter = nbr_iter-1;
else
    % initial distance map
    L = min(zeros(n,1) + Inf, L1);
end

if nbr_iter>5
    hh = waitbar(0,['Performing farthest sampling.']);
end
for i=1:nbr_iter
    if nbr_iter>5
        waitbar( i/nbr_iter ,hh);
    end
    options.nb_iter_max = Inf;
    options.constraint_map = L;
    D = my_eval_distance(vertex,faces, points(end), options);
    D = min(D,L); % known distance map to lanmarks
    L = min(D,L1); % cropp with other constraints
    % remove away data
    D(D==Inf) = 0;
    % compute farhtest points
    [tmp,I] = max(D(:));
    points = [points,I(1)];
end
if nbr_iter>5
    close(hh);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function D = my_eval_distance(vertex,faces,x, options)

options.null = 0;

if length(x)>1
    D = zeros(n)+Inf;
    for i=1:length(x)
        D = min(D, my_eval_distance(vertex,faces,x(i)));
    end
    return;
end
[D,Z,Q] = perform_fast_marching_mesh(vertex, faces, x, options);