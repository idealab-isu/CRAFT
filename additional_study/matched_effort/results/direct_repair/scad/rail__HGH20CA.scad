$fn = 64;

// Miniature linear guide rail (approximate profile)
// Overall: 20.0mm wide (X), 17.5mm tall (Z), 100mm long (Y)

rail_w = 20.0;
rail_h = 17.5;
rail_l = 100.0;

// Profile details (kept within overall envelope)
base_h = 6.0;
head_h = rail_h - base_h;

base_w = rail_w;
head_w = 14.0;

edge_r = 0.8;

// Mounting holes (typical rail pattern)
hole_d = 4.2;
csk_d  = 7.5;
csk_h  = 2.0;

end_margin = 10.0;
hole_pitch = 25.0;

module rounded_box(size=[10,10,10], r=1.0) {
    // Rounded only on vertical edges (Z), via 2D rounding + linear_extrude
    w = size[0];
    l = size[1];
    h = size[2];
    rr = min(r, w/2 - 0.001, l/2 - 0.001);
    linear_extrude(height=h)
        offset(r=rr)
            offset(delta=-rr)
                square([w, l], center=true);
}

module rail_body() {
    // Build as union of two stacked prisms with slight rounding on edges
    union() {
        // Base
        translate([0, 0, base_h/2])
            rounded_box([base_w, rail_l, base_h], r=edge_r);

        // Head (centered)
        translate([0, 0, base_h + head_h/2])
            rounded_box([head_w, rail_l, head_h], r=edge_r);
    }
}

module mounting_holes() {
    // Through holes along centerline, with shallow counterbore/countersink
    for (y = [-(rail_l/2 - end_margin) : hole_pitch : (rail_l/2 - end_margin)]) {
        // Through hole
        translate([0, y, -0.1])
            cylinder(d=hole_d, h=rail_h + 0.2);

        // Counterbore from top
        translate([0, y, rail_h - csk_h])
            cylinder(d=csk_d, h=csk_h + 0.2);
    }
}

difference() {
    rail_body();
    mounting_holes();
}