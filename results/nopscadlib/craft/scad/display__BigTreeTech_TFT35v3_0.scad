$fn = 96;

// Parameters
width_mm = 84.5; //[42.25:169:0.1]
height_mm = 54.5; //[27.25:109:0.1]
thickness_mm = 6; //[3:12:0.1]
corner_radius_mm = 0.5; //[0:5:0.1]

mounting_hole_diameter_mm = 3; //[1.5:6:0.1]
mounting_hole_edge_offset_x_mm = 5; //[2.5:10:0.1]
mounting_hole_edge_offset_y_mm = 5; //[2.5:10:0.1]
mounting_boss_height_mm = 1.5; //[0.5:4:0.1]
mounting_boss_diameter_mm = 5.5; //[3:10:0.1]

aperture_margin_x_mm = 6; //[2:15:0.1]
aperture_margin_y_mm = 6; //[2:15:0.1]
aperture_depth_mm = 1.2; //[0.3:3:0.1]
aperture_clearance_mm = 0.5; //[0.2:2:0.1]

pcb_thickness_mm = 1.6; //[0.8:3.2:0.1]
pcb_margin_mm = 2; //[0.5:6:0.1]
pcb_offset_mm = 1; //[0:4:0.1]

overlap_mm = 0.6; //[0.2:2:0.1]

// Extra feature params (formula-based placement)
bezel_lip_mm = 0.8;                 // raised bezel around screen
bezel_lip_width_mm = 2.0;           // width of bezel ring

connector_w_mm = 14;
connector_h_mm = 5;
connector_t_mm = 3;
connector_inset_mm = 1.0;           // inset from PCB edge

// Display "glass" feature (adds recognizable display detail)
glass_thickness_mm = 0.8;
glass_inset_mm = 0.2;               // inset inside aperture
glass_raise_mm = 0.15;              // slightly proud of recess floor

// ---------- Helpers ----------
module rounded_rect_prism(size=[10,10,2], r=1, center=true) {
  sx = size[0]; sy = size[1]; sz = size[2];
  rr = min(r, sx/2, sy/2);

  // Avoid degenerate hull when rr==0
  if (rr <= 0) {
    cube([sx, sy, sz], center=center);
  } else {
    translate(center ? [0,0,0] : [sx/2, sy/2, sz/2])
      hull() {
        for (x = [-1,1], y = [-1,1])
          translate([x*(sx/2-rr), y*(sy/2-rr), -sz/2])
            cylinder(r=rr, h=sz);
      }
  }
}

module mounting_pattern(zc) {
  for (x = [-1, 1], y = [-1, 1])
    translate([x * (width_mm/2 - mounting_hole_edge_offset_x_mm),
               y * (height_mm/2 - mounting_hole_edge_offset_y_mm),
               zc])
      children();
}

// ---------- Model ----------
module display_module_v3() {
  // Derived sizes
  aperture_w = width_mm  - 2*aperture_margin_x_mm + 2*aperture_clearance_mm;
  aperture_h = height_mm - 2*aperture_margin_y_mm + 2*aperture_clearance_mm;

  bezel_outer_w = max(aperture_w + 2*bezel_lip_width_mm, aperture_w + 0.1);
  bezel_outer_h = max(aperture_h + 2*bezel_lip_width_mm, aperture_h + 0.1);

  pcb_w = width_mm - 2*pcb_margin_mm;
  pcb_h = height_mm - 2*pcb_margin_mm;

  // Z positions (all formula-based)
  body_front_z =  thickness_mm/2;
  body_back_z  = -thickness_mm/2;

  // Bosses touch the back face and overlap slightly into the body to guarantee connectivity
  boss_zc = body_back_z + mounting_boss_height_mm/2 + overlap_mm/2;

  // PCB sits above bosses and overlaps into them (connected)
  boss_top_z = boss_zc + mounting_boss_height_mm/2;
  pcb_zc = boss_top_z + pcb_thickness_mm/2 - overlap_mm;

  pcb_top_z = pcb_zc + pcb_thickness_mm/2;

  // Connector sits on PCB top, near one long edge, overlaps into PCB
  conn_zc = pcb_top_z + connector_t_mm/2 - overlap_mm;
  conn_yc = (pcb_h/2 - connector_h/2 - connector_inset_mm);
  conn_xc = 0;

  // Screen recess location (from front face inward)
  recess_zc = body_front_z - aperture_depth_mm/2;

  // Glass sits inside recess, slightly raised from recess floor, and overlaps into body
  glass_w = max(0.1, aperture_w - 2*glass_inset_mm);
  glass_h = max(0.1, aperture_h - 2*glass_inset_mm);
  recess_floor_z = body_front_z - aperture_depth_mm;
  glass_zc = recess_floor_z + glass_thickness_mm/2 + glass_raise_mm;

  union() {
    // Main housing with recess + through mounting holes
    difference() {
      rounded_rect_prism([width_mm, height_mm, thickness_mm], r=corner_radius_mm, center=true);

      // Screen recess (cut)
      translate([0, 0, recess_zc])
        rounded_rect_prism([aperture_w, aperture_h, aperture_depth_mm + overlap_mm],
                           r=max(0, corner_radius_mm/2), center=true);

      // Mounting holes (through)
      mounting_pattern(0)
        cylinder(d=mounting_hole_diameter_mm, h=thickness_mm + 2*overlap_mm, center=true);
    }

    // Raised bezel ring around the screen (connected to body with overlap)
    translate([0, 0, body_front_z + bezel_lip_mm/2 - overlap_mm])
      difference() {
        rounded_rect_prism([bezel_outer_w, bezel_outer_h, bezel_lip_mm], r=max(0, corner_radius_mm/2), center=true);
        rounded_rect_prism([aperture_w, aperture_h, bezel_lip_mm + 2*overlap_mm], r=max(0, corner_radius_mm/2), center=true);
      }

    // Display glass inside the recess (connected by slight overlap into recess floor)
    translate([0, 0, glass_zc])
      rounded_rect_prism([glass_w, glass_h, glass_thickness_mm + overlap_mm],
                         r=max(0, corner_radius_mm/3), center=true);

    // Back-side bosses + PCB + connector as one connected solid
    difference() {
      union() {
        // Bosses (overlap into body ensured by boss_zc formula)
        mounting_pattern(boss_zc)
          cylinder(d=mounting_boss_diameter_mm, h=mounting_boss_height_mm + overlap_mm, center=true);

        // PCB (connected to bosses)
        translate([0, 0, pcb_zc])
          cube([pcb_w, pcb_h, pcb_thickness_mm], center=true);

        // Connector block (connected to PCB)
        translate([conn_xc, conn_yc, conn_zc])
          cube([connector_w_mm, connector_h_mm, connector_t_mm], center=true);
      }

      // Drill mounting holes through bosses too (aligned)
      mounting_pattern(boss_zc)
        cylinder(d=mounting_hole_diameter_mm, h=mounting_boss_height_mm + 3*overlap_mm, center=true);
    }
  }
}

display_module_v3();