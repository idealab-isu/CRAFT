// Parameters
bbox_L = 25.0; //[12.5:50.0:0.05]
bbox_W = 21.65; //[10.825:43.3:0.05]
H = 4.0; //[2.0:8.0:0.05]

hex_flat_to_flat_major = 25.0; //[12.5:50.0:0.05]
hex_flat_to_flat_minor = 21.65; //[10.825:43.3:0.05]

hole_d = 10.0; //[5.0:20.0:0.05]
step_d = 16.0; //[8.0:32.0:0.05]
step_h_top = 0.5; //[0.25:1.5:0.05]
step_h_bot = 0.5; //[0.25:1.5:0.05]

overlap = 0.2; //[0.05:1.0:0.05]
eps = 0.2; //[0.05:0.5:0.05]
$fn = 96;

// Regular hex sized by flat-to-flat distance (across flats)
module hex2d(flat_to_flat) {
    // For a regular hex, flat-to-flat = sqrt(3) * R (circumradius)
    R = flat_to_flat / sqrt(3);
    polygon(points=[for (i=[0:5]) [R*cos(60*i), R*sin(60*i)]]);
}

module hex_plate() {
    difference() {
        union() {
            // Base hex prism (use the larger flat-to-flat to match bbox_L)
            linear_extrude(height=H, center=true)
                hex2d(hex_flat_to_flat_major);

            // Shallow boss/recess-like steps (kept connected with overlap)
            translate([0, 0,  H/2 - step_h_top/2 - overlap/2])
                cylinder(d=step_d, h=step_h_top + overlap, center=true);

            translate([0, 0, -H/2 + step_h_bot/2 + overlap/2])
                cylinder(d=step_d, h=step_h_bot + overlap, center=true);
        }

        // Center through-hole (ensure it fully cuts through all features)
        cylinder(d=hole_d, h=H + step_h_top + step_h_bot + 4*eps, center=true);
    }
}

hex_plate();