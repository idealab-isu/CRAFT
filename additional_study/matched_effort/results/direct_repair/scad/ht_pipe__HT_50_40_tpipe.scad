$fn = 128;

// HT 50/40 T pipe (approximate dimensions, renderable)
// Main run: DN50 (OD 50mm), branch: DN40 (OD 40mm)
// Socketed ends typical for HT (push-fit) with slight taper and stop
// Units: mm

// ---------- Parameters ----------
od_main = 50;
od_branch = 40;

wall_main = 1.8;
wall_branch = 1.8;

id_main = od_main - 2*wall_main;
id_branch = od_branch - 2*wall_branch;

run_socket_len = 35;
branch_socket_len = 35;

run_center_len = 60;          // straight section between sockets (center body length)
branch_center_len = 45;       // branch protrusion from main OD to branch socket start

socket_wall_extra = 1.2;      // socket thickening
socket_taper = 0.6;           // OD taper over socket length
socket_stop_thickness = 2.0;  // internal stop ring thickness
socket_stop_depth = 6.0;      // how far from socket mouth the stop sits

fillet_r = 6;                 // outer blend radius at junction (approx)

// ---------- Helpers ----------
module tube(od, id, h, center=false) {
    difference() {
        cylinder(h=h, d=od, center=center);
        cylinder(h=h+0.2, d=id, center=center);
    }
}

module socket_end(od, id, len, wall_extra=1.2, taper=0.6, stop_th=2.0, stop_depth=6.0) {
    // Outer socket: slightly larger OD and slight taper
    // Inner: same ID as pipe, plus internal stop ring
    difference() {
        // outer
        cylinder(h=len, d1=od + 2*wall_extra + taper, d2=od + 2*wall_extra);
        // inner bore
        translate([0,0,-0.1]) cylinder(h=len+0.2, d=id);
        // stop ring: reduce bore locally by stop_th*2
        translate([0,0,stop_depth])
            cylinder(h=stop_th, d=id - 2*stop_th);
    }
}

module rounded_union() {
    // Minkowski-based rounding for junction only (kept small for performance)
    // Use hull of two cylinders then minkowski with sphere
    minkowski() {
        children();
        sphere(r=fillet_r);
    }
}

// ---------- Model ----------
module ht_t_pipe() {
    // Build solid outer shape then subtract inner bores
    difference() {
        union() {
            // Main run outer: center body + two sockets
            // Center body
            translate([0,0,0])
                cylinder(h=run_center_len, d=od_main);

            // Left socket (negative Z)
            translate([0,0,-run_socket_len])
                socket_end(od_main, id_main, run_socket_len, socket_wall_extra, socket_taper, socket_stop_thickness, socket_stop_depth);

            // Right socket (positive Z)
            translate([0,0,run_center_len])
                rotate([180,0,0])
                    socket_end(od_main, id_main, run_socket_len, socket_wall_extra, socket_taper, socket_stop_thickness, socket_stop_depth);

            // Branch outer: blend + branch socket
            // Branch center tube (from main OD outward)
            translate([0,0,run_center_len/2])
                rotate([0,90,0]) {
                    // short stub from intersection to socket
                    cylinder(h=branch_center_len, d=od_branch);
                    // branch socket at end
                    translate([0,0,branch_center_len])
                        rotate([180,0,0])
                            socket_end(od_branch, id_branch, branch_socket_len, socket_wall_extra, socket_taper, socket_stop_thickness, socket_stop_depth);
                }

            // Junction rounding blob (approx)
            // Create a local hull between main and branch then minkowski for fillet
            translate([0,0,run_center_len/2]) {
                // Keep rounding localized by intersecting with a box
                intersection() {
                    rounded_union() {
                        hull() {
                            // main local segment
                            translate([0,0,-10]) cylinder(h=20, d=od_main);
                            // branch local segment
                            rotate([0,90,0]) translate([0,0,0]) cylinder(h=20, d=od_branch);
                        }
                    }
                    // limit rounding extent
                    translate([-40,-40,-40]) cube([80,80,80]);
                }
            }
        }

        // Inner bores subtraction
        union() {
            // Main bore through entire run including sockets
            translate([0,0,-run_socket_len-1])
                cylinder(h=run_socket_len*2 + run_center_len + 2, d=id_main);

            // Branch bore through branch including socket
            translate([0,0,run_center_len/2])
                rotate([0,90,0])
                    translate([0,0,-1])
                        cylinder(h=branch_center_len + branch_socket_len + 2, d=id_branch);

            // Carve intersection to ensure smooth internal junction
            translate([0,0,run_center_len/2]) {
                // enlarge slightly to avoid thin artifacts
                hull() {
                    translate([0,0,-8]) cylinder(h=16, d=id_main);
                    rotate([0,90,0]) cylinder(h=16, d=id_branch);
                }
            }
        }
    }
}

ht_t_pipe();