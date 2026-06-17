// PTFE Tubing (hollow cylinder) - robust, visible, one connected solid

$fn = 128;

// Parameters
tube_length = 1000; //[500:2000:1]
tube_od = 4;        //[2:8:0.1]
tube_id = 2;        //[1:6:0.1]
chamfer_len = 0.6;  //[0:2:0.1]

// Robustness
eps = 0.05;         // overlap to avoid coplanar artifacts

// Derived
od_r = max(tube_od/2, 0.1);
id_r = min(max(tube_id/2, 0.01), od_r - 0.2); // ensure visible wall thickness
ch   = min(max(chamfer_len, 0), tube_length/2 - 0.1);

// Model
module ptfe_tube() {
    difference() {
        // Outer body with optional end chamfers (single connected solid)
        union() {
            // Main outer cylinder
            cylinder(h = tube_length, r = od_r, center = true);

            // Chamfers are implemented as added frustums that overlap the ends
            if (ch > 0) {
                // Top chamfer (overlaps into main cylinder by eps)
                translate([0, 0, tube_length/2 - ch/2])
                    cylinder(h = ch + 2*eps,
                             r1 = od_r,
                             r2 = max(od_r - ch, 0.01),
                             center = true);

                // Bottom chamfer (overlaps into main cylinder by eps)
                translate([0, 0, -(tube_length/2 - ch/2)])
                    cylinder(h = ch + 2*eps,
                             r1 = max(od_r - ch, 0.01),
                             r2 = od_r,
                             center = true);
            }
        }

        // Inner bore (through hole)
        cylinder(h = tube_length + 4*eps, r = id_r, center = true);
    }
}

color([0.85, 0.85, 0.8]) ptfe_tube();