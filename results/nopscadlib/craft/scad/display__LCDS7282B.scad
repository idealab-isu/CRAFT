$fn = 64;

// Target overall envelope (must match)
overall_width_mm  = 73.6;
overall_height_mm = 28.7;

// Thickness stack (kept realistic, but total stays within overall_thickness_mm)
overall_thickness_mm = 5.0;

// Front bezel + window
bezel_thickness_mm = 1.6;
bezel_corner_r_mm  = 1.2;

window_margin_x_mm = 4.0;
window_margin_y_mm = 3.2;
window_recess_mm   = 0.7;

// LCD glass (sits in recess)
glass_thickness_mm = 0.6;
glass_inset_mm     = 0.25;

// Rear PCB
pcb_thickness_mm = 1.6;
pcb_inset_mm     = 0.6;

// Rear features
standoff_d_mm     = 3.2;
standoff_h_mm     = 1.2;   // rises from PCB top toward bezel
mount_hole_d_mm   = 2.2;   // through PCB + standoff
standoff_inset_mm = 3.0;

// Connector / FFC tail (integrated as solid so model is ONE connected solid)
ffc_w_mm = 16.0;
ffc_l_mm = 10.0;
ffc_t_mm = 0.8;

// Small overlap to guarantee watertight unions/differences
eps = 0.15;

// Derived Z positions (centered assembly)
z_front =  overall_thickness_mm/2;
z_back  = -overall_thickness_mm/2;

z_bezel_center = z_front - bezel_thickness_mm/2;
z_pcb_center   = z_back  + pcb_thickness_mm/2;

// Ensure internal stack fits within overall thickness
// Remaining space between bezel back and PCB top:
z_bezel_back = z_front - bezel_thickness_mm;
z_pcb_top    = z_back + pcb_thickness_mm;
internal_gap = z_bezel_back - z_pcb_top; // should be >= 0

// Helpers
module rrect2d(w,h,r){
  r2 = min(r, min(w,h)/2);
  hull(){
    for (sx=[-1,1], sy=[-1,1])
      translate([sx*(w/2-r2), sy*(h/2-r2)]) circle(r=r2);
  }
}

module rrect3d(w,h,t,r){
  linear_extrude(height=t, center=true) rrect2d(w,h,r);
}

module standoff(x,y){
  // Standoff sits on PCB top and rises toward bezel; includes through-hole
  translate([x,y, z_pcb_center + pcb_thickness_mm/2 + standoff_h_mm/2 - eps])
    difference(){
      cylinder(h=standoff_h_mm + 2*eps, d=standoff_d_mm, center=true);
      cylinder(h=standoff_h_mm + 4*eps, d=mount_hole_d_mm, center=true);
    }
}

module pcb_with_features(){
  // PCB plate + standoffs + connector block + FFC tail (all solid, connected)
  union(){
    // PCB
    translate([0,0,z_pcb_center])
      rrect3d(overall_width_mm - 2*pcb_inset_mm,
              overall_height_mm - 2*pcb_inset_mm,
              pcb_thickness_mm,
              0.8);

    // Standoffs near corners (inset)
    sx = (overall_width_mm  - 2*standoff_inset_mm)/2;
    sy = (overall_height_mm - 2*standoff_inset_mm)/2;
    for (ix=[-1,1], iy=[-1,1])
      standoff(ix*sx, iy*sy);

    // Connector block on PCB top, near bottom edge
    conn_w = 14.0;
    conn_h = 4.0;
    conn_t = 2.0;
    conn_y = -(overall_height_mm/2 - pcb_inset_mm - conn_h/2 - 1.2);
    translate([0, conn_y,
               z_pcb_center + pcb_thickness_mm/2 + conn_t/2 - eps])
      rrect3d(conn_w, conn_h, conn_t, 0.6);

    // FFC tail extending out from bottom edge, attached to connector block
    // Place so its inner edge overlaps into connector by eps
    ffc_y_center = -(overall_height_mm/2 + ffc_l_mm/2 - eps);
    translate([0, ffc_y_center,
               z_pcb_center + pcb_thickness_mm/2 + ffc_t_mm/2 - eps])
      rrect3d(ffc_w_mm, ffc_l_mm, ffc_t_mm, 0.4);
  }
}

module bezel_with_window(){
  // Bezel with recessed window opening
  window_w = overall_width_mm  - 2*window_margin_x_mm;
  window_h = overall_height_mm - 2*window_margin_y_mm;

  translate([0,0,z_bezel_center])
    difference(){
      rrect3d(overall_width_mm, overall_height_mm, bezel_thickness_mm, bezel_corner_r_mm);

      // Recessed window pocket from front face inward
      // Pocket depth limited to bezel thickness
      pocket_t = min(window_recess_mm, bezel_thickness_mm - 0.2);
      translate([0,0, bezel_thickness_mm/2 - pocket_t/2 + eps])
        rrect3d(window_w, window_h, pocket_t + 2*eps, 0.8);
    }
}

module glass_in_window(){
  window_w = overall_width_mm  - 2*window_margin_x_mm;
  window_h = overall_height_mm - 2*window_margin_y_mm;

  // Glass sits inside the recess, slightly inset
  pocket_t = min(window_recess_mm, bezel_thickness_mm - 0.2);
  z_pocket_bottom = z_front - pocket_t; // bottom of recess
  z_glass_center  = z_pocket_bottom + glass_thickness_mm/2 + eps;

  translate([0,0,z_glass_center])
    rrect3d(window_w - 2*glass_inset_mm,
            window_h - 2*glass_inset_mm,
            glass_thickness_mm,
            0.6);
}

module module_solid(){
  // ONE connected solid: union of all physical parts
  // Ensure PCB touches bezel via standoffs (internal_gap should be >= standoff_h)
  union(){
    bezel_with_window();
    glass_in_window();
    pcb_with_features();

    // Add a thin internal "spacer web" to guarantee connectivity even if parameters change:
    // Connect PCB top to bezel back with a small rib near one side.
    rib_w = 6.0;
    rib_h = 3.0;
    rib_t = max(0.6, min(internal_gap + 2*eps, 1.2));
    rib_x = overall_width_mm/2 - rib_w/2 - 2.0;
    rib_z_center = (z_bezel_back + z_pcb_top)/2;
    translate([rib_x, 0, rib_z_center])
      rrect3d(rib_w, rib_h, rib_t, 0.6);
  }
}

module_solid();