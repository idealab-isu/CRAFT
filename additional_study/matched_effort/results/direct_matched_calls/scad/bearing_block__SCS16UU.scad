$fn = 96;

// Linear bearing block for 9.0mm shaft
// Overall block size: 50.0mm x 44.0mm (X x Y)
// Thickness chosen as a practical default; adjust as needed.

shaft_d = 9.0;

block_x = 50.0;
block_y = 44.0;
block_z = 20.0;

corner_r = 4.0;

// Bearing bore (through)
bore_d = shaft_d + 0.4;          // clearance for 9mm shaft
bore_z_extra = 2.0;

// Split clamp slot
slot_w = 2.0;
slot_x = block_x;                // full length slot
slot_y = 18.0;                   // slot depth into block from one side

// Clamp screw holes (2x), across the slot (Y direction), with nut traps
clamp_hole_d = 5.2;              // M5 clearance
clamp_head_d = 9.5;              // socket head clearance
clamp_head_h = 5.0;

nut_flat = 8.2;                  // M5 nut across flats
nut_thk  = 4.2;
nut_trap_depth = 4.6;

// Mounting holes (4x) from top face
mount_hole_d = 5.2;              // M5 clearance
mount_counterbore_d = 9.5;
mount_counterbore_h = 5.0;

mount_margin_x = 8.0;
mount_margin_y = 8.0;

// Grease/relief pocket around bore (optional)
relief_d = bore_d + 8.0;
relief_h = 2.0;

module rounded_block(x,y,z,r){
    // Rounded rectangle prism via hull of cylinders
    hull(){
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*(x/2 - r), sy*(y/2 - r), 0])
                cylinder(h=z, r=r);
        }
    }
}

module hex_prism(af, h){
    // Regular hex with across-flats = af
    r = af / (2*cos(30));
    cylinder(h=h, r=r, $fn=6);
}

difference(){
    // Body
    translate([0,0,0])
        rounded_block(block_x, block_y, block_z, corner_r);

    // Main bore (X axis)
    translate([0,0,block_z/2])
        rotate([0,90,0])
            cylinder(h=block_x + 2*bore_z_extra, d=bore_d, center=true);

    // Relief pocket around bore on top face
    translate([0,0,block_z - relief_h])
        rotate([0,90,0])
            cylinder(h=block_x + 2*bore_z_extra, d=relief_d, center=true);

    // Split clamp slot from +Y side to bore
    translate([0, block_y/2 - slot_y/2, block_z/2])
        cube([slot_x + 2, slot_y, slot_w], center=true);

    // Clamp screw holes (2x), along Y, crossing slot near bore
    for (xpos = [-block_x*0.18, block_x*0.18]){
        // Through hole
        translate([xpos, 0, block_z/2])
            rotate([90,0,0])
                cylinder(h=block_y + 2, d=clamp_hole_d, center=true);

        // Head clearance on -Y side
        translate([xpos, -block_y/2 + clamp_head_h/2 + 0.2, block_z/2])
            rotate([90,0,0])
                cylinder(h=clamp_head_h + 0.4, d=clamp_head_d, center=true);

        // Nut trap on +Y side
        translate([xpos, block_y/2 - nut_trap_depth/2 - 0.2, block_z/2])
            rotate([90,0,0])
                hex_prism(nut_flat, nut_trap_depth + 0.4);
    }

    // Mounting holes (4x) from top face (Z direction)
    for (xpos = [-(block_x/2 - mount_margin_x), (block_x/2 - mount_margin_x)])
    for (ypos = [-(block_y/2 - mount_margin_y), (block_y/2 - mount_margin_y)]){
        // Through hole
        translate([xpos, ypos, block_z/2])
            cylinder(h=block_z + 2, d=mount_hole_d, center=true);

        // Counterbore from top
        translate([xpos, ypos, block_z - mount_counterbore_h/2])
            cylinder(h=mount_counterbore_h + 0.2, d=mount_counterbore_d, center=true);
    }
}