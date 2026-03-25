$fn = 64;

// Parameters
display_type = 1602; //[1602:1602:1]
width_mm = 71.3; //[35.65:142.6:0.1]
height_mm = 24.3; //[12.15:48.6:0.1]
thickness_mm = 8; //[4:16:0.1]
pcb_thickness_mm = 1.6; //[0.8:3.2:0.1]
bezel_thickness_mm = 2.5; //[1.2:5:0.1]
bezel_margin_x_mm = 2; //[1:6:0.1]
bezel_margin_y_mm = 2; //[1:6:0.1]
aperture_width_mm = 64; //[32:128:0.1]
aperture_height_mm = 14; //[7:28:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// Derived / feature parameters (typical LCD1602A-like)
corner_r_mm = 1.2;
mount_hole_d_mm = 3.2;
mount_hole_edge_x_mm = 2.5;
mount_hole_edge_y_mm = 2.5;

header_pins = 16;
pin_pitch_mm = 2.54;
header_body_w_mm = header_pins * pin_pitch_mm + 2.0; // small margin around pins
header_body_h_mm = 5.0;
header_body_t_mm = 3.0;

pin_d_mm = 0.8;
pin_len_mm = 6.0;

back_chip_w_mm = 18;
back_chip_h_mm = 10;
back_chip_t_mm = 1.6;

back_blob_w_mm = 40;
back_blob_h_mm = 14;
back_blob_t_mm = 1.2;

eps = 0.01;

// Rounded rectangle prism (centered)
module rrect_prism(size=[10,10,1], r=1, center=true) {
    x = size[0]; y = size[1]; z = size[2];
    rr = min(r, x/2 - eps, y/2 - eps);
    translate(center ? [0,0,0] : [x/2, y/2, z/2])
        linear_extrude(height=z, center=true)
            offset(r=rr)
                square([x-2*rr, y-2*rr], center=true);
}

// LCD1602A-like module as ONE connected solid
module lcd1602a_module() {

    // Z stacking (centered around PCB mid-plane)
    pcb_z0 = 0;
    pcb_top = pcb_z0 + pcb_thickness_mm/2;
    pcb_bot = pcb_z0 - pcb_thickness_mm/2;

    bezel_zc = pcb_top + bezel_thickness_mm/2 - overlap_mm; // overlaps into PCB
    glass_t = max(0.8, thickness_mm - pcb_thickness_mm - 1.0); // visible front glass thickness
    glass_zc = pcb_top + glass_t/2 - overlap_mm;               // sits under bezel lip

    // Back components sit below PCB
    header_zc = pcb_bot - header_body_t_mm/2 + overlap_mm;     // overlaps into PCB
    pin_zc = pcb_bot - header_body_t_mm - pin_len_mm/2 + overlap_mm;

    chip_zc = pcb_bot - back_chip_t_mm/2 + overlap_mm;
    blob_zc = pcb_bot - back_blob_t_mm/2 + overlap_mm;

    // Mount hole positions (4 corners)
    hx = width_mm/2 - mount_hole_edge_x_mm;
    hy = height_mm/2 - mount_hole_edge_y_mm;

    // Header position (typical: along one long edge, near bottom)
    header_yc = -height_mm/2 + header_body_h_mm/2 + 1.2; // small inset from edge
    header_xc = 0;

    // Back IC / blob positions (offset to make back view distinct)
    chip_xc = width_mm*0.18;
    chip_yc = height_mm*0.10;

    blob_xc = -width_mm*0.10;
    blob_yc = height_mm*0.05;

    // Bezel outer size
    bezel_w = width_mm + 2*bezel_margin_x_mm;
    bezel_h = height_mm + 2*bezel_margin_y_mm;

    // Ensure aperture fits within bezel
    ap_w = min(aperture_width_mm, bezel_w - 2.0);
    ap_h = min(aperture_height_mm, bezel_h - 2.0);

    // Glass size (slightly larger than aperture, under bezel)
    glass_w = min(width_mm - 2.0, ap_w + 4.0);
    glass_h = min(height_mm - 2.0, ap_h + 4.0);

    difference() {
        union() {
            // PCB
            color([0.0, 0.4, 0.2])
                translate([0,0,pcb_z0])
                    rrect_prism([width_mm, height_mm, pcb_thickness_mm], r=corner_r_mm, center=true);

            // Front bezel/frame with window opening (solid ring)
            color([0.15, 0.2, 0.35])
                translate([0,0,bezel_zc])
                    difference() {
                        rrect_prism([bezel_w, bezel_h, bezel_thickness_mm], r=corner_r_mm, center=true);
                        // window cut
                        translate([0,0,0])
                            rrect_prism([ap_w, ap_h, bezel_thickness_mm + 2*overlap_mm], r=0.8, center=true);
                    }

            // Front glass area (under bezel, visible through aperture)
            color([0.0, 0.35, 0.15])
                translate([0,0,glass_zc])
                    rrect_prism([glass_w, glass_h, glass_t], r=0.6, center=true);

            // Back header plastic body
            color([0.05, 0.05, 0.05])
                translate([header_xc, header_yc, header_zc])
                    rrect_prism([header_body_w_mm, header_body_h_mm, header_body_t_mm], r=0.6, center=true);

            // Back header pins (16)
            color([0.75, 0.65, 0.2])
                for (i = [0:header_pins-1]) {
                    xpin = header_xc - (header_pins-1)*pin_pitch_mm/2 + i*pin_pitch_mm;
                    translate([xpin, header_yc, pin_zc])
                        cylinder(d=pin_d_mm, h=pin_len_mm, center=true);
                }

            // Back IC
            color([0.1, 0.1, 0.1])
                translate([chip_xc, chip_yc, chip_zc])
                    rrect_prism([back_chip_w_mm, back_chip_h_mm, back_chip_t_mm], r=0.8, center=true);

            // Back epoxy blob / component area
            color([0.08, 0.08, 0.08])
                translate([blob_xc, blob_yc, blob_zc])
                    rrect_prism([back_blob_w_mm, back_blob_h_mm, back_blob_t_mm], r=2.0, center=true);
        }

        // Mounting holes through PCB + bezel overlap region (keeps one connected solid)
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*hx, sy*hy, pcb_z0])
                cylinder(d=mount_hole_d_mm, h=pcb_thickness_mm + bezel_thickness_mm + 2*overlap_mm, center=true);
        }
    }
}

lcd1602a_module();