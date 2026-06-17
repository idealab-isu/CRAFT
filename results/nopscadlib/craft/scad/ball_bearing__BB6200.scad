// Ball bearing: 10mm bore, 30mm OD, 9mm width
// STRUCTURAL FIX: ensure balls are NOT floating by adding small "bridges" that
// physically fuse each ball to BOTH inner and outer races with 1-2mm overlap.
// Everything is combined in a single union() solid.

$fn = 128;

// Target dimensions
bore_diameter_mm  = 10.0;
outer_diameter_mm = 30.0;
width_mm          = 9.0;

// Detailing parameters
ball_diameter_mm = 4.0;
num_balls        = 10;

outer_ring_radial_thickness_mm = 3.0;
inner_ring_radial_thickness_mm = 3.0;

cage_thickness_mm = 1.2;   // axial thickness of cage band
cage_radial_mm    = 1.0;   // radial thickness of cage band

// Connectivity requirements: 1-2mm overlap
overlap_mm = 1.2;          // guaranteed overlap for connections
eps_mm     = 0.02;

// Bridge geometry (fuses balls to races)
bridge_axial_h_mm = 2.0;   // axial height of bridge "tabs" (kept within bearing width)
bridge_tangential_w_mm = 2.2; // tangential width of bridge tabs (small, but robust)

module bearing_connected() {
    // Radii
    r_bore = bore_diameter_mm/2;
    r_od   = outer_diameter_mm/2;

    // Ring boundaries
    r_outer_inner = r_od - outer_ring_radial_thickness_mm;   // inner radius of outer ring
    r_inner_outer = r_bore + inner_ring_radial_thickness_mm; // outer radius of inner ring

    // Ball path radius (center of balls)
    r_ball_path = (r_outer_inner + r_inner_outer)/2;

    // Ball radius
    r_ball = ball_diameter_mm/2;

    // Cage band radii (nominal)
    r_cage_outer = r_ball_path + cage_radial_mm/2;
    r_cage_inner = r_ball_path - cage_radial_mm/2;

    // Force cage to overlap into both races by overlap_mm
    r_cage_outer_conn = min(r_outer_inner + overlap_mm, r_cage_outer + overlap_mm);
    r_cage_inner_conn = max(r_inner_outer - overlap_mm, r_cage_inner - overlap_mm);

    // Bridge radial extents:
    // - Must intersect the ball by overlap_mm
    // - Must intersect the race by overlap_mm
    // Inner-side bridge: from inner ring outward into ball
    r_bridge_inner_min = r_inner_outer - overlap_mm;
    r_bridge_inner_max = r_ball_path - (r_ball - overlap_mm);

    // Outer-side bridge: from ball outward into outer ring
    r_bridge_outer_min = r_ball_path + (r_ball - overlap_mm);
    r_bridge_outer_max = r_outer_inner + overlap_mm;

    // Clamp to valid radii (avoid negative/invalid)
    r_bridge_inner_min_c = max(r_bore + eps_mm, r_bridge_inner_min);
    r_bridge_inner_max_c = min(r_outer_inner - eps_mm, r_bridge_inner_max);

    r_bridge_outer_min_c = max(r_inner_outer + eps_mm, r_bridge_outer_min);
    r_bridge_outer_max_c = min(r_od - eps_mm, r_bridge_outer_max);

    union() {
        // Outer ring (OD fixed at 30mm)
        difference() {
            cylinder(r=r_od, h=width_mm, center=true);
            cylinder(r=r_outer_inner, h=width_mm + 2*eps_mm, center=true);
        }

        // Inner ring (bore fixed at 10mm)
        difference() {
            cylinder(r=r_inner_outer, h=width_mm, center=true);
            cylinder(r=r_bore, h=width_mm + 2*eps_mm, center=true);
        }

        // Balls + bridges (bridges guarantee physical attachment to races)
        for (i = [0:num_balls-1]) {
            rotate([0, 0, i*360/num_balls]) {
                // Ball
                translate([r_ball_path, 0, 0])
                    sphere(r=r_ball);

                // Inner bridge tab (fuses ball to inner ring)
                // Positioned at the ball angle; radial span overlaps both ball and inner ring.
                if (r_bridge_inner_max_c > r_bridge_inner_min_c + eps_mm) {
                    translate([(r_bridge_inner_min_c + r_bridge_inner_max_c)/2, 0, 0])
                        cube([ (r_bridge_inner_max_c - r_bridge_inner_min_c),
                               bridge_tangential_w_mm,
                               bridge_axial_h_mm ],
                             center=true);
                }

                // Outer bridge tab (fuses ball to outer ring)
                if (r_bridge_outer_max_c > r_bridge_outer_min_c + eps_mm) {
                    translate([(r_bridge_outer_min_c + r_bridge_outer_max_c)/2, 0, 0])
                        cube([ (r_bridge_outer_max_c - r_bridge_outer_min_c),
                               bridge_tangential_w_mm,
                               bridge_axial_h_mm ],
                             center=true);
                }
            }
        }

        // Cage band with pockets (kept, and overlaps races slightly)
        difference() {
            // Cage band (solid)
            difference() {
                cylinder(r=r_cage_outer_conn, h=cage_thickness_mm, center=true);
                cylinder(r=r_cage_inner_conn, h=cage_thickness_mm + 2*eps_mm, center=true);
            }

            // Ball pockets (cutouts) - slightly larger than balls
            for (i = [0:num_balls-1]) {
                rotate([0, 0, i*360/num_balls])
                    translate([r_ball_path, 0, 0])
                        sphere(r=r_ball + 0.35);
            }
        }
    }
}

bearing_connected();