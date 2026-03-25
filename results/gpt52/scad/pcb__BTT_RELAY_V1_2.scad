$fn=64;

module mainboard(size_x=80.4, size_y=36.3, thickness=1.5) {
    translate([-size_x/2, -size_y/2, -thickness/2])
        cube([size_x, size_y, thickness], center=false);
}

mainboard();