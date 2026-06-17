$fn = 96;

// Requested key dimensions
shaft_diameter = 10.0;          // shaft bore
base_length    = 67.0;          // X
base_width     = 53.0;          // Y
base_thickness = 8.0;           // Z

// Pillow block proportions (parametric, typical look)
housing_outer_d = 34.0;         // outer "bearing seat" diameter
housing_len     = 38.0;         // length along X (across base)
housing_center_z = base_thickness + 16.0;  // center height of bore above base bottom

cap_thickness   = 6.0;          // top cap thickness
cap_width_y     = 44.0;         // cap width across Y
cap_len_x       = housing_len;  // cap length along X

mounting_hole_d = 7.0;          // base mounting holes
mount_edge_x    = 10.0;         // edge margin along X
mount_edge_y    = 10.0;         // edge margin along Y

gusset_thickness = 10.0;        // gusset thickness along X
gusset_y_span    = 18.0;        // gusset span along Y
gusset_overlap   = 0.6;         // small overlap to ensure watertight unions

// Derived
bore_d = shaft_diameter;        // exact 10mm bore
cx = base_length/2;
cy = base_width/2;

// Helpers
module rounded_block(size=[10,10,10], r=2) {
    // Minkowski rounded rectangular prism
    r2 = min(r, min(size[0], min(size[1], size[2]))/2 - 0.01);
    minkowski() {
        cube([size[0]-2*r2, size[1]-2*r2, size[2]-2*r2], center=true);
        sphere(r=r2);
    }
}

module base_plate() {
    // Base centered at origin in XY, bottom at Z=0
    translate([cx, cy, base_thickness/2])
        rounded_block([base_length, base_width, base_thickness], r=2.5);
}

module mounting_holes() {
    // 4 holes, symmetric, through base
    hx = base_length/2 - mount_edge_x;
    hy = base_width/2  - mount_edge_y;

    for (sx = [-1, 1])
        for (sy = [-1, 1])
            translate([cx + sx*hx, cy + sy*hy, base_thickness/2])
                cylinder(h=base_thickness + 2, d=mounting_hole_d, center=true);
}

module housing_body() {
    // Main housing: a horizontal cylinder (along X) sitting on base
    // Bottom of housing touches base at Z=base_thickness (with slight overlap)
    translate([cx, cy, housing_center_z])
        rotate([0, 90, 0])
            cylinder(h=housing_len, d=housing_outer_d, center=true);
}

module cap_block() {
    // Top cap: rounded rectangular block sitting on top of housing
    cap_z_center = housing_center_z + housing_outer_d/2 + cap_thickness/2 - gusset_overlap;

    translate([cx, cy, cap_z_center])
        rounded_block([cap_len_x, cap_width_y, cap_thickness], r=2.0);
}

module gussets() {
    // Two gussets (front/back) connecting base to housing
    // Use hull between a small pad on base and a pad on housing side.
    gx = gusset_thickness;
    gy = gusset_y_span;
    // Place gussets near +/-Y, centered in X
    for (sy = [-1, 1]) {
        y0 = cy + sy*(housing_outer_d/2 - 2); // near housing side
        hull() {
            // Base pad
            translate([cx, y0, base_thickness/2])
                cube([gx, gy, base_thickness], center=true);

            // Housing pad (slightly overlapping into housing)
            translate([cx, y0, housing_center_z])
                rotate([0, 90, 0])
                    cylinder(h=gx, d=gy, center=true);
        }
    }
}

module bore_cut() {
    // Through-bore along X through housing and cap
    translate([cx, cy, housing_center_z])
        rotate([0, 90, 0])
            cylinder(h=housing_len + 2, d=bore_d, center=true);
}

module cap_split_slot() {
    // A shallow slot on top to suggest split cap (visual feature)
    slot_w = 2.0;
    slot_h = cap_thickness + 1;
    slot_len = cap_len_x + 2;

    cap_z_center = housing_center_z + housing_outer_d/2 + cap_thickness/2 - gusset_overlap;

    translate([cx, cy, cap_z_center + 0.2])
        cube([slot_len, slot_w, slot_h], center=true);
}

module pillow_block() {
    difference() {
        union() {
            base_plate();
            // Ensure connected: housing overlaps base by a tiny amount
            housing_body();
            cap_block();
            gussets();
        }
        mounting_holes();
        bore_cut();
        cap_split_slot();
    }
}

pillow_block();