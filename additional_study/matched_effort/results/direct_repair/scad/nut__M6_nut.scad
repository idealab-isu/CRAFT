$fn = 120;

across_flats = 11.5;   // mm
thickness    = 5.0;    // mm
screw_diam   = 6.0;    // mm (clearance hole)

clearance = 0.4;       // mm added to screw diameter for clearance
hole_diam = screw_diam + clearance;

flat_to_vertex = across_flats / cos(30); // circumradius for hex with given across-flats

difference() {
    cylinder(h = thickness, r = flat_to_vertex/2, $fn = 6);
    translate([0,0,-0.1])
        cylinder(h = thickness + 0.2, d = hole_diam, $fn = 80);
}