// IEC power inlet module (IEC outlet RS 811-7193) - simplified but recognizable IEC C14 inlet
// Target front flange: 40.0mm x 32.0mm
// One connected solid (all features connected; no floating parts)

// ---------- Parameters ----------
overall_width_mm  = 40.0;   //[20.0:80.0:0.1]
overall_height_mm = 32.0;   //[16.0:64.0:0.1]

flange_thickness_mm = 2.0;  //[1.0:4.0:0.1]
bezel_thickness_mm  = 2.0;  //[1.0:6.0:0.1]
body_depth_mm       = 25.0; //[12.5:50.0:0.5]

corner_radius_mm = 3.0;     //[1.5:6.0:0.1]

screw_hole_diameter_mm = 3.2; //[2.0:6.0:0.1]
screw_hole_pitch_x_mm  = 30.0; //[15.0:60.0:0.1]
screw_hole_pitch_y_mm  = 22.0; //[11.0:44.0:0.1]

// IEC inlet opening (front face) - C14-ish
socket_opening_width_mm  = 27.0;  //[12.25:49.0:0.1]
socket_opening_height_mm = 19.0;  //[8.17:32.68:0.01]

// Rear body (snap-in / housing)
rear_body_width_mm  = 30.0; //[15.0:60.0:0.1]
rear_body_height_mm = 24.0; //[12.0:48.0:0.1]
rear_body_corner_radius_mm = 2.0; //[1.0:5.0:0.1]

// Terminal region + pins
terminal_region_depth_mm  = 8.0;  //[4.0:20.0:0.5]
terminal_region_width_mm  = 22.0; //[11.0:44.0:0.1]
terminal_region_height_mm = 12.0; //[5.0:20.0:0.1]

overlap_mm = 1.0; //[0.5:2.0:0.1]

// IEC C14-ish pin layout (approx)
pin_w_mm = 6.3;
pin_t_mm = 0.8;
pin_len_mm = 10.0;
pin_pitch_x_mm = 10.0;
pin_pitch_y_mm = 8.0;

// Inlet cavity depth (front recess)
inlet_cavity_depth_mm = 14.0; //[6:20:0.5]

// Snap-in side latches (simple approximation)
latch_thick_mm = 1.6;
latch_len_mm   = 10.0;
latch_drop_mm  = 2.0;

// Front bezel lip around opening (raised rim)
bezel_lip_w_mm = 2.0;  //[0.5:4.0:0.1]
bezel_lip_h_mm = 1.0;  //[0.5:3.0:0.1]

// ---------- Helpers ----------
$fn = 64;

module rounded_rect_2d(w, h, r) {
    r2 = min(r, min(w, h)/2);
    offset(r=r2) square([w-2*r2, h-2*r2], center=true);
}

module rounded_rect_prism(size=[10,10,10], r=2, center=true) {
    x = size[0]; y = size[1]; z = size[2];
    r2 = min(r, min(x,y)/2);
    translate(center ? [0,0,0] : [x/2,y/2,z/2])
        linear_extrude(height=z, center=true)
            rounded_rect_2d(x, y, r2);
}

// IEC C14-ish opening: rounded rectangle with two small top corner chamfers
module iec_opening_2d(w, h, r, chamfer=2.0) {
    difference() {
        rounded_rect_2d(w, h, r);
        // chamfer top-left and top-right
        for (sx = [-1, 1]) {
            translate([sx*(w/2 - chamfer/2), (h/2 - chamfer/2), 0])
                rotate([0,0,45])
                    square([chamfer, chamfer], center=true);
        }
    }
}

module iec_inlet_cavity() {
    // Recessed cavity behind the front opening to suggest IEC inlet shape
    // Uses hull between a larger mouth and a smaller deeper section.
    front_stack = flange_thickness_mm + bezel_thickness_mm;

    w1 = socket_opening_width_mm + 3.0;
    h1 = socket_opening_height_mm + 3.0;
    w2 = socket_opening_width_mm - 2.0;
    h2 = socket_opening_height_mm - 2.0;

    z_center = front_stack/2 + inlet_cavity_depth_mm/2 - overlap_mm;

    translate([0,0,z_center])
        hull() {
            translate([0,0,-inlet_cavity_depth_mm/2])
                linear_extrude(height=overlap_mm*2, center=true)
                    iec_opening_2d(w1, h1, r=2.0, chamfer=2.2);
            translate([0,0, inlet_cavity_depth_mm/2])
                linear_extrude(height=overlap_mm*2, center=true)
                    iec_opening_2d(w2, h2, r=1.5, chamfer=1.8);
        }
}

module pins() {
    // Three spade terminals on rear; connected to terminal block with ribs
    front_stack = flange_thickness_mm + bezel_thickness_mm;

