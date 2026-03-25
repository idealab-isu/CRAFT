$fn = 96;

// Parameters
resistance_value_ohm = 5.6; //[2.8:11.2:0.1]
power_rating_w = 3; //[1.5:6:0.5]
body_length_mm = 18; //[9:36:1]
body_diameter_mm = 6; //[3:12:0.5]
lead_diameter_mm = 0.8; //[0.4:1.6:0.1]
lead_length_each_mm = 30; //[15:60:1]
lead_pitch_mm = 78; //[39:156:1]
enamel_thickness_mm = 0.4; //[0.2:0.8:0.05]
endcap_length_mm = 1.2; //[0.6:2.4:0.1]
endcap_overlap_mm = 0.8; //[0.5:2:0.1]
sleeve_length_mm = 12; //[6:24:1]
sleeve_outer_diameter_mm = 1.8; //[1.2:3.6:0.1]
sleeve_overlap_mm = 1; //[0.5:2:0.1]
connection_overlap_mm = 1; //[0.5:2:0.1]

// Derived / safety
eps = 0.01;
overlap = max(0.2, connection_overlap_mm);
body_r = body_diameter_mm/2;
core_r = max(0.1, body_r - enamel_thickness_mm);
endcap_r = body_r * 0.98; // slight step like real end caps
sleeve_r = max(lead_diameter_mm/2 + 0.05, sleeve_outer_diameter_mm/2);

// Ensure overall lead-to-lead length matches pitch (if pitch is larger)
total_target_len = max(lead_pitch_mm, body_length_mm + 2*endcap_length_mm + 2*sleeve_length_mm + 2*lead_length_each_mm);
lead_len_each = max(0.1, (total_target_len - (body_length_mm + 2*endcap_length_mm + 2*sleeve_length_mm))/2);

// Axial positions along X
x_body_center = 0;
x_body_left_face  = -body_length_mm/2;
x_body_right_face =  body_length_mm/2;

x_endcap_left_center  = x_body_left_face  - endcap_length_mm/2 + endcap_overlap_mm;
x_endcap_right_center = x_body_right_face + endcap_length_mm/2 - endcap_overlap_mm;

x_endcap_left_outer_face  = x_endcap_left_center  - endcap_length_mm/2;
x_endcap_right_outer_face = x_endcap_right_center + endcap_length_mm/2;

x_sleeve_left_center  = x_endcap_left_outer_face  - sleeve_length_mm/2 + sleeve_overlap_mm;
x_sleeve_right_center = x_endcap_right_outer_face + sleeve_length_mm/2 - sleeve_overlap_mm;

x_sleeve_left_outer_face  = x_sleeve_left_center  - sleeve_length_mm/2;
x_sleeve_right_outer_face = x_sleeve_right_center + sleeve_length_mm/2;

x_lead_left_center  = x_sleeve_left_outer_face  - lead_len_each/2 + overlap;
x_lead_right_center = x_sleeve_right_outer_face + lead_len_each/2 - overlap;

// Vitreous-enamel power resistor body (slightly barrel-shaped)
module vitreous_body() {
    // Outer enamel shell (barrel)
    color("DimGray")
    rotate([0,90,0])
    hull() {
        translate([0,0,-body_length_mm/2]) cylinder(r=body_r*0.98, h=eps, center=false);
        translate([0,0, 0])               cylinder(r=body_r*1.03, h=eps, center=false);
        translate([0,0, body_length_mm/2]) cylinder(r=body_r*0.98, h=eps, center=false);
    }

    // Inner core (slightly smaller, for subtle edge definition)
    color([0.25,0.25,0.25])
    rotate([0,90,0])
    hull() {
        translate([0,0,-body_length_mm/2]) cylinder(r=core_r*0.98, h=eps, center=false);
        translate([0,0, 0])               cylinder(r=core_r*1.02, h=eps, center=false);
        translate([0,0, body_length_mm/2]) cylinder(r=core_r*0.98, h=eps, center=false);
    }
}

// End caps (metal/ceramic ends)
module endcaps() {
    color([0.35,0.35,0.35]) {
        translate([x_endcap_left_center, 0, 0])
            rotate([0,90,0])
                cylinder(r=endcap_r, h=endcap_length_mm, center=true);

        translate([x_endcap_right_center, 0, 0])
            rotate([0,90,0])
                cylinder(r=endcap_r, h=endcap_length_mm, center=true);
    }
}

// Insulating sleeves near body
module sleeves() {
    color("Black") {
        translate([x_sleeve_left_center, 0, 0])
            rotate([0,90,0])
                cylinder(r=sleeve_r, h=sleeve_length_mm, center=true);

        translate([x_sleeve_right_center, 0, 0])
            rotate([0,90,0])
                cylinder(r=sleeve_r, h=sleeve_length_mm, center=true);
    }
}

// Leads (axial wire)
module leads() {
    color("Silver") {
        translate([x_lead_left_center, 0, 0])
            rotate([0,90,0])
                cylinder(r=lead_diameter_mm/2, h=lead_len_each, center=true);

        translate([x_lead_right_center, 0, 0])
            rotate([0,90,0])
                cylinder(r=lead_diameter_mm/2, h=lead_len_each, center=true);
    }
}

// One connected solid assembly
module assembly() {
    union() {
        vitreous_body();
        endcaps();
        sleeves();
        leads();
    }
}

assembly();