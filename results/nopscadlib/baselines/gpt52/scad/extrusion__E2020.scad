$fn=64;

module tslot2020_profile(len=100, size=20, slot=6, wall=2, core=8) {
    difference() {
        translate([0,0,0]) cube([size, size, len], center=true);

        // central core hole
        cylinder(h=len+0.2, d=core, center=true);

        // T-slots on four sides (approximated)
        for (a = [0,90,180,270]) {
            rotate([0,0,a]) {
                // slot opening from side
                translate([size/2 - wall/2, 0, 0])
                    cube([wall+0.2, slot, len+0.2], center=true);

                // inner cavity behind opening
                translate([size/2 - wall - 3, 0, 0])
                    cube([6, 10, len+0.2], center=true);
            }
        }
    }
}

tslot2020_profile(len=100, size=20, slot=6, wall=2, core=8);