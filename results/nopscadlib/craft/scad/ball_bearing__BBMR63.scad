// Ball bearing: 3.0mm bore, 6.0mm OD, 2.5mm width
// One connected solid with visible balls and a guaranteed through-bore.

$fn = 160;

// Target dimensions (mm)
bore_diameter_mm  = 3.0;
outer_diameter_mm = 6.0;
width_mm          = 2.5;

// Derived radii
bore_r  = bore_diameter_mm/2;
outer_r = outer_diameter_mm/2;

// Small overlap to guarantee connectivity (do not affect nominal dims meaningfully)
eps = 0.03;

// Race sizing (kept plausible for 3x6x2.5)
race_radial_thickness = 0.60;   // radial thickness of each race
race_axial_margin     = 0.25;   // axial margin from each face

// Balls
num_balls     = 7;
ball_diameter = 0.80;
ball_r        = ball_diameter/2;

// Derived race radii
inner_race_outer_r = bore_r + race_radial_thickness;
outer_race_inner_r = outer_r - race_radial_thickness;

// Ball path radius between races
ball_path_r = (inner_race_outer_r + outer_race_inner_r)/2;

// Raceway band (a thin annulus that the balls intersect to ensure a single connected solid)
raceway_h = max(width_mm - 2*race_axial_margin, width_mm*0.6);
raceway_inner_r = inner_race_outer_r + 0.06;
raceway_outer_r = outer_race_inner_r - 0.06;

// Ensure raceway is valid
raceway_inner_r2 = min(raceway_inner_r, raceway_outer_r - 0.10);
raceway_outer_r2 = max(raceway_outer_r, raceway_inner_r2 + 0.10);

// Make balls slightly larger so they visibly intersect the raceway band and both races
ball_r_fused = ball_r + eps;

module bearing() {
    union() {
        // Outer race (ring)
        difference() {
            cylinder(r=outer_r, h=width_mm, center=true);
            cylinder(r=outer_race_inner_r, h=width_mm + 2*eps, center=true);
        }

        // Inner race (ring)
        difference() {
            cylinder(r=inner_race_outer_r, h=width_mm, center=true);
            cylinder(r=bore_r, h=width_mm + 2*eps, center=true);
        }

        // Raceway band (connects balls to races and suggests groove)
        difference() {
            cylinder(r=raceway_outer_r2, h=raceway_h, center=true);
            cylinder(r=raceway_inner_r2, h=raceway_h + 2*eps, center=true);
        }

        // Balls
        for (i = [0:num_balls-1]) {
            rotate([0, 0, i*360/num_balls])
                translate([ball_path_r, 0, 0])
                    sphere(r=ball_r_fused);
        }
    }
}

// Final: enforce a true through-bore so top/bottom views show the hole
difference() {
    bearing();
    cylinder(r=bore_r, h=width_mm + 4*eps, center=true);
}