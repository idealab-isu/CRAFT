$fn = 96;

// Resistor 5R6 3W vitreous enamel (axial leaded)
// Built along X axis and centered at origin for correct orthographic framing.
// Single connected solid (slight overlaps at joints). No text/labels.

// Approximate dimensions (mm) for 3W vitreous enamel style
body_len = 24.0;
body_dia = 9.0;

cap_len  = 2.0;     // metal end cap length each side
cap_dia  = 9.6;     // slightly larger than body

lead_dia = 0.9;
lead_len = 32.0;    // from each end cap outward

// Small overlaps to guarantee watertight union
overlap_ax = 0.25;  // axial overlap between adjacent parts
overlap_rd = 0.10;  // radial overlap (if needed)

module cyl_x(len, d, center=true){
    rotate([0,90,0]) cylinder(h=len, d=d, center=center);
}

module lead_wire(len=lead_len, dia=lead_dia){
    cyl_x(len=len, d=dia, center=true);
}

module end_cap(len=cap_len, dia=cap_dia){
    cyl_x(len=len, d=dia, center=true);
}

module body(len=body_len, dia=body_dia){
    // Slightly rounded ends via hull of two thin disks
    hull(){
        translate([-len/2 + 0.2, 0, 0]) cyl_x(len=0.4, d=dia, center=true);
        translate([ len/2 - 0.2, 0, 0]) cyl_x(len=0.4, d=dia, center=true);
    }
}

module resistor(){
    // Segment centers along X
    body_cx = 0;

    capL_cx = -(body_len/2 + cap_len/2 - overlap_ax);
    capR_cx =  (body_len/2 + cap_len/2 - overlap_ax);

    leadL_cx = -(body_len/2 + cap_len + lead_len/2 - 2*overlap_ax);
    leadR_cx =  (body_len/2 + cap_len + lead_len/2 - 2*overlap_ax);

    union(){
        // Leads
        translate([leadL_cx, 0, 0]) lead_wire();
        translate([leadR_cx, 0, 0]) lead_wire();

        // End caps
        translate([capL_cx, 0, 0]) end_cap();
        translate([capR_cx, 0, 0]) end_cap();

        // Body
        translate([body_cx, 0, 0]) body();
    }
}

resistor();