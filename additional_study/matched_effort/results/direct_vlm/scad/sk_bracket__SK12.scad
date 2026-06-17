$fn = 128;

// Shaft support bracket for 12.0mm rod, 23.0mm tall (overall Z)

// -------------------- Parameters --------------------
rod_d = 12.0;
rod_r = rod_d/2;

bracket_h = 23.0;          // overall height (Z)

base_len = 42.0;           // along X
base_w   = 20.0;           // along Y
base_th  = 6.0;            // base thickness (Z)

wall_th   = 5.0;           // clamp wall thickness around bore
inner_len = 18.0;          // clamp length along X (bore length)

top_margin = 3.0;          // material above rod top to bracket top

clamp_gap = 2.0;           // slit width for clamp (Y)
clamp_bolt_d = 5.2;        // clearance for M5
clamp_bolt_head_d = 9.5;   // counterbore for socket head / washer
clamp_bolt_head_h = 3.0;

mount_hole_d = 5.2;        // base mounting holes (M5)
mount_csk_d  = 10.0;       // counterbore diameter
mount_csk_h  = 2.5;

eps = 0.2;

// -------------------- Derived --------------------
outer_len = inner_len + 2*wall_th;                 // clamp block length (X)
outer_w   = (rod_d + 2.0) + 2*wall_th;             // clamp block width (Y)
outer_h   = bracket_h - base_th;                   // clamp block height above base (Z)

clamp_z0 = base_th;
clamp_z1 = base_th + outer_h;

// Rod center set to guarantee: overall height = bracket_h and full circular bore visible
rod_center_z = bracket_h - top_margin - rod_r;

// Keep bore fully inside clamp block with small safety margins
rod_center_z = max(rod_center_z, clamp_z0 + rod_r + 1.0);
rod_center_z = min(rod_center_z, clamp_z1 - (rod_r + top_margin));

// Mount hole spacing
hole_x = base_len * 0.28;

// Clamp bolt placement (above rod center, below top)
bolt_z = min(rod_center_z + rod_r*0.55, bracket_h - 2.0);

// Gussets (triangular ribs) to read clearly as a bracket
gus_h = min(10, outer_h - 1);
gus_l = min(14, (base_len - outer_len)/2 + outer_len/2 - 1); // keep within base footprint

// -------------------- Modules --------------------
module bracket_body() {
    union() {
        // Base plate (centered)
        translate([-base_len/2, -base_w/2, 0])
            cube([base_len, base_w, base_th], center=false);

        // Upright clamp block centered on base
        translate([-outer_len/2, -outer_w/2, base_th])
            cube([outer_len, outer_w, outer_h], center=false);

        // Two gussets connecting base to clamp block (fully overlapping both)
        for (sx = [-1, 1]) {
            // Gusset spans from near clamp block out toward base end
            // Place so its vertical edge overlaps clamp block side by ~1mm
            gus_x0 = sx*(outer_len/2 - 1);                 // near clamp side (overlap)
            gus_x1 = sx*(outer_len/2 + gus_l);             // toward base end
            translate([min(gus_x0, gus_x1), -base_w/2, 0])
                linear_extrude(height=base_w)
                    polygon(points=[
                        [0, 0],
                        [abs(gus_x1 - gus_x0), 0],
                        [0, base_th + gus_h]
                    ]);
        }
    }
}

module subtract_features() {
    // Full 12mm rod bore through X (clearance +0.25)
    translate([0, 0, rod_center_z])
        rotate([0, 90, 0])
            cylinder(h=outer_len + 2, r=rod_r + 0.25, center=true);

    // Clamp slit from top down past rod center (visible split)
    slit_z_top = bracket_h + 0.5;
    slit_z_bot = rod_center_z - rod_r - 0.8; // slightly below rod bottom
    slit_depth = slit_z_top - slit_z_bot;

    translate([0, 0, slit_z_bot + slit_depth/2])
        cube([outer_len + 2, clamp_gap, slit_depth], center=true);

    // Clamp bolt hole through Y (cross-bolt)
    translate([0, 0, bolt_z])
        rotate([90, 0, 0])
            cylinder(h=outer_w + 2, r=clamp_bolt_d/2, center=true);

    // Counterbores for clamp bolt head/nut on both sides (Y)
    for (sy = [-1, 1]) {
        translate([0, sy*(outer_w/2 - clamp_bolt_head_h/2 + eps), bolt_z])
            rotate([90, 0, 0])
                cylinder(h=clamp_bolt_head_h + 2*eps, r=clamp_bolt_head_d/2, center=true);
    }

    // Base mounting holes (two), through Z with counterbore from top
    for (sx = [-1, 1]) {
        translate([sx*hole_x, 0, -0.5])
            cylinder(h=base_th + 1.0, r=mount_hole_d/2, center=false);

        translate([sx*hole_x, 0, base_th - mount_csk_h])
            cylinder(h=mount_csk_h + 0.5, r=mount_csk_d/2, center=false);
    }

    // Lighten pocket under clamp block (keeps walls, stays connected)
    pocket_len = inner_len + 2.0;
    pocket_w   = (rod_d + 2.0) + 2.0;
    pocket_h   = max(0, outer_h * 0.55);

    translate([-pocket_len/2, -pocket_w/2, base_th + 1.0])
        cube([pocket_len, pocket_w, pocket_h], center=false);
}

// -------------------- Build --------------------
difference() {
    bracket_body();
    subtract_features();
}