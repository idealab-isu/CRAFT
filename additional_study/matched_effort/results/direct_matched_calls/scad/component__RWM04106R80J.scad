$fn=64;

// Resistor 6R8 3W vitreous enamel (axial leaded)
// Approximate dimensions (typical):
// Body: 18 mm length, 6 mm diameter
// Leads: 0.8 mm diameter, 28 mm each side
// Marking: "6R8" in black on white body

module resistor_6R8_3W(
    body_len=18,
    body_d=6,
    lead_d=0.8,
    lead_len=28,
    endcap_len=1.2,
    fillet=0.6,
    text_str="6R8",
    text_size=3.2,
    text_depth=0.25
){
    // Colors
    body_col = [0.97, 0.97, 0.95];   // off-white enamel
    cap_col  = [0.85, 0.85, 0.82];   // slightly darker ends
    lead_col = [0.75, 0.75, 0.78];   // tinned copper
    mark_col = [0.05, 0.05, 0.05];   // black marking

    // Helper: rounded cylinder along X
    module rounded_body(len, d, r){
        // r is fillet radius (clamped)
        rr = min(r, d/2 - 0.01);
        hull(){
            translate([-len/2 + rr, 0, 0]) rotate([0,90,0]) cylinder(h=0.01, d=d-2*rr);
            translate([ len/2 - rr, 0, 0]) rotate([0,90,0]) cylinder(h=0.01, d=d-2*rr);
            translate([-len/2 + rr, 0, 0]) sphere(d=d);
            translate([ len/2 - rr, 0, 0]) sphere(d=d);
        }
    }

    // Leads
    color(lead_col){
        translate([-(body_len/2 + lead_len), 0, 0])
            rotate([0,90,0]) cylinder(h=lead_len, d=lead_d);
        translate([ body_len/2, 0, 0])
            rotate([0,90,0]) cylinder(h=lead_len, d=lead_d);
    }

    // Body with subtle endcaps
    union(){
        // Main enamel body
        color(body_col)
            rounded_body(body_len, body_d, fillet);

        // Endcaps (slightly darker rings)
        color(cap_col){
            translate([-(body_len/2 - endcap_len/2), 0, 0])
                rotate([0,90,0]) cylinder(h=endcap_len, d=body_d*0.995);
            translate([ (body_len/2 - endcap_len/2), 0, 0])
                rotate([0,90,0]) cylinder(h=endcap_len, d=body_d*0.995);
        }

        // Marking text embossed slightly
        color(mark_col)
            translate([0, 0, body_d/2 - text_depth/2])
                linear_extrude(height=text_depth)
                    text(text_str, size=text_size, halign="center", valign="center", font="Liberation Sans:style=Bold");
    }
}

resistor_6R8_3W();