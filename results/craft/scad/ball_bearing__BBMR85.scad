// Ball bearing: 5.0mm bore, 8.0mm OD, 2.5mm width
// One connected solid with clear bore + inner/outer races + visible ball set (as connected bumps).

$fn = 220;

// Parameters (mm)
bore_diameter_mm  = 5.0;
outer_diameter_mm = 8.0;
width_mm          = 2.5;

// Visual/structural detailing (kept within envelope)
race_radial_thickness_mm = 0.70;   // radial thickness of each race ring
ball_diameter_mm         = 0.80;   // visual ball size
num_balls                = 8;
ball_embed_mm            = 0.18;   // embed balls into races so the whole model is one connected solid
connection_overlap_mm    = 0.06;   // small overlap for robust manifold booleans

// Derived
bore_r  = bore_diameter_mm/2;
outer_r = outer_diameter_mm/2;

// Race boundaries (kept inside OD/ID)
inner_race_or = bore_r + race_radial_thickness_mm;
outer_race_ir = outer_r - race_radial_thickness_mm;

// Ball path radius centered in the gap between races
ball_path_r = (inner_race_or + outer_race_ir)/2;

// Ensure balls stay within width
ball_r = ball_diameter_mm/2;
ball_z_limit = width_mm/2 - 0.01;

// Helper: ball bumps (slightly oversized so they intersect races -> single connected solid)
module ball_bumps() {
    for (i = [0:num_balls-1]) {
        rotate([0,0, i*360/num_balls])
            translate([ball_path_r, 0, 0])
                sphere(r=ball_r + ball_embed_mm, $fn=96);
    }
}

// Outer race ring (simple, clean geometry)
module outer_race() {
    difference() {
        cylinder(r=outer_r, h=width_mm, center=true);
        cylinder(r=outer_race_ir, h=width_mm + 2*connection_overlap_mm, center=true);
    }
}

// Inner race ring (simple, clean geometry with bore)
module inner_race() {
    difference() {
        cylinder(r=inner_race_or, h=width_mm, center=true);
        cylinder(r=bore_r, h=width_mm + 2*connection_overlap_mm, center=true);
    }
}

// Assembly: union ensures one connected solid; balls are connected bumps
module ball_bearing() {
    union() {
        outer_race();
        inner_race();

        // Keep bumps within the bearing width envelope
        intersection() {
            ball_bumps();
            cylinder(r=outer_r - 0.001, h=2*ball_z_limit, center=true);
        }
    }
}

ball_bearing();