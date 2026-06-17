$fn = 64;

// T-slot nut parameters (mm)
screw_d = 3.0;          // clearance for M3 screw
across_flats = 6.0;     // hex across flats
thickness = 2.75;       // nut thickness

// Derived
hex_R = across_flats / sqrt(3); // circumradius for hex with given across-flats
hole_d = screw_d + 0.4;         // typical clearance

module hex_prism(af, h){
    R = af / sqrt(3);
    linear_extrude(height=h)
        polygon([ for(i=[0:5]) [ R*cos(60*i), R*sin(60*i) ] ]);
}

difference(){
    hex_prism(across_flats, thickness);
    translate([0,0,-0.2])
        cylinder(d=hole_d, h=thickness+0.4);
}