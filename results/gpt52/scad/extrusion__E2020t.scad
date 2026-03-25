$fn=64;

module tslot2020_profile(len=100, size=20, slot=6, wall=2, core=8) {
    difference() {
        translate([0,0,0]) cube([size, size, len], center=true);

        // central bore
        cylinder(h=len+0.2, d=core, center=true);

        // T-slots on four sides (simple rectangular approximation)
        for (a = [0,90,180,270]) {
            rotate([0,0,a]) translate([0, size/2 - slot/2, 0])
                cube([size - 2*wall, slot, len+0.2], center=true);
        }

        // corner reliefs to suggest extrusion geometry
        for (sx=[-1,1], sy=[-1,1]) {
            translate([sx*(size/2 - wall), sy*(size/2 - wall), 0])
                cylinder(h=len+0.2, r=wall, center=true);
        }
    }
}

tslot2020_profile(len=100, size=20, slot=6, wall=2, core=8);