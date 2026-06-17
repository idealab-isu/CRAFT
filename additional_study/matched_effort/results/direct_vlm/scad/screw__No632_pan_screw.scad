$fn = 96;

shaft_d = 3.5;
length = 10;

head_d = 6.9;
head_h = 2.5;

// Simple pan head screw (unthreaded shaft)
union() {
    // Shaft
    cylinder(d = shaft_d, h = length);

    // Pan head (approximated as a short cylinder with a rounded top)
    translate([0,0,length])
    union() {
        cylinder(d = head_d, h = head_h * 0.55);
        translate([0,0,head_h * 0.55])
            scale([1,1,0.45])
                sphere(d = head_d);
    }
}