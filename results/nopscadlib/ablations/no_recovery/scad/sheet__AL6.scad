// Parameters
plate_length = 300; //[150:600:1]
plate_width = 200; //[100:400:1]
plate_thickness = 10; //[5:20:1]

// Geometry
module tooling_plate_sheet() {
  color("Silver") // Aluminum color
  translate([0, 0, 0]) // Centered position
    cube([plate_length, plate_width, plate_thickness], center=true);
}

// Final Output
tooling_plate_sheet();