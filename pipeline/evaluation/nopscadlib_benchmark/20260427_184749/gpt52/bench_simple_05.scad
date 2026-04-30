$fn=64;

bearing_od = 15;
bearing_len = 24;
shaft_d = 8;

wall = 3;
clearance = 0.3;

block_len = bearing_len + 2*wall;
block_w   = bearing_od + 2*wall;
block_h   = bearing_od + 2*wall;

clamp_gap = 2.0;
screw_d = 3.2;
screw_head_d = 6.2;
screw_head_h = 2.2;
screw_offset_y = (block_w/2 - wall/2);

module lm8uu_holder() {
    difference() {
        union() {
            cube([block_len, block_w, block_h], center=true);
        }

        // Bearing pocket (along X)
        rotate([0,90,0])
            cylinder(d=bearing_od + clearance, h=block_len + 2, center=true);

        // Through shaft clearance (optional, along X)
        rotate([0,90,0])
            cylinder(d=shaft_d + 1.0, h=block_len + 2, center=true);

        // Clamp slit (opens to +Z)
        translate([0,0,block_h/4])
            cube([block_len + 2, clamp_gap, block_h], center=true);

        // Two clamp screw holes (along Y), with counterbore for heads on +Y side
        for (xpos = [-block_len/4, block_len/4]) {
            // Through hole
            translate([xpos, 0, 0])
                rotate([90,0,0])
                    cylinder(d=screw_d, h=block_w + 2, center=true);

            // Counterbore on +Y side
            translate([xpos, block_w/2 - screw_head_h/2, 0])
                rotate([90,0,0])
                    cylinder(d=screw_head_d, h=screw_head_h + 0.2, center=true);
        }
    }
}

lm8uu_holder();