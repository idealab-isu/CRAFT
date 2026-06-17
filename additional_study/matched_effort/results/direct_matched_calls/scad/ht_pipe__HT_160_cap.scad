$fn = 180;

// HT 160 cap (approximation)
// Dimensions in mm
d_nom = 160;          // nominal pipe OD
wall = 4.5;           // typical wall thickness (approx)
cap_depth = 55;       // overall cap depth
socket_depth = 45;    // insertion depth
clearance = 0.6;      // radial clearance for fit
lip_thickness = 6;    // end face thickness
outer_rib_h = 2.0;    // small outer rib height
outer_rib_w = 6.0;    // small outer rib width

od = d_nom + 2*wall;                 // cap outer diameter (approx)
id_socket = d_nom + 2*clearance;     // socket inner diameter
id_cavity = id_socket;               // same cavity diameter
top_thickness = lip_thickness;       // closed end thickness

module ht160_cap() {
    difference() {
        union() {
            // Main outer body
            cylinder(h=cap_depth, d=od);

            // Outer rib near open end
            translate([0,0,2])
                cylinder(h=outer_rib_w, d=od + 2*outer_rib_h);

            // Slight chamfer ring at open end (outer)
            translate([0,0,0])
                cylinder(h=2, d1=od + 1.5, d2=od);
        }

        // Inner cavity (socket)
        translate([0,0,0])
            cylinder(h=socket_depth, d=id_socket);

        // Inner cavity continuation (keeps wall consistent up to near top)
        translate([0,0,socket_depth])
            cylinder(h=cap_depth - top_thickness - socket_depth, d=id_cavity);

        // Inner top relief to avoid sharp internal corner
        translate([0,0,cap_depth - top_thickness - 2])
            cylinder(h=2, d1=id_cavity, d2=id_cavity - 2);

        // Inner chamfer at mouth
        translate([0,0,0])
            cylinder(h=3, d1=id_socket + 3, d2=id_socket);
    }
}

ht160_cap();