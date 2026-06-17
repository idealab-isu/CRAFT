$fn=96;

// Linear bearing block for 8.0mm shaft
// Block size: 42.0mm x 36.0mm (X x Y)
// Includes: through bore, clamp slit, clamp screw holes, mounting holes, edge fillets (approx)

shaft_d = 8.0;
clearance = 0.35;          // bore clearance
bore_d = shaft_d + clearance;

block_x = 42.0;
block_y = 36.0;
block_z = 18.0;

corner_r = 3.0;            // outer corner radius
bore_z = block_z + 2.0;

slit_w = 1.2;              // clamp slit width
slit_x = block_x/2 + 1.0;  // slit reaches past center

// Clamp screws (across slit, along Y)
clamp_screw_d = 3.4;       // M3 clearance
clamp_head_d  = 6.2;       // counterbore for socket head
clamp_head_h  = 3.2;
clamp_y_off = 10.0;
clamp_z = block_z*0.65;

// Mounting holes (to mount block down to a plate)
mount_d = 4.5;             // M4 clearance
mount_cb_d = 8.5;          // counterbore
mount_cb_h = 4.0;
mount_x_off = 14.0;
mount_y_off = 12.0;

// Small relief around bore to reduce sharp edge
bore_chamfer_d = bore_d + 2.0;
bore_chamfer_h = 1.0;

module rounded_block(x,y,z,r){
    // Rounded rectangle prism via hull of cylinders
    hull(){
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*(x/2-r), sy*(y/2-r), 0])
                cylinder(h=z, r=r);
        }
    }
}

difference(){
    // Body
    translate([0,0,0])
        rounded_block(block_x, block_y, block_z, corner_r);

    // Shaft bore (along X)
    translate([0,0,block_z/2])
        rotate([0,90,0])
            cylinder(h=block_x+2, d=bore_d, center=true);

    // Bore edge relief (both ends)
    for (sx=[-1,1]){
        translate([sx*(block_x/2-0.5), 0, block_z/2])
            rotate([0,90,0])
                cylinder(h=bore_chamfer_h, d=bore_chamfer_d, center=true);
    }

    // Clamp slit (from +X side to bore)
    translate([block_x/2 - slit_x, -slit_w/2, 0])
        cube([slit_x + 1.0, slit_w, block_z+0.2], center=false);

    // Clamp screw holes (along Y, crossing slit)
    for (yy=[-clamp_y_off, clamp_y_off]){
        // Through hole
        translate([block_x/2 - 8.0, yy, clamp_z])
            rotate([90,0,0])
                cylinder(h=block_y+2, d=clamp_screw_d, center=true);

        // Counterbore from +Y side
        translate([block_x/2 - 8.0, block_y/2 - 0.01, clamp_z])
            rotate([90,0,0])
                cylinder(h=clamp_head_h, d=clamp_head_d, center=false);

        // Counterbore from -Y side (optional symmetry)
        translate([block_x/2 - 8.0, -block_y/2 + 0.01, clamp_z])
            rotate([-90,0,0])
                cylinder(h=clamp_head_h, d=clamp_head_d, center=false);
    }

    // Mounting holes (along Z)
    for (xx=[-mount_x_off, mount_x_off], yy=[-mount_y_off, mount_y_off]){
        // Through
        translate([xx, yy, -0.1])
            cylinder(h=block_z+0.2, d=mount_d, center=false);

        // Counterbore from top
        translate([xx, yy, block_z - mount_cb_h])
            cylinder(h=mount_cb_h+0.2, d=mount_cb_d, center=false);
    }
}