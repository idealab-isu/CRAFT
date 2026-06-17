$fn=96;

// Pillow block bearing for 8.0mm shaft, 55.0mm x 42.0mm base
// Parametric, printable representation (not a precision bearing model)

shaft_d = 8.0;

base_L = 55.0;
base_W = 42.0;
base_H = 10.0;

mount_hole_d = 6.5;
mount_hole_edge_x = 10.0;   // from each end along length
mount_hole_edge_y = 10.0;   // from each side along width

pedestal_L = 40.0;
pedestal_W = 30.0;
pedestal_H = 18.0;

housing_outer_d = 28.0;
housing_len = pedestal_W;   // cylinder axis along Y
housing_center_z = base_H + pedestal_H;

bore_clearance = 0.3;
bore_d = shaft_d + bore_clearance;

set_screw_d = 3.2;
set_screw_head_d = 6.0;
set_screw_z = housing_center_z + housing_outer_d*0.15;

fillet_r = 2.0;

module rounded_box(size=[10,10,10], r=1.5) {
    // Minkowski rounded edges (simple, renderable)
    minkowski() {
        cube([size[0]-2*r, size[1]-2*r, size[2]-2*r], center=true);
        sphere(r=r);
    }
}

module base_plate() {
    translate([0,0,base_H/2])
        rounded_box([base_L, base_W, base_H], r=fillet_r);
}

module pedestal() {
    translate([0,0,base_H + pedestal_H/2])
        rounded_box([pedestal_L, pedestal_W, pedestal_H], r=fillet_r);
}

module housing() {
    // Outer housing cylinder along Y
    translate([0,0,housing_center_z])
        rotate([90,0,0])
            cylinder(d=housing_outer_d, h=housing_len, center=true);
}

module mount_holes() {
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*(base_L/2 - mount_hole_edge_x), sy*(base_W/2 - mount_hole_edge_y), 0])
            cylinder(d=mount_hole_d, h=base_H + 0.5, center=false);
    }
}

module shaft_bore() {
    // Bore through housing along Y
    translate([0,0,housing_center_z])
        rotate([90,0,0])
            cylinder(d=bore_d, h=housing_len + 2, center=true);
}

module relief_under_housing() {
    // Slight relief pocket to avoid overhangs and mimic casting
    pocket_d = housing_outer_d - 6;
    pocket_h = pedestal_W + 2;
    translate([0,0,housing_center_z - housing_outer_d*0.25])
        rotate([90,0,0])
            cylinder(d=pocket_d, h=pocket_h, center=true);
}

module set_screw_hole() {
    // Radial set screw from top down into bore (along -Z)
    translate([0, 0, set_screw_z])
        rotate([0,0,0]) {
            cylinder(d=set_screw_d, h=housing_outer_d, center=false);
            // counterbore for head
            translate([0,0,0])
                cylinder(d=set_screw_head_d, h=3.0, center=false);
        }
}

difference() {
    union() {
        base_plate();
        pedestal();
        housing();
    }

    // Mounting holes
    mount_holes();

    // Shaft bore
    shaft_bore();

    // Relief pocket
    relief_under_housing();

    // Set screw
    set_screw_hole();
}