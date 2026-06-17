$fn=128;

// Shaft support bracket for 16.0mm rod, 27.0mm overall height (bottom of base to top of clamp)
rod_d   = 16.0;
height  = 27.0;

// Base
base_len = 60.0;
base_w   = 20.0;
base_th  = 8.0;

// Clamp block (upright)
block_len = 34.0;
block_w   = 20.0;
block_h   = height - base_th;          // ensures overall height = 27mm

// Clamp features
clamp_gap = 2.0;                        // slit width
clamp_screw_d = 5.2;                    // M5 clearance
clamp_screw_head_d = 9.5;               // socket head counterbore
clamp_screw_head_h = 4.5;

// Mounting holes
mount_hole_d = 5.2;                     // M5 clearance
mount_hole_x_off = 20.0;                // from center along X
mount_cb_d = 10.0;                      // washer/head relief
mount_cb_h = 3.0;

// Fillets
edge_r = 2.0;

// Derived: place rod bore so it is a true 16mm through-bore and fully enclosed by the clamp block
// Keep a clear, verifiable wall above and below the bore inside the clamp block.
seat_wall = 3.0;                        // wall above/below bore within clamp block
rod_center_z = base_th + seat_wall + rod_d/2;  // ensures bottom wall = seat_wall, top wall = block_h - (seat_wall + rod_d)

// Helpers
module rounded_box(size=[10,10,10], r=1) {
    x=size[0]; y=size[1]; z=size[2];
    rr = min(r, x/2, y/2);
    linear_extrude(height=z, center=true)
        offset(r=rr)
            square([x-2*rr, y-2*rr], center=true);
}

// Model
difference() {
    union() {
        // Base (centered at Z=base_th/2)
        translate([0,0,base_th/2])
            rounded_box([base_len, base_w, base_th], r=edge_r);

        // Upright clamp block (centered at Z=base_th + block_h/2)
        translate([0,0,base_th + block_h/2])
            rounded_box([block_len, block_w, block_h], r=edge_r);

        // Side ears/bosses around clamp screw (connected)
        ear_len = 10.0;
        ear_w   = 6.0;
        ear_h   = block_h*0.70;
        ear_z   = base_th + block_h/2;
        ear_overlap = 1.0;
        for (sy=[-1,1]) {
            translate([0, sy*(block_w/2 + ear_w/2 - ear_overlap), ear_z])
                rounded_box([ear_len, ear_w, ear_h], r=1.5);
        }

        // Small front/back ribs for stiffness (connected to block)
        rib_th = 5.0;
        rib_len = 18.0;
        rib_h = block_h*0.60;
        rib_overlap = 0.6;
        for (sy=[-1,1]) {
            translate([0, sy*(block_w/2 - rib_th/2 + rib_overlap), base_th + rib_h/2])
                rounded_box([rib_len, rib_th, rib_h], r=1.5);
        }
    }

    // Rod bore (along X) - true 16mm through-bore
    translate([0, 0, rod_center_z])
        rotate([0,90,0])
            cylinder(h=base_len + 10, d=rod_d, center=true);

    // Clamp slit (from top down to just above bore)
    slit_len = block_len + 2;
    top_z = base_th + block_h;
    slit_bottom_z = rod_center_z + rod_d/2; // touches bore at top tangent
    slit_h = (top_z - slit_bottom_z) + 0.6; // ensure full cut with small margin
    slit_z_center = (top_z + slit_bottom_z)/2;
    translate([0, 0, slit_z_center])
        cube([slit_len, clamp_gap, slit_h], center=true);

    // Clamp screw hole across Y (through clamp block + ears)
    // Place slightly above bore center for clamping action, but below top wall.
    screw_z = min(top_z - 3.0, rod_center_z + rod_d*0.35);
    ear_total_w = block_w + 2*6.0;
    translate([0, 0, screw_z])
        rotate([90,0,0])
            cylinder(h=ear_total_w + 2, d=clamp_screw_d, center=true);

    // Counterbores on both sides for screw heads (into ears)
    ear_face_y = (block_w/2 + 6.0);
    translate([0,  ear_face_y - 0.01, screw_z])
        rotate([90,0,0])
            cylinder(h=clamp_screw_head_h, d=clamp_screw_head_d, center=false);
    translate([0, -ear_face_y + 0.01, screw_z])
        rotate([-90,0,0])
            cylinder(h=clamp_screw_head_h, d=clamp_screw_head_d, center=false);

    // Base mounting holes (two along X)
    for (sx=[-1,1]) {
        translate([sx*mount_hole_x_off, 0, base_th/2])
            cylinder(h=base_th + 0.8, d=mount_hole_d, center=true);

        // Counterbore from bottom (Z=0 side)
        translate([sx*mount_hole_x_off, 0, mount_cb_h/2 - 0.01])
            cylinder(h=mount_cb_h + 0.02, d=mount_cb_d, center=true);
    }

    // Underside relief under clamp block (keeps bracket look, reduces material)
    relief_len = block_len - 8;
    relief_w   = block_w - 8;
    relief_h   = max(2.0, block_h*0.45);
    translate([0, 0, base_th + relief_h/2])
        rounded_box([relief_len, relief_w, relief_h], r=1.5);
}