// Axial target
ax_x = 5.21; //[2.605:10.42:0.01]
ax_y = 2.72; //[1.36:5.44:0.01]
ax_z = 0;    //[−5:5:0.01]

// Geometry
rod_radius = 0.5;            //[0.25:1:0.05]
origin_marker_radius = 1;    //[0.5:2:0.05]
origin_marker_height = 1;    //[0.5:2:0.05]
arrowhead_length = 2;        //[1:4:0.1]
arrowhead_radius = 1.2;      //[0.6:2.4:0.05]
end_marker_radius = 0.9;     //[0.45:1.8:0.05]
connect_overlap = 0.6;       //[0.2:1.5:0.05]

// Derived
vlen = sqrt(ax_x*ax_x + ax_y*ax_y + ax_z*ax_z);
eps = 1e-9;

// Rotate +Z to vector [vx, vy, vz]
module orient_to_vector(vx, vy, vz) {
    L = sqrt(vx*vx + vy*vy + vz*vz) + eps;

    // axis = cross([0,0,1],[vx,vy,vz]) = [-vy, vx, 0]
    ax = -vy;
    ay =  vx;
    az =  0;

    ang = acos(vz / L) * 180 / PI;

    if (abs(vx) < 1e-8 && abs(vy) < 1e-8) {
        if (vz >= 0) children();
        else rotate([180,0,0]) children();
    } else {
        rotate(a=ang, v=[ax, ay, az]) children();
    }
}

module axis_indicator_union() {
    union() {
        // Origin marker (centered at origin)
        cylinder(h=origin_marker_height, r=origin_marker_radius, center=true, $fn=64);

        // Rod: centered so it overlaps into origin marker and into arrowhead base
        orient_to_vector(ax_x, ax_y, ax_z)
            translate([0, 0, (vlen - arrowhead_length/2)/2])
                cylinder(
                    h=(vlen - arrowhead_length/2) + 2*connect_overlap,
                    r=rod_radius,
                    center=true,
                    $fn=64
                );

        // Arrowhead: base overlaps rod end
        orient_to_vector(ax_x, ax_y, ax_z)
            translate([0, 0, vlen - arrowhead_length/2 + connect_overlap])
                cylinder(
                    h=arrowhead_length,
                    r1=arrowhead_radius,
                    r2=0,
                    center=true,
                    $fn=64
                );

        // End marker: place along the axis direction so it intersects the arrow tip
        // (ensures one connected solid even when ax_z=0 and view projections look separated)
        orient_to_vector(ax_x, ax_y, ax_z)
            translate([0, 0, vlen + end_marker_radius - connect_overlap])
                sphere(r=end_marker_radius, $fn=64);
    }
}

axis_indicator_union();