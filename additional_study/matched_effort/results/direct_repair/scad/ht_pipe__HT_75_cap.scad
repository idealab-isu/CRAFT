$fn=128;

// HT 75 cap (approximate dimensions)
// Nominal: DN75 (OD ~75mm). Cap with socket and internal stop.
// Units: mm

// -------- Parameters --------
od_pipe = 75;          // outer diameter of pipe
wall   = 2.7;          // typical HT wall thickness
id_pipe = od_pipe - 2*wall;

socket_depth = 45;     // insertion depth
cap_top_thk  = 6;      // thickness of closed end
outer_lip    = 3;      // extra outer thickness for cap body
inner_clear  = 0.6;    // clearance for pipe insertion

// Derived
od_cap = od_pipe + 2*outer_lip;     // outer diameter of cap body
id_socket = od_pipe + 2*inner_clear; // inner diameter of socket (fits over pipe)
h_total = socket_depth + cap_top_thk;

// Internal stop ring (prevents pipe from going too far)
stop_thk = 3.0;
stop_height = 3.0;
stop_z = socket_depth - stop_height; // located near bottom of socket
stop_id = id_socket - 2*stop_thk;    // smaller opening at stop

// Small outer chamfer at mouth
mouth_chamfer_h = 2.0;
mouth_chamfer_w = 1.5;

// -------- Model --------
module ht75_cap() {
    difference() {
        // Outer body
        union() {
            cylinder(h=h_total, d=od_cap);

            // Outer mouth chamfer (add material then subtract to shape via difference below)
            // We'll shape by subtracting a cone from the outside edge.
        }

        // Hollow socket cavity
        translate([0,0,cap_top_thk])
            cylinder(h=socket_depth + 0.2, d=id_socket);

        // Create internal stop: reduce diameter for last few mm
        translate([0,0,cap_top_thk + stop_z])
            cylinder(h=stop_height + 0.2, d=stop_id);

        // Outer mouth chamfer subtraction
        translate([0,0,h_total - mouth_chamfer_h])
            difference() {
                // subtract a frustum from the outer rim
                cylinder(h=mouth_chamfer_h + 0.2, d1=od_cap + 2*mouth_chamfer_w, d2=od_cap);
                // keep only the part that intersects the cap (by subtracting nothing else)
            }

        // Slight inner lead-in chamfer for easier insertion
        translate([0,0,cap_top_thk + socket_depth - 3])
            cylinder(h=3.2, d1=id_socket + 2.0, d2=id_socket);
    }
}

ht75_cap();