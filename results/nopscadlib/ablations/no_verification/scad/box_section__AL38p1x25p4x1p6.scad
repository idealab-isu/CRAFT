// Aluminium rectangular box section: 38.1mm x 25.4mm x 1.6mm wall

// Parameters (mm)
outer_width     = 38.1;   // X
outer_height    = 25.4;   // Y
wall_thickness  = 1.6;    // wall
length          = 1000;   // Z
center_model    = true;   // true=centered on Z, false=base at Z=0
overlap         = 0.5;    // boolean robustness (mm)

// Derived inner dimensions
inner_width  = outer_width  - 2*wall_thickness;
inner_height = outer_height - 2*wall_thickness;

// Safety clamp
inner_width_safe  = max(0.01, inner_width);
inner_height_safe = max(0.01, inner_height);

module box_section_tube() {
    difference() {
        // Outer tube
        cube([outer_width, outer_height, length], center=true);

        // Inner void (slightly longer to guarantee clean subtraction)
        cube([inner_width_safe, inner_height_safe, length + 2*overlap], center=true);
    }
}

translate([0, 0, center_model ? 0 : length/2])
    box_section_tube();