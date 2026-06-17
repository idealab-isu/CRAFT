$fn = 96;

// Dimensions (mm)
shaft_d = 4.0;
length = 10.0;

head_d = 7.8;
head_h = 3.3;

// Simple pan head approximation: cylindrical head with rounded top edge
module pan_head_screw(shaft_d, length, head_d, head_h) {
    union() {
        // Shaft
        cylinder(h = length, d = shaft_d);

        // Head (base cylinder)
        translate([0,0,length])
            cylinder(h = head_h, d = head_d);

        // Rounded top (torus-like fillet via rotate_extrude)
        // Fillet radius chosen as a fraction of head height
        fillet_r = min(head_h * 0.45, (head_d - shaft_d) * 0.25);
        translate([0,0,length + head_h - fillet_r])
            rotate_extrude(angle = 360)
                translate([head_d/2 - fillet_r, 0, 0])
                    circle(r = fillet_r);
    }
}

pan_head_screw(shaft_d, length, head_d, head_h);