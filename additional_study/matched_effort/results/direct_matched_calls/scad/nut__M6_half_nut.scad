$fn = 120;

screw_d = 6.0;          // nominal screw diameter (M6)
across_flats = 11.5;    // mm
thickness = 3.0;        // mm

// Typical M6 coarse pitch clearance-ish hole; adjust if you want tighter/looser
hole_d = 6.4;

// Small chamfer on top/bottom edges
chamfer = 0.35;

module hex_prism(af, h){
    // For a regular hexagon: across_flats = 2 * apothem
    // Circumradius R = apothem / cos(30°) = (af/2)/cos(30°)
    R = (af/2) / cos(30);
    linear_extrude(height=h)
        polygon([ for (i=[0:5]) [ R*cos(60*i), R*sin(60*i) ] ]);
}

module chamfered_hex_nut(af, h, ch){
    // Create chamfers by hulling between slightly different hex sizes
    // at z=0, z=ch, z=h-ch, z=h
    hull() {
        translate([0,0,0])      hex_prism(af - 2*ch, 0.01);
        translate([0,0,ch])     hex_prism(af,        0.01);
    }
    translate([0,0,ch])
        hex_prism(af, h - 2*ch);
    hull() {
        translate([0,0,h-ch])   hex_prism(af,        0.01);
        translate([0,0,h])      hex_prism(af - 2*ch, 0.01);
    }
}

difference() {
    chamfered_hex_nut(across_flats, thickness, chamfer);
    translate([0,0,-1])
        cylinder(d=hole_d, h=thickness+2);
}