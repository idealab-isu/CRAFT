// HT 110 cap (end cap) - single connected solid (fixed, non-empty)

cap_diameter     = 110;  // outer diameter
cap_height       = 30;   // total height
wall_thickness   = 3;    // side wall thickness
bottom_thickness = 3;    // closed end thickness
stop_lip_height  = 5;    // internal stop lip height
stop_lip_radial  = 2;    // how much the lip protrudes inward (radial)

$fn = 160;

module ht_110_end_cap() {
    eps = 0.2;

    outer_r = cap_diameter/2;
    inner_r = outer_r - wall_thickness;

    // Keep all heights/radii valid
    inner_h = max(0.01, cap_height - bottom_thickness);
    lip_h   = min(stop_lip_height, inner_h);
    lip_r_i = max(0.01, inner_r - stop_lip_radial);

    // Build as one connected solid: outer shell minus inner void, plus internal lip
    union() {
        // Main cap shell (closed bottom, open top)
        difference() {
            cylinder(h=cap_height, r=outer_r, center=false);

            // Inner void: starts above bottom thickness and reaches the top
            translate([0, 0, bottom_thickness])
                cylinder(h=inner_h + eps, r=inner_r, center=false);
        }

        // Internal stop lip ring near the open end, overlapping into the shell
        translate([0, 0, cap_height - lip_h - eps])
            difference() {
                cylinder(h=lip_h + 2*eps, r=inner_r, center=false);
                translate([0, 0, -eps])
                    cylinder(h=lip_h + 4*eps, r=lip_r_i, center=false);
            }
    }
}

ht_110_end_cap();