$fn = 96;

// D-sub style connector body (generic "D connector")
module d_connector(
    body_len = 30,
    body_height = 12,
    body_depth = 10,
    flange_thickness = 2.5,
    flange_margin = 4,
    corner_r = 1.2,

    // D profile parameters (front face)
    d_width = 24,
    d_height = 10,

    // Mounting ears
    ear_radius = 5.5,
    ear_hole_d = 3.2,
    ear_offset = 18,   // center-to-center from body center along X

    // Pin field (visual only)
    pin_rows = 2,
    pins_per_row = 9,
    pin_pitch_x = 2.77,
    pin_pitch_y = 2.84,
    pin_d = 1.0,
    pin_len = 4.5,
    pin_inset = 1.2
) {
    module rounded_box(sz=[10,10,10], r=1) {
        r2 = min(r, min(sz[0], min(sz[1], sz[2]))/2);
        minkowski() {
            cube([sz[0]-2*r2, sz[1]-2*r2, sz[2]-2*r2], center=true);
            sphere(r=r2);
        }
    }

    // 2D D-shape: rectangle + semicircle on one side
    module d2d(w, h) {
        // Flat on left, round on right
        r = h/2;
        union() {
            translate([-w/2, -h/2]) square([w - r, h], center=false);
            translate([w/2 - r, 0]) circle(r=r);
        }
    }

    // Main body with D-shaped front face
    module body() {
        // Create a prism by extruding D-shape along depth (Y)
        // Coordinate system:
        // X = width, Y = depth (front to back), Z = height
        // Front face at Y=0, body extends to +Y
        translate([0, body_depth/2, 0])
            linear_extrude(height=body_depth, center=true, convexity=10)
                d2d(d_width, d_height);

        // Add a slightly larger rounded housing behind for realism
        translate([0, body_depth/2 + (body_len - body_depth)/2, 0])
            rounded_box([body_len, body_len*0.35, body_height], r=corner_r);
    }

    // Flange plate with ears and holes
    module flange() {
        flange_w = d_width + 2*flange_margin + 2*ear_radius;
        flange_h = d_height + 2*flange_margin;
        // Plate
        difference() {
            union() {
                translate([0, flange_thickness/2, 0])
                    rounded_box([flange_w, flange_thickness, flange_h], r=corner_r);

                // Ears (cylinders) blended into plate
                for (sx = [-1, 1]) {
                    translate([sx*ear_offset, flange_thickness/2, 0])
                        rotate([90,0,0])
                            cylinder(h=flange_thickness, r=ear_radius, center=true);
                }
            }

            // D opening cutout through flange
            translate([0, flange_thickness/2, 0])
                rotate([90,0,0])
                    linear_extrude(height=flange_thickness+0.2, center=true, convexity=10)
                        d2d(d_width+0.6, d_height+0.6);

            // Ear holes
            for (sx = [-1, 1]) {
                translate([sx*ear_offset, flange_thickness/2, 0])
                    rotate([90,0,0])
                        cylinder(h=flange_thickness+0.6, d=ear_hole_d, center=true);
            }
        }
    }

    // Pins (simple cylinders) on front
    module pins() {
        total_w = (pins_per_row-1)*pin_pitch_x;
        total_h = (pin_rows-1)*pin_pitch_y;
        x0 = -total_w/2;
        z0 = -total_h/2;

        for (r = [0:pin_rows-1]) {
            // Stagger second row slightly (typical D-sub)
            x_shift = (r % 2 == 1) ? pin_pitch_x/2 : 0;
            for (c = [0:pins_per_row-1]) {
                x = x0 + c*pin_pitch_x + x_shift;
                z = z0 + r*pin_pitch_y;
                translate([x, -pin_len/2 - pin_inset, z])
                    rotate([90,0,0])
                        cylinder(h=pin_len, d=pin_d, center=true);
            }
        }
    }

    // Assemble
    union() {
        // Flange at front (Y=0 plane)
        translate([0, 0, 0]) flange();

        // Body behind flange
        translate([0, flange_thickness, 0]) body();

        // Pins protruding from front
        translate([0, 0, 0]) pins();
    }
}

// Render
d_connector();