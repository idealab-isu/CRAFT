$fn = 64;

module iec_connector_lugless() {
    // Dimensions (mm)
    body_w = 30;
    body_d = 20;
    body_h = 15;

    rear_w = 28;
    rear_d = 18;
    rear_h = 7;

    flange_w = 34;
    flange_d = 24;
    flange_h = 2;

    bezel_w = 32;
    bezel_d = 22;
    bezel_h = 1;

    // Cutouts
    front_recess_w = 28;
    front_recess_d = 18;
    front_recess_h = 12; // recess depth from front face

    socket_w = 10;
    socket_d = 10;

    // Screw holes (lugless: holes only, no lugs)
    hole_r = 1.5;

    // Overlap / epsilon
    ov = 0.4;

    total_front_stack = flange_h + bezel_h;
    total_h = rear_h + body_h + total_front_stack;

    // Z placement (overall centered at z=0)
    z0 = 0;
    z_rear_center   = z0 - total_h/2 + rear_h/2;
    z_body_center   = z0 - total_h/2 + rear_h + body_h/2;
    z_flange_center = z0 + total_h/2 - total_front_stack + flange_h/2;
    z_bezel_center  = z0 + total_h/2 - bezel_h/2;

    // Faces
    z_front_face = z0 + total_h/2;
    z_back_face  = z0 - total_h/2;

    // Hole placement within flange footprint
    hole_x = flange_w/2 - 4;
    hole_y = flange_d/2 - 4;

    difference() {
        // ONE connected solid (stacked with overlaps)
        union() {
            translate([0, 0, z_body_center])
                cube([body_w, body_d, body_h + ov], center=true);

            translate([0, 0, z_rear_center])
                cube([rear_w, rear_d, rear_h + ov], center=true);

            translate([0, 0, z_flange_center])
                cube([flange_w, flange_d, flange_h + ov], center=true);

            translate([0, 0, z_bezel_center])
                cube([bezel_w, bezel_d, bezel_h + ov], center=true);
        }

        // Front recess: starts at front face and goes inward
        recess_center_z = z_front_face - front_recess_h/2;
        translate([0, 0, recess_center_z])
            cube([front_recess_w, front_recess_d, front_recess_h + 2*ov], center=true);

        // Socket orifice: through-all (guaranteed to cut entire part)
        translate([0, 0, z0])
            cube([socket_w, socket_d, total_h + 4*ov], center=true);

        // Screw holes: through bezel+flange only (from front face inward)
        hole_depth = total_front_stack + 2*ov;
        hole_center_z = z_front_face - hole_depth/2;
        for (x = [-hole_x, hole_x])
            for (y = [-hole_y, hole_y])
                translate([x, y, hole_center_z])
                    cylinder(h=hole_depth, r=hole_r, center=true);
    }
}

iec_connector_lugless();