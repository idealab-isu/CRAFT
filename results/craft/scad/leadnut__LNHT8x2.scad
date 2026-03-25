// Leadscrew nut housing block (single connected solid)
// Target outer size: 30.0mm x 34.0mm x 30.0mm

// Parameters
width_mm  = 30; //[15:60:1]
depth_mm  = 34; //[17:68:1]
height_mm = 30; //[15:60:1]

overlap_mm = 1; //[0.5:2:0.1]

nut_outer_diameter_mm      = 22; //[11:44:0.5]
nut_length_mm              = 18; //[9:36:0.5]
nut_cavity_clearance_mm    = 0.5; //[0.2:1.5:0.1]

leadscrew_diameter_mm      = 8; //[4:16:0.5]
leadscrew_clearance_mm     = 0.5; //[0.2:2:0.1]

mounting_hole_diameter_mm  = 4.5; //[2:9:0.1]
mounting_hole_spacing_x_mm = 20; //[10:40:1]
mounting_hole_spacing_y_mm = 24; //[12:48:1]

anti_rotation_slot_width_mm  = 6;  //[3:12:0.5]
anti_rotation_slot_depth_mm  = 3;  //[1:8:0.5]
anti_rotation_slot_height_mm = 14; //[6:28:0.5]

// Housing only (no separate nut or leadscrew geometry)
module nut_housing_block() {

  // Derived / clamped values to keep booleans valid and visible in all views
  nut_r = nut_outer_diameter_mm/2 + nut_cavity_clearance_mm;
  lead_r = leadscrew_diameter_mm/2 + leadscrew_clearance_mm;

  // Keep pocket within block
  pocket_h = min(nut_length_mm, height_mm - 2*overlap_mm);
  pocket_h = max(pocket_h, 0.1);

  // Pocket is a blind pocket from the TOP face
  // With center=true block, top face is at +height_mm/2.
  // Place pocket center at: top - pocket_h/2 (and overlap slightly into top for robust boolean)
  pocket_z = height_mm/2 - pocket_h/2 + overlap_mm;

  // Leadscrew hole should go THROUGH the entire block (not just within pocket),
  // so top/bottom views are not "blank" due to coplanar/degenerate subtraction.
  through_h = height_mm + 4*overlap_mm;

  // Anti-rotation slot height limited to pocket height
  slot_h = min(anti_rotation_slot_height_mm, pocket_h);
  slot_h = max(slot_h, 0.1);

  // Slot positioned to intersect the cavity and extend outward
  slot_x_center = nut_r + anti_rotation_slot_depth_mm/2 - overlap_mm;

  difference() {
    // Main 30x34x30 block
    cube([width_mm, depth_mm, height_mm], center=true);

    // Nut cavity (blind pocket from top face)
    translate([0, 0, pocket_z])
      cylinder(r=nut_r, h=pocket_h + 2*overlap_mm, center=true, $fn=96);

    // Leadscrew clearance hole THROUGH the block
    cylinder(r=lead_r, h=through_h, center=true, $fn=96);

    // Anti-rotation slot (connected to nut cavity, within pocket height)
    translate([slot_x_center, 0, pocket_z])
      cube([anti_rotation_slot_depth_mm + 2*overlap_mm,
            anti_rotation_slot_width_mm,
            slot_h + 2*overlap_mm], center=true);

    // Mounting holes through the block (Z direction)
    for (x = [-1, 1], y = [-1, 1])
      translate([x * mounting_hole_spacing_x_mm/2,
                 y * mounting_hole_spacing_y_mm/2,
                 0])
        cylinder(r=mounting_hole_diameter_mm/2,
                 h=through_h,
                 center=true,
                 $fn=64);
  }
}

nut_housing_block();