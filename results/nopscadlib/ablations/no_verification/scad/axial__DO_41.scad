$fn = 96;

// Requested axial vector (end point from origin)
A = [5.21, 2.72, 0];

// Geometry
rod_radius = 0.25;
origin_marker_radius = 0.5;
origin_marker_height = 0.5;
end_marker_radius = 0.45;
end_marker_height = 0.45;
arrowhead_radius = 0.6;
arrowhead_height = 1.2;

// Ensure positive overlap so the whole model is ONE connected solid
connect_overlap = 0.15;

// Helpers
function vlen(v) = sqrt(v[0]*v[0] + v[1]*v[1] + v[2]*v[2]);
function vunit(v) = let(L=vlen(v)) (L==0 ? [0,0,1] : [v[0]/L, v[1]/L, v[2]/L]);

rod_length = vlen(A);
u = vunit(A);

// Rotate +Z to direction v
module orient_to(v) {
    L = vlen(v);
    if (L == 0) {
        children();
    } else {
        axis = [-v[1], v[0], 0];                 // cross([0,0,1], v)
        axis_len = vlen(axis);
        ang = acos(v[2]/L);                      // angle between +Z and v
        if (axis_len < 1e-9) {
            if (v[2] >= 0) children();
            else rotate([180,0,0]) children();
        } else {
            rotate(a=ang, v=[axis[0]/axis_len, axis[1]/axis_len, axis[2]/axis_len])
                children();
        }
    }
}

module axis_indicator_union() {
    union() {
        // Origin marker (centered at origin)
        cylinder(h=origin_marker_height, r=origin_marker_radius, center=true);

        // Rod centered along vector A (from origin to A)
        translate([A[0]/2, A[1]/2, A[2]/2])
            orient_to(A)
                cylinder(h=rod_length, r=rod_radius, center=true);

        // End marker: overlap INTO rod by connect_overlap
        translate([
            A[0] - u[0]*(end_marker_height/2 - connect_overlap),
            A[1] - u[1]*(end_marker_height/2 - connect_overlap),
            A[2] - u[2]*(end_marker_height/2 - connect_overlap)
        ])
            orient_to(A)
                cylinder(h=end_marker_height, r=end_marker_radius, center=true);

        // Arrowhead: overlap INTO end marker by connect_overlap
        translate([
            A[0] + u[0]*(arrowhead_height/2 - connect_overlap),
            A[1] + u[1]*(arrowhead_height/2 - connect_overlap),
            A[2] + u[2]*(arrowhead_height/2 - connect_overlap)
        ])
            orient_to(A)
                cylinder(h=arrowhead_height, r1=arrowhead_radius, r2=0, center=true);
    }
}

axis_indicator_union();