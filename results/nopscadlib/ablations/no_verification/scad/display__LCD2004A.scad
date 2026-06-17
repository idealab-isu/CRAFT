$fn = 64;

// =====================
// LCD 2004A-like module
// Overall: 97.0mm x 39.5mm
// ONE connected solid (single difference() over a union())
// =====================

// Parameters (mm)
module_width_mm  = 97.0;
module_height_mm = 39.5;
module_thickness_mm = 12.0;

pcb_thickness_mm   = 1.6;
bezel_thickness_mm = 2.0;

// Typical-ish 2004A viewing window (approx; adjustable)
aperture_width_mm  = 76.0;
aperture_height_mm = 25.0;
aperture_offset_x_mm = 0.0;
aperture_offset_y_mm = 2.0;   // slightly above center like many 2004A layouts

mount_hole_diameter_mm = 3.2;
mount_hole_edge_margin_mm = 3.0;

boss_outer_diameter_mm = 7.0;
boss_height_mm = 3.0;

pin_header_pitch_mm = 2.54;
pin_header_pins = 16;

header_block_height_mm = 4.0;
header_block_depth_mm  = 6.0;
header_block_width_margin_mm = 6.0;

pin_d_mm   = 1.0;
pin_len_mm = 2.5;

display_glass_thickness_mm = 1.5;
display_glass_inset_mm = 0.6;

// Extra recognizable front details
bezel_frame_inset_mm = 2.0;
bezel_frame_raise_mm = 0.9;

inner_bezel_inset_mm = 6.0;     // inner "black mask" area around window
inner_bezel_raise_mm = 0.6;

active_area_margin_mm = 3.0;    // smaller "active" recess inside window
active_recess_mm = 0.4;

// Back-side details (connected)
back_bump_w = 34.0;
back_bump_h = 14.0;
back_bump_t = 3.0;

ic_bump_w = 18.0;
ic_bump_h = 10.0;
ic_bump_t = 2.2;

overlap_mm = 1.0;

// Derived Z layout (centered overall)
front_face_z =  module_thickness_mm/2;
back_face_z  = -module_thickness_mm/2;

bezel_center_z = front_face_z - bezel_thickness_mm/2 + overlap_mm*0.25;
pcb_center_z   = back_face_z  - pcb_thickness_mm/2   + overlap_mm*0.25;

// Glass sits behind bezel, inside aperture
glass_center_z = (front_face_z - bezel_thickness_mm) - display_glass_inset_mm - display_glass_thickness_mm/2;

// Mount hole XY positions
hole_x = module_width_mm/2  - mount_hole_edge_margin_mm - mount_hole_diameter_mm/2;
hole_y = module_height_mm/2 - mount_hole_edge_margin_mm - mount_hole_diameter_mm/2;

// Header block width and placement (near bottom edge on back)
header_block_w = (pin_header_pins - 1) * pin_header_pitch_mm + header_block_width_margin_mm;
header_block_center_y = -module_height_mm/2 + header_block_depth_mm/2 + overlap_mm;

// Header block sits on back side of PCB and overlaps into PCB for connectivity
header_block_center_z = (pcb_center_z - pcb_thickness_mm/2) - header_block_height_mm/2 + overlap_mm;

// Pin stubs protrude below header block, but overlap into it for connectivity
pin_center_z = (header_block_center_z - header_block_height_mm/2) - pin_len_mm/2 + overlap_mm;

// Front raised frame
bezel_frame_center_z = front_face_z + bezel_frame_raise_mm/2 - overlap_mm*0.25;

// Inner bezel mask (raised slightly, around aperture)
inner_bezel_center_z = front_face_z + inner_bezel_raise_mm/2 - overlap_mm*0.25;

// Back bumps (connected to PCB)
back_bump_center_z = (pcb_center_z - pcb_thickness_mm/2) - back_bump_t/2 + overlap_mm;
ic_bump_center_z   = (pcb_center_z - pcb_thickness_mm/2) - ic_bump_t/2   + overlap_mm;

// Back bump positions (keep within board outline)
back_bump_center_x = 0;
back_bump_center_y = 4.0;

ic_bump_center_x = module_width_mm/2 - (ic_bump_w/2 + 10.0);
ic_bump_center_y = 6.0;

// Helper: rounded rectangle prism (for nicer bezel/window)
module rrect_prism(size=[10,10,1], r=1, center=true) {
  w=size[0]; h=size[1]; t=size[2];
  translate(center ? [0,0,0] : [w/2,h/2,t/2])
    linear_extrude(height=t, center=true)
      offset(r=r)
        square([w-2*r, h-2*r], center=true);
}

