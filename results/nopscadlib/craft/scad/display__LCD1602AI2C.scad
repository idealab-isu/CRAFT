$fn = 48;

// Parameters
overall_width_mm = 71.3; //[35.65:142.6:0.1]
overall_height_mm = 24.3; //[12.15:48.6:0.1]
thickness_mm = 8; //[4:16:0.1]

pcb_thickness_mm = 1.6; //[0.8:3.2:0.1]
bezel_thickness_mm = 6.4; //[3.2:12.8:0.1]

aperture_width_mm = 64.5; //[32.25:129:0.1]
aperture_height_mm = 14.5; //[7.25:29:0.1]
aperture_depth_mm = 2; //[0.5:6:0.1]

mount_hole_diameter_mm = 3.2; //[1.6:6.4:0.1]
mount_hole_edge_margin_x_mm = 2.5; //[1.25:5:0.1]
mount_hole_edge_margin_y_mm = 2.5; //[1.25:5:0.1]

connector_pitch_mm = 2.54; //[1.27:5.08:0.01]
connector_pins = 16; //[8:20:1]
connector_body_depth_mm = 5; //[2.5:10:0.1]
connector_body_height_mm = 6; //[3:12:0.1]
connector_overhang_mm = 1; //[0.5:3:0.1]

overlap_mm = 1; //[0.5:2:0.1]

// Derived
pcb_zc   = -(thickness_mm/2) + (pcb_thickness_mm/2);
bezel_zc = -(thickness_mm/2) + pcb_thickness_mm + (bezel_thickness_mm/2) - overlap_mm;

// Keep the overall thickness exactly thickness_mm
bezel_top_z = bezel_zc + bezel_thickness_mm/2;
z_shift = (thickness_mm/2) - bezel_top_z;

// Final Z centers after shift
pcb_zc_s   = pcb_zc + z_shift;
bezel_zc_s = bezel_zc + z_shift;

// Aperture: cut into bezel from the front (top) face
aperture_zc_s = (thickness_mm/2) - (aperture_depth_mm/2);

// Connector: on back side, attached to PCB (not floating)
conn_w = connector_pins * connector_pitch_mm;
conn_yc = -(overall_height_mm/2) + (connector_body_depth_mm/2) - connector_overhang_mm;
conn_zc_s = (pcb_zc_s + pcb_thickness_mm/2) - (connector_body_height_mm/2) + overlap_mm;

// Mount holes positions
hole_x = overall_width_mm/2 - mount_hole_edge_margin_x_mm;
hole_y = overall_height_mm/2 - mount_hole_edge_margin_y_mm;

// Geometry (single connected solid)
module lcd1602a_module() {
  difference() {
    union() {
      // PCB
      translate([0, 0, pcb_zc_s])
        cube([overall_width_mm, overall_height_mm, pcb_thickness_mm], center=true);

      // Bezel (front)
      translate([0, 0, bezel_zc_s])
        cube([overall_width_mm, overall_height_mm, bezel_thickness_mm], center=true);

      // Back-side connector body (attached to PCB)
      translate([0, conn_yc, conn_zc_s])
        cube([conn_w, connector_body_depth_mm, connector_body_height_mm], center=true);

      // Small back-side stiffener/feature bar (typical PCB feature), attached to PCB
      // (kept subtle; ensures visible back detail without changing overall footprint)
      feature_w = overall_width_mm * 0.70;
      feature_d = 2.0;
      feature_h = 1.2;
      feature_yc = (overall_height_mm/2) - feature_d/2;
      feature_zc_s = (pcb_zc_s - pcb_thickness_mm/2) + feature_h/2 - overlap_mm;
      translate([0, feature_yc, feature_zc_s])
        cube([feature_w, feature_d, feature_h], center=true);
    }

    // Display aperture recess (cut into bezel only; does not remove entire model)
    translate([0, 0, aperture_zc_s])
      cube([aperture_width_mm, aperture_height_mm, aperture_depth_mm + 2*overlap_mm], center=true);

    // Mounting holes through entire thickness
    for (sx = [-1, 1])
      for (sy = [-1, 1])
        translate([sx*hole_x, sy*hole_y, 0])
          cylinder(d=mount_hole_diameter_mm, h=thickness_mm + 2*overlap_mm, center=true);
  }
}

lcd1602a_module();