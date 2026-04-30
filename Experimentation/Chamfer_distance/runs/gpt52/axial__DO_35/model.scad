$fn = 64;

module axial_component(body_length=0.55, body_d=1.2, lead_d=0.25, lead_length=8) {
    union() {
        // Body centered at origin along X axis
        rotate([0,90,0])
            cylinder(h=body_length, d=body_d, center=true);

        // Leads along X axis, symmetric
        translate([-(body_length/2 + lead_length/2),0,0])
            rotate([0,90,0])
                cylinder(h=lead_length, d=lead_d, center=true);

        translate([(body_length/2 + lead_length/2),0,0])
            rotate([0,90,0])
                cylinder(h=lead_length, d=lead_d, center=true);
    }
}

// Top-level call
axial_component(body_length=0.55);