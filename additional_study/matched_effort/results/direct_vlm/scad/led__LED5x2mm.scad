$fn=64;

// Simple 5mm LED (through-hole) model
// Units: mm

module led_5mm(
    body_d=5.0,
    body_h=8.0,
    dome_h=2.5,
    flange_d=5.8,
    flange_h=1.0,
    lead_d=0.6,
    lead_len=25.0,
    lead_spacing=2.54,
    lead_offset_from_body=0.5
){
    // Body (cyl + dome)
    color([0.85, 0.1, 0.1, 0.85])
    union() {
        // Main cylindrical body
        translate([0,0,flange_h])
            cylinder(d=body_d, h=body_h - dome_h);

        // Dome (spherical cap)
        translate([0,0,flange_h + (body_h - dome_h)])
            intersection() {
                sphere(d=body_d);
                translate([0,0,0])
                    cylinder(d=body_d, h=dome_h);
            }

        // Flange at base
        cylinder(d=flange_d, h=flange_h);
    }

    // Flat on one side (typical LED body flat)
    difference() {
        // Invisible helper to cut flat; applied by subtracting from a duplicate body
        // We'll re-render body with flat by subtracting a box from it.
        // To keep code simple and renderable, we overlay a slightly darker "flat" patch.
        // (True subtraction would require redoing the body as a difference; this is a visual cue.)
        // Flat patch:
        color([0.6, 0.05, 0.05, 0.85])
        translate([body_d*0.35, 0, flange_h + (body_h-dome_h)/2])
            rotate([0,90,0])
                cylinder(d=body_d*0.9, h=0.2, center=true);
    }

    // Leads
    color([0.75,0.75,0.78])
    union() {
        // Anode (longer)
        translate([-lead_spacing/2, 0, -lead_len])
            cylinder(d=lead_d, h=lead_len + lead_offset_from_body);

        // Cathode (shorter)
        translate([ lead_spacing/2, 0, -lead_len*0.85])
            cylinder(d=lead_d, h=lead_len*0.85 + lead_offset_from_body);
    }
}

led_5mm();