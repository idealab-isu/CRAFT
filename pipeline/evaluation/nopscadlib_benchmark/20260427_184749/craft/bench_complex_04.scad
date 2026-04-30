// Parameters
total_length = 24.384; //[12.192:48.768:0.1]
wall_thickness = 0.975; //[0.5:2.0:0.05]
lid_thickness = 0.975; //[0.5:2.0:0.05]
base_inner_length = 17.066; //[8.5:34.0:0.1]
base_inner_width = 7.314; //[3.5:15.0:0.1]
base_inner_height = 5.363; //[2.5:11.0:0.1]
lid_lip_height = 0.731; //[0.3:1.6:0.05]
lid_lip_clearance = 0.073; //[0.02:0.2:0.01]
print_clearance_general = 0.073; //[0.02:0.2:0.01]
fastener_boss_outer_diameter = 1.706; //[0.9:3.5:0.05]
fastener_hole_diameter = 0.731; //[0.4:1.6:0.05]
standoff_height = 1.219; //[0.6:2.6:0.05]
standoff_outer_diameter = 1.463; //[0.7:3.0:0.05]
standoff_hole_diameter = 0.731; //[0.4:1.6:0.05]
usb_cutout_width = 2.925; //[1.2:6.0:0.05]
usb_cutout_height = 1.463; //[0.6:3.0:0.05]
display_window_width = 6.338; //[3.0:13.0:0.05]
display_window_height = 3.413; //[1.5:7.0:0.05]
display_window_bezel = 0.366; //[0.1:1.0:0.02]
display_pcb_clearance_depth = 0.731; //[0.3:1.6:0.05]
pcb_length = 13.409; //[6.5:27.0:0.1]
pcb_width = 6.826; //[3.0:14.0:0.1]
pcb_thickness = 0.39; //[0.2:1.0:0.01]
pcb_clearance_xy = 0.244; //[0.1:0.6:0.01]
pcb_clearance_z = 0.488; //[0.2:1.2:0.02]
overlap = 0.08; //[0.02:0.2:0.01]

// Base Enclosure
module enclosure_base_outer() {
  cube([base_inner_length + 2*wall_thickness, base_inner_width + 2*wall_thickness, base_inner_height + wall_thickness], center=true);
}

module enclosure_base_inner_void() {
  translate([0, 0, wall_thickness/2])
    cube([base_inner_length, base_inner_width, base_inner_height + overlap], center=true);
}

module fastener_boss_cyl() {
  cylinder(r=fastener_boss_outer_diameter/2, h=base_inner_height + wall_thickness, center=true);
}

module fastener_hole_cyl() {
  cylinder(r=fastener_hole_diameter/2, h=base_inner_height + wall_thickness + 2*overlap, center=true);
}

module standoff_cyl() {
  cylinder(r=standoff_outer_diameter/2, h=standoff_height, center=true);
}

module standoff_hole_cyl() {
  cylinder(r=standoff_hole_diameter/2, h=standoff_height + 2*overlap, center=true);
}

module usb_access_cutout() {
  translate([base_inner_length/2 + wall_thickness/2, 0, -(base_inner_height + wall_thickness)/2 + wall_thickness + usb_cutout_height/2])
    cube([wall_thickness + 2*overlap, usb_cutout_width + 2*print_clearance_general, usb_cutout_height + 2*print_clearance_general], center=true);
}

module side_clearance_cutouts() {
  translate([0, base_inner_width/2 + wall_thickness/2, 0])
    cube([base_inner_length*0.35, wall_thickness + 2*overlap, base_inner_height*0.35], center=true);
}

module internal_board_clearance_volume() {
  translate([0, 0, -(base_inner_height + wall_thickness)/2 + wall_thickness + standoff_height + (pcb_thickness + pcb_clearance_z)/2])
    cube([pcb_length + 2*pcb_clearance_xy, pcb_width + 2*pcb_clearance_xy, pcb_thickness + pcb_clearance_z], center=true);
}

