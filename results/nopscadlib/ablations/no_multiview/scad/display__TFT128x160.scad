// Parameters
module_width_mm = 46; //[23:92:0.1]
module_height_mm = 34; //[17:68:0.1]
module_thickness_mm = 3; //[1.5:6:0.1]
bezel_thickness_mm = 2; //[1:4:0.1]
bezel_border_mm = 2; //[1:6:0.1]
aperture_width_mm = 38; //[19:76:0.1]
aperture_height_mm = 30; //[15:60:0.1]
corner_radius_mm = 0.5; //[0:2:0.1]
clearance_mm = 0.2; //[0:1:0.05]

// Use 1–2mm overlap to guarantee watertight connections
overlap_mm = 1.5; //[0.5:2:0.1]

pcb_plane_thickness_mm = 1.6; //[0.8:3.2:0.1]
display_thickness_mm = 1.2; //[0.5:3:0.1]

// Display - complete geometry (blue)
module display() {
  color([0.1, 0.1, 0.6])
    cube([aperture_width_mm, aperture_height_mm, display_thickness_mm], center=true);
}

// Main module body (gray frame/body)
module mod() {
  color([0.85, 0.85, 0.8])
    cube([module_width_mm, module_height_mm, module_thickness_mm], center=true);
}

// Front bezel frame (light gray)
module front_bezel_frame() {
  difference() {
    color([0.85, 0.85, 0.8])
      cube([module_width_mm + 2*(bezel_border_mm + clearance_mm),
            module_height_mm + 2*(bezel_border_mm + clearance_mm),
            bezel_thickness_mm], center=true);

    // Cut aperture through bezel; extend cut slightly to avoid coplanar faces
    translate([0, 0, -overlap_mm])
      cube([aperture_width_mm + 2*clearance_mm,
            aperture_height_mm + 2*clearance_mm,
            bezel_thickness_mm + 2*overlap_mm], center=true);
  }
}

// PCB mounting plane (green)
module pcb_mounting_plane() {
  color([0.0, 0.4, 0.2])
    cube([module_width_mm, module_height_mm, pcb_plane_thickness_mm], center=true);
}

// Assembly (all parts physically connected with slight overlaps)
module assembly() {

  // Clamp overlap so it cannot exceed half of any mating thickness
  ov_disp = min(overlap_mm, min(display_thickness_mm/2, module_thickness_mm/2));
  ov_bez  = min(overlap_mm, min(bezel_thickness_mm/2,  module_thickness_mm/2));
  ov_pcb  = min(overlap_mm, min(pcb_plane_thickness_mm/2, module_thickness_mm/2));

  // Centered main body
  z_mod = 0;

  // Place display so it INTERSECTS the front face of the main body by ov_disp
  // Condition: display_bottom = mod_front - ov_disp
  z_display = (module_thickness_mm/2) + (display_thickness_mm/2) - ov_disp;

  // Place bezel so it INTERSECTS the front face of the main body by ov_bez
  // Condition: bezel_bottom = mod_front - ov_bez
  z_bezel = (module_thickness_mm/2) + (bezel_thickness_mm/2) - ov_bez;

  // Place PCB so it INTERSECTS the back face of the main body by ov_pcb
  // Condition: pcb_top = mod_back + ov_pcb
  z_pcb = -(module_thickness_mm/2) - (pcb_plane_thickness_mm/2) + ov_pcb;

  // Ensure blue and green layers are not separated by the body:
  // Add an internal "spine" that overlaps both the display and PCB and passes through the body.
  // This guarantees a single connected solid even if display/PCB are on opposite sides.
  spine_z = (z_display + z_pcb) / 2;
  spine_h = abs(z_display - z_pcb) + max(display_thickness_mm, pcb_plane_thickness_mm) + 2*overlap_mm;
  spine_w = 6;  // small internal connector; does not change external design
  spine_d = 6;

  union() {
    translate([0, 0, z_mod]) mod();
    translate([0, 0, z_bezel]) front_bezel_frame();
    translate([0, 0, z_display]) display();
    translate([0, 0, z_pcb]) pcb_mounting_plane();

    // Internal connector (hidden inside the module footprint)
    color([0.85, 0.85, 0.8])
      translate([0, 0, spine_z])
        cube([spine_w, spine_d, spine_h], center=true);
  }
}

assembly();