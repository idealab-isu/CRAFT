$fn=64;

module lead(len=25, dia=1.0) {
    cylinder(h=len, d=dia, center=false);
}

module resistor_body(body_len=25, body_dia=9.5, cap_len=2.0, cap_dia=10.2) {
    union() {
        cylinder(h=body_len, d=body_dia, center=true);
        translate([0,0, body_len/2 - cap_len/2]) cylinder(h=cap_len, d=cap_dia, center=true);
        translate([0,0,-body_len/2 + cap_len/2]) cylinder(h=cap_len, d=cap_dia, center=true);
    }
}

module band(zpos, w=1.2, d=9.7) {
    translate([0,0,zpos]) cylinder(h=w, d=d, center=true);
}

module vitreous_resistor_3W() {
    body_len = 25;
    body_dia = 9.5;
    cap_len  = 2.0;
    cap_dia  = 10.2;

    lead_len = 28;
    lead_dia = 1.0;

    union() {
        color([0.85,0.85,0.85])
        rotate([0,90,0]) resistor_body(body_len=body_len, body_dia=body_dia, cap_len=cap_len, cap_dia=cap_dia);

        color([0.75,0.75,0.75]) {
            translate([-(body_len/2 + lead_len),0,0]) rotate([0,90,0]) lead(len=lead_len, dia=lead_dia);
            translate([ (body_len/2),0,0]) rotate([0,90,0]) lead(len=lead_len, dia=lead_dia);
        }

        color([0.15,0.15,0.15]) {
            rotate([0,90,0]) band(zpos=-6.5, w=1.2, d=body_dia+0.4);
            rotate([0,90,0]) band(zpos=-4.2, w=1.2, d=body_dia+0.4);
            rotate([0,90,0]) band(zpos= 4.2, w=1.2, d=body_dia+0.4);
            rotate([0,90,0]) band(zpos= 6.5, w=1.2, d=body_dia+0.4);
        }

        color([0.1,0.1,0.1])
        rotate([0,90,0]) translate([0,0,0]) cylinder(h=0.6, d=body_dia+0.2, center=true);
    }
}

vitreous_resistor_3W();