    z_term_front = front_stack + body_depth_mm - overlap_mm; // start of terminal region
    term_center_z = z_term_front + terminal_region_depth_mm/2;
    pin_center_z  = z_term_front + terminal_region_depth_mm + pin_len_mm/2 - overlap_mm;

    positions = [
        [0,  pin_pitch_y_mm/2, 0],                 // Earth (top center)
        [-pin_pitch_x_mm/2, -pin_pitch_y_mm/2, 0], // Neutral (bottom left)
        [ pin_pitch_x_mm/2, -pin_pitch_y_mm/2, 0]  // Live (bottom right)
    ];

    for (p = positions)
        translate([p[0], p[1], pin_center_z])
            cube([pin_w_mm, pin_t_mm, pin_len_mm], center=true);

    // ribs to ensure connectivity into terminal block
    for (p = positions)
        translate([p[0], p[1], (term_center_z + pin_center_z)/2])
            cube([pin_w_mm, pin_t_mm, (pin_center_z - term_center_z) + 2*overlap_mm], center=true);
}

module latches() {
    // Simple snap-in latches on left/right sides of rear body; connected with overlap
    front_stack = flange_thickness_mm + bezel_thickness_mm;

    z_latch_center = front_stack + body_depth_mm*0.55;
    x_side = rear_body_width_mm/2 + latch_thick_mm/2 - overlap_mm;

    for (sx = [-1, 1]) {
        translate([sx*x_side, 0, z_latch_center])
            union() {
                cube([latch_thick_mm, rear_body_height_mm*0.55, latch_len_mm], center=true);
                translate([0, 0, -latch_len_mm/2 + latch_drop_mm/2])
                    cube([latch_thick_mm + 0.8, rear_body_height_mm*0.25, latch_drop_mm], center=true);
            }
    }
}

module bezel_lip() {
    // Raised rim around the opening on the front face (adds recognizable front detail)
    front_stack = flange_thickness_mm + bezel_thickness_mm;

    outer_w = socket_opening_width_mm + 2*bezel_lip_w_mm;
    outer_h = socket_opening_height_mm + 2*bezel_lip_w_mm;

    z_center = bezel_lip_h_mm/2; // sits on front face at z=0

    translate([0,0,z_center])
        difference() {
            linear_extrude(height=bezel_lip_h_mm, center=true)
                iec_opening_2d(outer_w, outer_h, r=2.2, chamfer=2.2);
            translate([0,0,0])
                linear_extrude(height=bezel_lip_h_mm + 2*overlap_mm, center=true)
                    iec_opening_2d(socket_opening_width_mm, socket_opening_height_mm, r=1.6, chamfer=2.0);
        }
}

// ---------- Main Assembly ----------
module assembly() {
    // Coordinate system: front face at z=0, depth goes +Z
    front_stack = flange_thickness_mm + bezel_thickness_mm;

    union() {
        // Front flange/bezel block (with opening + screw holes + cavity)
        translate([0,0, front_stack/2])
            difference() {
                rounded_rect_prism(
                    [overall_width_mm, overall_height_mm, front_stack],
                    r=corner_radius_mm,
                    center=true
                );

                // IEC opening through flange
                translate([0,0,0])
                    linear_extrude(height=front_stack + 2*overlap_mm, center=true)
                        iec_opening_2d(socket_opening_width_mm, socket_opening_height_mm, r=1.6, chamfer=2.0);

                // Screw holes
                for (x = [-1, 1], y = [-1, 1]) {
                    translate([x*screw_hole_pitch_x_mm/2, y*screw_hole_pitch_y_mm/2, 0])
                        cylinder(d=screw_hole_diameter_mm, h=front_stack + 2*overlap_mm, center=true);
                }

                // Recessed inlet cavity behind opening
                iec_inlet_cavity();
            }

        // Raised bezel lip on the very front (connected to flange)
        bezel_lip();

        // Rear body housing (connected to flange with overlap)
        translate([0,0, front_stack + body_depth_mm/2 - overlap_mm])
            rounded_rect_prism(
                [rear_body_width_mm, rear_body_height_mm, body_depth_mm],
                r=rear_body_corner_radius_mm,
                center=true
            );

        // Terminal block region (connected)
        translate([0,0, front_stack + body_depth_mm - overlap_mm + terminal_region_depth_mm/2])
            rounded_rect_prism(
                [terminal_region_width_mm, terminal_region_height_mm, terminal_region_depth_mm],
                r=1.2,
                center=true
            );

        // Snap latches (connected to rear body)
        latches();

        // Spade terminals (connected to terminal block)
        pins();
    }
}

assembly();