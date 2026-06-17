// Ball bearing 3x8x3 (bore x OD x width) - single connected solid

// Requested dimensions
bore_diameter_mm  = 3.0;
outer_diameter_mm = 8.0;
width_mm          = 3.0;

// Visual/feature parameters (kept within the 3x8x3 envelope)
race_radial_thickness_mm = 1.0;   // ring thickness (radial)
race_axial_thickness_mm  = 3.0;   // must equal width to avoid floating parts
ball_diameter_mm         = 1.2;
ball_count               = 8;

// Small overlaps / tolerances
overlap_mm = 0.08;
eps_mm     = 0.02;

// Smooth circles (fix faceting / polygonal bore & OD)
$fn = 128;

// Derived radii
bore_r  = bore_diameter_mm/2;
outer_r = outer_diameter_mm/2;

// Ring radii
outer_race_inner_r = outer_r - race_radial_thickness_mm;
inner_race_outer_r = bore_r + race_radial_thickness_mm;

// Ball path radius (between races)
ball_path_r = (outer_race_inner_r + inner_race_outer_r)/2;

// Ensure balls touch both races slightly so everything is ONE connected solid
ball_r = ball_diameter_mm/2;
ball_r_connected = max(ball_r, (outer_race_inner_r - inner_race_outer_r)/2 + overlap_mm);

// Clamp ball size so it stays inside the bearing envelope
ball_r_connected = min(ball_r_connected, (outer_r - bore_r)/2 - eps_mm);

// Main bearing
module ball_bearing_3x8x3() {
    union() {
        // Outer race (full width)
        difference() {
            cylinder(r=outer_r, h=width_mm, center=true);
            cylinder(r=outer_race_inner_r, h=width_mm + 2*eps_mm, center=true);
        }

        // Inner race (full width)
        difference() {
            cylinder(r=inner_race_outer_r, h=width_mm, center=true);
            cylinder(r=bore_r, h=width_mm + 2*eps_mm, center=true);
        }

        // Balls (connected to races via slight overlap)
        for (i = [0:ball_count-1]) {
            rotate([0, 0, i * 360/ball_count])
                translate([ball_path_r, 0, 0])
                    sphere(r=ball_r_connected);
        }
    }
}

ball_bearing_3x8x3();