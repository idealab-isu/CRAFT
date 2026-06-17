// Environmental sensor board (single connected solid)
// Target PCB: 65.0mm x 30.6mm x 1.6mm

$fn = 64;

// -------------------- Parameters --------------------
board_length = 65.0;
board_width  = 30.6;
board_thickness = 1.6;

corner_radius = 3.0;

mount_hole_diameter = 3.2;
mount_hole_edge_offset_x = 5.0;
mount_hole_edge_offset_y = 4.0;
hole_cut_extra_height = 0.8;   // ensures clean through-cut

// Make all "details" part of ONE connected solid by using shallow embosses
// (not separate floating shells). These are subtle but visible in 3D.
emboss_h = 0.25;               // small raised features on top
engrave_h = 0.20;              // small recessed features on top
eps = 0.05;                    // overlap to guarantee manifold unions/differences

// Connector (header) block
connector_body_length = 16.0;
connector_body_width  = 8.0;
connector_body_height = 6.0;
pad_pitch = 2.54;
pad_count = 6;
pad_row_offset_x = 8.0;
pad_row_offset_y = 6.0;

// Sensor package
sensor_body_length = 10.0;
sensor_body_width  = 10.0;
sensor_body_height = 2.6;
sensor_offset_x_from_right = 14.0;
sensor_offset_y_from_top   = 8.0;
sensor_cap_radius = 1.2;
sensor_cap_height = 0.8;

// -------------------- Helpers --------------------
module rounded_rect_prism(L, W, H, R) {
    // Centered at origin, height along Z, centered in Z
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - R), sy*(W/2 - R), 0])
                cylinder(r=R, h=H, center=true);
    }
}

module mount_hole_at(x, y) {
    translate([x, y, 0])
        cylinder(d=mount_hole_diameter, h=board_thickness + hole_cut_extra_height, center=true);
}

module top_emboss(z0, h) {
    // Places features on top surface with guaranteed overlap into PCB
    translate([0, 0, z0 + h/2 - eps]) children();
}

module top_engrave(z0, h) {
    // Places cut features starting at top surface going downward
    translate([0, 0, z0 - h/2 + eps]) children();
}

// -------------------- Main PCB with holes --------------------
module pcb_with_holes() {
    difference() {
        rounded_rect_prism(board_length, board_width, board_thickness, corner_radius);

        // 4 mounting holes (through)
        mount_hole_at(-board_length/2 + mount_hole_edge_offset_x,
                      -board_width/2  + mount_hole_edge_offset_y);

        mount_hole_at( board_length/2 - mount_hole_edge_offset_x,
                      -board_width/2  + mount_hole_edge_offset_y);

        mount_hole_at(-board_length/2 + mount_hole_edge_offset_x,
                       board_width/2  - mount_hole_edge_offset_y);

        mount_hole_at( board_length/2 - mount_hole_edge_offset_x,
                       board_width/2  - mount_hole_edge_offset_y);
    }
}

// -------------------- Connected component geometry --------------------
module connector_block() {
    // Positioned near lower-left area; sits on top and overlaps into PCB
    x = -board_length/2 + pad_row_offset_x + ((pad_count-1)/2)*pad_pitch;
    y = -board_width/2  + pad_row_offset_y;
    z_top = board_thickness/2;

    top_emboss(z_top, connector_body_height)
        translate([x, y, 0])
            cube([connector_body_length, connector_body_width, connector_body_height], center=true);
}

module sensor_block() {
    // Positioned near upper-right area; sits on top and overlaps into PCB
    x =  board_length/2 - sensor_offset_x_from_right;
    y =  board_width/2  - sensor_offset_y_from_top;
    z_top = board_thickness/2;

    union() {
        top_emboss(z_top, sensor_body_height)
            translate([x, y, 0])
                cube([sensor_body_length, sensor_body_width, sensor_body_height], center=true);

        // Small cap on top of sensor body; overlaps into sensor body to ensure connection
        cap_z = z_top + sensor_body_height - eps;
        translate([x, y, cap_z + sensor_cap_height/2 - eps])
            cylinder(r=sensor_cap_radius, h=sensor_cap_height, center=true);
    }
}

module top_feature_frame() {
    // Subtle raised frame on top surface (connected)
    z_top = board_thickness/2;

    frame_inset = 1.2;
    frame_w = 0.8;

    outerL = board_length - 2*frame_inset;
    outerW = board_width  - 2*frame_inset;
    innerL = outerL - 2*frame_w;
    innerW = outerW - 2*frame_w;

    top_emboss(z_top, emboss_h)
        difference() {
            rounded_rect_prism(outerL, outerW, emboss_h, max(0.6, corner_radius - frame_inset));
            rounded_rect_prism(innerL, innerW, emboss_h + 2*eps, max(0.6, corner_radius - frame_inset - frame_w));
        }
}

module pad_row_emboss() {
    // Embossed pads (connected) to make connector area identifiable
    z_top = board_thickness/2;

    pad_d = 1.6;
    x0 = -board_length/2 + pad_row_offset_x;
    y0 = -board_width/2  + pad_row_offset_y;

    top_emboss(z_top, emboss_h)
        for (i = [0:pad_count-1]) {
            translate([x0 + (i - (pad_count-1)/2)*pad_pitch, y0, 0])
                cylinder(d=pad_d, h=emboss_h, center=true);
        }
}

module sensor_vents_engrave() {
    // Small engraved vent holes on sensor top (connected via difference)
    z_top = board_thickness/2;

    x =  board_length/2 - sensor_offset_x_from_right;
    y =  board_width/2  - sensor_offset_y_from_top;

    // Place vents within sensor footprint area on PCB top (purely visual)
    vent_d = 0.9;
    vent_pitch = 2.2;
    rows = 2;
    cols = 3;

    // Engrave shallowly into PCB top surface (not through)
    top_engrave(z_top, engrave_h)
        for (r = [0:rows-1], c = [0:cols-1]) {
            translate([
                x + (c - (cols-1)/2)*vent_pitch,
                y + (r - (rows-1)/2)*vent_pitch,
                0
            ])
            cylinder(d=vent_d, h=engrave_h, center=true);
        }
}

// -------------------- Complete model (ONE connected solid) --------------------
module complete_model() {
    difference() {
        union() {
            pcb_with_holes();

            // Connected top details
            top_feature_frame();
            pad_row_emboss();

            // Connected components
            connector_block();
            sensor_block();
        }

        // Shallow engravings (do not disconnect the solid)
        sensor_vents_engrave();
    }
}

// -------------------- Final Output --------------------
color([0.0, 0.4, 0.2])
complete_model();