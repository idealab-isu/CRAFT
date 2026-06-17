$fn = 120;

// Target specs
hex_flat_distance = 10.0;   // across flats
nut_thickness     = 3.75;   // overall thickness (Z)
thread_diameter   = 4.0;    // through hole for M4 (simple clearance/hole)

// Wing geometry (shaped lobes, not bars)
wing_span_from_flat = 9.0;  // how far each wing extends outward from hex flat
wing_width          = 8.0;  // wing width (Y) at the lobe
wing_root_width     = 5.0;  // wing width near the nut
wing_tip_round_r    = 3.0;  // rounding at wing tip
root_fillet_r       = 2.0;  // blend into nut

// Derived
hex_circ_d = hex_flat_distance / cos(30); // circumscribed diameter for 6-sided cylinder
eps = 0.02;

// 2D helper: rounded rectangle centered at origin
module rounded_rect_2d(w, h, r) {
    r2 = min(r, min(w, h)/2);
    hull() {
        translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
        translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
        translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
    }
}

// 2D wing lobe profile (one side, pointing +X), then extruded to nut_thickness
module wing_lobe_2d() {
    // Place the wing so it starts slightly inside the hex to guarantee connection
    // Hex flat is at x = hex_flat_distance/2; overlap into nut by root_fillet_r
    x0 = hex_flat_distance/2 - root_fillet_r;                 // wing root start (inside nut)
    x1 = hex_flat_distance/2 + wing_span_from_flat;           // wing tip end

    hull() {
        // Root pad (narrower)
        translate([x0 + root_fillet_r, 0])
            rounded_rect_2d(root_fillet_r*2, wing_root_width, root_fillet_r);

        // Mid pad (transition)
        translate([ (x0 + x1)/2, 0])
            rounded_rect_2d((x1 - x0)*0.55, (wing_root_width + wing_width)*0.6, wing_tip_round_r);

        // Tip pad (rounded)
        translate([x1 - wing_tip_round_r, 0])
            circle(r=wing_tip_round_r);
    }
}

// Main solid (hex + two wing lobes), then subtract hole
module wing_nut() {
    difference() {
        // ONE connected solid
        linear_extrude(height=nut_thickness, center=true, convexity=10)
        union() {
            // True hex body (across flats = hex_flat_distance)
            circle(d=hex_circ_d, $fn=6);

            // Two opposed wing lobes (shaped)
            wing_lobe_2d();
            mirror([1,0,0]) wing_lobe_2d();
        }

        // Through hole for 4.0mm screw (simple cylindrical hole)
        cylinder(d=thread_diameter, h=nut_thickness + 2, center=true);
    }
}

wing_nut();