// Lid Enclosure
module enclosure_lid_outer() {
  translate([0, 0, (base_inner_height + wall_thickness)/2 + (lid_thickness + lid_lip_height)/2 - overlap])
    cube([base_inner_length + 2*wall_thickness, base_inner_width + 2*wall_thickness, lid_thickness + lid_lip_height], center=true);
}

module enclosure_lid_underside_void() {
  translate([0, 0, (base_inner_height + wall_thickness)/2 + (lid_thickness + lid_lip_height)/2 - overlap - lid_thickness/2])
    cube([base_inner_length + 2*wall_thickness - 2*wall_thickness, base_inner_width + 2*wall_thickness - 2*wall_thickness, lid_lip_height + overlap], center=true);
}

module lid_lip_solid() {
  translate([0, 0, (base_inner_height + wall_thickness)/2 + lid_lip_height/2 - overlap])
    cube([base_inner_length - 2*lid_lip_clearance, base_inner_width - 2*lid_lip_clearance, lid_lip_height], center=true);
}

module display_window_cutout() {
  translate([0, 0, (base_inner_height + wall_thickness)/2 + (lid_thickness + lid_lip_height) - lid_thickness/2])
    cube([display_window_width, display_window_height, lid_thickness + 2*overlap], center=true);
}

module display_pocket_cutout() {
  translate([0, 0, (base_inner_height + wall_thickness)/2 + lid_lip_height - display_pcb_clearance_depth/2])
    cube([display_window_width + 2*display_window_bezel, display_window_height + 2*display_window_bezel, display_pcb_clearance_depth + overlap], center=true);
}

module display() {
  translate([0, 0, (base_inner_height + wall_thickness)/2 + lid_lip_height - display_pcb_clearance_depth*0.3])
    cube([display_window_width + 2*display_window_bezel, display_window_height + 2*display_window_bezel, display_pcb_clearance_depth*0.6], center=true);
}

module led() {
  translate([display_window_width/2 - display_window_height*0.25, display_window_height/2 - display_window_height*0.25, (base_inner_height + wall_thickness)/2 + (lid_thickness + lid_lip_height) - lid_thickness/2])
    cylinder(r=display_window_height*0.12, h=lid_thickness, center=true);
}

module box_header() {
  translate([-pcb_length*0.15, 0, -(base_inner_height + wall_thickness)/2 + wall_thickness + standoff_height + pcb_thickness + (pcb_thickness*2)/2])
    cube([pcb_width*0.35, pcb_width*0.18, pcb_thickness*2], center=true);
}

