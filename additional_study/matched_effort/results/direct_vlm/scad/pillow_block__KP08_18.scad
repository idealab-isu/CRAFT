$fn = 128;

// Pillow block bearing (UCP-style simplified) for 8.0mm shaft
// Base footprint: 55.0mm (X) x 42.0mm (Y)
// One connected solid; all placements derived from dimensions.

shaft_d = 8.0;

// Base
base_L  = 55.0;
base_W  = 42.0;
base_th = 8.0;

// Mounting holes (2x along X)
mount_hole_d = 6.5;          // clearance for M6
mount_hole_x = 40.0;         // center-to-center along X
mount_cbore_d = 12.0;
mount_cbore_h = 3.2;

// Housing (bore along X)
boss_outer_d = 34.0;
boss_len     = 30.0;

// Bearing seat / counterbore (visual insert pocket)
seat_d   = 22.0;
seat_len = 18.0;

// End reliefs (slightly larger than shaft)
bore_relief_d   = shaft_d + 2.0;
bore_relief_len = 6.0;

// Cap block (top)
cap_th    = 8.0;
cap_len   = 34.0;
cap_width = 38.0;

// Split line
split_w = 1.2;
split_h = 18.0;

// Set screw (radial, along Y)
set_screw_d = 4.2;

// Rounding
fillet_r = 3.0;

eps = 0.25;

module rounded_box(size=[10,10,10], r=2) {
    r2 = min(r, min(size[0], min(size[1], size[2]))/2);
    minkowski() {
        cube([size[0]-2*r2, size[1]-2*r2, size[2]-2*r2], center=true);
        sphere(r=r2);
    }
}

module pillow_block() {

    // Place boss so it clearly rises from base and overlaps into it
    boss_center_z = base_th + boss_outer_d/2 - 1.5;  // overlap into base
    boss_bottom_z = boss_center_z - boss_outer_d/2;
    boss_top_z    = boss_center_z + boss_outer_d/2;

    // Cheek block to blend base to boss (connected to both)
    cheek_L = boss_len + 6.0;
    cheek_W = base_W - 8.0;
    cheek_bottom_z = base_th/2 - eps;
    cheek_top_z    = boss_center_z + boss_outer_d*0.10; // slightly above center for stronger blend
    cheek_H = cheek_top_z - cheek_bottom_z;

    // Cap sits on top of boss with overlap
    cap_center_z = boss_top_z - cap_th/2 + eps;

    // Set screw slightly above bore center
    set_screw_z = boss_center_z + boss_outer_d*0.18;

    // Small mounting pads (feet) around bolt holes, connected to base
    pad_L = 16.0;
    pad_W = 18.0;
    pad_H = 4.0;
    pad_center_z = base_th + pad_H/2 - eps;

    difference() {
        union() {
            // Base
            translate([0,0,base_th/2])
                rounded_box([base_L, base_W, base_th], r=fillet_r);

            // Feet pads at bolt locations (make bolt pattern evident)
            for (sx=[-1,1]) {
                translate([sx*mount_hole_x/2, 0, pad_center_z])
                    rounded_box([pad_L, pad_W, pad_H], r=2.0);
            }

            // Main cylindrical housing (along X)
            translate([0,0,boss_center_z])
                rotate([0,90,0])
                    cylinder(d=boss_outer_d, h=boss_len, center=true);

            // Cheeks (blend into base and boss)
            translate([0,0,cheek_bottom_z + cheek_H/2])
                rounded_box([cheek_L, cheek_W, cheek_H], r=2.5);

            // Top cap block (split-cap look)
            translate([0,0,cap_center_z])
                rounded_box([cap_len, cap_width, cap_th], r=2.5);
        }

        // Shaft bore (through, along X)
        translate([0,0,boss_center_z])
            rotate([0,90,0])
                cylinder(d=shaft_d, h=boss_len + 2.0, center=true);

        // Bearing seat (counterbore) centered in housing
        translate([0,0,boss_center_z])
            rotate([0,90,0])
                cylinder(d=seat_d, h=seat_len, center=true);

        // End reliefs at both ends of bore (slightly larger)
        translate([0,0,boss_center_z])
            rotate([0,90,0])
                cylinder(d=bore_relief_d, h=bore_relief_len, center=true);

        // Mounting holes through base (Z)
        for (sx=[-1,1]) {
            translate([sx*mount_hole_x/2, 0, base_th/2])
                cylinder(d=mount_hole_d, h=base_th + pad_H + 2.0, center=true);

            // Shallow counterbore for washer (top side)
            translate([sx*mount_hole_x/2, 0, base_th + pad_H - mount_cbore_h/2 + eps])
                cylinder(d=mount_cbore_d, h=mount_cbore_h, center=true);
        }

        // Set screw hole (along Y) through boss
        translate([0,0,set_screw_z])
            rotate([90,0,0])
                cylinder(d=set_screw_d, h=base_W + 10.0, center=true);

        // Split line slot (cap split) along X at top
        translate([0,0,boss_top_z - split_h/2 + eps])
            cube([boss_len + 2.0, split_w, split_h], center=true);
    }
}

pillow_block();