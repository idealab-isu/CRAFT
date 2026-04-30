module gt2_pulley() {
    tooth_count = 20;
    tooth_pitch = 2; // GT2 pitch
    pulley_diameter = tooth_count * tooth_pitch / pi;
    bore_diameter = 5;
    pulley_height = 10;
    flange_thickness = 1.5;
    flange_diameter = pulley_diameter + 4;

    difference() {
        union() {
            // Main pulley body
            cylinder(h = pulley_height, d = pulley_diameter, $fn = 64);
            // Top flange
            translate([0, 0, pulley_height])
                cylinder(h = flange_thickness, d = flange_diameter, $fn = 64);
            // Bottom flange
            translate([0, 0, -flange_thickness])
                cylinder(h = flange_thickness, d = flange_diameter, $fn = 64);
        }
        // Bore hole
        translate([0, 0, -flange_thickness])
            cylinder(h = pulley_height + 2 * flange_thickness, d = bore_diameter, $fn = 64);
    }
}

gt2_pulley();