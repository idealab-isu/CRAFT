// LCD2004A (2004A) display module - 97.0mm x 39.5mm
// One connected solid, with bezel/aperture, 4 mounting holes, and 16-pin header block.

$fn = 64;

// Parameters (overall)
width_mm  = 97.0;   // X
height_mm = 39.5;   // Y

// PCB
pcb_thickness_mm = 1.6;

// Bezel / display body
body_margin_x_mm = 4.0;
body_margin_y_mm = 3.0;
display_body_thickness_mm = 8.0;

// Viewing aperture (cut into bezel)
aperture_width_mm  = 76.0;
aperture_height_mm = 25.0;
aperture_offset_x_mm = 0.0;
aperture_offset_y_mm = 0.0;

// Mounting holes
mount_hole_diameter_mm = 3.2;
mount_hole_edge_margin_x_mm = 3.5;
mount_hole_edge_margin_y_mm = 3.5;

// 16-pin header area (typical LCD2004A: 1x16, 2.54mm pitch)
pin_count = 16;
pin_pitch_mm = 2.54;
header_body_w_mm = pin_pitch_mm * (pin_count - 1) + 5.0; // plastic body length
header_body_d_mm = 6.0;   // depth (Y)
header_body_h_mm = 4.0;   // height (Z)
header_offset_y_from_edge_mm = 4.0; // from PCB bottom edge to header center

// Small overlap to guarantee connectivity / avoid coplanar artifacts
overlap_mm = 0.6;

// Derived sizes
bezel_w = width_mm  - 2*body_margin_x_mm;
bezel_h = height_mm - 2*body_margin_y_mm;

// Z placement (PCB centered at Z=0)
pcb_z = 0;
bezel_z = pcb_thickness_mm/2 + display_body_thickness_mm/2 - overlap_mm;

// Header placement (on back side of PCB)
header_z = -pcb_thickness_mm/2 - header_body_h_mm/2 + overlap_mm;

// Mount hole positions
hole_x = width_mm/2  - mount_hole_edge_margin_x_mm;
hole_y = height_mm/2 - mount_hole_edge_margin_y_mm;

// Header position (near bottom edge, centered in X)
header_y = -height_mm/2 + header_offset_y_from_edge_mm;

// Main solid
module lcd2004a_solid() {
    difference() {
        union() {
            // PCB
            cube([width_mm, height_mm, pcb_thickness_mm], center=true);

            // Bezel / display body (connected to PCB with overlap)
            translate([0, 0, bezel_z])
                cube([bezel_w, bezel_h, display_body_thickness_mm], center=true);

            // 16-pin header plastic body (connected to PCB underside with overlap)
            translate([0, header_y, header_z])
                cube([header_body_w_mm, header_body_d_mm, header_body_h_mm], center=true);
        }

        // Viewing aperture cutout (through bezel only; does not remove PCB)
        translate([aperture_offset_x_mm, aperture_offset_y_mm, bezel_z])
            cube([aperture_width_mm, aperture_height_mm, display_body_thickness_mm + 2*overlap_mm], center=true);

        // Mounting holes (through PCB + bezel stack)
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*hole_x, sy*hole_y, bezel_z])
                cylinder(h = pcb_thickness_mm + display_body_thickness_mm + 4*overlap_mm,
                         r = mount_hole_diameter_mm/2,
                         center = true);
        }
    }
}

lcd2004a_solid();