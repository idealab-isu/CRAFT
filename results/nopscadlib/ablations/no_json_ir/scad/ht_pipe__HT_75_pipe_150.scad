// HT 75 pipe 150 mm
// Units: mm
// One connected solid (hollow tube with two connected end collars)

$fn = 180;

outer_diameter  = 75;
wall_thickness  = 3.2;
length          = 150;

// End collars (simple socket-like rings)
collar_radial   = 2.5;   // added to outer radius
collar_height   = 10;    // axial height

// Robust boolean overlap
eps = 0.2;

outer_r = outer_diameter/2;
inner_r = outer_r - wall_thickness;

module ht_pipe() {
    difference() {
        // Outer shell (main tube + collars), all connected with calculated overlaps
        union() {
            // Main outer cylinder
            cylinder(h=length, r=outer_r, center=false);

            // Bottom collar: overlaps into main by eps
            translate([0, 0, -collar_height + eps])
                cylinder(h=collar_height, r=outer_r + collar_radial, center=false);

            // Top collar: overlaps into main by eps
            translate([0, 0, length - eps])
                cylinder(h=collar_height, r=outer_r + collar_radial, center=false);
        }

        // Inner void: through-hole extended beyond both collars for clean subtraction
        translate([0, 0, -collar_height - eps])
            cylinder(h=length + 2*collar_height + 2*eps, r=inner_r, center=false);
    }
}

ht_pipe();