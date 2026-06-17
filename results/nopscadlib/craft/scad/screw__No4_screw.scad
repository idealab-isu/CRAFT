// Pan head screw: 3.0mm shaft diameter, 5.5mm head diameter, 2.0mm head height, 10mm overall length
// Single connected solid (no extra parts)

$fn = 96;

shaft_diameter = 3.0;
head_diameter  = 5.5;
head_height    = 2.0;
overall_length = 10.0;

eps = 0.02;

// Simple pan head profile (cylindrical head with a slight dome)
module pan_head_screw(d_shaft=3, d_head=5.5, h_head=2, L=10) {
    shaft_len = L - h_head;

    union() {
        // Shaft (under-head to tip)
        translate([0, 0, -shaft_len])
            cylinder(h=shaft_len + eps, d=d_shaft);

        // Head base cylinder (full head height)
        cylinder(h=h_head, d=d_head);

        // Slight dome on top of head (kept within head height)
        // Dome height is a fraction of head height; overlaps into head for watertight union.
        dome_h = min(0.6, h_head * 0.35);
        translate([0, 0, h_head - dome_h])
            intersection() {
                // Sphere creates dome; intersection keeps it from bulging below the dome start plane
                sphere(d=d_head);
                translate([0, 0, 0])
                    cylinder(h=dome_h + eps, d=d_head);
            }
    }
}

pan_head_screw(shaft_diameter, head_diameter, head_height, overall_length);