// Parameters (A radial: [2.0, 0, 6])
radial_radius    = 2.0;  //[1:4:0.1]
radial_angle_deg = 0;    //[-180:180:1]
radial_height    = 6;    //[3:12:0.5]

// Quality
$fn = 64;

// Small overlap to guarantee a single connected solid
overlap = 0.2;

// A simple "radial" feature: a hub with one outward protruding arm,
// oriented by radial_angle_deg. All dimensions derived from parameters.
module radial_feature(r, ang, h) {
    hub_r   = r;
    hub_h   = h;

    arm_len = 2*r;          // protrudes outward by ~2 radii
    arm_w   = r;            // arm thickness
    arm_h   = h;

    union() {
        // Hub
        cylinder(r=hub_r, h=hub_h, center=true);

        // Radial arm (connected to hub with overlap)
        rotate([0, 0, ang])
            translate([hub_r + arm_len/2 - overlap, 0, 0])
                cube([arm_len, arm_w, arm_h], center=true);
    }
}

radial_feature(radial_radius, radial_angle_deg, radial_height);