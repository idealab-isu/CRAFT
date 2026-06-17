// 15mm x 15mm aluminium extrusion profile, 100mm long (single connected solid)

$fn = 64;

size = 15.0;
len  = 100.0;

// Profile feature sizes (kept modest and fully connected)
slot_w = 3.0;     // T-slot opening width
slot_d = 3.0;     // T-slot depth from each face
bore_r = 2.0;     // center bore radius

module extrusion_15x15(L=len) {
    difference() {
        // Main solid
        cube([size, size, L], center=false);

        // Center bore (through)
        translate([size/2, size/2, -0.1])
            cylinder(h=L + 0.2, r=bore_r, center=false);

        // Four shallow face slots (through along length)
        // Left face
        translate([-0.1, size/2 - slot_w/2, -0.1])
            cube([slot_d + 0.1, slot_w, L + 0.2], center=false);

        // Right face
        translate([size - slot_d, size/2 - slot_w/2, -0.1])
            cube([slot_d + 0.1, slot_w, L + 0.2], center=false);

        // Bottom face
        translate([size/2 - slot_w/2, -0.1, -0.1])
            cube([slot_w, slot_d + 0.1, L + 0.2], center=false);

        // Top face
        translate([size/2 - slot_w/2, size - slot_d, -0.1])
            cube([slot_w, slot_d + 0.1, L + 0.2], center=false);
    }
}

extrusion_15x15();