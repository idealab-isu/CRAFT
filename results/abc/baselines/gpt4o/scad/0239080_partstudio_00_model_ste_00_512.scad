module studded_strip() {
    // Dimensions
    plate_length = 100;
    plate_width = 10;
    plate_height = 2;
    stud_diameter = 4;
    stud_height = 2;
    stud_spacing = 10;
    
    // Plate
    plate = cube([plate_length, plate_width, plate_height], center = true);
    
    // Stud
    module stud() {
        translate([0, 0, plate_height / 2])
            cylinder(h = stud_height, d = stud_diameter, $fn = 64);
    }
    
    // Studded strip
    union() {
        translate([0, 0, -plate_height / 2])
            plate;
        for (x = [-plate_length/2 + stud_spacing/2 : stud_spacing : plate_length/2 - stud_spacing/2]) {
            translate([x, 0, 0])
                stud();
        }
    }
}

studded_strip();