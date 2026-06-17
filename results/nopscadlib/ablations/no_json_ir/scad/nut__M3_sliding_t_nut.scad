$fn = 80;

// T-slot nut for 3.0mm screws, 6.0mm across flats, 3.0mm thick
module t_slot_nut(af=6.0, thickness=3.0, screw_d=3.0, clearance=0.25) {

    // Geometry (printable generic T-slot nut)
    // - "across flats" implemented as a hex profile in plan view (Z extrusion)
    // - T-profile implemented by adding a wider top flange
    // - All Z translations are computed from thickness splits (no arbitrary offsets)

    flange_h = thickness * 0.45;
    body_h   = thickness - flange_h;

    // Length along slot (X)
    nut_len  = af * 1.6;

    // Hex body across-flats (Y direction in top view)
    // For a regular hex: across_flats = 2 * apothem
    apothem  = af / 2;
    hex_R    = apothem / cos(30); // circumradius

    // Flange width (Y) and length (X)
    flange_w = af * 1.55;
    flange_l = nut_len;

    hole_d   = screw_d + clearance;

    module hex_prism(h) {
        linear_extrude(height=h, center=true)
            polygon(points=[
                [ hex_R*cos(  0), hex_R*sin(  0)],
                [ hex_R*cos( 60), hex_R*sin( 60)],
                [ hex_R*cos(120), hex_R*sin(120)],
                [ hex_R*cos(180), hex_R*sin(180)],
                [ hex_R*cos(240), hex_R*sin(240)],
                [ hex_R*cos(300), hex_R*sin(300)]
            ]);
    }

    difference() {
        union() {
            // Main hex body (bottom)
            translate([0, 0, body_h/2])
                linear_extrude(height=body_h, center=true)
                    scale([nut_len/(2*hex_R), 1])  // stretch hex in X to nut_len
                        polygon(points=[
                            [ hex_R*cos(  0), hex_R*sin(  0)],
                            [ hex_R*cos( 60), hex_R*sin( 60)],
                            [ hex_R*cos(120), hex_R*sin(120)],
                            [ hex_R*cos(180), hex_R*sin(180)],
                            [ hex_R*cos(240), hex_R*sin(240)],
                            [ hex_R*cos(300), hex_R*sin(300)]
                        ]);

            // Top flange (wider "T" head), connected by exact stacking
            translate([0, 0, body_h + flange_h/2])
                cube([flange_l, flange_w, flange_h], center=true);
        }

        // Through hole for 3.0mm screw (clearance)
        translate([0, 0, thickness/2])
            cylinder(h=thickness + 0.6, d=hole_d, center=true);
    }
}

t_slot_nut();