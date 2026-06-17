$fn = 96;

// Vitreous enamel axial resistor (approx. 3W) - single connected solid

// Main dimensions (mm)
body_len      = 26;     // ceramic/enamel body length
body_d        = 10.5;   // ceramic/enamel body diameter (larger than small film resistors)

cap_len       = 3.2;    // metal end-cap length
cap_d         = 9.2;    // end-cap diameter (slightly smaller than body)

neck_len      = 1.6;    // small neck between cap and lead
neck_d        = 3.0;    // neck diameter

lead_d        = 1.0;    // lead wire diameter
lead_len      = 32;     // lead length from each end (outside body)

// Overlap to guarantee watertight union
ov = 0.25;

// Derived
core_len = body_len - 2*cap_len;
lead_z   = body_len/2 + lead_len/2 - ov;

// Modules
module body_core() {
    // Slightly rounded cylinder using hull of two short cylinders
    hull() {
        translate([0,0,-core_len/2 + 0.6])
            cylinder(h=1.2, d=body_d, center=true);
        translate([0,0, core_len/2 - 0.6])
            cylinder(h=1.2, d=body_d, center=true);
    }
}

module end_cap(sign=1) {
    // sign = +1 (top), -1 (bottom)
    z_cap  = sign*(core_len/2 + cap_len/2 - ov);
    z_neck = sign*(core_len/2 + cap_len + neck_len/2 - 2*ov);

    // Cap
    translate([0,0,z_cap])
        cylinder(h=cap_len + 2*ov, d=cap_d, center=true);

    // Neck (tapered into lead)
    translate([0,0,z_neck])
        cylinder(h=neck_len + 2*ov, d1=cap_d*0.55, d2=neck_d, center=true);

    // Small fillet at lead exit
    translate([0,0, sign*(body_len/2 + neck_len - 2*ov)])
        sphere(d=neck_d);
}

module lead(sign=1) {
    translate([0,0, sign*lead_z])
        cylinder(h=lead_len + 2*ov, d=lead_d, center=true);
}

module resistor_vitreous_enamel_3W() {
    union() {
        // Main body (core + caps)
        body_core();
        end_cap(+1);
        end_cap(-1);

        // Leads
        lead(+1);
        lead(-1);
    }
}

resistor_vitreous_enamel_3W();