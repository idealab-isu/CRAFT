$fn = 120;

// 3x8x3 ball bearing (single connected solid representation)
// Structural fixes:
// - Balls are now physically intersecting both races via shallow "race lands" (1mm overlap)
// - Cage is thickened and radially expanded to intersect balls and both rings (1mm overlap)
// - Everything is combined in a single union(), then bore is cut once at the end
module ball_bearing_3x8x3() {

    // Key dimensions
    bore_d  = 3.0;
    od_d    = 8.0;
    width   = 3.0;

    // Parameters
    clearance = 0.05;     // avoid coincident faces
    ring_wall = 1.0;      // outer ring radial thickness
    inner_od  = 5.0;      // inner ring outer diameter
    ball_d    = 1.0;
    n_balls   = 6;

    // Overlap to guarantee connectivity (1-2mm required)
    overlap = 1.0;

    // Derived radii
    od_r      = od_d/2;
    bore_r    = bore_d/2;
    inner_r_o = inner_od/2;

    // Outer ring inner radius (bore of outer ring)
    outer_r_i = od_r - ring_wall;

    // Ball path centered between races
    ball_path_r = (inner_r_o + outer_r_i) / 2;

    // Cage/web (connects rings + balls into one solid)
    cage_th    = 1.6; // thicker so it intersects balls (ball radius = 0.5)
    cage_r_in  = (inner_r_o - overlap); // overlaps inner ring
    cage_r_out = (outer_r_i + overlap); // overlaps outer ring

    // Small "race lands" that intentionally intersect balls and rings (ensures no gaps)
    // These are thin radial ribs at the ball radius, spanning the race gap with overlap.
    land_w = ball_d + 0.2; // tangential width (slightly larger than ball)
    land_h = width;        // full width so it always intersects rings
    land_len = (outer_r_i - inner_r_o) + 2*overlap; // spans gap + overlap into both rings

    difference() {
        union() {

            // Outer ring (race)
            difference() {
                cylinder(d=od_d, h=width, center=true);
                cylinder(d=od_d - 2*ring_wall, h=width + 2*clearance, center=true);
            }

            // Inner ring (race)
            difference() {
                cylinder(d=inner_od, h=width, center=true);
                cylinder(d=bore_d, h=width + 2*clearance, center=true);
            }

            // Balls (now guaranteed to intersect the cage + race lands)
            for (i = [0:n_balls-1]) {
                rotate([0, 0, i*360/n_balls])
                    translate([ball_path_r, 0, 0])
                        sphere(d=ball_d);
            }

            // Cage/web ring (overlaps both rings and intersects balls)
            difference() {
                cylinder(r=cage_r_out, h=cage_th, center=true);
                cylinder(r=cage_r_in,  h=cage_th + 2*clearance, center=true);
            }

            // Race lands: ribs at each ball position that intersect inner ring, ball, and outer ring
            // Positioned so the rib center is at the ball path radius; length spans the race gap.
            for (i = [0:n_balls-1]) {
                rotate([0, 0, i*360/n_balls])
                    translate([ball_path_r, 0, 0])
                        cube([land_len, land_w, land_h], center=true);
            }
        }

        // Ensure the bore is open through everything (including cage/lands)
        cylinder(d=bore_d, h=width + 4*clearance, center=true);
    }
}

ball_bearing_3x8x3();