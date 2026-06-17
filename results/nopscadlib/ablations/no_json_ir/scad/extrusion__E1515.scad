$fn = 64;

module t_slot_1515(length=100, size=15) {
    // Typical 15x15 T-slot style (approximate), extruded along Z
    wall = 1.5;          // outer wall thickness
    slot_w = 6.0;        // slot opening width at the face
    slot_d = 4.2;        // slot depth from face inward
    throat_w = 3.2;      // narrower throat near the center
    web = 1.2;           // material between throat and center bore
    bore_r = 2.5;        // center bore radius

    eps = 0.02;

    difference() {
        // Outer body
        cube([size, size, length], center=true);

        // Four T-slots (one per face), cut as a union of two rectangles:
        // - outer opening (wider)
        // - inner throat (narrower), reaching close to the center
        for (a = [0:90:270]) {
            rotate([0, 0, a]) {
                // Outer opening
                translate([0, size/2 - slot_d/2 + eps, 0])
                    cube([slot_w, slot_d + 2*eps, length + 2], center=true);

                // Inner throat
                throat_len = size/2 - slot_d - (bore_r + web);
                translate([0, (bore_r + web) + throat_len/2, 0])
                    cube([throat_w, throat_len + 2*eps, length + 2], center=true);
            }
        }

        // Center bore
        cylinder(r=bore_r, h=length + 2, center=true);
    }
}

t_slot_1515(length=100, size=15);