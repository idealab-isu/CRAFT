$fn = 96;

// Wing nut for M4 (4.0mm) screw
// Specs: 10.0mm across flats, 3.75mm thick

across_flats = 10.0;
thickness    = 3.75;

screw_d      = 4.0;
clearance    = 0.35;          // typical clearance for M4
hole_d       = screw_d + clearance;

nut_flat_to_corner = across_flats / cos(30); // circumscribed diameter for hex
hex_r = nut_flat_to_corner / 2;

wing_span = 22.0;             // overall width including wings
wing_len  = (wing_span - across_flats) / 2;
wing_w    = 7.0;              // wing width (Y direction)
wing_tip_r = 2.2;

module hex_prism(af, h){
    r = (af / cos(30)) / 2;
    linear_extrude(height=h)
        polygon([ for(i=[0:5]) [ r*cos(60*i+30), r*sin(60*i+30) ] ]);
}

module wing2d(len, w, tip_r){
    // Rounded rectangle-ish wing extending in +X from origin
    hull(){
        translate([0, 0]) circle(r=0.01);
        translate([len, 0]) circle(r=tip_r);
        translate([len,  w/2 - tip_r]) circle(r=tip_r);
        translate([len, -w/2 + tip_r]) circle(r=tip_r);
        translate([0,  w/2]) circle(r=0.01);
        translate([0, -w/2]) circle(r=0.01);
    }
}

module wingnut(){
    difference(){
        union(){
            // Main hex body
            hex_prism(across_flats, thickness);

            // Wings (two sides)
            linear_extrude(height=thickness)
                union(){
                    translate([across_flats/2, 0]) wing2d(wing_len, wing_w, wing_tip_r);
                    mirror([1,0,0]) translate([across_flats/2, 0]) wing2d(wing_len, wing_w, wing_tip_r);
                }

            // Slight top/bottom chamfer via minkowski-like bevel approximation
            // (kept subtle to preserve thickness)
        }

        // Through hole for screw
        translate([0,0,-0.2])
            cylinder(d=hole_d, h=thickness+0.4);
    }
}

wingnut();