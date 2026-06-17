$fn = 128;

// HT pipe parameters (HT 125, length 150 mm)
outer_d = 125;      // mm (spigot OD)
length  = 150;      // mm (overall length)
wall    = 3.2;      // mm

// Simple HT-style socket/bell end (typical visual feature)
socket_len = 45;    // mm
socket_wall_extra = 2.0; // mm added wall thickness at socket (visual)
lead_in = 2.0;      // mm small chamfer/lead-in at socket mouth

inner_d = outer_d - 2*wall;

// Derived
outer_r = outer_d/2;
inner_r = inner_d/2;

socket_outer_d = outer_d + 2*socket_wall_extra;
socket_outer_r = socket_outer_d/2;

// Place pipe axis along X
module x_cyl(h, d, center=true) {
    rotate([0, 90, 0]) cylinder(h=h, d=d, center=center);
}

difference() {
    // ONE connected solid: main pipe + socket (overlapping by overlap_x)
    union() {
        // Main outer body
        x_cyl(h=length, d=outer_d, center=true);

        // Socket/bell outer (connected at +X end)
        // Main spans X: [-length/2, +length/2]
        // Socket spans X: [length/2 - overlap_x, length/2 - overlap_x + socket_len]
        overlap_x = 1.0; // ensures union connectivity
        translate([length/2 - overlap_x + socket_len/2, 0, 0])
            x_cyl(h=socket_len, d=socket_outer_d, center=true);

        // Small lead-in ring at socket mouth (visual chamfer-like)
        // Positioned at the socket far end
        translate([length/2 - overlap_x + socket_len - lead_in/2, 0, 0])
            x_cyl(h=lead_in, d1=socket_outer_d, d2=socket_outer_d - 2*lead_in, center=true);
    }

    // Inner void through entire assembly (open ends)
    // Extend a bit to guarantee clean openings
    x_cyl(h=length + socket_len + 0.4, d=inner_d, center=true);

    // Slightly larger inner at socket region to suggest socket clearance
    // (still one connected solid; this is a subtraction)
    socket_clearance = 0.8; // mm radial clearance (visual)
    translate([length/2 - 1.0 + socket_len/2, 0, 0])
        x_cyl(h=socket_len + 0.4, d=inner_d + 2*socket_clearance, center=true);
}