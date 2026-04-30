$fn = 64;

module t_slot_extrusion() {
    difference() {
        // Outer square profile with corner fillets
        offset(r=0.5) {
            square([14, 14], center=true);
        }
        // Central round through-bore
        translate([0, 0, -10])
            cylinder(h=20, r=3.3/2, center=true);
        // Inner square chamber
        translate([-5.5/2, -5.5/2, -10])
            cube([5.5, 5.5, 20], center=true);
        // T-slot channels
        for (i = [0, 90, 180, 270]) {
            rotate([0, 0, i]) {
                translate([7.5, 0, -10]) {
                    // Slot channel
                    difference() {
                        square([9.5, 14], center=true);
                        translate([-6.2/2, -14/2, 0])
                            square([6.2, 14]);
                    }
                    // T-slot lip
                    translate([-6.2/2, -1, 0])
                        square([6.2, 1]);
                }
            }
        }
    }
}

t_slot_extrusion();