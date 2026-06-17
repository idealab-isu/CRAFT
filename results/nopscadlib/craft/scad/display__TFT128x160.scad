// LCD TFT display module 128x160 (approx) - 46.0mm x 34.0mm
// One connected solid with bezel, recessed window, mounting holes, and rear FFC connector bump.

$fn = 64;

// Parameters
overall_width_mm  = 46.0;  //[23.0:92.0:0.5]
overall_height_mm = 34.0;  //[17.0:68.0:0.5]

pcb_thickness_mm          = 1.6; //[0.8:3.2:0.1]
body_thickness_mm         = 3.2; //[1.6:6.4:0.1]
display_face_thickness_mm = 1.2; //[0.6:2.4:0.1]

display_window_margin_x_mm = 6.0; //[3.0:12.0:0.5]
display_window_margin_y_mm = 5.0; //[2.5:10.0:0.5]

aperture_depth_mm      = 0.8; //[0.4:1.6:0.1]
aperture_clearance_mm  = 0.6; //[0.2:1.5:0.1]
connection_overlap_mm  = 1.0; //[0.5:2.0:0.1]

corner_radius_mm = 1.2;
bezel_frame_mm   = 1.2;   // raised bezel ring width
bezel_raise_mm   = 0.6;   // bezel height above face
hole_d_mm        = 2.4;
hole_edge_margin_mm = 3.0;

ffc_w_mm = 14.0;
ffc_h_mm = 5.0;
ffc_t_mm = 2.2;
ffc_inset_from_edge_mm = 1.0;

eps = 0.01;

// Rounded rectangle prism (robust, no offset artifacts)
module rr_prism(size=[10,10,1], r=1, center=true) {
  x = size[0]; y = size[1]; z = size[2];
  r2 = max(0, min(r, x/2 - eps, y/2 - eps));

  translate(center ? [0,0,0] : [x/2, y/2, z/2])
    linear_extrude(height=z, center=true)
      hull() {
        for (sx=[-1,1], sy=[-1,1])
          translate([sx*(x/2 - r2), sy*(y/2 - r2), 0])
            circle(r=r2);
      }
}

module display_module() {
  // Derived Z stack (centered around Z=0 for easy viewing)
  total_t = pcb_thickness_mm + body_thickness_mm + display_face_thickness_mm + bezel_raise_mm;
  z0 = -total_t/2;

  // Ensure positive overlaps between stacked solids
  ov = min(connection_overlap_mm, min(pcb_thickness_mm, min(body_thickness_mm, display_face_thickness_mm)) - 0.05);

  z_pcb_c   = z0 + pcb_thickness_mm/2;
  z_body_c  = z0 + pcb_thickness_mm - ov + body_thickness_mm/2;
  z_face_c  = z0 + pcb_thickness_mm + body_thickness_mm - 2*ov + display_face_thickness_mm/2;
  z_bezel_c = z0 + pcb_thickness_mm + body_thickness_mm + display_face_thickness_mm - 3*ov + bezel_raise_mm/2;

  // Window sizes
  win_w = overall_width_mm  - 2*display_window_margin_x_mm;
  win_h = overall_height_mm - 2*display_window_margin_y_mm;

  // Aperture (recess) slightly larger than visible window
  ap_w = overall_width_mm  - 2*(display_window_margin_x_mm - aperture_clearance_mm);
  ap_h = overall_height_mm - 2*(display_window_margin_y_mm - aperture_clearance_mm);

  // Bezel outer and inner sizes
  bezel_inset = 0.6; // inset from PCB edge to show PCB outline
  bezel_outer_w = overall_width_mm  - 2*bezel_inset;
  bezel_outer_h = overall_height_mm - 2*bezel_inset;

  bezel_inner_w = min(bezel_outer_w - 2*bezel_frame_mm, ap_w + 2.0);
  bezel_inner_h = min(bezel_outer_h - 2*bezel_frame_mm, ap_h + 2.0);

  // Mounting holes positions (formula-based)
  hx = overall_width_mm/2  - hole_edge_margin_mm;
  hy = overall_height_mm/2 - hole_edge_margin_mm;

  // FFC connector bump on back side (bottom edge)
  ffc_x = 0;
  ffc_y = -overall_height_mm/2 + ffc_inset_from_edge_mm + ffc_h_mm/2;
  ffc_z = z0 + pcb_thickness_mm/2 + ffc_t_mm/2 - ov; // overlaps into PCB

  // Small stiffener/strain relief tab behind connector (still connected)
  stiff_w = ffc_w_mm*0.8;
  stiff_h = 1.2;
  stiff_t = ffc_t_mm*0.8;

  // Place stiffener so it touches/overlaps the connector bump (no floating)
  stiff_x = ffc_x;
  stiff_y = ffc_y - (ffc_h_mm/2 + stiff_h/2 - 0.4); // 0.4mm overlap
  stiff_z = ffc_z;

  color([0.1, 0.1, 0.6])
  difference() {
    union() {
      // PCB
      translate([0,0,z_pcb_c])
        rr_prism([overall_width_mm, overall_height_mm, pcb_thickness_mm], r=corner_radius_mm, center=true);

      // Main body (slightly inset to show PCB edge)
      translate([0,0,z_body_c])
        rr_prism([overall_width_mm-0.8, overall_height_mm-0.8, body_thickness_mm], r=max(0.6, corner_radius_mm-0.4), center=true);

      // Face plate
      translate([0,0,z_face_c])
        rr_prism([overall_width_mm-0.4, overall_height_mm-0.4, display_face_thickness_mm], r=max(0.6, corner_radius_mm-0.2), center=true);

      // Raised bezel ring (recognizable LCD module feature)
      translate([0,0,z_bezel_c])
        difference() {
          rr_prism([bezel_outer_w, bezel_outer_h, bezel_raise_mm], r=max(0.6, corner_radius_mm-0.2), center=true);
          rr_prism([bezel_inner_w, bezel_inner_h, bezel_raise_mm + 2*eps], r=max(0.4, corner_radius_mm-0.6), center=true);
        }

      // Rear FFC/connector bump (connected to PCB)
      translate([ffc_x, ffc_y, ffc_z])
        rr_prism([ffc_w_mm, ffc_h_mm, ffc_t_mm], r=0.6, center=true);

      // Stiffener/strain relief tab (connected to connector bump)
      translate([stiff_x, stiff_y, stiff_z])
        rr_prism([stiff_w, stiff_h, stiff_t], r=0.4, center=true);
    }

    // Recessed aperture into face (screen cutout) - ensure it actually cuts into face
    // Center the cut within the face thickness, starting from the top surface down by aperture_depth
    face_top_z = z0 + pcb_thickness_mm + body_thickness_mm + display_face_thickness_mm - 2*ov;
    ap_cz = face_top_z - aperture_depth_mm/2 + eps; // slight bias to guarantee cut
    translate([0,0,ap_cz])
      rr_prism([ap_w, ap_h, aperture_depth_mm + 2*eps], r=0.8, center=true);

    // Mounting holes through PCB+body (not through face/bezel)
    hole_h = pcb_thickness_mm + body_thickness_mm + 2*eps;
    hole_cz = z0 + (pcb_thickness_mm + body_thickness_mm)/2 - ov;
    for (sx = [-1, 1], sy = [-1, 1]) {
      translate([sx*hx, sy*hy, hole_cz])
        cylinder(d=hole_d_mm, h=hole_h, center=true);
    }
  }
}

// Mod - complete geometry
module mod() { display_module(); }

// Assembly
module assembly() { mod(); }

assembly();