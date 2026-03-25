$fn=64;

plate_size = 95.0;
thickness = 9.0;

module square_plate(size, t){
    translate([-size/2, -size/2, -t/2])
        cube([size, size, t], center=false);
}

square_plate(plate_size, thickness);