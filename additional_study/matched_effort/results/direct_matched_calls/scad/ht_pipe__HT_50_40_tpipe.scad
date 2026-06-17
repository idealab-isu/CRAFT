$fn = 128;

// HT 50/40 T pipe (approximation)
// Main run: DN50 (OD 50mm), branch: DN40 (OD 40mm)
// Typical HT wall thickness ~1.8mm (approx), socketed ends with slight flare.

module ht_socket(od=50, wall=1.8, socket_len=35, flare=2.0, flare_len=10, chamfer=1.0) {
    // Outer socket with slight flare at the mouth; inner bore expanded accordingly.
    difference() {
        union() {
            // main socket body
            cylinder(h=socket_len, d=od + 2*flare);
            // flare taper at mouth
            translate([0,0,socket_len - flare_len])
                cylinder(h=flare_len, d1=od + 2*flare, d2=od + 2*flare + 2.0);
        }
        // inner bore
        translate([0,0,-0.1])
            cylinder(h=socket_len + 0.2, d=od - 2*wall + 2*flare);
        // mouth chamfer (approx)
        translate([0,0,socket_len - chamfer])
            cylinder(h=chamfer + 0.2, d1=od - 2*wall + 2*flare, d2=od - 2*wall + 2*flare + 2.0);
    }
}

module ht_pipe_section(od=50, wall=1.8, len=100) {
    difference() {
        cylinder(h=len, d=od);
        translate([0,0,-0.1]) cylinder(h=len+0.2, d=od - 2*wall);
    }
}

module ht_tee_50_40(
    od_main=50,
    od_branch=40,
    wall=1.8,
    run_len=140,          // overall run length excluding sockets
    branch_len=90,        // branch length excluding socket
    socket_len_main=35,
    socket_len_branch=30,
    body_extra=18         // thickened center region length along run
) {
    // Build as union of hollow solids, then clean internal intersections by subtracting bores.
    difference() {
        union() {
            // Main run outer
            translate([0,0,-run_len/2])
                cylinder(h=run_len, d=od_main);

            // Thickened center collar on run (typical tee bulge)
            translate([0,0,-body_extra/2])
                cylinder(h=body_extra, d=od_main + 6);

            // Branch outer (perpendicular)
            rotate([0,90,0])
                translate([0,0,-branch_len/2])
                    cylinder(h=branch_len, d=od_branch);

            // Branch collar
            rotate([0,90,0])
                translate([0,0,-body_extra/2])
                    cylinder(h=body_extra, d=od_branch + 6);

            // Sockets on main ends
            translate([0,0, run_len/2])
                ht_socket(od=od_main, wall=wall, socket_len=socket_len_main, flare=2.0, flare_len=10, chamfer=1.0);

            translate([0,0,-run_len/2 - socket_len_main])
                ht_socket(od=od_main, wall=wall, socket_len=socket_len_main, flare=2.0, flare_len=10, chamfer=1.0);

            // Socket on branch end
            rotate([0,90,0])
                translate([0,0, branch_len/2])
                    ht_socket(od=od_branch, wall=wall, socket_len=socket_len_branch, flare=2.0, flare_len=10, chamfer=1.0);
        }

        // Subtract main bore through entire run + sockets
        translate([0,0,-(run_len/2 + socket_len_main) - 1])
            cylinder(h=run_len + 2*socket_len_main + 2, d=od_main - 2*wall);

        // Subtract branch bore through entire branch + socket
        rotate([0,90,0])
            translate([0,0,-(branch_len/2 + socket_len_branch) - 1])
                cylinder(h=branch_len + socket_len_branch + 2, d=od_branch - 2*wall);

        // Smooth intersection: remove any internal wall where bores cross (open tee)
        // Use a slightly enlarged cutter at the junction.
        intersection_cutter_d = max(od_branch - 2*wall, od_main - 2*wall) + 2.0;
        translate([0,0,-20])
            cylinder(h=40, d=intersection_cutter_d);
        rotate([0,90,0])
            translate([0,0,-20])
                cylinder(h=40, d=intersection_cutter_d);
    }
}

// Render
ht_tee_50_40();