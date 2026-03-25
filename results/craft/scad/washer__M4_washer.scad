// Flat washer parameters (mm)
inner_diameter = 4.0;   // through-hole diameter
outer_diameter = 9.0;   // outside diameter
thickness      = 0.8;   // washer thickness

$fn = 128;

module flat_washer(id, od, h) {
    difference() {
        cylinder(d=od, h=h, center=true);
        cylinder(d=id, h=h + 0.2, center=true); // slight extra to guarantee clean through-hole
    }
}

flat_washer(inner_diameter, outer_diameter, thickness);