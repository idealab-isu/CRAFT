// IEC fused inlet module (JR-101-1F style) - simplified but recognizable
// Target panel cutout: 36.0mm x 27.0mm
// Model is ONE connected solid (union of all features). No floating parts.

// ---------- Parameters ----------
cutout_width_mm  = 36.0;  //[18.0:72.0:0.1]
cutout_height_mm = 27.0;  //[13.5:54.0:0.1]

tolerance_mm = 0.2;       //[0.05:0.6:0.05]
panel_thickness_mm = 2.0; //[0.8:4.0:0.1]

flange_width_mm  = 44.0;  //[36.0:88.0:0.1]
flange_height_mm = 34.0;  //[27.0:68.0:0.1]
flange_thickness_mm = 2.5;//[1.0:6.0:0.1]
bezel_thickness_mm  = 1.5;//[0.8:4.0:0.1]
front_protrusion_mm = 1.0;//[0.0:4.0:0.1]

body_width_mm  = 38.0;    //[30.0:76.0:0.1]
body_height_mm = 29.0;    //[22.0:58.0:0.1]
body_depth_mm  = 40.0;    //[25.0:80.0:0.5]

snap_feature_thickness_mm = 2.0; //[1.0:4.0:0.1]
snap_feature_depth_mm     = 10.0;//[6.0:20.0:0.5]
snap_hook_height_mm       = 1.5; //[0.8:3.0:0.1]
snap_overlap_mm           = 1.0; //[0.5:2.0:0.1]

fuse_drawer_width_mm  = 16.0; //[10.0:28.0:0.1]
fuse_drawer_height_mm = 12.0; //[8.0:22.0:0.1]
fuse_drawer_depth_mm  = 14.0; //[8.0:30.0:0.5]

terminal_tab_width_mm     = 6.3; //[4.0:10.0:0.1]
terminal_tab_thickness_mm = 0.8; //[0.5:1.5:0.05]
terminal_tab_length_mm    = 12.0;//[8.0:25.0:0.5]
terminal_spacing_x_mm     = 10.0;//[6.0:16.0:0.5]
terminal_offset_y_mm      = 6.0; //[0.0:12.0:0.5]

// Visual/shape helpers
$fn = 64;
eps = 0.01;

// ---------- Helper: rounded rectangle prism ----------
module rrect_prism(size=[10,10,10], r=1, center=true) {
    x=size[0]; y=size[1]; z=size[2];
    r2 = min(r, x/2 - eps, y/2 - eps);
    linear_extrude(height=z, center=center)
        offset(r=r2)
            square([x-2*r2, y-2*r2], center=true);
}

// ---------- Helper: simple C14 opening (rounded rect + top chamfer hint) ----------
module c14_opening_2d(w=27.5, h=20, r=2.0) {
    // A recognizable C14-ish silhouette: rounded rectangle with a slight top "flat" hint
    // (kept simple and robust for boolean ops)
    difference() {
        offset(r=r) square([w-2*r, h-2*r], center=true);
        // shave a tiny amount near top corners to suggest the C14 top profile
        shave_w = w*0.22;
        shave_h = h*0.18;
        translate([ w/2 - shave_w/2,  h/2 - shave_h/2]) square([shave_w, shave_h], center=true);
        translate([-w/2 + shave_w/2,  h/2 - shave_h/2]) square([shave_w, shave_h], center=true);
    }
}

// ---------- IEC module ----------
module iec_fused_inlet() {

    // Coordinate convention:
    // Z=0 is panel plane center. +Z is front (outside), -Z is rear (inside).
    // Place flange slightly in front of panel, body behind panel.

    flange_total_t = flange_thickness_mm + bezel_thickness_mm;

    // Z positions (all computed from dimensions)
    z_flange_center = (flange_total_t/2) - (panel_thickness_mm/2) + front_protrusion_mm;
    z_body_center   = -(panel_thickness_mm/2) - (body_depth_mm/2) + snap_overlap_mm;

    // Front face reference (for recesses)
    z_flange_front = z_flange_center + flange_total_t/2;

    // --- IEC C14 opening + pin cavity geometry (front) ---
    c14_w = 27.5;
    c14_h = 20.0;
    c14_r = 2.0;

    // Make the opening go through flange and into body so it reads as an inlet, not a shallow recess
    c14_throat_depth = min(18, flange_total_t + 10); // extends into body
    c14_front_recess = min(5.5, flange_total_t + front_protrusion_mm + 2);

