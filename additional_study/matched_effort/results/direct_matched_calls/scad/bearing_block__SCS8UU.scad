$fn = 96;

// Linear bearing block for 6.0mm shaft
// Block size: 34.0mm x 30.0mm (X x Y). Height chosen as a practical default.

shaft_d = 6.0;
block_x = 34.0;
block_y = 30.0;
block_z = 16.0;

clearance = 0.25;          // general clearance for shaft/bearing fit
shaft_hole_d = shaft_d + 2*clearance;

bearing_od = 12.0;         // typical for 6mm linear bearing (LM6UU OD ~12mm)
bearing_len = 19.0;        // typical LM6UU length
bearing_clear = 0.25;
bearing_bore_d = bearing_od + 2*bearing_clear;

wall_min = 2.5;

// Place bearing pocket centered; if block_z too small, pocket will be through
pocket_z = min(bearing_len, block_z - 2*wall_min);
pocket_z = max(pocket_z, 8.0);

// Mounting holes (4x) with counterbore
mount_hole_d = 3.4;        // for M3 clearance
mount_cbore_d = 6.2;       // counterbore for M3 socket head
mount_cbore_depth = 3.0;

edge_margin_x = 5.0;
edge_margin_y = 5.0;

module rounded_block(x,y,z,r){
    r2 = min(r, min(x,y)/2 - 0.01);
    linear_extrude(height=z)
        offset(r=r2)
            square([x-2*r2, y-2*r2], center=true);
}

module bearing_block(){
    difference(){
        // Body
        rounded_block(block_x, block_y, block_z, r=2.0);

        // Shaft through-hole along X
        translate([0,0,block_z/2])
            rotate([0,90,0])
                cylinder(d=shaft_hole_d, h=block_x+2, center=true);

        // Bearing pocket (cylindrical) along X, centered
        translate([0,0,block_z/2])
            rotate([0,90,0])
                cylinder(d=bearing_bore_d, h=pocket_z, center=true);

        // Mounting holes (4) through Z with counterbore on top
        for (sx = [-1,1], sy = [-1,1]){
            xh = sx*(block_x/2 - edge_margin_x);
            yh = sy*(block_y/2 - edge_margin_y);

            // Through hole
            translate([xh, yh, -1])
                cylinder(d=mount_hole_d, h=block_z+2);

            // Counterbore (top)
            translate([xh, yh, block_z - mount_cbore_depth])
                cylinder(d=mount_cbore_d, h=mount_cbore_depth+1);
        }

        // Small relief slot on bottom to reduce print elephant foot / allow clamp flex
        slot_w = 2.0;
        slot_h = 1.2;
        translate([0,0,slot_h/2])
            cube([block_x-6, slot_w, slot_h], center=true);
    }
}

bearing_block();