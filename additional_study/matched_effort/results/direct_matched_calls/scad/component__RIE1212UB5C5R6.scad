$fn=64;

// Resistor 5R6F 5R6 3W vitreous enamel (axial, vitreous enamel wirewound style)
// Approximate dimensions (mm)
body_len = 15.0;
body_d   = 6.0;

lead_d   = 0.8;
lead_len_each = 28.0;

cap_len  = 1.2;   // small end caps
cap_d    = 6.2;

text_size = 2.2;
text_depth = 0.35;

module lead_wire(len, d){
    color([0.75,0.75,0.78])
    cylinder(h=len, d=d, center=false);
}

module resistor_body(){
    // Main enamel body
    color([0.96,0.96,0.94])
    cylinder(h=body_len, d=body_d, center=false);

    // End caps
    color([0.85,0.85,0.86])
    translate([0,0,0])
        cylinder(h=cap_len, d=cap_d, center=false);
    color([0.85,0.85,0.86])
    translate([0,0,body_len-cap_len])
        cylinder(h=cap_len, d=cap_d, center=false);

    // Printed marking (engraved slightly)
    // Place on side: rotate so text extrudes inward
    translate([0, body_d/2 + 0.01, body_len/2])
    rotate([90,0,180])
    color([0.15,0.15,0.15])
    linear_extrude(height=text_depth)
        text("5R6", size=text_size, halign="center", valign="center", font="Liberation Sans:style=Bold");
}

module resistor(){
    // Axis along Z, centered at origin
    translate([0,0,-(body_len/2)])
    difference(){
        resistor_body();
        // Engrave text by subtracting a slightly deeper version
        translate([0, body_d/2 + 0.02, body_len/2])
        rotate([90,0,180])
        linear_extrude(height=text_depth+0.05)
            text("5R6", size=text_size, halign="center", valign="center", font="Liberation Sans:style=Bold");
    }

    // Leads
    // Left lead
    translate([0,0,-(body_len/2) - lead_len_each])
        lead_wire(lead_len_each, lead_d);

    // Right lead
    translate([0,0,(body_len/2)])
        lead_wire(lead_len_each, lead_d);
}

resistor();