$fn = 160;

// Target bearing dimensions (mm)
bore_diameter_mm  = 10.0;
outer_diameter_mm = 30.0;
width_mm          = 9.0;

// Visual/detail parameters (kept within target envelope)
ring_radial_thickness_mm = 3.0;   // inner/outer ring wall thickness
radial_clearance_mm      = 0.6;   // gap between rings (ball space)
shield_thickness_mm      = 0.6;   // thin shields
shield_radial_overlap_mm = 0.8;   // shield overlaps into ring faces
ball_diameter_mm         = 4.0;   // visual balls
num_balls                = 9;     // visual
cage_thickness_mm        = 1.2;   // simple cage ring thickness
cage_pocket_clear_mm     = 0.35;  // clearance around balls in cage pockets
overlap_mm               = 0.25;  // small overlap to ensure one connected solid

// Derived radii
r_bore   = bore_diameter_mm/2;
r_outer  = outer_diameter_mm/2;

r_inner_ring_outer = r_bore + ring_radial_thickness_mm;
r_outer_ring_inner = r_outer - ring_radial_thickness_mm;

// Ensure there is room for balls between rings
ball_r = ball_diameter_mm/2;
available_radial = r_outer_ring_inner - r_inner_ring_outer;
ball_r_eff = min(ball_r, max(0.1, available_radial/2 - radial_clearance_mm/2));
ball_d_eff = 2*ball_r_eff;

// Ball pitch radius (center of balls)
r_ball_pitch = (r_inner_ring_outer + r_outer_ring_inner)/2;

// Axial layout
z_shield = width_mm/2 - shield_thickness_mm/2;

// Helper: torus-like race groove cut (rotate_extrude of a circle)
module race_groove_cut(r_center, groove_r) {
    rotate_extrude(convexity=10)
        translate([r_center, 0, 0])
            circle(r=groove_r);
}

module bearing_solid() {
    union() {
        // OUTER RING with race groove
        difference() {
            cylinder(r=r_outer, h=width_mm, center=true);
            cylinder(r=r_outer_ring_inner, h=width_mm + 2*overlap_mm, center=true);

            // race groove cut into inner face of outer ring
            race_groove_cut(r_ball_pitch + ball_r_eff*0.15, ball_r_eff + 0.35);
        }

        // INNER RING with race groove
        difference() {
            cylinder(r=r_inner_ring_outer, h=width_mm, center=true);
            cylinder(r=r_bore, h=width_mm + 2*overlap_mm, center=true);

            // race groove cut into outer face of inner ring
            race_groove_cut(r_ball_pitch - ball_r_eff*0.15, ball_r_eff + 0.35);
        }

        // SHIELDS (two thin annular discs) - connected to rings by overlap
        for (s = [-1, 1]) {
            translate([0, 0, s*z_shield])
                difference() {
                    cylinder(
                        r = r_outer - ring_radial_thickness_mm + shield_radial_overlap_mm,
                        h = shield_thickness_mm,
                        center = true
                    );
                    cylinder(
                        r = r_bore + ring_radial_thickness_mm - shield_radial_overlap_mm,
                        h = shield_thickness_mm + 2*overlap_mm,
                        center = true
                    );
                }
        }

        // CAGE (simple ring with ball pockets), centered axially
        // Provides guaranteed connectivity between inner and outer rings.
        difference() {
            cylinder(r=r_outer_ring_inner + overlap_mm, h=cage_thickness_mm, center=true);
            cylinder(r=r_inner_ring_outer - overlap_mm, h=cage_thickness_mm + 2*overlap_mm, center=true);

            for (i = [0:num_balls-1]) {
                rotate([0, 0, i*360/num_balls])
                    translate([r_ball_pitch, 0, 0])
                        cylinder(
                            r = ball_r_eff + cage_pocket_clear_mm,
                            h = cage_thickness_mm + 2*overlap_mm,
                            center = true
                        );
            }
        }

        // BALLS (slightly overlapped into cage so everything is one connected solid)
        for (i = [0:num_balls-1]) {
            rotate([0, 0, i*360/num_balls])
                translate([r_ball_pitch, 0, 0])
                    sphere(r=ball_r_eff + overlap_mm);
        }
    }
}

bearing_solid();