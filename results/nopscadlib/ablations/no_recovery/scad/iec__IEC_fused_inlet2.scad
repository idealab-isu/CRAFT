// Parameters
cutout_width_mm = 36; //[18:72:0.1]
cutout_height_mm = 27; //[13.5:54:0.1]
panel_thickness_mm = 2; //[1:6:0.1]
clearance_mm = 0.2; //[0:1:0.05]
include_mounting_holes = 0; //[0:1:1]
mounting_hole_diameter_mm = 3.2; //[2:6.4:0.1]
mounting_hole_pitch_x_mm = 40; //[20:80:0.1]
mounting_hole_pitch_y_mm = 0; //[0:40:0.1]
include_flange_clearance = 1; //[0:1:1]
flange_width_mm = 50; //[30:100:0.1]
flange_height_mm = 35; //[20:70:0.1]
panel_margin_mm = 12; //[6:30:0.5]
envelope_thickness_mm = 0.8; //[0.4:3:0.1]
carrier_web_thickness_mm = 0.8; //[0.4:3:0.1]
overlap_mm = 1; //[0.5:2:0.1]
iec_body_depth_mm = 25; //[12:60:0.5]
iec_body_clearance_mm = 1; //[0:5:0.1]
mod_block_depth_mm = 18; //[8:50:0.5]

// IEC Module - complete geometry
module iec() {
  color("DimGray") {
    // IEC Body
    cube([cutout_width_mm + 2*iec_body_clearance_mm, 
          cutout_height_mm + 2*iec_body_clearance_mm, 
          iec_body_depth_mm], center=true);
  }
}

// Mod Module - complete geometry
module mod() {
  color("Black") {
    // Mod Block
    cube([(cutout_width_mm + 2*iec_body_clearance_mm) * 0.9, 
          (cutout_height_mm + 2*iec_body_clearance_mm) * 0.9, 
          mod_block_depth_mm], center=true);
  }
}

// Panel with cutouts
module panel_with_cutouts() {
  color("Silver") {
    difference() {
      // Panel Reference Face
      cube([cutout_width_mm + 2*panel_margin_mm, 
            cutout_height_mm + 2*panel_margin_mm, 
            panel_thickness_mm], center=true);
      // Panel Cutout Rect
      translate([0, 0, 0])
        cube([cutout_width_mm + 2*clearance_mm, 
              cutout_height_mm + 2*clearance_mm, 
              panel_thickness_mm + 2*overlap_mm], center=true);
      // Mounting Holes
      if (include_mounting_holes) {
        translate([mounting_hole_pitch_x_mm/2, mounting_hole_pitch_y_mm/2, 0])
          cylinder(h=panel_thickness_mm + 2*overlap_mm, 
                   r=(mounting_hole_diameter_mm + 2*clearance_mm)/2, center=true);
        translate([-mounting_hole_pitch_x_mm/2, -mounting_hole_pitch_y_mm/2, 0])
          cylinder(h=panel_thickness_mm + 2*overlap_mm, 
                   r=(mounting_hole_diameter_mm + 2*clearance_mm)/2, center=true);
      }
    }
  }
}

// Flange Clearance Envelope
module flange_clearance_envelope() {
  if (include_flange_clearance) {
    color("Silver") {
      translate([0, 0, panel_thickness_mm/2 + envelope_thickness_mm/2 - overlap_mm])
        cube([flange_width_mm + 2*clearance_mm, 
              flange_height_mm + 2*clearance_mm, 
              envelope_thickness_mm], center=true);
    }
  }
}

// Carrier Web
module carrier_web() {
  color("Silver") {
    translate([0, 0, (envelope_thickness_mm - iec_body_depth_mm - mod_block_depth_mm)/2])
      cube([carrier_web_thickness_mm, 
            carrier_web_thickness_mm, 
            panel_thickness_mm + envelope_thickness_mm + iec_body_depth_mm + mod_block_depth_mm], center=true);
  }
}

// Assembly
module assembly() {
  panel_with_cutouts();
  flange_clearance_envelope();
  translate([0, 0, -panel_thickness_mm/2 - iec_body_depth_mm/2 + overlap_mm]) iec();
  translate([0, 0, -panel_thickness_mm/2 - iec_body_depth_mm - mod_block_depth_mm/2 + 2*overlap_mm]) mod();
  carrier_web();
}

assembly();