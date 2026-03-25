$fn=64;

module extrusion_4040(length=100, size=40, wall=2.0, slot=8.0, slot_depth=10.0, center_hole_d=6.8) {
    difference() {
        translate([0,0,-length/2])
            cube([size,size,length], center=false);

        // Center hole
        cylinder(h=length+2, d=center_hole_d, center=true);

        // Inner lightening pocket
        translate([0,0,-length/2-1])
            cube([size-2*wall, size-2*wall, length+2], center=true);

        // T-slots on 4 sides (approximated)
        for (a=[0,90,180,270]) {
            rotate([0,0,a]) {
                // Slot opening
                translate([0, size/2 - slot_depth/2, 0])
                    cube([slot, slot_depth, length+2], center=true);

                // Slot cavity (wider inside)
                translate([0, size/2 - slot_depth - 6/2, 0])
                    cube([slot+6, 6, length+2], center=true);
            }
        }
    }
}

extrusion_4040(100, 40);