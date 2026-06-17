$fn = 96;

// -------------------- Parameters --------------------
d_width = 40;          // overall D width (X)
d_height = 20;         // overall D height (Y)
d_depth = 30;          // shell depth (Z)

wall_thickness = 2;

flange_thickness = 3;  // flange thickness (Z)
flange_width = 50;     // flange width (X)
flange_height = 30;    // flange height (Y)

hole_diameter = 3;
hole_offset = 6;       // from flange side edges (X)

pin_diameter = 1.5;
pin_spacing = 5;
pin_rows = 2;
pin_columns = 5;

boot_length = 10;
boot_diameter = 15;

// overlap to guarantee watertight unions
overlap = 1.2;

// -------------------- Helpers --------------------
module d2d(w, h) {
    // 2D D-shape centered at origin: flat on left, rounded on right
    r = h/2;
    union() {
        translate([w/2 - r, 0]) circle(r=r);
        translate([-(w/2 - r)/2, 0]) square([w - 2*r, h], center=true);
    }
}

module d3d(w, h, z) {
    linear_extrude(height=z, center=false) d2d(w, h);
}

// -------------------- Parts --------------------
module shell_with_cavity() {
    // Shell runs from z=0 (front/mating face) to z=d_depth (rear)
    difference() {
        // Outer shell
        d3d(d_width, d_height, d_depth);

        // Inner cavity: open at rear, leave a front wall thickness
        // Ensure cavity actually exists even if parameters change
        inner_h = max(0.01, d_depth - wall_thickness + overlap);
        translate([0, 0, wall_thickness])
            linear_extrude(height=inner_h, center=false)
                offset(delta=-wall_thickness)
                    d2d(d_width, d_height);
    }
}

module flange_with_holes() {
    // Flange plate centered on D, attached at front (z=0)
    // Place flange so its back face overlaps into shell at z=0 by "overlap"
    // Flange spans: z = -(flange_thickness - overlap) ... +overlap
    zc = -flange_thickness/2 + overlap;

    difference() {
        translate([0, 0, zc])
            cube([flange_width, flange_height, flange_thickness], center=true);

        // Mounting holes through flange thickness (along Z)
        for (sx = [-1, 1]) {
            translate([sx*(flange_width/2 - hole_offset), 0, zc])
                cylinder(h=flange_thickness + 2*overlap, d=hole_diameter, center=true);
        }
    }
}

module mounting_ears() {
    // Raised bosses around the mounting holes (typical D-sub ears),
    // centered on flange so they are guaranteed connected.
    boss_d = hole_diameter + 6;
    boss_h = flange_thickness + 2; // protrude slightly forward/back
    zc = -flange_thickness/2 + overlap; // same center as flange

    for (sx = [-1, 1]) {
        translate([sx*(flange_width/2 - hole_offset), 0, zc])
            difference() {
                cylinder(h=boss_h, d=boss_d, center=true);
                cylinder(h=boss_h + 2*overlap, d=hole_diameter, center=true);
            }
    }
}

module pin_array() {
    // Pins protrude out the front face (z<0) and overlap into the shell front wall.
    pin_len = 4;

    // Place pins so they extend out of the front and into the shell by "overlap"
    // Pins span: z = -(pin_len - overlap) ... +overlap
    zc = -pin_len/2 + overlap;

    // Fit pins within inner opening
    usable_w = d_width - 2*wall_thickness - 4;
    usable_h = d_height - 2*wall_thickness - 4;

    total_w = (pin_columns - 1) * pin_spacing;
    row_sep = pin_spacing * 0.9;

    x0 = -total_w/2;
    y0 = 0;

    for (r = [0:pin_rows-1]) {
        y = y0 + (r==0 ? row_sep/2 : -row_sep/2);
        x_shift = (r==0 ? pin_spacing/2 : 0); // stagger
        for (c = [0:pin_columns-1]) {
            x = x0 + c*pin_spacing + x_shift;

            if (abs(x) <= usable_w/2 && abs(y) <= usable_h/2)
                translate([x, y, zc])
                    cylinder(h=pin_len, d=pin_diameter, center=true);
        }
    }
}

module strain_relief_boot() {
    // Boot attached to rear (z=d_depth), centered on connector.
    // Overlap into shell by "overlap" so it is one solid.
    translate([0, 0, d_depth - overlap])
        cylinder(h=boot_length + overlap, d=boot_diameter, center=false);
}

// -------------------- Assembly --------------------
module d_sub_connector() {
    union() {
        // Front flange + ears (recognizable D-sub mounting)
        flange_with_holes();
        mounting_ears();

        // D-shaped shell body
        shell_with_cavity();

        // Pin array at mating face
        pin_array();

        // Rear strain relief boot
        strain_relief_boot();
    }
}

d_sub_connector();