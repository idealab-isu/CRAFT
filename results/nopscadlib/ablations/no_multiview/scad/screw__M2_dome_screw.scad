// Parameters
shaft_diameter_mm = 2.0; //[1.0:4.0:0.1]
length_mm = 10.0; //[5.0:20.0:0.5]
head_diameter_mm = 3.5; //[2.0:7.0:0.1]
head_height_mm = 1.3; //[0.7:2.6:0.05]
thread_length_mm = 10.0; //[5.0:20.0:0.5]
thread_depth_mm = 0.15; //[0.05:0.4:0.01]
thread_pitch_mm = 0.4; //[0.25:0.8:0.05]
washer_outer_diameter_mm = 5.0; //[3.0:10.0:0.1]
washer_thickness_mm = 0.6; //[0.3:1.5:0.05]
washer_hole_clearance_mm = 0.2; //[0.0:0.6:0.05]
spacer_height_mm = 6.0; //[3.0:15.0:0.5]
spacer_wall_mm = 1.8; //[0.8:3.6:0.1]
buzzer_diameter_mm = 12.0; //[6.0:24.0:0.5]
buzzer_height_mm = 5.0; //[2.5:12.0:0.5]
buzzer_post_diameter_mm = 2.5; //[1.5:5.0:0.1]
buzzer_post_height_mm = 2.0; //[1.0:6.0:0.5]

// Use 1–2mm overlap to guarantee watertight connections
overlap_mm = 1.2; //[0.5:2.0:0.1]

// Extra part seen in the views: hex/cylindrical collar (light gray block)
collar_flat_to_flat_mm = 4.6;
collar_height_mm       = 2.2;
collar_rounding_mm     = 0.0;

$fn = 96;

// Helpers
function hex_r_from_flat(flat) = flat / sqrt(3); // circumradius for a hex with given flat-to-flat

// Screw and Washer - fixed connectivity (single union solid)
module screw_and_washer() {

  // Coordinate system:
  // z=0 is the underside of the head (top of shaft).
  // Shaft extends downward (negative z).
  // Head extends upward (positive z).
  // Washer sits just under the head and overlaps the shaft slightly.

  shaft_r = shaft_diameter_mm/2;
  head_r  = head_diameter_mm/2;

  // Shaft: top at z=0, bottom at z=-length_mm
  shaft_center_z = -length_mm/2;

  // Dome head: spherical cap that spans slightly below z=0 for overlap into shaft
  sphere_center_z = head_height_mm - head_r;

  // Collar: MUST be under the head (negative z) and overlap into head/shaft
  collar_h = collar_height_mm;
  collar_top_z = overlap_mm;                 // penetrates into head region by overlap_mm
  collar_bottom_z = collar_top_z - collar_h; // extends downward
  collar_center_z = (collar_top_z + collar_bottom_z)/2;

  // Washer: under head, overlapping shaft/collar
  washer_h = washer_thickness_mm;
  washer_top_z = overlap_mm;                 // penetrates into head region by overlap_mm
  washer_bottom_z = washer_top_z - washer_h;
  washer_center_z = (washer_top_z + washer_bottom_z)/2;

  union() {

    // Screw (head + shaft + collar + thread shell) as one connected solid
    color("DimGray")
    union() {

      // Shaft (top at z=0)
      translate([0,0,shaft_center_z])
        cylinder(h=length_mm, r=shaft_r, center=true);

      // Dome head cap: slab from z=-overlap_mm to z=head_height_mm
      // ensures physical intersection with shaft (no visible gap)
      intersection() {
        translate([0,0,sphere_center_z])
          sphere(r=head_r, center=true);

        translate([0,0,(head_height_mm - overlap_mm)/2])
          cube([head_diameter_mm*3, head_diameter_mm*3, head_height_mm + overlap_mm], center=true);
      }

      // Hex collar: placed directly under head, overlapping into head and onto shaft
      translate([0,0,collar_center_z])
        cylinder(h=collar_h, r=hex_r_from_flat(collar_flat_to_flat_mm), $fn=6, center=true);

      // Thread representation (thin shell) - overlaps shaft so it cannot float
      // Top at z=0, extends down thread_length_mm
      thread_center_z = -thread_length_mm/2;
      difference() {
        translate([0,0,thread_center_z])
          cylinder(h=thread_length_mm, r=shaft_r + thread_depth_mm, center=true);
        translate([0,0,thread_center_z])
          cylinder(h=thread_length_mm + overlap_mm*2, r=shaft_r, center=true);
      }
    }

    // Washer: part of same union and overlaps shaft/collar/head underside
    color("Silver")
    difference() {
      translate([0,0,washer_center_z])
        cylinder(h=washer_h, r=washer_outer_diameter_mm/2, center=true);
      translate([0,0,washer_center_z])
        cylinder(h=washer_h + overlap_mm*2, r=(shaft_diameter_mm + washer_hole_clearance_mm)/2, center=true);
    }
  }
}

// PCB Spacer - connected to washer via overlap
module pcb_spacer() {
  // Washer bottom z:
  washer_top_z = overlap_mm;
  washer_bottom_z = washer_top_z - washer_thickness_mm;

  // Spacer top overlaps into washer by overlap_mm
  spacer_h = spacer_height_mm;
  spacer_top_z = washer_bottom_z + overlap_mm;
  spacer_bottom_z = spacer_top_z - spacer_h;
  spacer_center_z = (spacer_top_z + spacer_bottom_z)/2;

  color("Silver")
  difference() {
    translate([0,0,spacer_center_z])
      cylinder(h=spacer_h, r=(shaft_diameter_mm + washer_hole_clearance_mm)/2 + spacer_wall_mm, center=true);
    translate([0,0,spacer_center_z])
      cylinder(h=spacer_h + overlap_mm*2, r=(shaft_diameter_mm + washer_hole_clearance_mm)/2, center=true);
  }
}

// Buzzer - connected to spacer via overlap
module buzzer() {
  // Washer bottom z:
  washer_top_z = overlap_mm;
  washer_bottom_z = washer_top_z - washer_thickness_mm;

  // Spacer geometry (must match pcb_spacer placement)
  spacer_top_z = washer_bottom_z + overlap_mm;
  spacer_bottom_z = spacer_top_z - spacer_height_mm;

  // Post: top overlaps into spacer by overlap_mm
  post_h = buzzer_post_height_mm;
  post_top_z = spacer_bottom_z + overlap_mm;
  post_bottom_z = post_top_z - post_h;
  post_center_z = (post_top_z + post_bottom_z)/2;

  // Body: top overlaps into post by overlap_mm
  body_h = buzzer_height_mm;
  body_top_z = post_bottom_z + overlap_mm;
  body_bottom_z = body_top_z - body_h;
  body_center_z = (body_top_z + body_bottom_z)/2;

  color("Black")
  union() {
    translate([0,0,post_center_z])
      cylinder(h=post_h, r=buzzer_post_diameter_mm/2, center=true);

    translate([0,0,body_center_z])
      cylinder(h=body_h, r=buzzer_diameter_mm/2, center=true);
  }
}

// Assembly - single connected union (all parts physically intersect)
module assembly() {
  union() {
    screw_and_washer();  // screw (head+shaft+collar+thread) + washer
    pcb_spacer();        // spacer overlaps washer
    buzzer();            // post overlaps spacer; body overlaps post
  }
}

assembly();