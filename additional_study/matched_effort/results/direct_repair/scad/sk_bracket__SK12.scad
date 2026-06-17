$fn=96;

// Parameters
rod_d = 12.0;
rod_r = rod_d/2;

bracket_height = 23.0;      // overall height
base_len = 42.0;            // along X
base_w   = 20.0;            // along Y
base_th  = 6.0;             // along Z

wall_th  = 6.0;             // clamp wall thickness around bore
cap_th   = 6.0;             // thickness above bore to reach height

// Derived
bore_center_z = base_th + rod_r + cap_th; // ensures top reaches bracket_height
// Adjust cap_th if needed to hit exact height
cap_th = bracket_height - (base_th + rod_r);
bore_center_z = base_th + rod_r;

// Clamp block dimensions
block_len = base_len;
block_w   = base_w;
block_h   = bracket_height;

// Mount holes
mount_hole_d = 5.2;         // for M5 clearance
mount_csk_d  = 9.5;         // counterbore diameter
mount_csk_h  = 3.0;         // counterbore depth
mount_x_off  = 14.0;        // from center to each hole
mount_y      = 0;

// Clamp slit + screw
slit_w = 2.0;
clamp_screw_d = 5.2;        // M5 clearance
clamp_nut_flat = 8.2;       // M5 nut across flats
clamp_nut_th   = 4.2;
clamp_screw_z  = bore_center_z; // through clamp at bore height
clamp_screw_y  = 0;
clamp_screw_x  = 0;

// Helpers
module hex_prism(af, h){
    // across flats -> circumradius
    r = af / (2*cos(180/6));
    cylinder(r=r, h=h, $fn=6);
}

difference() {
    // Main body: base + upper clamp block (single block)
    translate([-block_len/2, -block_w/2, 0])
        cube([block_len, block_w, block_h]);

    // Rod bore (through Y)
    translate([0, 0, bore_center_z])
        rotate([90,0,0])
            cylinder(d=rod_d, h=block_w+2, center=true);

    // Open-top relief to make it a "support" (U-shape): remove above bore on top center
    // Leaves side walls and top cap thickness minimal; creates a saddle-like support.
    // Cut a slot from top down to just above bore center.
    top_relief_w = rod_d + 2.0; // opening width
    top_relief_len = block_len - 8.0;
    translate([-top_relief_len/2, -top_relief_w/2, bore_center_z + rod_r*0.15])
        cube([top_relief_len, top_relief_w, block_h - (bore_center_z + rod_r*0.15) + 1]);

    // Clamp slit (front-to-back along Y) from top down past bore
    translate([-block_len/2-1, -slit_w/2, bore_center_z - rod_r - 1])
        cube([block_len+2, slit_w, block_h - (bore_center_z - rod_r - 1) + 1]);

    // Clamp screw hole (through X)
    translate([0, clamp_screw_y, clamp_screw_z])
        rotate([0,90,0])
            cylinder(d=clamp_screw_d, h=block_len+2, center=true);

    // Nut trap on one side (left)
    nut_trap_len = 6.5;
    translate([-block_len/2 - 0.01, 0, clamp_screw_z])
        rotate([0,90,0])
            hex_prism(clamp_nut_flat, nut_trap_len);

    // Screw head counterbore on other side (right)
    head_cb_d = 10.0;
    head_cb_h = 4.0;
    translate([block_len/2 - head_cb_h + 0.01, 0, clamp_screw_z])
        rotate([0,90,0])
            cylinder(d=head_cb_d, h=head_cb_h+0.5, center=false);

    // Mounting holes (through Z) with counterbores from bottom
    for (sx = [-1, 1]) {
        x = sx * mount_x_off;
        // through hole
        translate([x, mount_y, -1])
            cylinder(d=mount_hole_d, h=base_th+2);
        // counterbore
        translate([x, mount_y, -1])
            cylinder(d=mount_csk_d, h=mount_csk_h+1);
    }

    // Undercut to emphasize base plate (optional): remove material above base outside clamp region
    // Keeps a stronger clamp area in the middle.
    undercut_margin = 6.0;
    undercut_h = block_h - base_th;
    translate([-block_len/2, -block_w/2, base_th])
        difference() {
            cube([block_len, block_w, undercut_h+1]);
            // keep central rib
            rib_w = rod_d + 2*wall_th;
            rib_len = block_len - 2*undercut_margin;
            translate([(block_len-rib_len)/2, (block_w-rib_w)/2, -1])
                cube([rib_len, rib_w, undercut_h+3]);
        }
}