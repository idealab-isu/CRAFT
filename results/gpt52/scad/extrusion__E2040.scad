$fn=64;

module tslot_2040_profile(length=100, w=40, h=20, corner_r=1.5, slot_w=6, slot_d=6, center_hole_d=5.2) {
    difference() {
        linear_extrude(height=length, center=true, convexity=10)
            offset(r=corner_r)
                square([w-2*corner_r, h-2*corner_r], center=true);

        // Center bore
        cylinder(h=length+2, d=center_hole_d, center=true);

        // T-slots (approximate) on all four faces
        for (rot = [0, 90, 180, 270]) {
            rotate([0,0,rot]) {
                // Slot on +Y face
                translate([0, h/2 - slot_d/2, 0])
                    cube([slot_w, slot_d, length+2], center=true);
            }
        }
    }
}

tslot_2040_profile(100, 40, 20, 1.5, 6, 6, 5.2);