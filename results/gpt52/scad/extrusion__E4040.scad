$fn=64;

module extrusion_4040(length=100, size=40, wall=2, slot=6, slot_depth=8, center_hole_d=8) {
    difference() {
        translate([0,0,-length/2])
            cube([size,size,length], center=false);

        // Center hole
        cylinder(h=length+2, d=center_hole_d, center=true);

        // Inner cavity to create wall thickness
        translate([0,0,-(length+2)/2])
            cube([size-2*wall, size-2*wall, length+2], center=false);

        // T-slots on four sides
        for (a = [0,90,180,270]) {
            rotate([0,0,a]) {
                // Slot opening
                translate([size/2 - slot_depth/2, 0, 0])
                    cube([slot_depth, slot, length+2], center=true);
                // Slot undercut (wider inside)
                translate([size/2 - (slot_depth + wall)/2, 0, 0])
                    cube([slot_depth + wall, slot + 4, length+2], center=true);
            }
        }
    }
}

extrusion_4040(100, 40, 2, 6, 8, 8);