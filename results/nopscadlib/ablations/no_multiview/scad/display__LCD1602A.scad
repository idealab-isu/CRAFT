// Parameters
overall_width_mm = 71.3; //[35.65:142.6:0.1]
overall_height_mm = 24.3; //[12.15:48.6:0.1]
overall_thickness_mm = 8.5; //[4.25:17:0.1]
bezel_thickness_mm = 3.0; //[1.5:6:0.1]
pcb_thickness_mm = 1.6; //[0.8:3.2:0.1]
pcb_margin_mm = 0.6; //[0.2:2:0.1]
aperture_width_mm = 64.0; //[32:80:0.1]
aperture_height_mm = 14.0; //[7:20:0.1]
aperture_depth_mm = 2.2; //[1:5:0.1]
glass_thickness_mm = 1.2; //[0.6:3:0.1]
glass_clearance_mm = 0.4; //[0.1:1.5:0.1]
mount_hole_diameter_mm = 3.2; //[1.6:6.4:0.1]
mount_hole_spacing_x_mm = 75.0; //[37.5:150:0.1]
mount_hole_spacing_y_mm = 31.0; //[15.5:62:0.1]
pin_header_pitch_mm = 2.54; //[1.27:5.08:0.01]
pin_count = 16; //[8:20:1]
pin_zone_width_mm = 41.0; //[20.5:82:0.1]
pin_zone_height_mm = 6.0; //[3:12:0.1]
pin_zone_thickness_mm = 3.0; //[1.5:8:0.1]
pin_zone_edge_offset_y_mm = 3.0; //[1:8:0.1]

// Use 1-2mm overlap to guarantee manifold connections
overlap_mm = 1.2; //[0.5:2.0:0.1]

// Display module - complete geometry (all parts physically connected)
module display() {

  // Derived Z reference planes (centered model)
  z_front =  overall_thickness_mm/2;
  z_back  = -overall_thickness_mm/2;

  // Bezel occupies the front thickness
  z_bezel_center = z_front - bezel_thickness_mm/2;

  // PCB sits at the back
  z_pcb_center = z_back + pcb_thickness_mm/2;

  // Glass sits behind the bezel front, and overlaps into bezel by overlap_mm
  z_glass_center =
    (z_front - bezel_thickness_mm) + glass_thickness_mm/2 - overlap_mm;

  // Pin zone sits behind PCB and overlaps into PCB by overlap_mm
  z_pin_center =
    (z_back + pcb_thickness_mm) + pin_zone_thickness_mm/2 - overlap_mm;

  // Thin strip/plate: MUST be attached (overlap into PCB by overlap_mm)
  strip_thickness_mm = 1.2;
  strip_height_mm    = 2.0;
  // Place it just behind the PCB so it intersects the PCB volume by overlap_mm
  z_strip_center =
    (z_back + pcb_thickness_mm) + strip_thickness_mm/2 - overlap_mm;

  color([0.0, 0.4, 0.2]) { // PCB/green parts
    union() {

      // Bezel (front) with aperture cut
      difference() {
        translate([0, 0, z_bezel_center])
          cube([overall_width_mm, overall_height_mm, bezel_thickness_mm], center=true);

        // Cut aperture into bezel (ensure cut fully passes through bezel with overlap)
        translate([0, 0, z_front - aperture_depth_mm/2])
          cube([aperture_width_mm, aperture_height_mm, aperture_depth_mm + 2*overlap_mm], center=true);
      }

      // PCB backing plate (rear)
      translate([0, 0, z_pcb_center])
        cube([overall_width_mm + 2*pcb_margin_mm,
              overall_height_mm + 2*pcb_margin_mm,
              pcb_thickness_mm], center=true);

      // Pin header interface zone (rear, near bottom edge) - overlaps PCB
      translate([
        0,
        -(overall_height_mm + 2*pcb_margin_mm)/2 + pin_zone_edge_offset_y_mm + pin_zone_height_mm/2,
        z_pin_center
      ])
        cube([pin_zone_width_mm, pin_zone_height_mm, pin_zone_thickness_mm], center=true);

      // Display glass (overlaps bezel by overlap_mm)
      translate([0, 0, z_glass_center])
        cube([aperture_width_mm - 2*glass_clearance_mm,
              aperture_height_mm - 2*glass_clearance_mm,
              glass_thickness_mm], center=true);

      // Structural fix: thin strip/plate that was floating
      // Now positioned to INTERSECT the PCB by overlap_mm (not just "near" it).
      translate([
        0,
        -(overall_height_mm + 2*pcb_margin_mm)/2 + strip_height_mm/2, // along bottom edge
        z_strip_center
      ])
        cube([overall_width_mm + 2*pcb_margin_mm, strip_height_mm, strip_thickness_mm], center=true);
    }
  }
}

// Mod - complete geometry
module mod() {
  color([0.1, 0.1, 0.6]) { // Blue color for mod
    cube([overall_width_mm, overall_height_mm, overall_thickness_mm], center=true);
  }
}

// Assembly (single connected solid via union; holes applied after union)
module assembly() {
  difference() {
    union() {
      display();
      mod();
    }

    // Mounting holes (cut through the combined solid)
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * mount_hole_spacing_x_mm/2, y * mount_hole_spacing_y_mm/2, 0])
        cylinder(r=mount_hole_diameter_mm/2, h=overall_thickness_mm + 2*overlap_mm, center=true);
    }
  }
}

assembly();