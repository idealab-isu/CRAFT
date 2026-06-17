$fn = 64;

// =====================
// LCD Module S-7282B (approx) 73.6 x 28.7 mm
// One connected solid (single manifold) with bezel, recessed window, rear PCB step,
// rear FFC connector bump, and mounting holes.
// =====================

// Overall envelope (XY)
width_mm  = 73.6;
height_mm = 28.7;

// Thickness stack (Z)
body_thickness_mm   = 3.2;   // main frame thickness
bezel_thickness_mm  = 1.2;   // front bezel lip thickness
pcb_thickness_mm    = 1.2;   // rear PCB thickness (modeled as solid, fused)
ffc_thickness_mm    = 1.2;   // connector bump thickness (rear)
total_thickness_mm  = body_thickness_mm + bezel_thickness_mm + pcb_thickness_mm + ffc_thickness_mm;

// Front window/aperture (recess, not through)
aperture_width_mm    = 62.0;
aperture_height_mm   = 16.5;
aperture_recess_mm   = 1.0;   // depth of recess from front face
aperture_offset_x_mm = 0;
aperture_offset_y_mm = 0;

// Bezel rim (visible border around aperture)
bezel_rim_mm = 3.0;

// Corner rounding
corner_r_mm = 1.2;

// Mounting holes (through)
hole_d_mm = 2.4;
hole_edge_x_mm = 3.5;  // from left/right edge to hole center
hole_edge_y_mm = 3.5;  // from top/bottom edge to hole center

// Rear PCB inset (slightly smaller than body)
pcb_inset_mm = 1.0;

// Rear FFC/connector bump (near bottom edge, centered in X)
ffc_w_mm = 20.0;
ffc_h_mm = 7.0;
ffc_inset_from_edge_mm = 2.0; // from bottom edge (Y-)
ffc_overlap_mm = 0.6;         // overlap into PCB to ensure fusion

// Extra rear "stiffener" rib to make the back view less like a plain plate (still one solid)
rib_w_mm = 46.0;
rib_h_mm = 6.0;
rib_thickness_mm = 0.8;
rib_overlap_mm = 0.4;

// Small overlap to guarantee watertight unions
eps = 0.2;

// ---------- Helpers ----------
module rounded_rect_prism(size=[10,10,2], r=1, center=true) {
    x = size[0]; y = size[1]; z = size[2];
    r2 = min(r, min(x,y)/2 - 0.01);
    translate(center ? [0,0,0] : [x/2,y/2,z/2])
        linear_extrude(height=z, center=true)
            offset(r=r2)
                square([x-2*r2, y-2*r2], center=true);
}

module mounting_holes(h) {
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([
            sx*(width_mm/2 - hole_edge_x_mm),
            sy*(height_mm/2 - hole_edge_y_mm),
            0
        ])
        cylinder(d=hole_d_mm, h=h, center=true);
    }
}

// ---------- Main solid ----------
module lcd_module_solid() {

    // Z references (centered model)
    z_front =  total_thickness_mm/2;
    z_back  = -total_thickness_mm/2;

    // Layer centers (computed)
    z_body  = z_back + ffc_thickness_mm + pcb_thickness_mm + body_thickness_mm/2;
    z_bezel = z_front - bezel_thickness_mm/2;
    z_pcb   = z_back + ffc_thickness_mm + pcb_thickness_mm/2;

    // FFC bump position (rear, near bottom edge)
    ffc_y_center = -height_mm/2 + ffc_inset_from_edge_mm + ffc_h_mm/2;

    // Rear rib position (rear, above FFC)
    rib_y_center = ffc_y_center + ffc_h_mm/2 + rib_h_mm/2 + 1.0; // 1.0mm gap, derived from sizes

    difference() {
        union() {
            // Main body/frame
            translate([0,0,z_body])
                rounded_rect_prism([width_mm, height_mm, body_thickness_mm + eps], r=corner_r_mm, center=true);

            // Front bezel lip
            translate([0,0,z_bezel])
                rounded_rect_prism([width_mm, height_mm, bezel_thickness_mm + eps], r=corner_r_mm, center=true);

            // Rear PCB plate (inset)
            translate([0,0,z_pcb])
                rounded_rect_prism(
                    [width_mm - 2*pcb_inset_mm, height_mm - 2*pcb_inset_mm, pcb_thickness_mm + eps],
                    r=max(0.6, corner_r_mm-0.4),
                    center=true
                );

            // Rear FFC/connector bump (fused to PCB with overlap)
            translate([
                0,
                ffc_y_center,
                z_back + ffc_thickness_mm/2 + ffc_overlap_mm/2
            ])
                rounded_rect_prism(
                    [ffc_w_mm, ffc_h_mm, ffc_thickness_mm + ffc_overlap_mm + eps],
                    r=0.6,
                    center=true
                );

            // Rear stiffener rib (fused to PCB with overlap)
            translate([
                0,
                rib_y_center,
                z_back + (rib_thickness_mm/2) + (rib_overlap_mm/2)
            ])
                rounded_rect_prism(
                    [rib_w_mm, rib_h_mm, rib_thickness_mm + rib_overlap_mm + eps],
                    r=0.6,
                    center=true
                );
        }

        // Front aperture recess (not through)
        aw = min(aperture_width_mm,  width_mm  - 2*bezel_rim_mm);
        ah = min(aperture_height_mm, height_mm - 2*bezel_rim_mm);

        translate([
            aperture_offset_x_mm,
            aperture_offset_y_mm,
            z_front - aperture_recess_mm/2
        ])
            rounded_rect_prism([aw, ah, aperture_recess_mm + eps], r=0.8, center=true);

        // Mounting holes through entire module
        mounting_holes(total_thickness_mm + 2);
    }
}

lcd_module_solid();