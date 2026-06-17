$fn = 180;

// Dimensions (mm)
bore_d = 5.0;
od_d   = 13.0;
width  = 4.0;

flange_d = 15.0;
flange_t = 1.0;          // typical flange thickness
flange_z = 0.0;          // flange at bottom face

// Simple visual details (non-critical)
shield_recess_d = 11.6;  // slight recess to suggest shields
shield_recess_t = 0.15;

edge_chamfer = 0.25;     // small chamfer on outer edges

module chamfered_cylinder(d=10, h=5, c=0.2) {
    // Approximates chamfer by stacking three cylinders
    union() {
        translate([0,0,c]) cylinder(d=d, h=h-2*c);
        cylinder(d1=d-2*c, d2=d, h=c);
        translate([0,0,h-c]) cylinder(d1=d, d2=d-2*c, h=c);
    }
}

difference() {
    union() {
        // Main bearing body
        chamfered_cylinder(d=od_d, h=width, c=edge_chamfer);

        // Flange
        translate([0,0,flange_z])
            cylinder(d=flange_d, h=flange_t);
    }

    // Bore
    translate([0,0,-0.5])
        cylinder(d=bore_d, h=width + flange_t + 1.0);

    // Shield recess (top)
    translate([0,0,width - shield_recess_t])
        cylinder(d=shield_recess_d, h=shield_recess_t + 0.01);

    // Shield recess (bottom, above flange if flange is at bottom)
    translate([0,0,flange_t])
        cylinder(d=shield_recess_d, h=shield_recess_t + 0.01);
}