    // Pin cavity (rear of inlet) - three rectangular cavities inside the throat
    pin_cav_w = 4.2;
    pin_cav_h = 3.0;
    pin_cav_depth = 10.0;
    pin_pitch_x = 10.0;
    pin_row_y = -2.0;      // L/N row slightly lower
    pe_y = 5.5;            // PE above
    pin_cav_rim = 1.2;     // small clearance around cavities

    // Place C14 opening slightly left of center (typical fused inlet layout)
    c14_x = -(flange_width_mm*0.14);
    c14_y = -(flange_height_mm*0.06);

    // --- Fuse drawer features (front + housing) ---
    fuse_recess_w = fuse_drawer_width_mm - 0.8;
    fuse_recess_h = fuse_drawer_height_mm - 0.8;
    fuse_recess_r = 1.0;
    fuse_recess_depth = min(6.0, flange_total_t + front_protrusion_mm + 2);

    // Fuse drawer housing block (rear-ish but attached to body)
    z_fuse_housing_center =
        z_body_center + (body_depth_mm/2) - (fuse_drawer_depth_mm/2) - snap_overlap_mm;

    // Place fuse drawer at top-right of flange (typical)
    fuse_x = (flange_width_mm/2) - (fuse_drawer_width_mm/2) - 2.0;
    fuse_y = (flange_height_mm/2) - (fuse_drawer_height_mm/2) - 2.0;

    // Add a small "drawer lip" protrusion on front to make it recognizable
    drawer_lip_w = fuse_drawer_width_mm * 0.78;
    drawer_lip_h = fuse_drawer_height_mm * 0.22;
    drawer_lip_t = 1.2;

    // Snap arms Z center (behind panel, attached to body)
    z_snap_center =
        -(panel_thickness_mm/2) - (snap_feature_depth_mm/2) + snap_overlap_mm;

    // Terminal tabs: attach to rear of body with slight overlap
    z_body_rear = z_body_center - body_depth_mm/2;
    z_term_center = z_body_rear - (terminal_tab_length_mm/2) + snap_overlap_mm;

