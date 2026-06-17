$fn = 64;

length = 100;
size = 40;

slot_w = 8;
slot_depth = 10;

wall = 2.5;
core = 16;

module tslot_4040_profile_2d() {
    difference() {
        square([size, size], center=true);

        // Central bore
        circle(d=5.2);

        // Core relief (gives a more extrusion-like look)
        square([core, core], center=true);

        // Four T-slots (simplified)
        for (a = [0, 90, 180, 270]) {
            rotate(a)
                translate([0, size/2 - slot_depth/2])
                    square([slot_w, slot_depth], center=true);
        }

        // Corner reliefs (lighten corners a bit)
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(size/2 - wall), sy*(size/2 - wall)])
                circle(r=3);
        }
    }
}

linear_extrude(height=length, center=false, convexity=10)
    tslot_4040_profile_2d();