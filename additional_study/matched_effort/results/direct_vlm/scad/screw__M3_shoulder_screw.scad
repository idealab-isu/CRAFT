$fn = 96;

shaft_d = 4.0;
head_d  = 7.0;
head_h  = 2.4;
len     = 10.0;

module screw_simple(shaft_d, head_d, head_h, len) {
    union() {
        // Shaft
        cylinder(d = shaft_d, h = len);

        // Head (simple cylindrical head)
        translate([0,0,len])
            cylinder(d = head_d, h = head_h);
    }
}

screw_simple(shaft_d, head_d, head_h, len);