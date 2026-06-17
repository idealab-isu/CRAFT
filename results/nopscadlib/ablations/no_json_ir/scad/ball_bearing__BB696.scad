$fn = 128;

// Target bearing dimensions (mm)
inner_bore_diameter = 6.0;   // bore ID
outer_diameter      = 16.0;  // OD
width               = 5.0;   // overall width

// Visual details (kept within envelope)
num_balls     = 8;
ball_diameter = 2.0;

// Small overlap to ensure one connected solid (avoid coincident faces)
eps = 0.05;

module ball_bearing_6x16x5() {
    bore_r  = inner_bore_diameter/2;
    outer_r = outer_diameter/2;

    // Choose a ball path radius that keeps balls inside the bearing ring
    // Ensure: bore_r + ball_r < ball_path_r < outer_r - ball_r
    ball_r = ball_diameter/2;
    ball_path_r = (bore_r + outer_r)/2;

    // Main ring (outer cylinder minus bore)
    difference() {
        cylinder(r=outer_r, h=width, center=true);
        cylinder(r=bore_r,  h=width + 2, center=true);
    }

    // Add balls (slightly intersect ring so everything is one connected solid)
    for (i = [0:num_balls-1]) {
        rotate([0, 0, i * 360/num_balls])
            translate([ball_path_r, 0, 0])
                sphere(r=ball_r + eps);
    }

    // Add simple "race" lips as shallow internal chamfers (still within envelope)
    // These are added solids that intersect the ring, improving bearing-like look.
    lip_h = width * 0.22;
    lip_r_in  = bore_r + ball_r * 0.65;
    lip_r_out = outer_r - ball_r * 0.65;

    // Front lip
    translate([0, 0,  width/2 - lip_h/2 + eps])
        difference() {
            cylinder(r=lip_r_out, h=lip_h + 2*eps, center=true);
            cylinder(r=lip_r_in,  h=lip_h + 2 + 2*eps, center=true);
        }

    // Back lip
    translate([0, 0, -width/2 + lip_h/2 - eps])
        difference() {
            cylinder(r=lip_r_out, h=lip_h + 2*eps, center=true);
            cylinder(r=lip_r_in,  h=lip_h + 2 + 2*eps, center=true);
        }
}

ball_bearing_6x16x5();