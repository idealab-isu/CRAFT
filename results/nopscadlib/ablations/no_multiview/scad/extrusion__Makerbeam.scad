// Parameters
cross_section_width_mm = 10; //[5:20:0.5]
cross_section_height_mm = 10; //[5:20:0.5]
length_mm = 100; //[50:200:1]
t_slot_opening_width_mm = 3; //[1.5:6:0.25]
t_slot_inner_width_mm = 6; //[3:9:0.25]
t_slot_depth_mm = 2.5; //[1:4.5:0.25]
t_slot_neck_depth_mm = 1.2; //[0.5:2.5:0.1]
center_bore_diameter_mm = 4.2; //[2:7:0.1]
corner_hole_diameter_mm = 2.5; //[1.5:4:0.1]
corner_hole_inset_mm = 2.2; //[1.2:4:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// --- Helper: small "rectangular pieces" that must be attached to the extrusion ends ---
// These are thin tabs that overlap into the extrusion by overlap_mm to guarantee connection.
module end_tabs(z_sign=+1, tab_count=3) {
  tab_thickness = 2;                 // thickness along Z
  tab_len_y = 6;                     // length along Y (visible in top view)
  tab_w_x = 8;                       // width along X
  tab_gap_y = 1.5;                   // spacing between tabs along Y

  // Place tabs just beyond the end face, but overlapping into the extrusion by overlap_mm.
  // Extrusion spans Z = [-length/2, +length/2]
  z_center = z_sign * (length_mm/2 + tab_thickness/2 - overlap_mm);

  // Center the 3 tabs as a group around Y=0
  total_span = tab_count*tab_len_y + (tab_count-1)*tab_gap_y;
  y0 = -total_span/2 + tab_len_y/2;

  for (i = [0:tab_count-1]) {
    translate([0, y0 + i*(tab_len_y + tab_gap_y), z_center])
      cube([tab_w_x, tab_len_y, tab_thickness], center=true);
  }
}

