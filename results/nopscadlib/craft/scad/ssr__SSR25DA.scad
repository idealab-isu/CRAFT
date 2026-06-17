$fn = 64;

// Target overall envelope (must match)
length_mm = 63.0;
width_mm  = 45.0;
height_mm = 23.0;

// Feature parameters (kept simple but recognizable)
overlap_mm = 0.6;

// Baseplate (heatsink/base) thickness included in overall height
base_thk = 4.0;                         // bottom plate thickness
body_h   = height_mm - base_thk;        // main housing height above base

// Main housing footprint (slightly inset from base)
body_len = length_mm - 2.0;
body_wid = width_mm  - 2.0;

// Mounting lugs (integral with base, within overall length)
lug_len = 6.0;                          // along X
lug_wid = 20.0;                         // along Y
lug_thk = base_thk;                     // same as base thickness

// Mounting holes (through base + lugs)
mount_hole_d = 4.0;
mount_hole_spacing = 48.0;              // along X between hole centers
mount_hole_y = 0.0;

// Terminal block (top/front)
term_depth = 8.0;                       // protrudes in +Y
term_h     = 10.0;
term_len   = length_mm - 6.0;           // slightly inset from ends

// Terminal screws (bosses) on terminal block
screw_d = 4.2;
screw_h = 2.2;
screw_pitch = 10.0;
screw_count = 4;

// Helper: rounded rectangle prism (optional radius)
module rrect_prism(size=[10,10,10], r=1, center=true) {
    l = size[0]; w = size[1]; h = size[2];
    rr = min(r, min(l,w)/2);
    if (rr <= 0) {
        cube(size, center=center);
    } else {
        translate(center ? [0,0,0] : [l/2,w/2,h/2])
            linear_extrude(height=h, center=true)
                offset(r=rr)
                    square([l-2*rr, w-2*rr], center=true);
    }
}

module ssr_module() {
    // Z references
    z_bottom = -height_mm/2;
    z_base_c = z_bottom + base_thk/2;
    z_body_c = z_bottom + base_thk + body_h/2;

    // X references for lugs and holes
    x_lug_c_left  = -length_mm/2 + lug_len/2;
    x_lug_c_right =  length_mm/2 - lug_len/2;

    // Terminal block placement (attached to top/front of body)
    y_term_c = (body_wid/2) + term_depth/2 - overlap_mm;
    z_term_c = (z_bottom + base_thk + body_h) - term_h/2 + overlap_mm;

    difference() {
        union() {
            color([0.85, 0.85, 0.8]) {
                // Base plate (full footprint)
                translate([0, 0, z_base_c])
                    rrect_prism([length_mm, width_mm, base_thk], r=1.2, center=true);

                // Mounting lugs (integral with base, within overall length)
                translate([x_lug_c_left, 0, z_base_c])
                    rrect_prism([lug_len, lug_wid, lug_thk], r=1.0, center=true);
                translate([x_lug_c_right, 0, z_base_c])
                    rrect_prism([lug_len, lug_wid, lug_thk], r=1.0, center=true);

                // Main housing (inset on base)
                translate([0, 0, z_body_c])
                    rrect_prism([body_len, body_wid, body_h], r=1.5, center=true);

                // Terminal block (front/top)
                translate([0, y_term_c, z_term_c])
                    rrect_prism([term_len, term_depth, term_h], r=0.8, center=true);

                // Screw bosses on terminal block top (small cylinders)
                // Positioned along X, centered in terminal block depth
                y_screw = y_term_c;
                z_screw = (z_term_c + term_h/2) + screw_h/2 - overlap_mm;
                x0 = -((screw_count-1) * screw_pitch)/2;
                for (i = [0:screw_count-1]) {
                    translate([x0 + i*screw_pitch, y_screw, z_screw])
                        cylinder(d=screw_d, h=screw_h, center=true);
                }
            }
        }

        // Mounting holes through base + lugs (cut)
        // Hole centers at +/- mount_hole_spacing/2 along X
        hole_h = base_thk + 2; // ensure full cut
        z_hole_c = z_bottom + base_thk/2;
        for (x = [-mount_hole_spacing/2, mount_hole_spacing/2]) {
            translate([x, mount_hole_y, z_hole_c])
                cylinder(d=mount_hole_d, h=hole_h, center=true);
        }

        // Slight recess on bottom to suggest heatsink/base detail (still one solid)
        recess_thk = 1.2;
        recess_margin = 3.0;
        translate([0, 0, z_bottom + recess_thk/2 + 0.01])
            rrect_prism([length_mm - 2*recess_margin, width_mm - 2*recess_margin, recess_thk], r=1.0, center=true);
    }
}

ssr_module();