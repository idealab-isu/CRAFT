$fn = 64;

// DC-DC power converter module, PCB: 78 x 47 x 1.6 mm
module dcdc_power_converter_module(
    length = 78.0,
    width  = 47.0,
    thickness = 1.6,
    corner_r = 2.0
){
    corner_r_eff = min(corner_r, min(length, width)/2);

    // Mounting holes
    hole_d = 3.2;
    hole_edge = 4.0;

    // Keep all features within outline
    edge_clear = 1.0;

    // Terminal blocks (2 total, one on each short edge)
    term_w = 12.0;     // along X
    term_d = 9.0;      // along Y (depth from edge inward)
    term_h = 8.0;      // above PCB
    term_inset = 0.8;  // from board edge inward
    term_overlap = 0.5;

    // Inductor (shielded)
    ind_r = 7.5;
    ind_h = 5.0;
    ind_overlap = 0.5;

    // Electrolytic capacitors
    cap_r = 4.0;
    cap_h = 9.0;
    cap_overlap = 0.5;

    // IC (controller)
    ic_l = 12.0;
    ic_w = 10.0;
    ic_h = 2.0;
    ic_overlap = 0.4;

    // Small SMD parts
    sm_l = 5.0;
    sm_w = 2.6;
    sm_h = 1.2;
    sm_overlap = 0.3;

    // Copper pad bumps (to make it look like a module, still one solid)
    pad_h = 0.25;
    pad_overlap = 0.15;

    // Helper: rounded rectangle prism centered at origin, bottom at z=0
    module rounded_board(l, w, h, r){
        translate([0,0,h/2])
            linear_extrude(height = h, center = true)
                offset(r = r)
                    square([l - 2*r, w - 2*r], center = true);
    }

    // Helper: place a part sitting on top of PCB with slight overlap for union connectivity
    module on_top(part_h, overlap){
        translate([0,0, thickness + part_h/2 - overlap])
            children();
    }

    // Helper: mounting hole (through PCB)
    module mount_hole(x, y){
        translate([x, y, thickness/2])
            cylinder(h = thickness + 0.4, d = hole_d, center = true);
    }

    // Helper: simple terminal block with two pin bumps (still one solid)
    module terminal_block(w, d, h, pin_d=1.6, pin_h=1.2, pin_pitch=5.0, overlap=0.4){
        union(){
            cube([w, d, h], center=true);
            // two "pins" on top face
            for (sx = [-pin_pitch/2, pin_pitch/2]){
                translate([sx, 0, h/2 + pin_h/2 - overlap])
                    cylinder(h=pin_h, d=pin_d, center=true);
            }
        }
    }

    // Helper: SMD chip with tiny end caps
    module smd_chip(l,w,h,cap=0.6, cap_h=0.25, overlap=0.15){
        union(){
            cube([l,w,h], center=true);
            translate([ l/2 - cap/2, 0, h/2 + cap_h/2 - overlap])
                cube([cap, w*0.9, cap_h], center=true);
            translate([-l/2 + cap/2, 0, h/2 + cap_h/2 - overlap])
                cube([cap, w*0.9, cap_h], center=true);
        }
    }

    difference() {
        union() {
            // PCB (exact footprint)
            rounded_board(length, width, thickness, corner_r_eff);

            // Terminal blocks on opposite short edges (±Y), centered in X
            // Place so their outer face is inset from board edge by term_inset
            term_y = width/2 - term_d/2 - term_inset;
            translate([0,  term_y, 0])
                on_top(term_h, term_overlap)
                    terminal_block(term_w, term_d, term_h);

            translate([0, -term_y, 0])
                on_top(term_h, term_overlap)
                    terminal_block(term_w, term_d, term_h);

            // Inductor (left side area)
            ind_x = -length*0.22;
            translate([ind_x, 0, 0])
                on_top(ind_h, ind_overlap)
                    cylinder(h = ind_h, r = ind_r, center = true);

            // Two electrolytic capacitors (right side)
            cap_x = length*0.22;
            cap_y = width*0.18;
            translate([cap_x,  cap_y, 0])
                on_top(cap_h, cap_overlap)
                    cylinder(h = cap_h, r = cap_r, center = true);

            translate([cap_x, -cap_y, 0])
                on_top(cap_h, cap_overlap)
                    cylinder(h = cap_h, r = cap_r, center = true);

            // Controller IC near center
            translate([0, 0, 0])
                on_top(ic_h, ic_overlap)
                    cube([ic_l, ic_w, ic_h], center = true);

            // Small SMD components around IC (top side only)
            sm_positions = [
                [-length*0.06,  width*0.22],
                [ length*0.06,  width*0.22],
                [-length*0.06, -width*0.22],
                [ length*0.06, -width*0.22],
                [ 0,            width*0.30],
                [ 0,           -width*0.30],
                [-length*0.12,  0],
                [ length*0.12,  0]
            ];
            for (p = sm_positions){
                translate([p[0], p[1], 0])
                    on_top(sm_h, sm_overlap)
                        smd_chip(sm_l, sm_w, sm_h);
            }

            // A row of "pads" near each terminal to add recognizable PCB detail
            pad_w = 2.2;
            pad_l = 3.0;
            pad_pitch = 3.2;
            pad_cols = 6;

            // Top edge pads (near +Y terminal)
            pads_y = width/2 - term_d - term_inset - edge_clear - pad_w/2;
            for (i = [0:pad_cols-1]){
                px = (i - (pad_cols-1)/2) * pad_pitch;
                translate([px, pads_y, 0])
                    on_top(pad_h, pad_overlap)
                        cube([pad_l, pad_w, pad_h], center=true);
            }

            // Bottom edge pads (near -Y terminal)
            for (i = [0:pad_cols-1]){
                px = (i - (pad_cols-1)/2) * pad_pitch;
                translate([px, -pads_y, 0])
                    on_top(pad_h, pad_overlap)
                        cube([pad_l, pad_w, pad_h], center=true);
            }
        }

        // Mounting holes (4 corners)
        mount_hole(-length/2 + hole_edge, -width/2 + hole_edge);
        mount_hole( length/2 - hole_edge, -width/2 + hole_edge);
        mount_hole(-length/2 + hole_edge,  width/2 - hole_edge);
        mount_hole( length/2 - hole_edge,  width/2 - hole_edge);
    }
}

dcdc_power_converter_module();