// Extrusion - complete detailed geometry
module extrusion() {
  color("Silver") {
    union() {
      // Main extrusion body (with cuts)
      difference() {
        // Outer extrusion body
        cube([cross_section_width_mm, cross_section_height_mm, length_mm], center=true);

        // T-slot cuts
        union() {
          // Positive X neck and inner
          translate([cross_section_width_mm/2 - (t_slot_neck_depth_mm + overlap_mm)/2, 0, 0])
            cube([t_slot_neck_depth_mm + overlap_mm, t_slot_opening_width_mm, length_mm + overlap_mm], center=true);
          translate([cross_section_width_mm/2 - t_slot_neck_depth_mm - ((t_slot_depth_mm - t_slot_neck_depth_mm) + overlap_mm)/2, 0, 0])
            cube([(t_slot_depth_mm - t_slot_neck_depth_mm) + overlap_mm, t_slot_inner_width_mm, length_mm + overlap_mm], center=true);

          // Negative X neck and inner
          translate([-cross_section_width_mm/2 + (t_slot_neck_depth_mm + overlap_mm)/2, 0, 0])
            cube([t_slot_neck_depth_mm + overlap_mm, t_slot_opening_width_mm, length_mm + overlap_mm], center=true);
          translate([-cross_section_width_mm/2 + t_slot_neck_depth_mm + ((t_slot_depth_mm - t_slot_neck_depth_mm) + overlap_mm)/2, 0, 0])
            cube([(t_slot_depth_mm - t_slot_neck_depth_mm) + overlap_mm, t_slot_inner_width_mm, length_mm + overlap_mm], center=true);

          // Positive Y neck and inner
          translate([0, cross_section_height_mm/2 - (t_slot_neck_depth_mm + overlap_mm)/2, 0])
            cube([t_slot_opening_width_mm, t_slot_neck_depth_mm + overlap_mm, length_mm + overlap_mm], center=true);
          translate([0, cross_section_height_mm/2 - t_slot_neck_depth_mm - ((t_slot_depth_mm - t_slot_neck_depth_mm) + overlap_mm)/2, 0])
            cube([t_slot_inner_width_mm, (t_slot_depth_mm - t_slot_neck_depth_mm) + overlap_mm, length_mm + overlap_mm], center=true);

          // Negative Y neck and inner
          translate([0, -cross_section_height_mm/2 + (t_slot_neck_depth_mm + overlap_mm)/2, 0])
            cube([t_slot_opening_width_mm, t_slot_neck_depth_mm + overlap_mm, length_mm + overlap_mm], center=true);
          translate([0, -cross_section_height_mm/2 + t_slot_neck_depth_mm + ((t_slot_depth_mm - t_slot_neck_depth_mm) + overlap_mm)/2, 0])
            cube([t_slot_inner_width_mm, (t_slot_depth_mm - t_slot_neck_depth_mm) + overlap_mm, length_mm + overlap_mm], center=true);
        }

        // Center bore
        cylinder(r=center_bore_diameter_mm/2, h=length_mm + overlap_mm, center=true);

        // Corner holes
        union() {
          translate([cross_section_width_mm/2 - corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + overlap_mm, center=true);
          translate([-cross_section_width_mm/2 + corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + overlap_mm, center=true);
          translate([-cross_section_width_mm/2 + corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + overlap_mm, center=true);
          translate([cross_section_width_mm/2 - corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + overlap_mm, center=true);
        }
      }

      // --- FIX: attach the "three small rectangular pieces" to BOTH ends of the extrusion ---
      // Top view showed floating pieces above and below; these are now physically connected
      // by overlapping into the extrusion by overlap_mm.
      end_tabs(+1, 3);  // above / +Z end
      end_tabs(-1, 3);  // below / -Z end
    }
  }
}

// Extrusion Cross Section - detailed geometry (kept for reference; not used in final solid)
module extrusion_cross_section() {
  color("Silver") {
    difference() {
      square([cross_section_width_mm, cross_section_height_mm], center=true);

      union() {
        translate([cross_section_width_mm/2 - (t_slot_neck_depth_mm + overlap_mm)/2, 0])
          square([t_slot_neck_depth_mm + overlap_mm, t_slot_opening_width_mm], center=true);
        translate([cross_section_width_mm/2 - t_slot_neck_depth_mm - ((t_slot_depth_mm - t_slot_neck_depth_mm) + overlap_mm)/2, 0])
          square([(t_slot_depth_mm - t_slot_neck_depth_mm) + overlap_mm, t_slot_inner_width_mm], center=true);

        translate([-cross_section_width_mm/2 + (t_slot_neck_depth_mm + overlap_mm)/2, 0])
          square([t_slot_neck_depth_mm + overlap_mm, t_slot_opening_width_mm], center=true);
        translate([-cross_section_width_mm/2 + t_slot_neck_depth_mm + ((t_slot_depth_mm - t_slot_neck_depth_mm) + overlap_mm)/2, 0])
          square([(t_slot_depth_mm - t_slot_neck_depth_mm) + overlap_mm, t_slot_inner_width_mm], center=true);

        translate([0, cross_section_height_mm/2 - (t_slot_neck_depth_mm + overlap_mm)/2])
          square([t_slot_opening_width_mm, t_slot_neck_depth_mm + overlap_mm], center=true);
        translate([0, cross_section_height_mm/2 - t_slot_neck_depth_mm - ((t_slot_depth_mm - t_slot_neck_depth_mm) + overlap_mm)/2])
          square([t_slot_inner_width_mm, (t_slot_depth_mm - t_slot_neck_depth_mm) + overlap_mm], center=true);

        translate([0, -cross_section_height_mm/2 + (t_slot_neck_depth_mm + overlap_mm)/2])
          square([t_slot_opening_width_mm, t_slot_neck_depth_mm + overlap_mm], center=true);
        translate([0, -cross_section_height_mm/2 + t_slot_neck_depth_mm + ((t_slot_depth_mm - t_slot_neck_depth_mm) + overlap_mm)/2])
          square([t_slot_inner_width_mm, (t_slot_depth_mm - t_slot_neck_depth_mm) + overlap_mm], center=true);
      }

      circle(r=center_bore_diameter_mm/2);

      union() {
        translate([cross_section_width_mm/2 - corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm])
          circle(r=corner_hole_diameter_mm/2);
        translate([-cross_section_width_mm/2 + corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm])
          circle(r=corner_hole_diameter_mm/2);
        translate([-cross_section_width_mm/2 + corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm])
          circle(r=corner_hole_diameter_mm/2);
        translate([cross_section_width_mm/2 - corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm])
          circle(r=corner_hole_diameter_mm/2);
      }
    }
  }
}

// Assembly: output a single connected solid (extrusion + attached tabs)
module assembly() {
  extrusion();
}

assembly();