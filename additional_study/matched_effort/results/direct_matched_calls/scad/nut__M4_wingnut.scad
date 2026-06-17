$fn = 96;

// Wing nut for M4 (4.0mm) screw
// Specs: 10.0mm across flats, 3.75mm thick

across_flats = 10.0;
thickness    = 3.75;

screw_d      = 4.0;      // nominal screw diameter
clearance    = 0.4;      // clearance for through-hole
hole_d       = screw_d + clearance;

wing_span    = 22.0;     // overall width including wings
wing_len     = (wing_span - across_flats)/2;
wing_w       = 7.0;      // wing width (front-back)
wing_tip_r   = 2.0;      // rounding at wing tips

module hex_prism(af, h){
    r = af / sqrt(3); // circumradius for given across-flats
    cylinder(h=h, r=r, $fn=6);
}

module wing2d(len, w, tip_r){
    // Rounded rectangle extending from x=0..len, centered on y=0
    hull(){
        translate([tip_r, 0]) circle(r=tip_r);
        translate([len - tip_r, 0]) circle(r=tip_r);
        translate([tip_r,  w/2 - tip_r]) circle(r=tip_r);
        translate([tip_r, -w/2 + tip_r]) circle(r=tip_r);
        translate([len - tip_r,  w/2 - tip_r]) circle(r=tip_r);
        translate([len - tip_r, -w/2 + tip_r]) circle(r=tip_r);
    }
}

difference(){
    union(){
        // Central hex body
        hex_prism(across_flats, thickness);

        // Wings (left and right)
        for (sx = [-1, 1]){
            translate([sx*(across_flats/2), 0, 0])
                linear_extrude(height=thickness)
                    mirror([sx<0 ? 1 : 0, 0, 0])
                        wing2d(wing_len, wing_w, wing_tip_r);
        }
    }

    // Through hole for M4 screw
    translate([0,0,-0.2])
        cylinder(h=thickness+0.4, d=hole_d, $fn=96);
}