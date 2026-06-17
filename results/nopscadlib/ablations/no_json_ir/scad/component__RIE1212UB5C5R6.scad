// Parameters
resistor_length = 20; // mm
resistor_diameter = 6; // mm
lead_length = 15; // mm
lead_diameter = 1;2 // mm
coating_thickness = 0.5; // mm
endcap_length = 1; // mm

// Resistor body
module resistor_body() {
    cylinder(h = resistor_length, d = resistor_diameter, center = true);
}

// Axial leads
module axial_leads() {
    translate([0, 0, -(resistor_length/2 + lead_length)])
        cylinder(h = lead_length, d = lead_diameter, center = false);
    translate([0, 0, resistor_length/2])
        cylinder(h = lead_length, d = lead_diameter, center = false);
}

// Lead exit fillet or endcaps
module lead_exit_fillet_or_endcaps() {
    translate([0, 0, -(resistor_length/2 + endcap_length)])
        cylinder(h = endcap_length, d = resistor_diameter, center = false);
    translate([0, 0, resistor_length/2])
        cylinder(h = endcap_length, d = resistor_diameter, center = false);
}

// Body coating layer
module body_coating_layer() {
    cylinder(h = resistor_length, d = resistor_diameter + 2 * coating_thickness, center = true);
}

// Complete resistor
module resistor() {
    union() {
        resistor_body();
        lead_exit_fillet_or_endcaps();
    }
}

// Aluminum clad resistor
module al_clad_resistor() {
    difference() {
        body_coating_layer();
        resistor();
    }
}

// Aluminum clad resistor assembly
module al_clad_resistor_assembly() {
    union() {
        al_clad_resistor();
        axial_leads();
    }
}

// Sleeved resistor
module sleeved_resistor() {
    al_clad_resistor_assembly();
}

// Render the sleeved resistor
sleeved_resistor();