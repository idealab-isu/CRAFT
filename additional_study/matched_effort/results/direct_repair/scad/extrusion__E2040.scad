$fn = 64;

length = 100;
w = 40;
h = 20;

slot_w = 6;
slot_depth = 6;

core_w = 18;
core_h = 8;

module extrusion2040(len=100) {
    linear_extrude(height=len, center=false, convexity=10)
        difference() {
            square([w, h], center=true);

            // Central core void (approximation)
            square([core_w, core_h], center=true);

            // T-slots (approximation) on all four sides
            // Left
            translate([-w/2 + slot_depth/2, 0])
                square([slot_depth, slot_w], center=true);

            // Right
            translate([ w/2 - slot_depth/2, 0])
                square([slot_depth, slot_w], center=true);

            // Bottom
            translate([0, -h/2 + slot_depth/2])
                square([slot_w, slot_depth], center=true);

            // Top
            translate([0,  h/2 - slot_depth/2])
                square([slot_w, slot_depth], center=true);
        }
}

extrusion2040(length);