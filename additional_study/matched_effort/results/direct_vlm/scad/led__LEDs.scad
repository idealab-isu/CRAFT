$fn=96;

// Simple 5mm through-hole LED model (generic)
module led_5mm(
    body_d=5.0,
    body_h=8.0,
    lens_h=2.0,
    flange_d=5.6,
    flange_h=1.0,
    lead_d=0.6,
    lead_len=25.0,
    lead_spacing=2.54,
    lead_offset_from_body=0.2,
    cathode_flat_depth=0.35
){
    // Leads
    color([0.75,0.75,0.78])
    translate([0,0,-lead_len])
    union(){
        translate([-lead_spacing/2,0,0]) cylinder(d=lead_d, h=lead_len + lead_offset_from_body);
        translate([ lead_spacing/2,0,0]) cylinder(d=lead_d, h=lead_len + lead_offset_from_body);
    }

    // Body + flange + lens with a small cathode flat
    color([0.85,0.1,0.1,0.55])
    difference(){
        union(){
            // Flange at base
            cylinder(d=flange_d, h=flange_h);

            // Main cylindrical body
            translate([0,0,flange_h])
                cylinder(d=body_d, h=body_h);

            // Rounded lens top (spherical cap approximation)
            translate([0,0,flange_h + body_h])
                intersection(){
                    cylinder(d=body_d, h=lens_h);
                    translate([0,0,lens_h])
                        sphere(d=body_d);
                }
        }

        // Cathode flat on side of body (subtle)
        translate([body_d/2 - cathode_flat_depth, 0, flange_h + 0.5])
            cube([cathode_flat_depth*2, body_d*1.2, body_h + lens_h], center=true);
    }
}

// Render
led_5mm();