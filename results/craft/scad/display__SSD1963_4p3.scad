$fn = 64;

// ===== Parameters (from request) =====
overall_width     = 105.5;
overall_height    = 67.2;
overall_thickness = 3.4;

// Front window / bezel opening (requested [[-50,-26.5],[50,31.5,0.5]])
aperture_min_x     = -50;
aperture_min_y     = -26.5;
aperture_max_x     =  50;
aperture_max_y     =  31.5;
aperture_cut_depth = 0.5;

// Back step region (requested [[-105.5/2, -65/2+1],[105.5/2, 65/2+1, 1]])
back_step_min_x   = -overall_width/2;
back_step_min_y   = -65/2 + 1;
back_step_max_x   =  overall_width/2;
back_step_max_y   =  65/2 + 1;
back_step_depth   = 1;

// Bottom connector/feature (requested [[0,-34.5],[12,-31.5]])
conn_center_x     = 0;
conn_min_y        = -34.5;
conn_max_y        = -31.5;
conn_width_x      = 12;

// ===== Modeling controls =====
eps     = 0.05;   // overlap to guarantee manifold unions/differences
bezel_r = 1.2;    // corner rounding

// ===== Helpers =====
module rounded_plate_xy(size=[10,10,1], r=1, center=true) {
    w = size[0]; h = size[1]; t = size[2];
    translate(center ? [0,0,-t/2] : [0,0,0])
        linear_extrude(height=t, convexity=10)
            offset(r=r)
                square([max(0.01, w-2*r), max(0.01, h-2*r)], center=true);
}

// ===== One connected solid display module =====
module display_module() {
    // Derived sizes
    aperture_w  = aperture_max_x - aperture_min_x;
    aperture_h  = aperture_max_y - aperture_min_y;
    aperture_cx = (aperture_min_x + aperture_max_x)/2;
    aperture_cy = (aperture_min_y + aperture_max_y)/2;

    step_w  = back_step_max_x - back_step_min_x;
    step_h  = back_step_max_y - back_step_min_y;
    step_cx = (back_step_min_x + back_step_max_x)/2;
    step_cy = (back_step_min_y + back_step_max_y)/2;

    conn_h_y = conn_max_y - conn_min_y;
    conn_cy  = (conn_min_y + conn_max_y)/2;

    // Make connector thickness tied to known dimensions (visible, but not arbitrary)
    conn_thickness = min(2.2, overall_thickness); // keep plausible and connected

    // Z references
    z_front =  overall_thickness/2;
    z_back  = -overall_thickness/2;

    union() {
        // Base with front recess cut
        difference() {
            rounded_plate_xy([overall_width, overall_height, overall_thickness], r=bezel_r, center=true);

            // Cut from the FRONT face inward by aperture_cut_depth
            translate([aperture_cx, aperture_cy, z_front - (aperture_cut_depth/2) + eps/2])
                cube([aperture_w, aperture_h, aperture_cut_depth + eps], center=true);
        }

        // Back step pad (protrudes from back face by back_step_depth)
        translate([step_cx, step_cy, z_back - back_step_depth/2 + eps])
            cube([step_w, step_h, back_step_depth], center=true);

        // Bottom connector/feature (protrudes from back; guaranteed to intersect base/step)
        translate([conn_center_x, conn_cy, z_back - conn_thickness/2 + eps])
            cube([conn_width_x, conn_h_y, conn_thickness], center=true);
    }
}

display_module();