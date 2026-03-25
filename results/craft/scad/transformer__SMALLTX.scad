// Mains transformer 38.0mm x 32.0mm x 33.0mm
// Simplified for fast rendering: no hull/sphere rounding, reduced $fn, fewer expensive ops.

$fn = 32;

// Overall target envelope
overall_width  = 38;   // X
overall_depth  = 32;   // Y
overall_height = 33;   // Z

// Feature controls
include_footplate      = 1;  // [0:1]
include_mounting_holes = 1;  // [0:1]
include_terminal_block = 1;  // [0:1]

// Geometry parameters
eps_overlap = 0.4;

// Footplate
foot_thickness = 2;
foot_margin_x  = 3;
foot_margin_y  = 3;

// Core/bobbin proportions
lamination_height      = 24;
lamination_width_ratio = 0.84;
lamination_depth_ratio = 0.78;

bobbin_width_ratio  = 0.62;
bobbin_depth_ratio  = 0.92;
bobbin_height_ratio_of_lamination = 0.92;

// Core window (visual transformer feature)
window_width_ratio  = 0.38;  // of lam_w
window_depth_ratio  = 0.42;  // of lam_d
window_height_ratio = 0.70;  // of lam_h
window_bottom_clear = 3.0;   // mm from bottom of lamination to window start

// Mounting holes
mounting_hole_diameter = 3.2;
corner_radius = 2;

// Terminal block
terminal_height_ratio = 0.27;
terminal_depth_ratio  = 0.55;
terminal_width_ratio  = 0.70;

// Pins/terminals (kept within overall envelope)
pin_d = 1.2;
pin_len = 3.0; // protrude in +Y direction
pin_rows = 2;
pins_per_row = 3;
pin_pitch_x = 4.0;
pin_pitch_z = 2.5;

// Derived sizes
foot_on = (include_footplate > 0) ? 1 : 0;
term_on = (include_terminal_block > 0) ? 1 : 0;

foot_h = foot_on ? foot_thickness : 0;

lam_w = overall_width  * lamination_width_ratio;
lam_d = overall_depth  * lamination_depth_ratio;
lam_h = lamination_height;

bob_w = overall_width  * bobbin_width_ratio;
bob_d = overall_depth  * bobbin_depth_ratio;
bob_h = lam_h * bobbin_height_ratio_of_lamination;

foot_w = lam_w + 2*foot_margin_x;
foot_d = lam_d + 2*foot_margin_y;

// Terminal block height constrained to keep total height exactly overall_height
term_h_nom = overall_height * terminal_height_ratio;
term_h_max = max(0, overall_height - (foot_h + lam_h));
term_h     = term_on ? min(term_h_nom, term_h_max) : 0;

term_w = overall_width * terminal_width_ratio;
term_d = overall_depth * terminal_depth_ratio;

// Ensure terminal block doesn't exceed overall depth when pins are added
term_d_eff = term_on ? min(term_d, overall_depth - pin_len) : 0;

// Z placement (stacked with slight overlaps for connectivity)
z0 = 0; // bottom of model

z_foot_center = z0 + foot_h/2;
z_lam_center  = z0 + foot_h + lam_h/2 - eps_overlap;
z_bob_center  = z0 + foot_h + lam_h/2 + eps_overlap*0.2;
z_term_center = z0 + foot_h + lam_h + term_h/2 - eps_overlap;

// Fast rounded rectangle prism using 2D offset (much cheaper than hull of spheres)
module rounded_box(size=[10,10,10], r=1, center=true) {
    r2 = max(0, min(r, min(size[0], size[1]) / 2));
    translate(center ? [0,0,0] : [size[0]/2, size[1]/2, size[2]/2])
        linear_extrude(height=size[2], center=true, convexity=4)
            offset(r=r2)
                square([max(0.01, size[0]-2*r2), max(0.01, size[1]-2*r2)], center=true);
}

// Modules
module lamination_core_block() {
    win_w = lam_w * window_width_ratio;
    win_d = lam_d * window_depth_ratio;
    win_h = lam_h * window_height_ratio;

    win_z_center = (z0 + foot_h) + window_bottom_clear + win_h/2;

    difference() {
        translate([0, 0, z_lam_center])
            rounded_box([lam_w, lam_d, lam_h], r=1.0);

        translate([0, 0, win_z_center])
            cube([win_w, win_d, win_h], center=true);
    }
}

module bobbin_body() {
    translate([0, 0, z_bob_center])
        rounded_box([bob_w, bob_d, bob_h], r=0.8);
}

module mounting_footplate_raw() {
    if (foot_on)
        translate([0, 0, z_foot_center])
            rounded_box([foot_w, foot_d, foot_h], r=1.0);
}

module mounting_holes() {
    if (foot_on && include_mounting_holes) {
        x_off = foot_w/2 - (mounting_hole_diameter/2 + corner_radius);
        translate([-x_off, 0, z_foot_center])
            cylinder(d=mounting_hole_diameter, h=foot_h + 2*eps_overlap, center=true);
        translate([ x_off, 0, z_foot_center])
            cylinder(d=mounting_hole_diameter, h=foot_h + 2*eps_overlap, center=true);
    }
}

module mounting_footplate() {
    if (foot_on) {
        if (include_mounting_holes) {
            difference() {
                mounting_footplate_raw();
                mounting_holes();
            }
        } else {
            mounting_footplate_raw();
        }
    }
}

module terminal_block_volume() {
    if (term_on && term_h > 0)
        translate([0, 0, z_term_center])
            rounded_box([term_w, term_d_eff, term_h], r=0.6);
}

module terminal_pins() {
    if (term_on && term_h > 0) {
        y_pin_center = term_d_eff/2 + pin_len/2 - eps_overlap;

        z_span  = (pin_rows-1) * pin_pitch_z;
        z_start = z_term_center - z_span/2;

        x_span  = (pins_per_row-1) * pin_pitch_x;
        x_start = -x_span/2;

        for (rz = [0:pin_rows-1])
            for (ix = [0:pins_per_row-1]) {
                x = x_start + ix*pin_pitch_x;
                z = z_start + rz*pin_pitch_z;

                if (abs(x) <= term_w/2 - pin_d && abs(z - z_term_center) <= term_h/2 - pin_d)
                    translate([x, y_pin_center, z])
                        rotate([90, 0, 0])
                            cylinder(d=pin_d, h=pin_len, center=true);
            }
    }
}

// Final assembly
module transformer() {
    union() {
        mounting_footplate();
        lamination_core_block();
        bobbin_body();
        terminal_block_volume();
        terminal_pins();
    }
}

transformer();