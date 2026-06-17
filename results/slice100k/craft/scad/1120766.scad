// Symmetric cross-shaped hub (one connected solid)
// Bounding box target: 11.7 x 11.7 x 6.3 mm

$fn = 128; // smooth circular core (avoid faceted/octagonal look)

// Parameters (mm)
bbox_x = 11.68;
bbox_y = 11.68;
bbox_z = 6.35;

core_d = 7.0;
core_h = bbox_z;

lug_len_radial = (bbox_x - core_d) / 2;   // ensures overall width matches bbox
lug_w_tangential = 3.0;
lug_h = bbox_z;

overlap = 0.6; // overlap into core to guarantee connectivity

module hub() {
    union() {
        // Core cylinder
        cylinder(r = core_d/2, h = core_h, center = true);

        // Four radial lugs at 0/90/180/270 degrees
        for (a = [0:90:270]) {
            rotate([0, 0, a])
                translate([core_d/2 + lug_len_radial/2 - overlap, 0, 0])
                    cube([lug_len_radial + 2*overlap, lug_w_tangential, lug_h], center = true);
        }
    }
}

hub();