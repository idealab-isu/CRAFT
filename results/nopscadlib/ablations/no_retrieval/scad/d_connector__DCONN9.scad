// D-sub (D-connector) simplified solid model (one connected solid)
// Structural fix: make silhouette clearly D-sub (D-face + flange ears + pin array),
// and ensure ALL parts are connected with explicit overlaps and recalculated translates.
// Kept geometric/clean; no text; single connected solid.

$fn = 64;

// ---------- Parameters ----------
shell_width = 30;              // overall D width (X)
shell_height = 12;             // overall D height (Y)
shell_depth = 10;              // shell depth (Z)
shell_wall_thickness = 1.2;

body_width = 34;
body_height = 16;
body_depth = 18;

flange_width = 40;
flange_height = 18;
flange_thickness = 2.5;

mount_hole_diameter = 3.2;
mount_hole_spacing = 33;

mating_recess_depth = 2;
overlap = 1.2;                 // ensure solid connections (1–2mm)

pin_diameter = 1;
pin_length = 4;
pin_rows = 2;
pins_per_row = 5;
pin_pitch_x = 2.8;
pin_pitch_y = 2.3;

jackscrew_diameter = 4.5;
jackscrew_length = 6;

strain_relief_diameter = 10;
strain_relief_length = 14;
rear_cable_exit_diameter = 6;

chamfer_size = 0.8;

// ---------- Helpers ----------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// D profile: flat on one side, rounded on the other (typical D-sub outline)
// Flat at bottom (negative Y), round at top (positive Y)
module d_profile_2d(w, h) {
    r = w/2;
    rect_h = clamp(h - r, 0.01, h);
    union() {
        translate([-w/2, -h/2]) square([w, rect_h], center=false);
        translate([0, -h/2 + rect_h]) circle(r=r);
    }
}

module d_shell_outer() {
    linear_extrude(height=shell_depth, center=true)
        d_profile_2d(shell_width, shell_height);
}

module d_shell_inner() {
    inner_w = shell_width - 2*shell_wall_thickness;
    inner_h = shell_height - 2*shell_wall_thickness;
    inner_d = shell_depth - 2*shell_wall_thickness;

    iw = clamp(inner_w, 0.5, shell_width);
    ih = clamp(inner_h, 0.5, shell_height);
    id = clamp(inner_d, 0.5, shell_depth);

    linear_extrude(height=id, center=true)
        d_profile_2d(iw, ih);
}

module mating_recess() {
    // Recess at the front face (negative Z side)
    recess_w = shell_width - 2*shell_wall_thickness;
    recess_h = shell_height - 2*shell_wall_thickness;

    rw = clamp(recess_w, 0.5, shell_width);
    rh = clamp(recess_h, 0.5, shell_height);

    // Cut starts at the front face and goes inward
    translate([0, 0, -shell_depth/2 + mating_recess_depth/2])
        linear_extrude(height=mating_recess_depth + 2*overlap, center=true)
            d_profile_2d(rw, rh);
}

module shell_hollow_with_recess() {
    difference() {
        d_shell_outer();
        d_shell_inner();
        mating_recess();
    }
}

module connector_body() {
    // Body behind shell (positive Z), connected with overlap
    // Shell back face at +shell_depth/2
    translate([0, 0, shell_depth/2 + body_depth/2 - overlap])
        cube([body_width, body_height, body_depth], center=true);
}

module flange_plate() {
    // Flange at front (negative Z), connected with overlap into shell
    // Shell front face at -shell_depth/2
    translate([0, 0, -shell_depth/2 - flange_thickness/2 + overlap])
        cube([flange_width, flange_height, flange_thickness], center=true);
}

module mounting_holes() {
    // Through flange (cut)
    zc = -shell_depth/2 - flange_thickness/2 + overlap;
    for (sx = [-1, 1]) {
        translate([sx*mount_hole_spacing/2, 0, zc])
            cylinder(r=mount_hole_diameter/2, h=flange_thickness + 6*overlap, center=true);
    }
}

module jackscrews() {
    // Solid posts on front, centered on mounting holes, connected to flange
    // Flange front face (most negative Z) is:
    // z = (-shell_depth/2 - flange_thickness + overlap)
    z_front_flange = (-shell_depth/2 - flange_thickness + overlap);

    // Place so the rear end overlaps into flange by 'overlap'
    // Rear end of jackscrew at z = z_front_flange + overlap
    // Center = rear_end - length/2
    zc = (z_front_flange + overlap) - jackscrew_length/2;

    for (sx = [-1, 1]) {
        translate([sx*mount_hole_spacing/2, 0, zc])
            cylinder(r=jackscrew_diameter/2, h=jackscrew_length, center=true);
    }
}

module pin_array() {
    // Pins protrude forward from inside the recess (negative Z direction)
    // Recess spans approx: [-shell_depth/2, -shell_depth/2 + mating_recess_depth]
    // Put pin rear end inside recess by overlap:
    // rear_end = (-shell_depth/2 + mating_recess_depth - overlap)
    // center = rear_end - pin_length/2
    z_rear_end = (-shell_depth/2 + mating_recess_depth - overlap);
    zc = z_rear_end - pin_length/2;

    row_y = (pin_rows == 1) ? [0] :
            (pin_rows == 2) ? [ pin_pitch_y/2, -pin_pitch_y/2 ] :
                              [ pin_pitch_y, 0, -pin_pitch_y ];

    for (ri = [0:len(row_y)-1]) {
        y = row_y[ri];
        x_shift = (ri % 2 == 1) ? pin_pitch_x/2 : 0;

        for (ci = [0:pins_per_row-1]) {
            x = (ci - (pins_per_row-1)/2) * pin_pitch_x + x_shift;
            translate([x, y, zc])
                cylinder(r=pin_diameter/2, h=pin_length, center=true);
        }
    }
}

module strain_relief() {
    // Strain relief cylinder behind body (positive Z), hollowed by cable exit
    // Connected to body with overlap.
    // Body back face at: z = shell_depth/2 + body_depth - overlap
    z_back_body = shell_depth/2 + body_depth - overlap;

    // Place so front end overlaps into body by 'overlap'
    // front_end = z_back_body - overlap
    // center = front_end + length/2
    zc = (z_back_body - overlap) + strain_relief_length/2;

    difference() {
        translate([0, 0, zc])
            cylinder(r=strain_relief_diameter/2, h=strain_relief_length, center=true);

        translate([0, 0, zc])
            cylinder(r=rear_cable_exit_diameter/2, h=strain_relief_length + 6*overlap, center=true);
    }
}

module chamfer_kernel() {
    sphere(r=chamfer_size/2);
}

// ---------- Assembly ----------
module dsub_connector() {
    // One connected solid: union main parts, subtract mounting holes, then soften edges.
    minkowski() {
        difference() {
            union() {
                // D-shaped mating shell with recess (recognizable D-sub face)
                shell_hollow_with_recess();

                // Rectangular rear body
                connector_body();

                // Front flange/ears
                flange_plate();

                // Jackscrews on ears
                jackscrews();

                // Pin array on mating face
                pin_array();

                // Rear strain relief
                strain_relief();
            }
            // Cut mounting holes through flange
            mounting_holes();
        }
        chamfer_kernel();
    }
}

// ---------- Output ----------
dsub_connector();