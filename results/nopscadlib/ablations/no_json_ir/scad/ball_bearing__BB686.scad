$fn = 128;

// Ball bearing target dimensions (mm)
bore_diameter  = 6.0;
outer_diameter = 13.0;
width          = 5.0;

// Visual bearing details
ball_diameter = 2.0;
ball_count    = 8;

// Small overlaps to guarantee connectivity
eps     = 0.05;
overlap = 0.20;

module ball_bearing() {
    r_bore  = bore_diameter/2;
    r_outer = outer_diameter/2;

    // Race thickness (kept realistic and leaves room for balls)
    race_th = (r_outer - r_bore) * 0.28;
    race_th = max(0.8, min(1.3, race_th));

    // Inner ring outer radius and outer ring inner radius
    r_inner_outer = r_bore + race_th;
    r_outer_inner = r_outer - race_th;

    // Ball path radius between races
    r_ball_path = (r_inner_outer + r_outer_inner)/2;

    // Cage ring sized to intersect balls and both races (one connected solid)
    cage_th   = 0.70;
    cage_r_in = r_ball_path - ball_diameter/2 - cage_th/2;
    cage_r_out= r_ball_path + ball_diameter/2 + cage_th/2;

    // Ensure cage actually touches both races (with overlap)
    cage_r_in  = min(cage_r_in,  r_inner_outer + overlap);
    cage_r_out = max(cage_r_out, r_outer_inner - overlap);

    // Keep balls within width but still visibly spherical
    ball_z_scale = min(1, (width - 0.4)/ball_diameter);

    union() {
        // Outer ring
        difference() {
            cylinder(r=r_outer, h=width, center=true);
            cylinder(r=r_outer_inner, h=width + 2*eps, center=true);
        }

        // Inner ring
        difference() {
            cylinder(r=r_inner_outer, h=width, center=true);
            cylinder(r=r_bore, h=width + 2*eps, center=true);
        }

        // Cage ring (thin)
        difference() {
            cylinder(r=cage_r_out, h=width - 2*eps, center=true);
            cylinder(r=cage_r_in,  h=width - 2*eps + 2*eps, center=true);
        }

        // Balls (intersect cage and races via overlap)
        for (i = [0:ball_count-1]) {
            angle = i * 360/ball_count;
            rotate([0, 0, angle])
                translate([r_ball_path, 0, 0])
                    scale([1, 1, ball_z_scale])
                        sphere(d=ball_diameter);
        }
    }
}

// Final: enforce exact 6mm through-bore and keep one connected solid
difference() {
    ball_bearing();
    cylinder(d=bore_diameter, h=width + 2*eps, center=true);
}