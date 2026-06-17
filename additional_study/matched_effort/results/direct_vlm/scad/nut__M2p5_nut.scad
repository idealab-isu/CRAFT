$fn = 120;

across_flats = 5.8;   // mm
thickness    = 2.2;   // mm
screw_d      = 2.5;   // mm

// Typical clearance for M2.5 nut hole (approx). Adjust if needed.
hole_d = 2.7;         // mm

module hex_prism_af(af, h){
    // For a regular hexagon: across_flats = 2 * apothem
    // Circumradius R = af / sqrt(3)
    R = af / sqrt(3);
    linear_extrude(height=h)
        polygon([ for(i=[0:5]) [ R*cos(60*i), R*sin(60*i) ] ]);
}

difference(){
    hex_prism_af(across_flats, thickness);
    translate([0,0,-0.2])
        cylinder(d=hole_d, h=thickness+0.4);
}