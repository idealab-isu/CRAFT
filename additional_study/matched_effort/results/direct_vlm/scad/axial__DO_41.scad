$fn = 128;

axial = [5.21, 2.72, 0];

// Treat axial as overall dimensions [X,Y,Z]. If Z==0, give it a small
// but visible thickness so top/bottom views are not empty.
min_th = 0.5;

sx = max(axial[0], 0.01);
sy = max(axial[1], 0.01);
sz = (axial[2] <= 0) ? min_th : axial[2];

// One connected solid: an ellipsoid (scaled sphere) centered at origin.
scale([sx/2, sy/2, sz/2])
    sphere(r=1);