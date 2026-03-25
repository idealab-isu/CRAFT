$fn=96;

module led_lead(len=25, dia=0.6) {
    cylinder(h=len, d=dia, center=false);
}

module led_body(d=10.0, h=11.0) {
    union() {
        cylinder(h=h-2.0, d=d, center=false);
        translate([0,0,h-2.0]) sphere(d=d);
        translate([0,0,0]) cylinder(h=1.0, d=d*1.02, center=false);
    }
}

module led_10mm_tht(body_d=10.0, body_h=11.0, lead_len=25.0, lead_pitch=2.54, lead_d=0.6) {
    union() {
        translate([0,0,0]) led_body(d=body_d, h=body_h);

        translate([-lead_pitch/2, 0, -lead_len]) led_lead(len=lead_len, dia=lead_d);
        translate([ lead_pitch/2, 0, -lead_len]) led_lead(len=lead_len, dia=lead_d);

        translate([-lead_pitch/2, 0, -2.0]) cylinder(h=2.0, d=lead_d*1.6, center=false);
        translate([ lead_pitch/2, 0, -2.0]) cylinder(h=2.0, d=lead_d*1.6, center=false);
    }
}

translate([0,0,-11.0/2]) led_10mm_tht(body_d=10.0, body_h=11.0, lead_len=25.0, lead_pitch=2.54, lead_d=0.6);