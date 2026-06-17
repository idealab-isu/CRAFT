$fn=64;

// Thermistor Honeywell 135-104LAC-J01 (100K 1%) - approximate 3D model
// Radial epoxy-coated bead thermistor with two leads.
// Dimensions are representative/approximate for visualization.

module lead(len=28, dia=0.55) {
    color([0.75,0.75,0.78])
    cylinder(h=len, d=dia, center=false);
}

module thermistor_body(body_d=3.2, body_h=2.6) {
    // Epoxy bead / small cylinder with rounded ends
    color([0.12,0.12,0.12])
    hull() {
        translate([0,0,0.35]) sphere(d=body_d);
        translate([0,0,body_h-0.35]) sphere(d=body_d);
    }
}

module thermistor_135_104LAC_J01() {
    // Parameters (approx.)
    lead_d = 0.55;
    lead_len = 30;
    lead_pitch = 2.54;     // typical radial spacing
    standoff = 1.2;        // distance from board to body bottom
    body_d = 3.2;
    body_h = 2.6;

    // Leads (downwards to board)
    translate([-lead_pitch/2, 0, 0]) rotate([180,0,0]) lead(len=lead_len, dia=lead_d);
    translate([ lead_pitch/2, 0, 0]) rotate([180,0,0]) lead(len=lead_len, dia=lead_d);

    // Small kink/transition into body (short vertical segments above body bottom)
    color([0.75,0.75,0.78]) {
        translate([-lead_pitch/2, 0, standoff]) cylinder(h=2.0, d=lead_d);
        translate([ lead_pitch/2, 0, standoff]) cylinder(h=2.0, d=lead_d);
    }

    // Body centered between leads
    translate([0,0,standoff+2.0]) thermistor_body(body_d=body_d, body_h=body_h);

    // Lead entry points into body (slight embed)
    color([0.75,0.75,0.78]) {
        translate([-lead_pitch/2, 0, standoff+2.0+0.2]) cylinder(h=0.9, d=lead_d);
        translate([ lead_pitch/2, 0, standoff+2.0+0.2]) cylinder(h=0.9, d=lead_d);
    }
}

thermistor_135_104LAC_J01();