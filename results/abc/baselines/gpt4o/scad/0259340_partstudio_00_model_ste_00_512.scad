$fn=64;

module rounded_rectangle(width, height, radius) {
    difference() {
        offset(r=radius) {
            square([width - 2*radius, height - 2*radius], center=true);
        }
        translate([-width/2, -height/2])
            square([width, height], center=false);
    }
}

module diamond_hole(size) {
    rotate(45)
        square([size, size], center=true);
}

module perforated_wall(width, height, hole_size, spacing) {
    difference() {
        square([width, height], center=true);
        for (x = [-width/2 + spacing/2 : spacing : width/2 - spacing/2])
            for (y = [-height/2 + spacing/2 : spacing : height/2 - spacing/2])
                translate([x, y])
                    diamond_hole(hole_size);
    }
}

module tray() {
    difference() {
        union() {
            translate([0, 0, 0.05])
                rounded_rectangle(0.3, 0.1, 0.01);
            translate([0, 0, 0.05])
                offset(delta=0.01)
                    rounded_rectangle(0.3, 0.1, 0.01);
        }
        translate([0, 0, 0.05])
            cube([0.3, 0.1, 0.01], center=true);
    }
}

module flange() {
    difference() {
        offset(delta=0.02)
            rounded_rectangle(0.3, 0.1, 0.01);
        rounded_rectangle(0.3, 0.1, 0.01);
    }
}

module tray_with_flange() {
    union() {
        tray();
        translate([0, 0, 0.06])
            flange();
    }
}

module perforated_tray() {
    difference() {
        tray_with_flange();
        translate([0, 0, 0.05])
            perforated_wall(0.3, 0.1, 0.005, 0.02);
    }
}

perforated_tray();