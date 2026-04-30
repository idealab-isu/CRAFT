$fn=64;

// SG90 micro servo bracket with horn slot
// Dimensions are approximate and intended for typical SG90 (9g) servos.

servo_w = 23.0;      // body width (X)
servo_d = 12.5;      // body depth (Y)
servo_h = 24.0;      // body height (Z)

clearance = 0.6;

wall = 3.0;
base_t = 4.0;

inner_w = servo_w + 2*clearance;
inner_d = servo_d + 2*clearance;
inner_h = servo_h + 2.0;

outer_w = inner_w + 2*wall;
outer_d = inner_d + 2*wall;
outer_h = inner_h + wall;

base_w = outer_w + 10.0;
base_d = outer_d + 10.0;

mount_hole_d = 3.2;
mount_hole_offset_x = base_w/2 - 7.0;
mount_hole_offset_y = base_d/2 - 7.0;

horn_slot_w = 18.0;
horn_slot_d = 6.0;
horn_slot_z = base_t + inner_h - 6.0; // near top opening

side_screw_d = 2.2;
side_screw_len = outer_d + 2.0;
side_screw_z = base_t + inner_h*0.55;
side_screw_x = outer_w/2 - wall/2;

module rounded_box(size=[10,10,10], r=2) {
    // Minkowski with sphere for rounded edges
    minkowski() {
        cube([size[0]-2*r, size[1]-2*r, size[2]-2*r], center=true);
        sphere(r=r);
    }
}

difference() {
    union() {
        // Base plate
        translate([0,0,-(outer_h/2) + base_t/2])
            rounded_box([base_w, base_d, base_t], r=1.5);

        // U-bracket body (walls)
        translate([0,0,0])
            rounded_box([outer_w, outer_d, outer_h], r=2.0);

        // Small front lip for retention
        translate([0, outer_d/2 - wall/2, -(outer_h/2) + base_t + 6])
            cube([outer_w*0.7, wall, 12], center=true);

        // Small back lip for retention
        translate([0, -(outer_d/2 - wall/2), -(outer_h/2) + base_t + 6])
            cube([outer_w*0.7, wall, 12], center=true);
    }

    // Hollow cavity for servo body (open top)
    translate([0,0,base_t/2])
        cube([inner_w, inner_d, outer_h], center=true);

    // Open top cut (ensure top is open)
    translate([0,0, outer_h/2 - wall/2])
        cube([outer_w+2, outer_d+2, wall+2], center=true);

    // Horn slot on top area (for horn movement/clearance)
    translate([0,0, -(outer_h/2) + horn_slot_z])
        cube([horn_slot_w, horn_slot_d, 8.0], center=true);

    // Base mounting holes (4)
    for (sx=[-1,1], sy=[-1,1]) {
        translate([sx*mount_hole_offset_x, sy*mount_hole_offset_y, -(outer_h/2) + base_t/2])
            cylinder(h=base_t+2, d=mount_hole_d, center=true);
    }

    // Side screw holes (optional clamp holes)
    // Right side
    translate([ side_screw_x, 0, -(outer_h/2) + side_screw_z])
        rotate([90,0,0])
            cylinder(h=side_screw_len, d=side_screw_d, center=true);

    // Left side
    translate([-side_screw_x, 0, -(outer_h/2) + side_screw_z])
        rotate([90,0,0])
            cylinder(h=side_screw_len, d=side_screw_d, center=true);

    // Front/back cable relief notch
    translate([0, outer_d/2 - wall, -(outer_h/2) + base_t + 4])
        cube([inner_w*0.6, wall*2.2, 10], center=true);
}