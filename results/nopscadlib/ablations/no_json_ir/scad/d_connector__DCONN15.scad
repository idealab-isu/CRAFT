$fn = 64;

// ---------------- Parameters (mm) ----------------
d_shell_width       = 40;
d_shell_height      = 20;
d_shell_depth       = 12;   // front-to-back depth of metal shell
d_shell_thickness   = 2.0;  // wall thickness

flange_thickness    = 2.0;
flange_extension    = 5.0;

mounting_hole_diameter = 3.2;
mounting_hole_offset_x = 6.0;  // from outer flange edge in X
mounting_hole_y        = 0;    // centered vertically

// Simplified "contact" pins (visual)
pin_rows          = 2;
pins_per_row      = 5;
pin_d             = 1.2;
pin_len           = 3.0;   // protrusion from mating face
pin_pitch_x       = 2.77;
pin_pitch_y       = 2.84;

// Back cable exit block
cable_exit_width  = 16;
cable_exit_height = 10;
cable_exit_depth  = 10;

// Jackscrew posts (simplified, common D-sub feature)
jackscrew_post_d      = 6.0;
jackscrew_post_len    = 5.0;   // protrudes forward from flange
jackscrew_hole_d      = 3.2;   // through-hole in post

// Overlap to ensure watertight unions
ov = 1.5;

// ---------------- Helpers ----------------

// Fast 2D rounded rectangle using offset (no minkowski)
module rounded_rect_2d(w, h, r, center=true) {
    r2 = min(r, min(w, h)/2);
    offset(r=r2)
        square([max(0.01, w-2*r2), max(0.01, h-2*r2)], center=center);
}

// D-sub outline: flat left, rounded right (recognizable D profile)
module d_outline_2d(w, h, r_corner) {
    r2 = min(r_corner, h/2);
    intersection() {
        // base rounded rectangle
        rounded_rect_2d(w, h, r2, center=true);

        // keep a flat left side by clipping with a big rectangle
        translate([-w/2, 0]) square([w, 2*h], center=true);

        // enforce rounded right side with a circle cap
        translate([w/2 - h/2, 0]) circle(r=h/2);
    }
}

// Solid D-shaped body (dominant connector silhouette)
module d_body_3d(depth) {
    linear_extrude(height=depth, center=false, convexity=10)
        d_outline_2d(d_shell_width, d_shell_height, d_shell_height/2);
}

// Hollow shell (outer minus inner) to suggest metal shell
module d_shell_3d() {
    r_corner = d_shell_height/2;
    difference() {
        d_body_3d(d_shell_depth);

        // inner cavity starts slightly behind the mating face to keep a rim
        translate([0, 0, d_shell_thickness])
            linear_extrude(height=max(0.01, d_shell_depth - d_shell_thickness + ov), center=false, convexity=10)
                d_outline_2d(d_shell_width - 2*d_shell_thickness,
                             d_shell_height - 2*d_shell_thickness,
                             max(0.1, r_corner - d_shell_thickness));
    }
}

// Front flange plate with mounting holes (connected to shell)
module flange_3d() {
    outer_w = d_shell_width + 2*flange_extension;
    outer_h = d_shell_height + 2*flange_extension;
    r = min(outer_h/2, d_shell_height/2 + flange_extension);

    difference() {
        // Flange spans z=[-flange_thickness, 0] and overlaps into shell by ov
        translate([0, 0, -flange_thickness])
            linear_extrude(height=flange_thickness + ov, center=false, convexity=10)
                rounded_rect_2d(outer_w, outer_h, r, center=true);

        // Mounting holes (two)
        hole_x = outer_w/2 - mounting_hole_offset_x;
        for (sx = [-1, 1]) {
            translate([sx*hole_x, mounting_hole_y, -flange_thickness - 2*ov])
                cylinder(h=flange_thickness + 4*ov, d=mounting_hole_diameter, center=false);
        }

        // Clear the shell opening through the flange
        translate([0, 0, -flange_thickness - 2*ov])
            linear_extrude(height=flange_thickness + 4*ov, center=false, convexity=10)
                d_outline_2d(d_shell_width, d_shell_height, d_shell_height/2);
    }
}

// Recessed mating face "insulator" block inside shell opening (recognizable D-sub face)
module insulator_3d() {
    // Slightly smaller than shell opening, sits just behind flange
    ins_w = d_shell_width - 2*(d_shell_thickness + 1.0);
    ins_h = d_shell_height - 2*(d_shell_thickness + 1.0);
    ins_d = 2.0;

    // Place so it fuses with shell rim and flange overlap
    translate([0, 0, 0.5])  // just behind the mating plane (z=0)
        linear_extrude(height=ins_d, center=false, convexity=10)
            d_outline_2d(ins_w, ins_h, ins_h/2);
}

// Pin array (positive geometry) on the mating face
module pins_3d() {
    total_w = (pins_per_row - 1) * pin_pitch_x;
    x0 = -total_w/2;
    y0 = -(pin_pitch_y/2);

    // Start pins slightly inside the shell so they fuse (no floating)
    z0 = -pin_len + ov;

    for (row = [0:pin_rows-1]) {
        y = y0 + row*pin_pitch_y;
        for (i = [0:pins_per_row-1]) {
            x = x0 + i*pin_pitch_x;
            translate([x, y, z0])
                cylinder(h=pin_len + ov, d=pin_d, center=false);
        }
    }
}

// Side jackscrew posts (simplified cylinders) attached to flange front
module jackscrews_3d() {
    outer_w = d_shell_width + 2*flange_extension;
    hole_x = outer_w/2 - mounting_hole_offset_x;

    // Posts protrude forward from flange front face (z=0) and overlap into flange by ov
    for (sx = [-1, 1]) {
        difference() {
            translate([sx*hole_x, mounting_hole_y, -ov])
                cylinder(h=jackscrew_post_len + ov, d=jackscrew_post_d, center=false);

            // Through-hole for screw
            translate([sx*hole_x, mounting_hole_y, -2*ov])
                cylinder(h=jackscrew_post_len + 4*ov, d=jackscrew_hole_d, center=false);
        }
    }
}

// Back cable exit block (connected to shell back with overlap)
module cable_exit_3d() {
    // Attach to shell back face at z=d_shell_depth, overlap by ov
    translate([-cable_exit_width/2, -cable_exit_height/2, d_shell_depth - ov])
        cube([cable_exit_width, cable_exit_height, cable_exit_depth + ov], center=false);
}

// ---------------- Main assembly ----------------
module d_sub_connector() {
    union() {
        // Flange + shell are the main recognizable connector
        flange_3d();
        d_shell_3d();

        // Recessed face + pins to read as a D-sub connector
        insulator_3d();
        pins_3d();

        // Side jackscrews (common D-sub feature)
        jackscrews_3d();

        // Rear strain relief / cable exit
        cable_exit_3d();
    }
}

d_sub_connector();