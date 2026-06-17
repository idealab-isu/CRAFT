$fn = 96;

// Parameters
shaft_d = 9.0;
shaft_r = shaft_d/2;

block_w = 50.0;   // X
block_l = 85.0;   // Y
block_h = 24.0;   // Z

// Bearing bore (slightly oversized for clearance)
bore_d = 9.2;
bore_r = bore_d/2;

// Split clamp slot
slot_w = 2.0;     // X width of slot
slot_y = block_l; // full length
slot_z0 = 0;      // from bottom
slot_z1 = block_h;

// Mounting holes (4x)
mount_hole_d = 5.2;
mount_head_d = 9.5;
mount_head_h = 3.0;

edge_x = 10.0;
edge_y = 12.0;

// Clamp screw holes (2x) across the split
clamp_hole_d = 4.2;
clamp_head_d = 8.0;
clamp_head_h = 3.0;
clamp_nut_flat = 7.0; // M4-ish
clamp_nut_h = 3.2;

clamp_y_offset = 18.0;
clamp_z = block_h*0.65;

// Fillets (approximated by minkowski with small sphere)
fillet_r = 1.2;

module rounded_block(size=[block_w, block_l, block_h], r=1.2){
    // Keep renderable and not too heavy
    minkowski(){
        cube([size[0]-2*r, size[1]-2*r, size[2]-2*r], center=true);
        sphere(r=r);
    }
}

module counterbore_hole(d_thru, d_cb, h_cb, h_thru){
    // Along +Z
    union(){
        cylinder(d=d_thru, h=h_thru, center=false);
        translate([0,0,h_thru-h_cb]) cylinder(d=d_cb, h=h_cb, center=false);
    }
}

module hex_prism(flat=7, h=3){
    // flat-to-flat = flat
    // radius to vertices:
    r = flat / (2*cos(30));
    cylinder(r=r, h=h, $fn=6);
}

difference(){
    // Main body
    translate([0,0,block_h/2])
        rounded_block([block_w, block_l, block_h], fillet_r);

    // Shaft bore along Y (lengthwise)
    translate([0,0,block_h/2])
        rotate([90,0,0])
            cylinder(r=bore_r, h=block_l+2, center=true);

    // Split clamp slot (through)
    translate([-slot_w/2, -block_l/2-1, -1])
        cube([slot_w, block_l+2, block_h+2], center=false);

    // Mounting holes (4) from bottom with counterbore for socket head
    for (sx = [-1, 1], sy = [-1, 1]){
        x = sx*(block_w/2 - edge_x);
        y = sy*(block_l/2 - edge_y);
        translate([x, y, 0])
            counterbore_hole(mount_hole_d, mount_head_d, mount_head_h, block_h+0.5);
    }

    // Clamp screw holes (2) across X, with counterbore on +X side and nut trap on -X side
    for (yy = [-1, 1]){
        y = yy*clamp_y_offset;
        // Through hole along X
        translate([0, y, clamp_z])
            rotate([0,90,0])
                cylinder(d=clamp_hole_d, h=block_w+2, center=true);

        // Counterbore on +X side
        translate([block_w/2 - 0.01, y, clamp_z])
            rotate([0,90,0])
                cylinder(d=clamp_head_d, h=clamp_head_h+0.5, center=false);

        // Nut trap on -X side
        translate([-block_w/2 + 0.01, y, clamp_z])
            rotate([0,90,0])
                hex_prism(clamp_nut_flat, clamp_nut_h+0.5);
    }

    // Lightening pockets (optional) - shallow recesses on sides
    pocket_depth = 3.0;
    pocket_margin = 6.0;
    pocket_h = block_h - 6.0;

    // Left side pocket
    translate([-block_w/2 - 0.5, 0, block_h/2])
        rotate([0,90,0])
            translate([0,0,0])
                cube([block_l - 2*pocket_margin, pocket_h, pocket_depth+1], center=true);

    // Right side pocket
    translate([block_w/2 + 0.5, 0, block_h/2])
        rotate([0,90,0])
            cube([block_l - 2*pocket_margin, pocket_h, pocket_depth+1], center=true);
}