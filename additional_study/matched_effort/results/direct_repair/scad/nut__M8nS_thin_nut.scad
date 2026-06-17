$fn = 120;

screw_d = 8.0;          // nominal screw diameter (mm)
clearance = 0.4;        // typical clearance for M8 (adjust for your printer)
hole_d = screw_d + clearance;

across_flats = 13.0;    // mm
thickness = 4.0;        // mm

module hex_prism_af(af, h) {
    // For a regular hexagon: across_flats = sqrt(3) * circumradius
    r = af / sqrt(3);
    linear_extrude(height = h)
        polygon(points = [for (i = [0:5]) [r*cos(60*i), r*sin(60*i)]]);
}

difference() {
    hex_prism_af(across_flats, thickness);
    translate([0,0,-0.2])
        cylinder(d = hole_d, h = thickness + 0.4);
}