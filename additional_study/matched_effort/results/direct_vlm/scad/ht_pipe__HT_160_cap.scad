$fn=180;

// HT 160 end cap (approximation)
// Dimensions in mm
D_nom = 160;          // nominal pipe OD
wall = 4.0;           // cap wall thickness
cap_depth = 55;       // overall cap height
socket_depth = 45;    // insertion depth
clearance = 0.6;      // radial clearance for pipe insertion
lip = 3.0;            // small outer lip height
lip_overhang = 2.0;   // outer lip radial overhang

// Derived
OD = D_nom;
ID_socket = OD + 2*clearance;     // inner diameter of socket
OD_cap = OD + 2*wall;             // outer diameter of cap body
OD_lip = OD_cap + 2*lip_overhang; // outer diameter of lip

module ht160_cap() {
    difference() {
        union() {
            // Main outer body
            cylinder(h=cap_depth, d=OD_cap);

            // Outer lip at open end
            translate([0,0,cap_depth - lip])
                cylinder(h=lip, d=OD_lip);
        }

        // Hollow socket from open end
        translate([0,0,cap_depth - socket_depth])
            cylinder(h=socket_depth + 0.2, d=ID_socket);

        // Slight internal lead-in chamfer (approximated as a cone)
        chamfer_h = 3.0;
        translate([0,0,cap_depth - socket_depth])
            cylinder(h=chamfer_h, d1=ID_socket + 2.0, d2=ID_socket);

        // Ensure closed end thickness
        // (No subtraction beyond socket_depth; bottom remains solid)
    }
}

ht160_cap();