$fn=64;

// Approximate GT2 20T pulley (2mm pitch) with 5mm bore
// Dimensions are typical/approximate for printable model.

teeth = 20;
pitch = 2.0;
bore_d = 5.0;

pulley_od = 12.2;          // typical OD for 20T GT2 pulley
tooth_ring_od = 13.0;      // slight outer ring for tooth approximation
tooth_ring_id = 11.2;      // inner ring for tooth approximation

body_h = 16.0;             // overall height
tooth_h = 7.0;             // toothed section height
flange_h = 1.2;            // flange thickness
flange_od = 16.0;          // flange diameter

hub_od = 14.0;             // hub diameter
hub_h = body_h;            // full height hub

set_screw_d = 2.5;         // optional set screw hole
set_screw_z = 0;           // centered
set_screw_r = hub_od/2 - 1.5;

module gt2_pulley_20t_5mm() {
    difference() {
        union() {
            // Hub/body
            cylinder(d=hub_od, h=hub_h, center=true);

            // Tooth ring (approximation)
            translate([0,0,0])
                difference() {
                    cylinder(d=tooth_ring_od, h=tooth_h, center=true);
                    cylinder(d=tooth_ring_id, h=tooth_h+0.2, center=true);
                }

            // Flanges
            translate([0,0, body_h/2 - flange_h/2])
                cylinder(d=flange_od, h=flange_h, center=true);
            translate([0,0,-body_h/2 + flange_h/2])
                cylinder(d=flange_od, h=flange_h, center=true);

            // Slight outer cylinder to reach pulley OD in toothed area
            translate([0,0,0])
                cylinder(d=pulley_od, h=tooth_h, center=true);
        }

        // Bore
        cylinder(d=bore_d, h=body_h+2, center=true);

        // Set screw hole (radial)
        translate([0,0,set_screw_z])
            rotate([0,90,0])
                translate([0,0,set_screw_r])
                    cylinder(d=set_screw_d, h=hub_od+4, center=true);

        // Tooth notches (simple rectangular approximation around circumference)
        for (i = [0:teeth-1]) {
            angle = i * 360 / teeth;
            // notch dimensions
            notch_w = 0.9;     // tangential width
            notch_d = 0.6;     // radial depth
            notch_h = tooth_h + 0.4;

            rotate([0,0,angle])
                translate([pulley_od/2 - notch_d/2, 0, 0])
                    cube([notch_d, notch_w, notch_h], center=true);
        }
    }
}

gt2_pulley_20t_5mm();