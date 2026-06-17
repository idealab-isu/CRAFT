$fn = 128;

// Dimensions (mm)
shaft_d = 4.2;
shaft_r = shaft_d/2;

length = 10.0;

head_d = 8.2;
head_r = head_d/2;

head_h = 3.05;

// Simple pan head profile parameters
head_cyl_h = head_h * 0.55;
head_dome_h = head_h - head_cyl_h;

module pan_head_screw() {
    union() {
        // Shaft
        cylinder(h = length, r = shaft_r);

        // Head: short cylinder + rounded dome
        translate([0,0,length])
        union() {
            cylinder(h = head_cyl_h, r = head_r);

            // Dome via scaled sphere intersected to keep only top portion
            translate([0,0,head_cyl_h])
            intersection() {
                scale([1,1,head_dome_h/(head_r)]) sphere(r = head_r);
                translate([-head_r,-head_r,0]) cube([2*head_r, 2*head_r, head_dome_h]);
            }
        }
    }
}

pan_head_screw();