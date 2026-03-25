// Ball bearing: 3.0mm bore, 9.0mm OD, 4.0mm width
// One connected solid, with visible balls and race grooves.

$fn = 128;

// Parameters
bore_diameter_mm  = 3.0;
outer_diameter_mm = 9.0;
width_mm          = 4.0;

ball_diameter_mm  = 1.2;
ball_count        = 8;

// Geometry tuning (kept small so OD/ID stay correct)
race_radial_thickness_mm = 1.0;   // ring thickness for inner/outer races
race_groove_depth_mm     = 0.35;  // how deep the groove cuts into each race
race_groove_radius_mm    = ball_diameter_mm/2 + 0.10; // groove "tube" radius

shield_thickness_mm      = 0.30;
shield_radial_overlap_mm = 0.20;

connection_overlap_mm    = 0.20;  // small overlap to guarantee manifold union

// Derived
bore_r  = bore_diameter_mm/2;
outer_r = outer_diameter_mm/2;

inner_race_or = bore_r + race_radial_thickness_mm;
outer_race_ir = outer_r - race_radial_thickness_mm;

// Ball path radius (between races)
ball_path_r = (inner_race_or + outer_race_ir)/2;

// Keep balls inside width
ball_z_clear = width_mm/2 - shield_thickness_mm - ball_diameter_mm/2 - 0.05;
ball_z = 0; // centered

// Helpers
module ring(r_out, r_in, h) {
    difference() {
        cylinder(r=r_out, h=h, center=true);
        cylinder(r=r_in,  h=h + 2*connection_overlap_mm, center=true);
    }
}

// Groove cutter: torus-like cut made by rotate_extrude of a circle
module race_groove_cutter(path_r, tube_r) {
    rotate_extrude(convexity=10)
        translate([path_r, 0, 0])
            circle(r=tube_r);
}

module ball_bearing() {
    union() {
        // OUTER RACE with groove
        difference() {
            ring(outer_r, outer_race_ir, width_mm);
            // Cut groove into inner face of outer race
            // Place cutter so it intersects the race volume
            race_groove_cutter(ball_path_r, race_groove_radius_mm);
        }

        // INNER RACE with groove
        difference() {
            ring(inner_race_or, bore_r, width_mm);
            // Cut groove into outer face of inner race
            race_groove_cutter(ball_path_r, race_groove_radius_mm);
        }

        // SHIELDS (thin rings) - overlap slightly into races so everything is connected
        for (side = [-1, 1]) {
            translate([0, 0, side*(width_mm/2 - shield_thickness_mm/2)])
                ring(
                    outer_r - race_radial_thickness_mm + shield_radial_overlap_mm,
                    bore_r  + race_radial_thickness_mm - shield_radial_overlap_mm,
                    shield_thickness_mm + 2*connection_overlap_mm
                );
        }

        // BALLS (unioned into the solid so the result is one connected solid)
        // Slightly enlarge balls to ensure contact/connection with grooves.
        for (i = [0:ball_count-1]) {
            rotate([0, 0, i*360/ball_count])
                translate([ball_path_r, 0, ball_z])
                    sphere(r=ball_diameter_mm/2 + 0.05);
        }
    }
}

ball_bearing();