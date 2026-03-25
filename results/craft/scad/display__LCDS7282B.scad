// LCD Display Module (S-7282B) - 73.6mm x 28.7mm
// One connected solid with bezel + recessed viewing window + mounting holes + PCB + FFC tail + backside components

$fn = 64;

// -------------------- Parameters --------------------
width_mm  = 73.6;                 //[36.8:147.2:0.1]
height_mm = 28.7;                 //[14.35:57.4:0.1]

// Front housing (plastic frame)
housing_thickness_mm = 4.2;       //[2:8:0.1]
corner_radius_mm     = 1.2;       //[0:3:0.1]

// Bezel lip on front
bezel_lip_thickness_mm = 1.2;     //[0.5:3:0.1]
bezel_frame_mm         = 2.2;     //[0.5:6:0.1]

// Viewing window recess
aperture_x0_mm      = 0;          //[-10:10:0.1]
aperture_y0_mm      = 0;          //[-10:10:0.1]
aperture_width_mm   = 62.0;       //[20:73.6:0.1]
aperture_height_mm  = 18.0;       //[8:28.7:0.1]
aperture_depth_mm   = 0.9;        //[0.2:2.5:0.1]

// Back PCB
pcb_present       = 1;            //[0:1:1]
pcb_thickness_mm  = 1.6;          //[0.8:3.2:0.1]
pcb_margin_mm     = 0.8;          //[0:5:0.1]

// Mounting holes (through housing + PCB)
mount_hole_d_mm   = 2.2;          //[1.2:4:0.1]
mount_edge_x_mm   = 3.0;          //[1:8:0.1]
mount_edge_y_mm   = 3.0;          //[1:8:0.1]

// FFC tail (flex) from one short edge
ffc_present       = 1;            //[0:1:1]
ffc_width_mm      = 16.0;         //[6:30:0.1]
ffc_length_mm     = 12.0;         //[4:30:0.1]
ffc_thickness_mm  = 0.35;         //[0.15:1:0.01]
ffc_side          = -1;           //[-1:1:2]  // -1 = bottom edge (negative Y), +1 = top edge

// Backside components (simple bumps on PCB)
back_components_present = 1;      //[0:1:1]
chip_count = 3;                   //[0:6:1]

// Connectivity overlap (ensures one connected solid)
overlap_mm = 0.6;                 //[0.2:2:0.1]

// -------------------- Derived / clamps --------------------
eps = 0.01;
r = max(0, corner_radius_mm);

// Ensure aperture stays inside bezel frame
ap_w = min(aperture_width_mm,  width_mm  - 2*bezel_frame_mm);
ap_h = min(aperture_height_mm, height_mm - 2*bezel_frame_mm);
ap_d = min(aperture_depth_mm,  bezel_lip_thickness_mm - 0.05);

// -------------------- Helpers --------------------
module rbox(size=[10,10,2], rad=0.5, center=true) {
    rad2 = min(rad, min(size[0], size[1]) / 2 - eps);
    if (rad2 <= 0) {
        cube(size, center=center);
    } else {
        linear_extrude(height=size[2], center=center)
            offset(r=rad2)
                square([size[0]-2*rad2, size[1]-2*rad2], center=true);
    }
}

// -------------------- Main assembly --------------------
module lcd_module() {

    // Z stack (front is +Z)
    housing_zc = 0;
    housing_top = housing_zc + housing_thickness_mm/2;
    housing_bot = housing_zc - housing_thickness_mm/2;

    bezel_zc = housing_top + bezel_lip_thickness_mm/2 - overlap_mm; // overlaps into housing
    bezel_top = bezel_zc + bezel_lip_thickness_mm/2;

    pcb_zc = housing_bot - pcb_thickness_mm/2 + overlap_mm; // overlaps into housing

    // Overall back extent for through-holes
    total_back = (housing_thickness_mm/2) + (pcb_thickness_mm) + 2*eps;

    // Mount hole positions (formulas from dimensions)
    hole_x = width_mm/2  - mount_edge_x_mm;
    hole_y = height_mm/2 - mount_edge_y_mm;

    // FFC tail placement (attached to PCB edge, extends outward in Y)
    ffc_y_edge = ffc_side * ( (height_mm - 2*pcb_margin_mm)/2 ); // PCB edge in Y
    ffc_yc = ffc_y_edge + ffc_side * (ffc_length_mm/2 - overlap_mm); // overlap into PCB
    ffc_zc = pcb_zc + pcb_thickness_mm/2 - ffc_thickness_mm/2 + overlap_mm; // overlap into PCB
    ffc_xc = 0;

