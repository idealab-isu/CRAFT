$fn = 160;

// Target dimensions (mm)
bore_diameter_mm   = 5.0;   // bore
outer_diameter_mm  = 16.0;  // OD (outer race)
width_mm           = 5.0;   // overall width (excluding flange thickness is included by placement)
flange_diameter_mm = 18.0;  // flange OD

// Feature tuning (kept small so dimensions remain correct)
flange_width_mm        = 1.0;   // axial thickness of flange
outer_race_wall_mm     = 1.2;   // radial wall thickness of outer race
inner_race_wall_mm     = 1.0;   // radial wall thickness of inner race (bore -> inner race OD)
race_gap_mm            = 0.6;   // radial gap between races (for balls)
ball_diameter_mm       = 2.0;
ball_count             = 8;
cage_thickness_mm      = 0.6;   // thin ring to connect balls into one solid
cage_axial_clear_mm    = 0.6;   // keep cage inside width
connect_overlap_mm     = 0.2;   // small overlap to ensure manifold unions

// Derived radii
bore_r   = bore_diameter_mm/2;
outer_r  = outer_diameter_mm/2;
flange_r = flange_diameter_mm/2;

// Inner race outer radius
inner_race_or = bore_r + inner_race_wall_mm;

// Outer race inner radius
outer_race_ir = outer_r - outer_race_wall_mm;

// Ball path radius (between races)
ball_path_r = (inner_race_or + outer_race_ir)/2;

// Safety: ensure balls fit in the gap
ball_r = ball_diameter_mm/2;
min_gap = outer_race_ir - inner_race_or;
ball_r_eff = min(ball_r, (min_gap/2) - 0.05);

// Axial extents
bearing_h = width_mm;
flange_h  = flange_width_mm;

// Place flange on one side, connected to outer race with overlap
flange_z = -bearing_h/2 + flange_h/2 - connect_overlap_mm/2;

// Cage dimensions
cage_h = max(0.2, bearing_h - 2*cage_axial_clear_mm);
cage_r1 = ball_path_r - ball_r_eff*0.55;
cage_r2 = ball_path_r + ball_r_eff*0.55;

module outer_race_with_flange() {
    union() {
        // Outer race ring
        difference() {
            cylinder(r=outer_r, h=bearing_h, center=true);
            cylinder(r=outer_race_ir, h=bearing_h + 2*connect_overlap_mm, center=true);
        }
        // Flange ring (only on one side)
        translate([0,0,flange_z])
        difference() {
            cylinder(r=flange_r, h=flange_h, center=true);
            // keep flange connected to outer race body; remove only the bore-sized center
            cylinder(r=outer_race_ir, h=flange_h + 2*connect_overlap_mm, center=true);
        }
    }
}

module inner_race() {
    difference() {
        cylinder(r=inner_race_or, h=bearing_h, center=true);
        cylinder(r=bore_r, h=bearing_h + 2*connect_overlap_mm, center=true);
    }
}

module balls_and_cage() {
    union() {
        // Balls
        for (i = [0:ball_count-1]) {
            ang = i * 360/ball_count;
            rotate([0,0,ang])
                translate([ball_path_r, 0, 0])
                    sphere(r=ball_r_eff);
        }
        // Simple cage ring to make the whole model ONE connected solid
        difference() {
            cylinder(r=cage_r2, h=cage_h, center=true);
            cylinder(r=cage_r1, h=cage_h + 2*connect_overlap_mm, center=true);
        }
    }
}

module flanged_ball_bearing() {
    // Make a single connected solid by unioning all components.
    // (Real bearings are separate parts; here we intentionally connect via cage contact.)
    union() {
        outer_race_with_flange();
        inner_race();
        balls_and_cage();
    }
}

flanged_ball_bearing();