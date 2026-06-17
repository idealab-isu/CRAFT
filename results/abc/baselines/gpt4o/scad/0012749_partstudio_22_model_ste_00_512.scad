module chamfered_plate() {
    plate_length = 100;
    plate_width = 50;
    plate_thickness = 2;
    chamfer_size = 5;

    difference() {
        cube([plate_length, plate_width, plate_thickness], center = true);
        for (x_offset = [-1, 1])
            for (y_offset = [-1, 1])
                translate([x_offset * (plate_length / 2 - chamfer_size), y_offset * (plate_width / 2 - chamfer_size), 0])
                    cube([chamfer_size, chamfer_size, plate_thickness], center = false);
    }
}

chamfered_plate();