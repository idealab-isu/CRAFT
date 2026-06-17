module corrugated_cardboard(length=200, width=100, thickness=5, wave_height=2, wave_length=10) {
    difference() {
        cube([length, width, thickness], center=true);
        translate([-length/2, -width/2, -thickness/2]) {
            for (x = [0 : wave_length : length]) {
                for (y = [0 : wave_length : width]) {
                    translate([x, y, thickness/2]) {
                        rotate([90, 0, 0]) {
                            cylinder(h=thickness, r=wave_height, $fn=64);
                        }
                    }
                }
            }
        }
    }
}

corrugated_cardboard();