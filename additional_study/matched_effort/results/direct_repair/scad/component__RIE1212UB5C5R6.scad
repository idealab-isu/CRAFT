$fn=64;

// Resistor 5R6F 5R6 3W vitreous enamel (axial, vitreous enamel wirewound style)
// Approximate dimensions (mm)
body_len = 18.0;
body_d   = 6.0;

cap_len  = 1.2;
cap_d    = 6.2;

lead_d   = 0.8;
lead_len_each = 28.0;

fillet_r = 0.6;

// Colors
col_body = [0.96, 0.96, 0.94];   // off-white enamel
col_cap  = [0.75, 0.75, 0.75];   // light gray end caps
col_lead = [0.72, 0.72, 0.72];   // tinned copper
col_mark = [0.10, 0.55, 0.10];   // green marking

module rounded_cylinder(h, d, r){
    // Minkowski rounded ends (capsule-like)
    // Ensure h >= 2r
    hh = max(h - 2*r, 0.01);
    minkowski(){
        cylinder(h=hh, d=d-2*r, center=true);
        sphere(r=r);
    }
}

module resistor_body(){
    // Main enamel body with slight rounding
    color(col_body)
    translate([0,0,0])
        rounded_cylinder(body_len, body_d, fillet_r);

    // End caps
    for (s=[-1,1]){
        color(col_cap)
        translate([0,0,s*(body_len/2 - cap_len/2)])
            cylinder(h=cap_len, d=cap_d, center=true);
    }

    // Marking band + text-like stripe approximation
    // A thin band around the body near one end
    color(col_mark)
    translate([0,0, body_len*0.18])
        difference(){
            cylinder(h=0.6, d=body_d+0.15, center=true);
            cylinder(h=0.8, d=body_d-0.25, center=true);
        }

    // Simple "5R6" marking as raised bars (approx)
    // Three small rectangles on top surface
    color(col_mark)
    translate([0, body_d/2 - 0.35, -body_len*0.05])
    rotate([90,0,0])
    linear_extrude(height=0.5)
    union(){
        // "5" approximation
        translate([-4.2,0]) square([1.2,3.2], center=false);
        translate([-4.2,2.0]) square([2.4,1.2], center=false);
        translate([-4.2,1.0]) square([2.0,1.0], center=false);
        translate([-2.2,0.0]) square([2.4,1.2], center=false);

        // "R" approximation
        translate([-0.6,0]) square([1.2,3.2], center=false);
        translate([-0.6,2.0]) square([2.2,1.2], center=false);
        translate([0.8,1.0]) square([0.8,1.0], center=false);
        translate([0.6,0.0]) polygon(points=[[0,0],[1.8,0],[0.6,1.2]]);

        // "6" approximation
        translate([3.0,0]) square([1.2,3.2], center=false);
        translate([3.0,2.0]) square([2.4,1.2], center=false);
        translate([3.0,1.0]) square([2.0,1.0], center=false);
        translate([3.0,0.0]) square([2.4,1.2], center=false);
        translate([4.2,0.0]) square([1.2,2.2], center=false);
    }
}

module leads(){
    // Leads extend from end caps
    color(col_lead)
    union(){
        // Left lead
        translate([0,0,-(body_len/2 + lead_len_each/2)])
            cylinder(h=lead_len_each, d=lead_d, center=true);
        // Right lead
        translate([0,0,(body_len/2 + lead_len_each/2)])
            cylinder(h=lead_len_each, d=lead_d, center=true);
    }
}

module resistor_3w_vitreous(){
    // Align along Z axis (axial)
    union(){
        leads();
        resistor_body();
    }
}

resistor_3w_vitreous();