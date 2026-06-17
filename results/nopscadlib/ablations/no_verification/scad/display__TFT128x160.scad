$fn = 64;

// Parameters (mm)
overall_width_mm = 46.0;          //[23:92:0.5]
overall_height_mm = 34.0;         //[17:68:0.5]
pcb_thickness_mm = 1.6;           //[0.8:3.2:0.1]

bezel_thickness_mm = 2.0;         //[1:4:0.1]
aperture_depth_mm = 1.2;          //[0.5:3:0.1]
display_glass_thickness_mm = 0.8; //[0.4:2:0.1]

active_area_width_mm = 28.0;      //[14:56:0.5]
active_area_height_mm = 35.0;     //[17.5:70:0.5]  // will be clamped to fit

corner_radius_mm = 0.8;           //[0:2:0.1]

mount_hole_diameter_mm = 2.0;     //[1:4:0.1]
mount_hole_edge_offset_mm = 2.5;  //[1.25:5:0.1]
mount_pad_diameter_mm = 4.0;      //[2:8:0.1]
mount_pad_height_mm = 0.6;        //[0.3:1.5:0.1]

connector_width_mm = 15.0;        //[7.5:30:0.5]
connector_depth_mm = 5.0;         //[2.5:10:0.5]
connector_height_mm = 3.0;        //[1.5:6:0.1]

overlap_mm = 0.4;                 //[0.1:2:0.1]

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module rrect2d(w, h, r) {
  r2 = clamp(r, 0, min(w, h)/2);
  if (r2 <= 0)
    square([w, h], center=true);
  else
    offset(r=r2) offset(delta=-r2) square([w, h], center=true);
}

module rrect3d(w, h, t, r) {
  linear_extrude(height=t, center=true)
    rrect2d(w, h, r);
}

// Main model: ONE connected solid
module lcd_tft_128x160_module() {

  // Clamp active area to fit within bezel footprint
  aa_w = clamp(active_area_width_mm, 1, overall_width_mm - 2*mount_hole_edge_offset_mm);
  aa_h = clamp(active_area_height_mm, 1, overall_height_mm - 2*mount_hole_edge_offset_mm);

  // Z stacking (centered around Z=0 for PCB)
  pcb_zc   = 0;
  pcb_top  = pcb_zc + pcb_thickness_mm/2;
  pcb_bot  = pcb_zc - pcb_thickness_mm/2;

  bezel_zc = pcb_top + bezel_thickness_mm/2 - overlap_mm; // overlap into PCB
  bezel_top = bezel_zc + bezel_thickness_mm/2;

  // Glass sits in the aperture (slightly overlapping for watertight union)
  glass_zc = (bezel_top - aperture_depth_mm) + display_glass_thickness_mm/2 - overlap_mm;

  // Connector on back side, attached to PCB bottom
  conn_zc = pcb_bot - connector_height_mm/2 + overlap_mm;

  // Mounting hole positions
  hx = overall_width_mm/2  - mount_hole_edge_offset_mm;
  hy = overall_height_mm/2 - mount_hole_edge_offset_mm;

  union() {

    // PCB with mounting holes (holes are cut through PCB only)
    difference() {
      translate([0,0,pcb_zc])
        rrect3d(overall_width_mm, overall_height_mm, pcb_thickness_mm, corner_radius_mm);

      for (x = [-1, 1])
        for (y = [-1, 1])
          translate([x*hx, y*hy, pcb_zc])
            cylinder(h=pcb_thickness_mm + 2*overlap_mm, r=mount_hole_diameter_mm/2, center=true);
    }

    // Mount pads (rings) around holes on top side, connected to PCB
    for (x = [-1, 1])
      for (y = [-1, 1])
        translate([x*hx, y*hy, pcb_top + mount_pad_height_mm/2 - overlap_mm])
          difference() {
            cylinder(h=mount_pad_height_mm, r=mount_pad_diameter_mm/2, center=true);
            cylinder(h=mount_pad_height_mm + 2*overlap_mm, r=mount_hole_diameter_mm/2, center=true);
          }

    // Bezel/frame with screen window cutout
    difference() {
      translate([0,0,bezel_zc])
        rrect3d(overall_width_mm, overall_height_mm, bezel_thickness_mm, corner_radius_mm);

      // Aperture cut (window) from top face down by aperture_depth
      translate([0,0,bezel_top - aperture_depth_mm/2 + overlap_mm])
        rrect3d(aa_w, aa_h, aperture_depth_mm + 2*overlap_mm, max(0, corner_radius_mm*0.6));
    }

    // Display glass inside the aperture
    translate([0,0,glass_zc])
      rrect3d(aa_w, aa_h, display_glass_thickness_mm, max(0, corner_radius_mm*0.4));

    // Back connector block (centered on bottom edge), attached to PCB underside
    translate([0, -(overall_height_mm/2 + connector_depth_mm/2 - overlap_mm), conn_zc])
      rrect3d(connector_width_mm, connector_depth_mm, connector_height_mm, 0.4);
  }
}

lcd_tft_128x160_module();