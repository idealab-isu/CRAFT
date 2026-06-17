$fn = 128;

// HT 50/40 T pipe (approximate, single connected solid)
// Main run: DN50 (OD 50mm), branch: DN40 (OD 40mm)
// Socketed ends with stop ring + internal gasket seat + reducer step on branch.

module socket_ht(od=50, id=46, depth=35,
                 taper=1.0,
                 stop_th=2.5, stop_len=6,
                 seat_len=8, seat_step=1.2, leadin=2.0) {

    // Outer: tapered socket + outer stop ring bulge
    // Inner: bore + gasket seat (slightly smaller ID near mouth) + lead-in chamfer
    difference() {
        union() {
            cylinder(h=depth, r1=od/2 + taper, r2=od/2);
            translate([0,0,depth-stop_len])
                cylinder(h=stop_len, r=od/2 + taper + stop_th);
        }

        union() {
            // Main inner bore
            translate([0,0,-0.1])
                cylinder(h=depth+0.2, r1=id/2 + taper*0.6, r2=id/2);

            // Gasket seat: slightly reduced ID near mouth
            translate([0,0,depth-seat_len])
                cylinder(h=seat_len+0.2, r=id/2 - seat_step);

            // Lead-in chamfer at mouth (helps look like molded socket)
            translate([0,0,depth-leadin])
                cylinder(h=leadin+0.2, r1=id/2 + 0.6, r2=id/2 - seat_step);
        }
    }
}

module pipe_segment(od=50, id=46, len=60) {
    difference() {
        cylinder(h=len, r=od/2);
        translate([0,0,-0.1]) cylinder(h=len+0.2, r=id/2);
    }
}

module tee_ht_50_40(
    run_od=50, run_id=46,
    branch_od=40, branch_id=36,

    run_socket_depth=35,
    branch_socket_depth=30,

    run_mid_len=40,
    branch_mid_len=35,

    // Intersection shaping
    fillet_r=6,
    overlap=1.0,

    // Branch reducer/step (HT 50/40 feature)
    reducer_len=10,
    reducer_id=34,          // smaller ID section inside branch socket
    reducer_step=1.0        // additional seat step
) {
    // Coordinate system:
    // Run axis = Z, centered around Z=0 for mid segment.
    // Branch axis = +X, centered at Y=0, Z=0.

    run_total_len = 2*run_socket_depth + run_mid_len;
    run_z0 = -(run_socket_depth + run_mid_len/2); // start of left socket
    run_z1 =  (run_mid_len/2 + run_socket_depth); // end of right socket

    // Place branch so its socket overlaps into run body (no floating)
    // Branch socket starts slightly inside run OD to guarantee union connectivity.
    branch_x0 = run_od/2 - fillet_r - overlap; // start of branch socket (at run wall, with overlap)
    branch_total_len = branch_socket_depth + branch_mid_len;
    branch_x1 = branch_x0 + branch_total_len;

    difference() {
        // OUTER SOLID (single connected union)
        union() {
            // Run: left socket + mid + right socket (all connected)
            translate([0,0,run_z0])
                socket_ht(od=run_od, id=run_id, depth=run_socket_depth,
                          taper=1.0, stop_th=2.5, stop_len=6,
                          seat_len=8, seat_step=1.2, leadin=2.0);

            translate([0,0,-run_mid_len/2])
                pipe_segment(od=run_od, id=run_id, len=run_mid_len);

            translate([0,0,run_mid_len/2])
                socket_ht(od=run_od, id=run_id, depth=run_socket_depth,
                          taper=1.0, stop_th=2.5, stop_len=6,
                          seat_len=8, seat_step=1.2, leadin=2.0);

            // Branch: socket + mid (connected to run via overlap and blended boss)
            translate([branch_x0,0,0])
                rotate([0,90,0])
                    socket_ht(od=branch_od, id=branch_id, depth=branch_socket_depth,
                              taper=1.0, stop_th=2.2, stop_len=5,
                              seat_len=7, seat_step=1.0, leadin=2.0);

            translate([branch_x0 + branch_socket_depth - overlap,0,0])
                rotate([0,90,0])
                    pipe_segment(od=branch_od, id=branch_id, len=branch_mid_len + overlap);

            // Molded junction boss (ensures closed/finished intersection externally)
            // Use hull between two cylinders to create a smooth, connected lump.
            hull() {
                // Around run
                translate([0,0,0])
                    rotate([90,0,0])
                        cylinder(h=run_od*0.55, r=run_od/2 + 2.0, center=true);

                // Around branch
                translate([run_od/2 - fillet_r,0,0])
                    rotate([0,90,0])
                        cylinder(h=branch_od*0.55, r=branch_od/2 + 2.0, center=true);
            }
        }

        // INNER VOID (bores) - union of bores, with controlled intersection (no open cutaway)
        union() {
            // Run bore through entire run length
            translate([0,0,run_z0 - 1])
                cylinder(h=run_total_len + 2, r=run_id/2);

            // Branch bore through branch length
            translate([branch_x0 - 1,0,0])
                rotate([0,90,0])
                    cylinder(h=branch_total_len + 2, r=branch_id/2);

            // Branch reducer step inside socket (HT 50/40 feature)
            // A shorter, smaller-ID section near the socket mouth.
            translate([branch_x0 + branch_socket_depth - reducer_len,0,0])
                rotate([0,90,0])
                    cylinder(h=reducer_len + 0.2, r=reducer_id/2);

            // Reducer seat step (slightly smaller) at very end of reducer section
            translate([branch_x0 + branch_socket_depth - min(4, reducer_len),0,0])
                rotate([0,90,0])
                    cylinder(h=min(4, reducer_len) + 0.2, r=reducer_id/2 - reducer_step);

            // Smooth internal junction blend (prevents thin internal web, but keeps closed walls)
            // Use hull of two spheres to create a rounded internal intersection.
            hull() {
                translate([run_od/2 - fillet_r,0,0])
                    sphere(r=max(run_id, branch_id)/2 + 0.8);
                translate([run_od/2 - fillet_r - 6,0,0])
                    sphere(r=max(run_id, branch_id)/2 + 0.8);
            }
        }
    }
}

// Render
tee_ht_50_40();