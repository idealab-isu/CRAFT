// Parameters
shaft_diameter_mm = 8.0; //[4.0:16.0:0.1]
length_under_head_mm = 10.0; //[5.0:20.0:0.5]
head_diameter_mm = 13.0; //[6.5:26.0:0.1]
head_height_mm = 8.0; //[4.0:16.0:0.1]
socket_across_flats_mm = 6.0; //[3.0:12.0:0.1]
socket_depth_mm = 5.0; //[2.5:10.0:0.1]
under_head_chamfer_height_mm = 1.0; //[0.5:2.0:0.1]
shaft_end_chamfer_height_mm = 1.0; //[0.5:2.0:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]
eps_mm = 0.2; //[0.05:0.5:0.05]
washer_outer_diameter_mm = 16.0; //[8.0:32.0:0.1]
washer_thickness_mm = 1.6; //[0.8:3.2:0.1]
washer_hole_diameter_mm = 8.4; //[4.2:16.8:0.1]
pin_socket_cutout_size_mm = 0.0; //[0.0:20.0:0.5]
pcb_spacer_cutout_size_mm = 0.0; //[0.0:30.0:0.5]
buzzer_cutout_size_mm = 0.0; //[0.0:50.0:0.5]

// Pin Socket - Placeholder geometry (kept, but attached)
module pin_socket() {
  cube([10, 10, 10], center=true);
}

// PCB Spacer - Placeholder geometry (kept, but attached)
module pcb_spacer() {
  cylinder(r=5, h=10, center=true);
}

// Buzzer - Placeholder geometry (kept, but attached)
module buzzer() {
  cylinder(r=10, h=5, center=true);
}

// Screw (single connected solid)
module screw() {

  head_r  = head_diameter_mm/2;
  shaft_r = shaft_diameter_mm/2;

  // Head is centered at z=0
  head_top_z    =  head_height_mm/2;
  head_bottom_z = -head_height_mm/2;

  // Shaft: ensure it overlaps into the under-head chamfer/head by overlap_mm
  shaft_top_z = head_bottom_z + overlap_mm;
  shaft_center_z = shaft_top_z - length_under_head_mm/2;

  // Under-head chamfer: spans from head_bottom_z down to head_bottom_z - under_head_chamfer_height_mm
  // Push it up by overlap_mm so it intersects the head slightly.
  chamfer_center_z = head_bottom_z - under_head_chamfer_height_mm/2 + overlap_mm;

  // Shaft end chamfer (the previously "floating frustum"): place it so its TOP overlaps the shaft bottom
  shaft_bottom_z = shaft_top_z - length_under_head_mm;
  end_chamfer_top_z = shaft_bottom_z + overlap_mm; // overlap into shaft
  end_chamfer_center_z = end_chamfer_top_z - shaft_end_chamfer_height_mm/2;

  // Washer: overlap into underside of head
  washer_center_z = head_bottom_z - washer_thickness_mm/2 + overlap_mm;

  // Attach placeholder parts with overlap into head
  block_size = [10, 10, 10];
  block_center_x = head_r + block_size[0]/2 - overlap_mm;
  block_center_z = 0;

  spacer_r = 5;
  spacer_center_x = -(head_r + spacer_r - overlap_mm);
  spacer_center_z = 0;

  buzzer_h = 5;
  buzzer_center_z = head_top_z + buzzer_h/2 - overlap_mm;

  union() {
    // Main screw body with socket cut
    difference() {
      union() {
        // Cap head
        cylinder(r=head_r, h=head_height_mm, center=true);

        // Shaft
        translate([0, 0, shaft_center_z])
          cylinder(r=shaft_r, h=length_under_head_mm, center=true);

        // Under-head chamfer
        translate([0, 0, chamfer_center_z])
          cylinder(r1=head_r, r2=shaft_r, h=under_head_chamfer_height_mm, center=true);

        // Shaft end chamfer / tip frustum (now physically attached via overlap)
        translate([0, 0, end_chamfer_center_z])
          cylinder(
            r1=shaft_r,
            r2=max(0.01, shaft_r - shaft_end_chamfer_height_mm),
            h=shaft_end_chamfer_height_mm,
            center=true
          );
      }

      // Hex socket cut into head
      translate([0, 0, head_top_z - socket_depth_mm/2])
        cylinder(
          r=socket_across_flats_mm/(2*cos(30)),
          h=socket_depth_mm + eps_mm,
          center=true,
          $fn=6
        );
    }

    // Washer (unioned; overlaps head)
    difference() {
      translate([0, 0, washer_center_z])
        cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
      translate([0, 0, washer_center_z])
        cylinder(r=washer_hole_diameter_mm/2, h=washer_thickness_mm + 2*eps_mm, center=true);
    }

    // Attached placeholder parts (kept connected)
    translate([block_center_x, 0, block_center_z]) pin_socket();
    translate([spacer_center_x, 0, spacer_center_z]) pcb_spacer();
    translate([0, 0, buzzer_center_z]) buzzer();
  }
}

// Output the expected part: screw
screw();