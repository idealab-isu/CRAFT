$fn=64;

module slot2D(slot_w=8, slot_depth=10, throat_w=4, throat_depth=2) {
    union() {
        translate([0, -slot_depth/2]) square([slot_w, slot_depth], center=true);
        translate([0, slot_depth/2 - throat_depth/2]) square([throat_w, throat_depth], center=true);
    }
}

module extrusion4080_profile_2D(w=80, h=40, wall=2.5, core_w=20, core_h=20) {
    difference() {
        square([w, h], center=true);

        // Inner cavity
        square([w-2*wall, h-2*wall], center=true);

        // Central core void
        square([core_w, core_h], center=true);

        // T-slots on all four sides
        translate([0,  h/2]) slot2D();
        translate([0, -h/2]) rotate(180) slot2D();
        translate([ w/2, 0]) rotate(-90) slot2D();
        translate([-w/2, 0]) rotate(90) slot2D();
    }
}

module extrusion4080(length=100) {
    linear_extrude(height=length, center=true, convexity=10)
        extrusion4080_profile_2D();
}

extrusion4080(100);