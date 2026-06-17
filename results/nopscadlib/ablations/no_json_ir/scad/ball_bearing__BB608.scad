$fn = 128;

// Ball bearing dimensions (mm) - 608 size
inner_bore      = 8.0;   // bore diameter
outer_diameter  = 22.0;  // outer diameter
width           = 7.0;   // total width

// Visual/detail parameters (simplified but proportionally realistic)
ball_diameter    = 3.5;
ball_count       = 8;
shield_thickness = 0.5;

// Robustness / overlap
eps = 0.05;
overlap_z = 1.2;   // 1–2mm overlap to guarantee axial connections

module ball_bearing_608() {

    inner_r = inner_bore/2;
    outer_r = outer_diameter/2;

    // Axial layout
    race_axial = width - 2*shield_thickness;
    race_axial = max(race_axial, width*0.6);

    // Radial layout
    ring_radial = 2.0;
    ring_radial = min(ring_radial, (outer_r - inner_r)/2 - 0.6);

    // Ball path radius centered between raceways
    ball_path_r = (inner_r + ring_radial) + ball_diameter/2;

    // Outer ring inner radius:
    outer_ring_inner_r = outer_r - ring_radial;

    // Keep balls between rings
    ball_path_r = min(ball_path_r, outer_ring_inner_r - ball_diameter/2 - 0.2);
    ball_path_r = max(ball_path_r, inner_r + ring_radial + ball_diameter/2 + 0.2);

    // Groove radius
    groove_r = ball_diameter*0.48;

    // Connectivity: enlarge balls so they intersect grooves/rings
    embed = 0.18;

    // --- FIX: make the three coaxial "discs" physically connected ---
    // Add a thin outer-rim bridge that overlaps all axial sections.
    // This keeps the overall look but guarantees a single connected solid.
    bridge_r_outer = outer_r;
    bridge_r_inner = outer_r - 0.9;                 // thin rim (keeps appearance)
    bridge_h       = width + 2*overlap_z;           // overlaps shields + races

    difference() {
        union() {

            // OUTER RACE (ring with groove)
            difference() {
                cylinder(r=outer_r, h=race_axial, center=true);
                cylinder(r=outer_ring_inner_r, h=race_axial + 2*eps, center=true);

                rotate_extrude(angle=360)
                    translate([ball_path_r, 0, 0])
                        circle(r=groove_r);
            }

            // INNER RACE (ring with groove)
            difference() {
                cylinder(r=inner_r + ring_radial, h=race_axial, center=true);
                cylinder(r=inner_r, h=race_axial + 2*eps, center=true);

                rotate_extrude(angle=360)
                    translate([ball_path_r, 0, 0])
                        circle(r=groove_r);
            }

            // SHIELDS (thin rings) - ensure they overlap into the race volume
            // Recalculate z positions so each shield intersects the race by overlap_z.
            z_shield_front =  (race_axial/2) + (shield_thickness/2) - overlap_z;
            z_shield_back  = -(race_axial/2) - (shield_thickness/2) + overlap_z;

            for (zpos = [z_shield_front, z_shield_back]) {
                translate([0,0,zpos])
                    difference() {
                        cylinder(r=outer_r, h=shield_thickness + 2*eps, center=true);
                        cylinder(r=inner_r + 1.0, h=shield_thickness + 4*eps, center=true);
                    }
            }

            // AXIAL BRIDGE RIM (connects upper/middle/lower rings into one body)
            // Slightly overlaps everything in Z so there are no gaps.
            difference() {
                cylinder(r=bridge_r_outer, h=bridge_h, center=true);
                cylinder(r=bridge_r_inner, h=bridge_h + 2*eps, center=true);
            }

            // BALLS (embedded so they intersect grooves/rings -> connected manifold)
            for (i = [0:ball_count-1]) {
                rotate([0,0,i*360/ball_count])
                    translate([ball_path_r, 0, 0])
                        sphere(r=ball_diameter/2 + embed);
            }
        }

        // THROUGH-BORE (cut last)
        cylinder(r=inner_r, h=width + 4*eps, center=true);
    }
}

ball_bearing_608();