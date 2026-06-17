$fn = 64;

// Parameters
width_mm = 84.5; //[42.25:169:0.1]
height_mm = 54.5; //[27.25:109:0.1]
thickness_mm = 8; //[4:16:0.1]
corner_radius_mm = 3; //[1.5:6:0.1]
front_face_thickness_mm = 1.5; //[0.75:3:0.1]
pcb_thickness_mm = 1.6; //[0.8:3.2:0.1]
aperture_width_mm = 70; //[35:80:0.1]
aperture_height_mm = 40; //[20:50:0.1]
aperture_depth_mm = 2; //[1:6:0.1]
display_thickness_mm = 3; //[1.5:6:0.1]
mount_hole_diameter_mm = 3.2; //[1.6:6.4:0.1]
mount_hole_edge_margin_mm = 4.5; //[2.25:9:0.1]
connector_clearance_mm = 6; //[3:12:0.1]
connector_width_mm = 18; //[9:36:0.1]
connector_height_mm = 8; //[4:16:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// Rounded rectangle prism (centered)
module rounded_box(size=[10,10,2], r=1, center=true) {
  x = size[0]; y = size[1]; z = size[2];
  rr = min(r, x/2, y/2);
  translate(center ? [0,0,0] : [x/2,y/2,z/2])
    linear_extrude(height=z, center=true)
      offset(rr)
        square([x-2*rr, y-2*rr], center=true);
}

// Display block (solid, connected)
module display_block() {
  // Place display behind the front face, inside the aperture pocket, with overlap into body
  z_disp = (thickness_mm/2 + front_face_thickness_mm) - aperture_depth_mm - display_thickness_mm/2 + overlap_mm;
  translate([0, 0, z_disp])
    cube([aperture_width_mm - 2*overlap_mm, aperture_height_mm - 2*overlap_mm, display_thickness_mm], center=true);
}

// Back connector bump (solid, connected)
module connector_bump() {
  // Attach to the back of the PCB plate with overlap
  z_bump = (-thickness_mm/2 - pcb_thickness_mm) - connector_clearance_mm/2 + overlap_mm;
  translate([0, 0, z_bump])
    cube([connector_width_mm, connector_height_mm, connector_clearance_mm], center=true);
}

// Main assembly (ONE connected solid)
module assembly() {

  // Z extents for through-holes (ensure they cut everything)
  total_z = thickness_mm + front_face_thickness_mm + pcb_thickness_mm + connector_clearance_mm + 4*overlap_mm;

  difference() {
    union() {
      // Main body with rounded corners (exact overall XY: 84.5 x 54.5)
      color([0.85, 0.85, 0.8])
        rounded_box([width_mm, height_mm, thickness_mm], r=corner_radius_mm, center=true);

      // Front face plate (overlaps into body to guarantee connectivity)
      z_front = thickness_mm/2 + front_face_thickness_mm/2 - overlap_mm;
      color([0.1, 0.1, 0.6])
        translate([0, 0, z_front])
          rounded_box([width_mm, height_mm, front_face_thickness_mm], r=corner_radius_mm, center=true);

      // Rear PCB plate (overlaps into body to guarantee connectivity)
      z_pcb = -thickness_mm/2 - pcb_thickness_mm/2 + overlap_mm;
      color([0.1, 0.1, 0.6])
        translate([0, 0, z_pcb])
          rounded_box([width_mm, height_mm, pcb_thickness_mm], r=corner_radius_mm, center=true);

      // Display block (connected)
      color([0.72, 0.42, 0.12])
        display_block();

      // Back connector bump (connected)
      color([0.2, 0.2, 0.2])
        connector_bump();
    }

    // Display aperture pocket (cuts into front face/body)
    z_ap = (thickness_mm/2 + front_face_thickness_mm) - aperture_depth_mm/2 + overlap_mm;
    translate([0, 0, z_ap])
      cube([aperture_width_mm, aperture_height_mm, aperture_depth_mm + 2*overlap_mm], center=true);

    // Mounting holes (through everything)
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * (width_mm/2 - mount_hole_edge_margin_mm),
                 y * (height_mm/2 - mount_hole_edge_margin_mm),
                 0])
        cylinder(h=total_z, r=mount_hole_diameter_mm/2, center=true);
    }
  }
}

assembly();