    // Backside components placement (on PCB back side)
    comp_base_zc = pcb_zc - pcb_thickness_mm/2 + 0.9; // centered slightly above PCB back face
    comp_h = 1.8;
    comp_zc = pcb_zc - pcb_thickness_mm/2 + comp_h/2 - overlap_mm; // overlap into PCB

    // PCB size
    pcb_w = width_mm  - 2*pcb_margin_mm;
    pcb_h = height_mm - 2*pcb_margin_mm;

    // Build as ONE connected solid: union of solids, with differences only for recess/holes
    difference() {
        union() {

            // Housing body
            translate([0,0,housing_zc])
                rbox([width_mm, height_mm, housing_thickness_mm], r, center=true);

            // Bezel lip (front), with window recess cut later in difference()
            translate([0,0,bezel_zc])
                rbox([width_mm, height_mm, bezel_lip_thickness_mm], r, center=true);

            // Glass slab inside window (connected by overlap into bezel)
            glass_t = 0.7;
            glass_zc = bezel_top - ap_d + glass_t/2 - overlap_mm;
            translate([aperture_x0_mm, aperture_y0_mm, glass_zc])
                rbox([ap_w-0.8, ap_h-0.8, glass_t], max(0, r-0.4), center=true);

            // PCB (back)
            if (pcb_present) {
                translate([0,0,pcb_zc])
                    rbox([pcb_w, pcb_h, pcb_thickness_mm], max(0, r-0.4), center=true);

                // FFC tail (flex) attached to PCB edge
                if (ffc_present) {
                    translate([ffc_xc, ffc_yc, ffc_zc])
                        rbox([ffc_width_mm, ffc_length_mm, ffc_thickness_mm], 0.4, center=true);

                    // Stiffener / connector bar at PCB edge (small bump, connected)
                    stiff_w = ffc_width_mm + 4;
                    stiff_l = 3.2;
                    stiff_t = 1.2;
                    stiff_yc = ffc_y_edge + ffc_side * (stiff_l/2 - overlap_mm);
                    stiff_zc = pcb_zc + pcb_thickness_mm/2 + stiff_t/2 - overlap_mm;
                    translate([0, stiff_yc, stiff_zc])
                        rbox([stiff_w, stiff_l, stiff_t], 0.6, center=true);
                }

                // Backside components (simple IC bumps), connected to PCB
                if (back_components_present && chip_count > 0) {
                    chip_w = 10;
                    chip_l = 6;
                    // Spread along X within PCB, keep inside margins
                    x_span = max(0, pcb_w - 2*(mount_edge_x_mm + 6));
                    for (i = [0:chip_count-1]) {
                        t = (chip_count==1) ? 0.5 : i/(chip_count-1);
                        cx = -x_span/2 + t*x_span;
                        cy = 0;
                        translate([cx, cy, comp_zc])
                            rbox([chip_w, chip_l, comp_h], 0.6, center=true);
                    }

                    // One longer driver bar near opposite edge (connected)
                    bar_w = pcb_w - 10;
                    bar_l = 4.0;
                    bar_h = 1.4;
                    bar_y = -ffc_side * (pcb_h/2 - 5.0); // opposite side from FFC
                    bar_zc = pcb_zc - pcb_thickness_mm/2 + bar_h/2 - overlap_mm;
                    translate([0, bar_y, bar_zc])
                        rbox([bar_w, bar_l, bar_h], 0.6, center=true);
                }
            }
        }

        // --- Subtractions (do not break connectivity) ---

        // Window recess cut into bezel from the front
        translate([aperture_x0_mm, aperture_y0_mm, bezel_top - ap_d/2 + eps])
            rbox([ap_w, ap_h, ap_d + 2*eps], max(0, r-0.4), center=true);

        // Mounting holes (through housing + PCB)
        // Start slightly in front of bezel and go through to PCB back
        hole_h = (bezel_lip_thickness_mm + housing_thickness_mm + pcb_thickness_mm) + 4*eps;
        hole_zc = (bezel_top - bezel_lip_thickness_mm) - (hole_h/2) + 2*eps; // spans front to back
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*hole_x, sy*hole_y, hole_zc])
                cylinder(d=mount_hole_d_mm, h=hole_h, center=true);
        }

        // Slight back relief around FFC exit (small notch on PCB edge), optional but subtle
        if (pcb_present && ffc_present) {
            notch_w = ffc_width_mm + 2.0;
            notch_l = 2.0;
            notch_t = pcb_thickness_mm + 2*eps;
            notch_yc = ffc_y_edge + ffc_side * (notch_l/2 - 0.2);
            notch_zc = pcb_zc;
            translate([0, notch_yc, notch_zc])
                rbox([notch_w, notch_l, notch_t], 0.4, center=true);
        }
    }
}

lcd_module();