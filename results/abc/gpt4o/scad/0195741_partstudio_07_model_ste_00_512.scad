cylinder_rod_diameter = 0.02;
cylinder_rod_length = 0.2;
hole_diameter = 0.005;
hole_offset = 0.015;
$fn = 12; // Low-poly surface finish

module rod_with_hole() {
    difference() {
        // Main cylindrical rod
        cylinder(h = cylinder_rod_length, d = cylinder_rod_diameter, $fn = $fn);
        
        // Transverse through-hole
        translate([0, 0, hole_offset])
            rotate([90, 0, 0])
                cylinder(h = cylinder_rod_diameter, d = hole_diameter, $fn = $fn);
    }
}

translate([0, 0, -cylinder_rod_length / 2])
    rod_with_hole();