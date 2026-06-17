$fn=64;

// Resistor 6R8 3W vitreous enamel (axial, ceramic body)
// Approximate dimensions (mm)
body_len = 15.0;
body_dia = 5.5;
lead_dia = 0.8;
lead_len_each = 25.0;

cap_len = 1.2;          // metal end cap length
cap_dia = body_dia*1.02;

fillet_r = 0.6;         // slight rounding at body ends

// Color palette
col_body = [0.96, 0.96, 0.94];   // off-white ceramic
col_cap  = [0.75, 0.75, 0.78];   // tinned metal
col_lead = [0.80, 0.80, 0.82];   // lead wire
col_text = [0.15, 0.15, 0.15];   // marking

module rounded_cylinder(h, d, r){
    // Minkowski rounded ends (kept light by using small sphere)
    minkowski(){
        cylinder(h=max(0.01, h-2*r), d=d-2*r, center=true);
        sphere(r=r);
    }
}

module lead_wire(len, d){
    cylinder(h=len, d=d, center=true);
}

module resistor_body(){
    // Main ceramic body with slight rounding
    color(col_body)
    rounded_cylinder(h=body_len, d=body_dia, r=fillet_r);

    // End caps
    for (s=[-1,1]){
        translate([0,0,s*(body_len/2 - cap_len/2)])
            color(col_cap)
            cylinder(h=cap_len, d=cap_dia, center=true);
    }

    // Marking text (approximate)
    // Place on side; extrude slightly
    translate([0, body_dia/2 + 0.01, 0])
        rotate([90,0,180])
            color(col_text)
            linear_extrude(height=0.25)
                text("6R8 3W", size=3.0, halign="center", valign="center", font="Liberation Sans:style=Bold");
}

module resistor(){
    // Leads
    total_lead = body_len + 2*lead_len_each;
    // Left lead
    translate([0,0,-(body_len/2 + lead_len_each/2)])
        color(col_lead)
        lead_wire(lead_len_each, lead_dia);
    // Right lead
    translate([0,0,(body_len/2 + lead_len_each/2)])
        color(col_lead)
        lead_wire(lead_len_each, lead_dia);

    // Body
    resistor_body();
}

// Orient along X axis for typical axial component display
rotate([0,90,0]) resistor();