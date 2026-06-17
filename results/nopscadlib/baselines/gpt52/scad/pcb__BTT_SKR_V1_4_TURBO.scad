$fn=64;

module mainboard(length=110.0, width=85.0, thickness=1.6) {
    translate([0,0,thickness/2])
        cube([length, width, thickness], center=true);
}

mainboard();