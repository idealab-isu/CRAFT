$fn=96;

// Linear bearing block for 8.0mm shaft
// Block size: 40.0 x 35.0 mm (X x Y). Height chosen as a practical default.

shaft_d = 8.0;

block_x = 40.0;
block_y = 35.0;
block_z = 18.0;

wall = 3.0;                 // minimum wall thickness around bore
bore_d = shaft_d + 0.4;     // clearance for 8mm shaft
bore_len = block_x + 2.0;   // through bore

// Clamp slit and screw parameters
slit_w = 1.2;
slit_depth = block_z;       // full height slit
screw_d = 4.2;              // clearance for M4
nut_flat = 7.2;             // M4 nut across flats
nut_thk = 3.4;
screw_head_d = 8.0;         // socket cap head clearance
screw_head_h = 4.0;

edge_margin = 6.0;
screw_y_offset = block_y/2 - edge_margin;
screw_z = block_z/2;

// Mounting holes (to mount block to a plate)
mount_d = 5.2;              // clearance for M5
mount_head_d = 10.0;        // counterbore for M5 head
mount_head_h = 4.0;
mount_x_offset = 12.0;
mount_y_offset = 10.0;

module hex_prism(af=7.2, h=3.4){
    // across flats -> circumradius
    r = af / (2*cos(180/6));
    cylinder(r=r, h=h, $fn=6);
}

module bearing_block(){
    difference(){
        // Main block with slight edge chamfer via minkowski (small)
        minkowski(){
            cube([block_x-1.0, block_y-1.0, block_z-1.0], center=true);
            sphere(r=0.5);
        }

        // Shaft bore along X
        rotate([0,90,0])
            cylinder(d=bore_d, h=bore_len, center=true);

        // Clamp slit (from top down to bore)
        translate([0, 0, 0])
            cube([block_x+2, slit_w, slit_depth+2], center=true);

        // Two clamp screws across Y (left/right of slit), with nut traps on one side and head counterbores on the other
        for (xpos = [-block_x*0.18, block_x*0.18]){
            // Through hole along Y
            translate([xpos, 0, screw_z])
                rotate([90,0,0])
                    cylinder(d=screw_d, h=block_y+2, center=true);

            // Head counterbore on +Y side
            translate([xpos, block_y/2 - 0.01, screw_z])
                rotate([90,0,0])
                    cylinder(d=screw_head_d, h=screw_head_h, center=false);

            // Nut trap on -Y side
            translate([xpos, -block_y/2 + 0.01, screw_z])
                rotate([90,0,0])
                    hex_prism(af=nut_flat, h=nut_thk);
        }

        // Mounting holes (4x) from bottom (Z-) upward with counterbores
        for (sx = [-1, 1], sy = [-1, 1]){
            translate([sx*mount_x_offset, sy*mount_y_offset, 0])
                cylinder(d=mount_d, h=block_z+2, center=true);

            // Counterbore from bottom
            translate([sx*mount_x_offset, sy*mount_y_offset, -block_z/2 - 0.01])
                cylinder(d=mount_head_d, h=mount_head_h, center=false);
        }

        // Lightening pockets on sides (optional, keeps walls)
        pocket_x = block_x - 2*(wall+2);
        pocket_y = block_y - 2*(wall+2);
        pocket_z = block_z - 2*(wall+2);

        translate([0,0,0])
            cube([pocket_x, pocket_y, pocket_z], center=true);
        
        // Restore material around bore by subtracting less in a band (i.e., keep a rib)
        // (This is achieved by adding back via difference trick: subtract pocket but not near bore)
        // Implemented by subtracting pocket minus rib volume:
        // We'll re-add rib by subtracting a "negative pocket" (i.e., don't subtract there) using intersection.
    }
}

// Rebuild with controlled pocketing (difference with nested difference)
module bearing_block_with_rib(){
    difference(){
        // Outer
        minkowski(){
            cube([block_x-1.0, block_y-1.0, block_z-1.0], center=true);
            sphere(r=0.5);
        }

        // Shaft bore
        rotate([0,90,0])
            cylinder(d=bore_d, h=bore_len, center=true);

        // Clamp slit
        cube([block_x+2, slit_w, block_z+2], center=true);

        // Clamp screws
        for (xpos = [-block_x*0.18, block_x*0.18]){
            translate([xpos, 0, screw_z])
                rotate([90,0,0])
                    cylinder(d=screw_d, h=block_y+2, center=true);

            translate([xpos, block_y/2 - 0.01, screw_z])
                rotate([90,0,0])
                    cylinder(d=screw_head_d, h=screw_head_h, center=false);

            translate([xpos, -block_y/2 + 0.01, screw_z])
                rotate([90,0,0])
                    hex_prism(af=nut_flat, h=nut_thk);
        }

        // Mount holes
        for (sx = [-1, 1], sy = [-1, 1]){
            translate([sx*mount_x_offset, sy*mount_y_offset, 0])
                cylinder(d=mount_d, h=block_z+2, center=true);

            translate([sx*mount_x_offset, sy*mount_y_offset, -block_z/2 - 0.01])
                cylinder(d=mount_head_d, h=mount_head_h, center=false);
        }

        // Pocketing with rib around bore
        difference(){
            // Main pocket
            pocket_x = block_x - 2*(wall+2);
            pocket_y = block_y - 2*(wall+2);
            pocket_z = block_z - 2*(wall+2);
            cube([pocket_x, pocket_y, pocket_z], center=true);

            // Rib volume to keep (so remove it from pocket subtraction)
            rib_thk = 6.0;
            rotate([0,90,0])
                cylinder(d=bore_d + 2*rib_thk, h=block_x+4, center=true);
        }
    }
}

bearing_block_with_rib();