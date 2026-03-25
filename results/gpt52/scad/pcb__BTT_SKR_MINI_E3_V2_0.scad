$fn=64;

module mainboard(length=100.75, width=70.25, thickness=1.6) {
    cube([length, width, thickness], center=true);
}

mainboard();