$fn=64;

module extrusion_3060(length=100, w=60, h=30, wall=2.0, slot=8.0, slot_depth=6.0, core_d=12.0, bore_d=5.2) {
    difference() {
        // Outer body
        cube([w, h, length], center=true);

        // Inner hollow (approximate)
        cube([w-2*wall, h-2*wall, length+0.2], center=true);

        // Central bore
        cylinder(d=bore_d, h=length+0.4, center=true);

        // Core relief (approximate)
        cylinder(d=core_d, h=length+0.4, center=true);

        // T-slots (approximate) on all four sides
        // +X face
        translate([w/2 - slot_depth/2, 0, 0])
            cube([slot_depth+0.2, slot, length+0.4], center=true);
        // -X face
        translate([-w/2 + slot_depth/2, 0, 0])
            cube([slot_depth+0.2, slot, length+0.4], center=true);
        // +Y face
        translate([0, h/2 - slot_depth/2, 0])
            cube([slot, slot_depth+0.2, length+0.4], center=true);
        // -Y face
        translate([0, -h/2 + slot_depth/2, 0])
            cube([slot, slot_depth+0.2, length+0.4], center=true);

        // Corner reliefs (approximate)
        for (sx=[-1,1], sy=[-1,1]) {
            translate([sx*(w/2-wall), sy*(h/2-wall), 0])
                cylinder(d=6.0, h=length+0.4, center=true);
        }
    }
}

extrusion_3060(length=100, w=60, h=30);