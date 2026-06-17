// Parameters
radius = 2.0; //[1:4:0.1]
angle_deg = 0; //[-180:180:1]
height = 6; //[3:12:0.5]

// Radial settings (6-fold)
num_radial = 6;

// Detail
$fn = 96;

// Geometry
module radial_component(r=radius, h=height, n=num_radial) {
    hub_r = r;
    hub_h = h;

    // Arms: ensure clear 6-fold symmetry and solid connectivity
    arm_len  = r * 1.10;                 // protrusion beyond hub
    arm_w    = max(0.35, r * 0.35);      // arm thickness
    overlap  = min(0.30, r * 0.20);      // overlap into hub for guaranteed union

    union() {
        // Hub
        cylinder(h=hub_h, r=hub_r, center=true);

        // 6 radial arms (consistent in all orthographic views)
        for (i = [0:n-1]) {
            rotate([0, 0, i * 360 / n + angle_deg])
                translate([hub_r + arm_len/2 - overlap, 0, 0])
                    cube([arm_len, arm_w, hub_h], center=true);
        }
    }
}

// Build (angle applied inside to avoid double-rotation ambiguity)
radial_component();