// Assembly
module enclosure_assembly() {
  union() {
    // Base
    difference() {
      enclosure_base_outer();
      enclosure_base_inner_void();
    }
    // Fastener Bosses
    union() {
      translate([base_inner_length/2 - fastener_boss_outer_diameter/2 - wall_thickness/2, base_inner_width/2 - fastener_boss_outer_diameter/2 - wall_thickness/2, 0])
        fastener_boss_cyl();
      mirror([1, 0, 0])
        translate([base_inner_length/2 - fastener_boss_outer_diameter/2 - wall_thickness/2, base_inner_width/2 - fastener_boss_outer_diameter/2 - wall_thickness/2, 0])
        fastener_boss_cyl();
      mirror([0, 1, 0])
        translate([base_inner_length/2 - fastener_boss_outer_diameter/2 - wall_thickness/2, base_inner_width/2 - fastener_boss_outer_diameter/2 - wall_thickness/2, 0])
        fastener_boss_cyl();
      mirror([1, 1, 0])
        translate([base_inner_length/2 - fastener_boss_outer_diameter/2 - wall_thickness/2, base_inner_width/2 - fastener_boss_outer_diameter/2 - wall_thickness/2, 0])
        fastener_boss_cyl();
    }
    // Fastener Holes
    difference() {
      union() {
        translate([base_inner_length/2 - fastener_boss_outer_diameter/2 - wall_thickness/2, base_inner_width/2 - fastener_boss_outer_diameter/2 - wall_thickness/2, 0])
          fastener_hole_cyl();
        mirror([1, 0, 0])
          translate([base_inner_length/2 - fastener_boss_outer_diameter/2 - wall_thickness/2, base_inner_width/2 - fastener_boss_outer_diameter/2 - wall_thickness/2, 0])
          fastener_hole_cyl();
        mirror([0, 1, 0])
          translate([base_inner_length/2 - fastener_boss_outer_diameter/2 - wall_thickness/2, base_inner_width/2 - fastener_boss_outer_diameter/2 - wall_thickness/2, 0])
          fastener_hole_cyl();
        mirror([1, 1, 0])
          translate([base_inner_length/2 - fastener_boss_outer_diameter/2 - wall_thickness/2, base_inner_width/2 - fastener_boss_outer_diameter/2 - wall_thickness/2, 0])
          fastener_hole_cyl();
      }
      usb_access_cutout();
      side_clearance_cutouts();
    }
    // PCB Mounting Standoffs
    difference() {
      union() {
        translate([pcb_length/2 - standoff_outer_diameter/2 - pcb_clearance_xy, pcb_width/2 - standoff_outer_diameter/2 - pcb_clearance_xy, -(base_inner_height + wall_thickness)/2 + wall_thickness + standoff_height/2 - overlap])
          standoff_cyl();
        mirror([1, 0, 0])
          translate([pcb_length/2 - standoff_outer_diameter/2 - pcb_clearance_xy, pcb_width/2 - standoff_outer_diameter/2 - pcb_clearance_xy, -(base_inner_height + wall_thickness)/2 + wall_thickness + standoff_height/2 - overlap])
          standoff_cyl();
        mirror([0, 1, 0])
          translate([pcb_length/2 - standoff_outer_diameter/2 - pcb_clearance_xy, pcb_width/2 - standoff_outer_diameter/2 - pcb_clearance_xy, -(base_inner_height + wall_thickness)/2 + wall_thickness + standoff_height/2 - overlap])
          standoff_cyl();
        mirror([1, 1, 0])
          translate([pcb_length/2 - standoff_outer_diameter/2 - pcb_clearance_xy, pcb_width/2 - standoff_outer_diameter/2 - pcb_clearance_xy, -(base_inner_height + wall_thickness)/2 + wall_thickness + standoff_height/2 - overlap])
          standoff_cyl();
      }
      union() {
        translate([pcb_length/2 - standoff_outer_diameter/2 - pcb_clearance_xy, pcb_width/2 - standoff_outer_diameter/2 - pcb_clearance_xy, -(base_inner_height + wall_thickness)/2 + wall_thickness + standoff_height/2 - overlap])
          standoff_hole_cyl();
        mirror([1, 0, 0])
          translate([pcb_length/2 - standoff_outer_diameter/2 - pcb_clearance_xy, pcb_width/2 - standoff_outer_diameter/2 - pcb_clearance_xy, -(base_inner_height + wall_thickness)/2 + wall_thickness + standoff_height/2 - overlap])
          standoff_hole_cyl();
        mirror([0, 1, 0])
          translate([pcb_length/2 - standoff_outer_diameter/2 - pcb_clearance_xy, pcb_width/2 - standoff_outer_diameter/2 - pcb_clearance_xy, -(base_inner_height + wall_thickness)/2 + wall_thickness + standoff_height/2 - overlap])
          standoff_hole_cyl();
        mirror([1, 1, 0])
          translate([pcb_length/2 - standoff_outer_diameter/2 - pcb_clearance_xy, pcb_width/2 - standoff_outer_diameter/2 - pcb_clearance_xy, -(base_inner_height + wall_thickness)/2 + wall_thickness + standoff_height/2 - overlap])
          standoff_hole_cyl();
      }
    }
    // Lid
    difference() {
      union() {
        enclosure_lid_outer();
        lid_lip_solid();
      }
      enclosure_lid_underside_void();
      display_window_cutout();
      display_pocket_cutout();
    }
    // Display and LED
    display();
    led();
    // Internal Board Clearance and Header
    internal_board_clearance_volume();
    box_header();
  }
}

// Final Output
enclosure_assembly();