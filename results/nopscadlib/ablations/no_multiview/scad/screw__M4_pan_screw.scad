// Parameters
shaft_diameter_mm = 4; //[2:8:0.1]
length_under_head_mm = 10; //[5:20:0.5]
head_diameter_mm = 7.8; //[4:15.6:0.1]
head_height_mm = 3.3; //[1.6:6.6:0.1]
overlap_mm = 1.2; //[0.2:2:0.1]   // use 1-2mm overlap for reliable fusion
threaded = 1; //[0:1:1]
thread_pitch_mm = 0.7; //[0.4:1.2:0.05]
thread_depth_mm = 0.25; //[0.1:0.6:0.05]
drive_socket_radius_factor = 0.6; //[0.4:0.8:0.05]
drive_socket_depth_factor = 0.5; //[0.3:0.8:0.05]
drive_slot_width_mm = 1; //[0.6:2:0.1]

// Added parts (to match the reported floating pieces)
washer_outer_d_mm = 20;          // blue circular base/washer-like disk
washer_thickness_mm = 5;

sleeve_outer_w_mm = 6;           // beige rectangular sleeve/spacer around shaft
sleeve_outer_d_mm = 6;
sleeve_height_mm  = 10;

// Screw (shaft + head) as a single solid
module screw_solid() {
  union() {
    // Shaft (under-head) - top of shaft overlaps into head by overlap_mm
    translate([0, 0, -(head_height_mm/2 + length_under_head_mm/2 - overlap_mm)])
      cylinder(r=shaft_diameter_mm/2, h=length_under_head_mm, center=true);

    // Optional simplified thread ridges (kept, but ensured to overlap the shaft)
    if (threaded) {
      union() {
        translate([0, 0, -(head_height_mm/2 + length_under_head_mm/2 - overlap_mm)])
          cylinder(r=shaft_diameter_mm/2 - thread_depth_mm,
                   h=length_under_head_mm + overlap_mm*2, center=true);

        for (i = [0:19]) {
          translate([0, 0, -(head_height_mm/2 + length_under_head_mm - overlap_mm) + thread_pitch_mm*i])
            scale([1, 1, thread_pitch_mm/(head_diameter_mm)])
              rotate_extrude()
                translate([shaft_diameter_mm/2 - thread_depth_mm/2, 0])
                  circle(r=thread_depth_mm/2);
        }
      }
    }

    // Head (pan-ish)
    translate([0,0,0])
    difference() {
      intersection() {
        cylinder(r=head_diameter_mm/2, h=head_height_mm, center=true);
        translate([0, 0, head_height_mm/2 - (head_diameter_mm/2)])
          sphere(r=head_diameter_mm/2);
        cube([head_diameter_mm*3, head_diameter_mm*3, head_height_mm], center=true);
      }
      union() {
        translate([0, 0, head_height_mm/2 - (head_height_mm*drive_socket_depth_factor)/2])
          cylinder(r=(head_diameter_mm/2)*drive_socket_radius_factor,
                   h=head_height_mm*drive_socket_depth_factor + overlap_mm*2, center=true);

        translate([0, 0, head_height_mm/2 - (head_height_mm*drive_socket_depth_factor)/2])
          cube([(head_diameter_mm/2)*drive_socket_radius_factor*2 + overlap_mm*2,
                drive_slot_width_mm,
                head_height_mm*drive_socket_depth_factor + overlap_mm*2], center=true);

        translate([0, 0, head_height_mm/2 - (head_height_mm*drive_socket_depth_factor)/2])
          cube([drive_slot_width_mm,
                (head_diameter_mm/2)*drive_socket_radius_factor*2 + overlap_mm*2,
                head_height_mm*drive_socket_depth_factor + overlap_mm*2], center=true);
      }
    }
  }
}

// Blue circular base/washer-like disk (must be attached)
module base_disk_solid() {
  cylinder(r=washer_outer_d_mm/2, h=washer_thickness_mm, center=true);
}

// Beige rectangular sleeve/spacer around the shaft (must be attached)
module sleeve_solid() {
  difference() {
    cube([sleeve_outer_w_mm, sleeve_outer_d_mm, sleeve_height_mm], center=true);
    // through-hole for shaft, slightly oversized and extended to avoid coplanar faces
    cylinder(r=shaft_diameter_mm/2 + 0.2, h=sleeve_height_mm + overlap_mm*2, center=true);
  }
}

// Connected assembly: screw + sleeve + base disk as ONE unioned solid
module screw_with_attached_parts() {

  // --- Z references for the screw as built in screw_solid() ---
  // Head spans: [-head_height/2 .. +head_height/2]
  // Shaft is centered at: z = -(head_height/2 + length/2 - overlap)
  // Therefore shaft bottom is at:
  shaft_center_z = -(head_height_mm/2 + length_under_head_mm/2 - overlap_mm);
  shaft_bottom_z = shaft_center_z - length_under_head_mm/2;

  // --- Place base disk so its TOP intersects the shaft bottom by overlap_mm ---
  // disk_top_z = disk_center_z + washer_thickness/2 = shaft_bottom_z + overlap
  disk_center_z = (shaft_bottom_z + overlap_mm) - washer_thickness_mm/2;
  disk_top_z    = disk_center_z + washer_thickness_mm/2;

  // --- Place sleeve so its BOTTOM intersects the disk TOP by overlap_mm ---
  // sleeve_bottom_z = sleeve_center_z - sleeve_height/2 = disk_top_z - overlap
  sleeve_center_z = (disk_top_z - overlap_mm) + sleeve_height_mm/2;

  union() {
    color("Silver") screw_solid();

    // Attached sleeve (beige) - overlaps disk and surrounds shaft
    color([0.85, 0.85, 0.8])
      translate([0, 0, sleeve_center_z])
        sleeve_solid();

    // Attached base disk (blue) - overlaps shaft bottom (no gap)
    color([0.1, 0.1, 0.6])
      translate([0, 0, disk_center_z])
        base_disk_solid();
  }
}

// Keep original extra modules (not used in final unioned screw, but left intact)
module pcb_spacer() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      cylinder(r=3, h=10, center=true);
      translate([0, 0, -5])
        cylinder(r=1.5, h=10, center=true);
    }
  }
}

module buzzer() {
  color([0.1, 0.1, 0.6]) {
    union() {
      cylinder(r=10, h=5, center=true);
      translate([0, 0, 2.5])
        cylinder(r=8, h=1, center=true);
    }
  }
}

// Final: single connected solid for the screw assembly (no floating disk/sleeve)
screw_with_attached_parts();