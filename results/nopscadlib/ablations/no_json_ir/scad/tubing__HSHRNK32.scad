$fn = 96;

// Parameters for the heatshrink sleeving (tube)
inner_diameter = 10;   // ID
wall_thickness = 1;    // wall
length = 50;           // tube length

// Small overlaps to ensure clean boolean results and one connected solid
eps = 0.2;

// Heatshrink sleeving as a hollow tube, oriented along X so side views show length
module heatshrink_sleeve(id, wall, len) {
    od = id + 2*wall;
    rotate([0, 90, 0])  // axis along X
    difference() {
        cylinder(h = len, d = od, center = true);
        cylinder(h = len + 2*eps, d = id, center = true); // extend to guarantee open ends
    }
}

// Optional internal core (e.g., wire/resistor lead) to make a single connected solid
// Kept thin so the tube still reads as hollow in orthographic views.
module inner_core(id, len) {
    core_d = max(0.8, id * 0.18);
    rotate([0, 90, 0])
        cylinder(h = len + 2*eps, d = core_d, center = true);
}

// Assemble as ONE connected solid (core touches inner wall via tiny bridge ribs)
module tubing() {
    id = inner_diameter;
    wall = wall_thickness;
    len = length;

    union() {
        heatshrink_sleeve(id, wall, len);

        // Core
        inner_core(id, len);

        // Two tiny ribs to connect core to sleeve (ensures single connected solid)
        // Positioned at +/- len/4 along tube, spanning from core to inner wall.
        rib_len = id/2 - max(0.8, id*0.18)/2 + eps;
        rib_w   = max(0.6, wall*0.8);
        rib_h   = max(0.6, wall*0.8);

        for (sx = [-1, 1]) {
            translate([sx * len/4, 0, 0])
                cube([rib_w, rib_len, rib_h], center = true);
        }
    }
}

tubing();