    // Build as one connected solid: union of solids, with recesses cut from flange/body
    difference() {
        union() {
            // Front flange/bezel
            translate([0,0,z_flange_center])
                rrect_prism([flange_width_mm, flange_height_mm, flange_total_t], r=1.2, center=true);

            // Main body
            translate([0,0,z_body_center])
                rrect_prism([body_width_mm, body_height_mm, body_depth_mm], r=1.0, center=true);

            // Fuse drawer housing (attached to body)
            translate([fuse_x, fuse_y, z_fuse_housing_center])
                rrect_prism([fuse_drawer_width_mm, fuse_drawer_height_mm, fuse_drawer_depth_mm], r=0.8, center=true);

            // Fuse drawer front lip (attached to flange front)
            z_lip_center = z_flange_front + drawer_lip_t/2 - eps; // slight overlap into flange
            translate([fuse_x, fuse_y - fuse_drawer_height_mm*0.18, z_lip_center])
                rrect_prism([drawer_lip_w, drawer_lip_h, drawer_lip_t], r=0.6, center=true);

            // Snap arms (left/right) attached to body
            snap_arm_h = body_height_mm * 0.62;
            snap_hook_h = body_height_mm * 0.28;

            // Left snap arm
            translate([-(cutout_width_mm/2 + snap_feature_thickness_mm/2 - snap_overlap_mm), 0, z_snap_center])
                cube([snap_feature_thickness_mm, snap_arm_h, snap_feature_depth_mm], center=true);

            // Right snap arm
            translate([(cutout_width_mm/2 + snap_feature_thickness_mm/2 - snap_overlap_mm), 0, z_snap_center])
                cube([snap_feature_thickness_mm, snap_arm_h, snap_feature_depth_mm], center=true);

            // Hooks near panel plane (ensure overlap into flange/body region)
            z_hook_center = -(panel_thickness_mm/2) - (snap_hook_height_mm/2) + snap_overlap_mm;

            translate([-(cutout_width_mm/2 + snap_feature_thickness_mm/2 - snap_overlap_mm), 0, z_hook_center])
                cube([snap_feature_thickness_mm + 2*snap_overlap_mm, snap_hook_h, snap_hook_height_mm], center=true);

            translate([(cutout_width_mm/2 + snap_feature_thickness_mm/2 - snap_overlap_mm), 0, z_hook_center])
                cube([snap_feature_thickness_mm + 2*snap_overlap_mm, snap_hook_h, snap_hook_height_mm], center=true);

            // Rear terminal spades (L, N, PE) attached to rear of body
            translate([-terminal_spacing_x_mm/2, -terminal_offset_y_mm, z_term_center])
                cube([terminal_tab_width_mm, terminal_tab_thickness_mm, terminal_tab_length_mm], center=true);

            translate([ terminal_spacing_x_mm/2, -terminal_offset_y_mm, z_term_center])
                cube([terminal_tab_width_mm, terminal_tab_thickness_mm, terminal_tab_length_mm], center=true);

            translate([0, terminal_offset_y_mm, z_term_center])
                cube([terminal_tab_width_mm, terminal_tab_thickness_mm, terminal_tab_length_mm], center=true);
        }

        // --- Openings / recesses ---

        // Panel cutout "throat" through flange (represents the 36x27 cutout)
        // Centered on panel plane; cut through flange thickness only.
        translate([0,0,z_flange_center])
            cube([cutout_width_mm + 2*tolerance_mm,
                  cutout_height_mm + 2*tolerance_mm,
                  flange_total_t + 2*eps], center=true);

        // IEC C14 opening: cut through flange and into body (throat)
        z_c14_throat_center = z_flange_front - c14_throat_depth/2 + eps;
        translate([c14_x, c14_y, z_c14_throat_center])
            linear_extrude(height=c14_throat_depth + 2*eps, center=true)
                c14_opening_2d(c14_w, c14_h, c14_r);

        // Front recess step for C14 (gives bezel depth)
        z_c14_front_center = z_flange_front - c14_front_recess/2 + eps;
        translate([c14_x, c14_y, z_c14_front_center])
            linear_extrude(height=c14_front_recess + 2*eps, center=true)
                offset(r=0.6)
                    c14_opening_2d(c14_w*0.98, c14_h*0.98, c14_r);

        // Pin cavities inside the inlet (three slots) to make it recognizable in orthographic views
        // Place them slightly behind the front recess, within the throat.
        z_pin_center = z_flange_front - c14_front_recess - pin_cav_depth/2 + eps;

        // L cavity
        translate([c14_x - pin_pitch_x/2, c14_y + pin_row_y, z_pin_center])
            rrect_prism([pin_cav_w + pin_cav_rim, pin_cav_h + pin_cav_rim, pin_cav_depth + 2*eps], r=0.6, center=true);

        // N cavity
        translate([c14_x + pin_pitch_x/2, c14_y + pin_row_y, z_pin_center])
            rrect_prism([pin_cav_w + pin_cav_rim, pin_cav_h + pin_cav_rim, pin_cav_depth + 2*eps], r=0.6, center=true);

        // PE cavity
        translate([c14_x, c14_y + pe_y, z_pin_center])
            rrect_prism([pin_cav_w + pin_cav_rim, pin_cav_h + pin_cav_rim, pin_cav_depth + 2*eps], r=0.6, center=true);

        // Fuse drawer recess on front face (top-right)
        translate([fuse_x, fuse_y, z_flange_front - fuse_recess_depth/2 + eps])
            rrect_prism([fuse_recess_w, fuse_recess_h, fuse_recess_depth + 2*eps], r=fuse_recess_r, center=true);

        // Notch in fuse recess to suggest pull tab
        notch_w = fuse_recess_w * 0.38;
        notch_h = fuse_recess_h * 0.28;
        translate([fuse_x, fuse_y - fuse_recess_h*0.36, z_flange_front - fuse_recess_depth/2 + eps])
            cube([notch_w, notch_h, fuse_recess_depth + 2*eps], center=true);

        // Fuse drawer "window" cut slightly into the housing to read as a drawer cavity
        // (kept shallow so the model remains a single solid with visible feature)
        drawer_window_depth = min(8.0, fuse_drawer_depth_mm - 2.0);
        z_drawer_window_center = z_fuse_housing_center + fuse_drawer_depth_mm/2 - drawer_window_depth/2 + eps;
        translate([fuse_x, fuse_y, z_drawer_window_center])
            rrect_prism([fuse_drawer_width_mm*0.86, fuse_drawer_height_mm*0.72, drawer_window_depth + 2*eps], r=0.8, center=true);

        // Slight chamfer-like relief around main cutout (front only)
        chamfer_depth = min(1.2, flange_total_t);
        translate([0,0, z_flange_front - chamfer_depth/2 + eps])
            rrect_prism([cutout_width_mm + 6, cutout_height_mm + 6, chamfer_depth + 2*eps], r=1.5, center=true);
    }
}

// Render
iec_fused_inlet();