module lcd2004a_connected() {
  color([0.85, 0.85, 0.8])
  difference() {
    union() {
      // Main body (overall thickness envelope)
      cube([module_width_mm, module_height_mm, module_thickness_mm], center=true);

      // Front bezel plate (overlaps into body)
      translate([0, 0, bezel_center_z])
        cube([module_width_mm, module_height_mm, bezel_thickness_mm], center=true);

      // Raised outer bezel frame (front detail)
      difference() {
        translate([0, 0, bezel_frame_center_z])
          cube([module_width_mm, module_height_mm, bezel_frame_raise_mm], center=true);
        translate([0, 0, bezel_frame_center_z])
          cube([module_width_mm - 2*bezel_frame_inset_mm,
                module_height_mm - 2*bezel_frame_inset_mm,
                bezel_frame_raise_mm + overlap_mm*2], center=true);
      }

      // Inner bezel mask area (front detail around window)
      difference() {
        translate([0, 0, inner_bezel_center_z])
          cube([module_width_mm - 2*inner_bezel_inset_mm,
                module_height_mm - 2*inner_bezel_inset_mm,
                inner_bezel_raise_mm], center=true);

        // Cut the viewing window out of the inner mask too (so it frames the aperture)
        translate([aperture_offset_x_mm, aperture_offset_y_mm, inner_bezel_center_z])
          rrect_prism([aperture_width_mm, aperture_height_mm, inner_bezel_raise_mm + overlap_mm*2],
                      r=1.2, center=true);
      }

      // Display glass (slightly overlaps into bezel region for connectivity)
      translate([aperture_offset_x_mm, aperture_offset_y_mm, glass_center_z])
        rrect_prism([aperture_width_mm - overlap_mm*2,
                     aperture_height_mm - overlap_mm*2,
                     display_glass_thickness_mm],
                    r=1.0, center=true);

      // Rear PCB (overlaps into body)
      translate([0, 0, pcb_center_z])
        cube([module_width_mm, module_height_mm, pcb_thickness_mm], center=true);

      // Back-side component bump (connected to PCB)
      translate([back_bump_center_x, back_bump_center_y, back_bump_center_z])
        cube([back_bump_w, back_bump_h, back_bump_t], center=true);

      // Smaller IC bump (connected to PCB)
      translate([ic_bump_center_x, ic_bump_center_y, ic_bump_center_z])
        cube([ic_bump_w, ic_bump_h, ic_bump_t], center=true);

      // Standoff bosses (connected to back face region)
      for (xsgn = [-1, 1], ysgn = [-1, 1]) {
        translate([xsgn*hole_x, ysgn*hole_y, back_face_z + boss_height_mm/2 - overlap_mm])
          cylinder(r=boss_outer_diameter_mm/2, h=boss_height_mm, center=true);
      }

      // Header block (connected to PCB)
      translate([0, header_block_center_y, header_block_center_z])
        cube([header_block_w, header_block_depth_mm, header_block_height_mm], center=true);

      // Pin stubs (embedded into header block for connectivity)
      for (i = [0:pin_header_pins-1]) {
        xpin = -((pin_header_pins-1)*pin_header_pitch_mm)/2 + i*pin_header_pitch_mm;
        translate([xpin, header_block_center_y, pin_center_z])
          cylinder(d=pin_d_mm, h=pin_len_mm, center=true);
      }
    }

    // ===== Subtractions (do not disconnect the solid) =====

    // Viewing aperture through bezel (and slightly into body)
    translate([aperture_offset_x_mm, aperture_offset_y_mm, bezel_center_z])
      rrect_prism([aperture_width_mm, aperture_height_mm, bezel_thickness_mm + overlap_mm*4],
                  r=1.2, center=true);

    // Active area recess inside the window (front distinct detail)
    // (A shallow pocket in the glass area; does not cut through)
    translate([aperture_offset_x_mm, aperture_offset_y_mm, glass_center_z + display_glass_thickness_mm/2 - active_recess_mm/2])
      rrect_prism([aperture_width_mm - 2*active_area_margin_mm,
                   aperture_height_mm - 2*active_area_margin_mm,
                   active_recess_mm + overlap_mm*0.5],
                  r=0.8, center=true);

    // Mounting holes through entire stack
    hole_h = module_thickness_mm + pcb_thickness_mm + bezel_thickness_mm + boss_height_mm + overlap_mm*10;
    for (xsgn = [-1, 1], ysgn = [-1, 1]) {
      translate([xsgn*hole_x, ysgn*hole_y, 0])
        cylinder(d=mount_hole_diameter_mm, h=hole_h, center=true);
    }
  }
}

lcd2004a_connected();