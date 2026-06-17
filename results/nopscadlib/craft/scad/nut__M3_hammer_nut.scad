// Parameters
screw_thread_diameter = 3; //[1.5:6:0.1]
across_flats = 6; //[3:12:0.1]
thickness = 2.75; //[1.4:5.5:0.05]
thread_pitch = 0.5; //[0.25:1:0.05]
t_slot_interface_width = 6.2; //[4:12:0.1]
t_slot_interface_height = 3.2; //[2:8:0.1]
t_slot_interface_clearance = 0.2; //[0:0.6:0.05]
anti_rotation_tab_width = 1.2; //[0.6:2.4:0.05]
anti_rotation_tab_height = 0.6; //[0.3:1.2:0.05]
edge_chamfer = 0.2; //[0:0.8:0.05]
corner_radius = 0.2; //[0:0.8:0.05]
hole_clearance = 0.2; //[0:0.6:0.05]
hole_diameter = 2.8; //[2.4:3.4:0.05]
overlap = 0.8; //[0.5:2:0.1]
washer_outer_diameter = 7; //[4:14:0.1]
washer_thickness = 0.8; //[0.4:2:0.05]
assembly_gap = 0.5; //[0:3:0.1]

// Nut and Washer - complete geometry
module nut_and_washer() {

  // Derived sizes
  hex_r = across_flats/(2*cos(30));                 // circumscribed radius for $fn=6
  tab_x_len = anti_rotation_tab_width*2;
  tab_y_len = anti_rotation_tab_height*2;
  tab_y_span = t_slot_interface_height - t_slot_interface_clearance;
  tab_x_span = t_slot_interface_width  - t_slot_interface_clearance;

  // Requested: ensure real overlap between parts (1-2mm)
  attach_ov = min(2, max(1, overlap));

  // --- Attachment positions (recalculated to GUARANTEE intersection) ---
  // Use the hex's *inradius* (across-flats/2) as the contact plane for blocks.
  // This ensures the blocks intersect the hex even at the flats (not just near vertices).
  hex_inr = across_flats/2;

  // Side blocks: inner face at x = +hex_inr - attach_ov  => guaranteed overlap
  side_x = (hex_inr - attach_ov) + tab_x_len/2;

  // Top/bottom blocks: inner face at y = +hex_inr - attach_ov => guaranteed overlap
  cap_y  = (hex_inr - attach_ov) + tab_y_len/2;

  // Build as ONE connected solid (nut body + all flanges) then subtract hole/chamfers
  color("DimGray")
  difference() {
    union() {
      // Hexagonal body
      cylinder(r=hex_r, h=thickness, center=true, $fn=6);

      // Left/right rectangular blocks (ATTACHED with overlap)
      translate([ side_x, 0, 0])
        cube([tab_x_len, tab_y_span, thickness], center=true);
      translate([-side_x, 0, 0])
        cube([tab_x_len, tab_y_span, thickness], center=true);

      // Top/bottom rectangular blocks (ATTACHED with overlap)
      translate([0,  cap_y, 0])
        cube([tab_x_span, tab_y_len, thickness], center=true);
      translate([0, -cap_y, 0])
        cube([tab_x_span, tab_y_len, thickness], center=true);
    }

    // Lead-in chamfers (subtractive) - keep them, but ensure cutters fully span the body
    translate([t_slot_interface_width/2 - edge_chamfer + attach_ov/2, 0, 0])
      cube([edge_chamfer*2, t_slot_interface_height*2, thickness + attach_ov*4], center=true);
    translate([-(t_slot_interface_width/2 - edge_chamfer + attach_ov/2), 0, 0])
      cube([edge_chamfer*2, t_slot_interface_height*2, thickness + attach_ov*4], center=true);
    translate([0, t_slot_interface_height/2 - edge_chamfer + attach_ov/2, 0])
      cube([t_slot_interface_width*2, edge_chamfer*2, thickness + attach_ov*4], center=true);
    translate([0, -(t_slot_interface_height/2 - edge_chamfer + attach_ov/2), 0])
      cube([t_slot_interface_width*2, edge_chamfer*2, thickness + attach_ov*4], center=true);

    // Threaded hole (modeled as clearance cylinder)
    cylinder(r=hole_diameter/2, h=thickness + attach_ov*4, center=true);
  }

  // Washer: keep as separate part by default (not part of "nut" solid)
  // (Structural issues listed are about the flange blocks; washer is not required to be fused.)
  washer_fuse = false;

  washer_z = -(thickness/2 + assembly_gap + washer_thickness/2);
  washer_z_fused = -(thickness/2 + washer_thickness/2 - attach_ov);

  color("Silver")
  if (washer_fuse) {
    // Fused washer (single solid with nut)
    difference() {
      translate([0, 0, washer_z_fused])
        cylinder(r=washer_outer_diameter/2, h=washer_thickness, center=true);
      translate([0, 0, washer_z_fused])
        cylinder(r=(screw_thread_diameter + hole_clearance)/2, h=washer_thickness + attach_ov*4, center=true);
    }
  } else {
    // Non-fused washer (assembly gap preserved)
    difference() {
      translate([0, 0, washer_z])
        cylinder(r=washer_outer_diameter/2, h=washer_thickness, center=true);
      translate([0, 0, washer_z])
        cylinder(r=(screw_thread_diameter + hole_clearance)/2, h=washer_thickness + attach_ov*4, center=true);
    }
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();