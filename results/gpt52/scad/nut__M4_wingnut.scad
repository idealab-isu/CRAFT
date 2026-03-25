$fn=96;

screw_d = 4.0;
clearance = 0.4;
hole_d = screw_d + clearance;

across_flats = 10.0;
thickness = 3.75;

wing_span = 22.0;
wing_width = 7.0;
wing_tip_r = 2.0;

hub_r = across_flats / sqrt(3);
hub_flat_r = across_flats / 2;

module hex_prism(af, h){
    r = af / sqrt(3);
    cylinder(h=h, r=r, $fn=6, center=true);
}

module wing2d(len, w, tipr){
    hull(){
        translate([0,0]) circle(r=w/2, $fn=64);
        translate([len,0]) circle(r=tipr, $fn=64);
    }
}

module wing3d(len, w, tipr, h){
    linear_extrude(height=h, center=true, convexity=10)
        wing2d(len, w, tipr);
}

module wingnut_body(){
    union(){
        hex_prism(across_flats, thickness);
        translate([hub_flat_r,0,0]) wing3d(wing_span/2 - hub_flat_r, wing_width, wing_tip_r, thickness);
        mirror([1,0,0]) translate([hub_flat_r,0,0]) wing3d(wing_span/2 - hub_flat_r, wing_width, wing_tip_r, thickness);
    }
}

difference(){
    wingnut_body();
    cylinder(h=thickness+2, d=hole_d, center=true, $fn=96);
}