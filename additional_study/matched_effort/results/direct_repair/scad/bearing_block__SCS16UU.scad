$fn = 96;

// Linear bearing block for 9.0mm shaft
// Overall block size: 50.0mm x 44.0mm (X x Y)
// Thickness chosen as a practical default; adjust as needed.

shaft_d = 9.0;

block_x = 50.0;
block_y = 44.0;
block_z = 20.0;

wall = 4.0;                 // minimum wall around bore
bore_clearance = 0.3;       // clearance for shaft
bore_d = shaft_d + bore_clearance;

mount_hole_d = 5.2;         // M5 clearance
mount_counterbore_d = 9.5;  // counterbore for socket head
mount_counterbore_depth = 4.0;

edge_margin_x = 8.0;
edge_margin_y = 8.0;

slot_width = 3.0;           // clamp slit width
clamp_screw_d = 4.3;        // M4 clearance
clamp_nut_flat = 7.2;       // M4 nut across flats
clamp_nut_thick = 3.2;

fillet_r = 2.0;

module rounded_block(x,y,z,r){
    // 2D rounded rectangle extruded
    linear_extrude(height=z)
        offset(r=r)
            square([x-2*r, y-2*r], center=true);
}

module hex_prism(af, h){
    // across flats = af
    r = af / (2*cos(30));
    cylinder(h=h, r=r, $fn=6);
}

module bearing_block(){
    difference(){
        // Body
        translate([0,0,block_z/2])
            rounded_block(block_x, block_y, block_z, fillet_r);

        // Shaft bore (along X)
        translate([0,0,block_z/2])
            rotate([0,90,0])
                cylinder(h=block_x+2, d=bore_d, center=true);

        // Clamp slit from top down to bore
        // Slit centered on bore, runs along X
        slit_depth = block_z/2 + bore_d/2 + 1.0;
        translate([0,0,block_z - slit_depth/2])
            cube([block_x+2, slot_width, slit_depth], center=true);

        // Clamp screw across Y (tightens slit)
        // Place above bore, near top
        clamp_z = block_z*0.78;
        translate([0,0,clamp_z])
            rotate([90,0,0])
                cylinder(h=block_y+2, d=clamp_screw_d, center=true);

        // Nut trap on one side (negative Y)
        translate([0,-(block_y/2 - 3.0),clamp_z])
            rotate([90,0,0])
                hex_prism(clamp_nut_flat, clamp_nut_thick+0.6);

        // Mounting holes (4x), through Z with counterbore on top
        for (sx = [-1,1], sy = [-1,1]){
            x = sx*(block_x/2 - edge_margin_x);
            y = sy*(block_y/2 - edge_margin_y);

            // Through hole
            translate([x,y,0])
                cylinder(h=block_z+1, d=mount_hole_d, center=false);

            // Counterbore from top
            translate([x,y,block_z - mount_counterbore_depth])
                cylinder(h=mount_counterbore_depth+1, d=mount_counterbore_d, center=false);
        }

        // Lightening pockets (optional, keep walls)
        pocket_z = block_z - 6.0;
        if (pocket_z > 2){
            pocket_x = block_x - 2*(wall+3.0);
            pocket_y = block_y - 2*(wall+3.0);
            translate([0,0,3.0 + pocket_z/2])
                linear_extrude(height=pocket_z)
                    offset(r=1.5)
                        square([pocket_x-3.0, pocket_y-3.0], center=true);
        }
    }
}

bearing_block();