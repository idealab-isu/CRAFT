$fn=64;

plate_x = 200;
plate_y = 150;
plate_th = 10;

module tooling_plate(x, y, th){
    translate([-x/2, -y/2, -th/2])
        cube([x, y, th], center=false);
}

tooling_plate(plate_x, plate_y, plate_th);