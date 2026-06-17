// Parameters
length = 300; //[150:600:1]
width = 10; //[5:20:1]
thickness = 2; //[1:4:0.1]
pcb_thickness = 1.2; //[0.6:2.4:0.1]
led_pitch = 16.7; //[8:33.4:0.1]
led_count = 18; //[6:36:1]
led_size_x = 5; //[3:8:0.1]
led_size_y = 5; //[3:8:0.1]
led_height = 1.6; //[0.8:3.2:0.1]
led_lens_diameter = 3.5; //[2:6:0.1]
led_lens_height = 1.6; //[0.8:3.2:0.1]
solder_pad_length = 8; //[4:16:0.5]
solder_pad_width = 8; //[4:10:0.5]
solder_pad_thickness = 0.2; //[0.1:0.6:0.05]
segment_mark_width = 0.4; //[0.2:1.2:0.1]
segment_mark_height = 0.2; //[0.1:0.6:0.05]
segment_count = 3; //[2:6:1]
mounting_hole_diameter = 3; //[1.5:6:0.1]
mounting_hole_spacing = 100; //[50:200:1]
mounting_hole_count = 3; //[2:6:1]
hole_edge_margin = 12; //[6:24:1]
clip_wall = 2; //[1:4:0.1]
clip_length = 20; //[10:40:1]
clip_depth = 8; //[4:16:0.5]
clip_clearance = 0.6; //[0.2:1.5:0.1]
clip_overhang = 2; //[1:5:0.1]
overlap = 1; //[0.5:2:0.1]

// Light Strip - complete geometry
module light_strip() {
  color([0.85, 0.85, 0.8]) {
    // Rigid strip body
    cube([length, width, thickness], center=true);
    
    // PCB section
    translate([0, 0, thickness/2 + pcb_thickness/2 - overlap])
      cube([length - 2*overlap, width - 2*overlap, pcb_thickness], center=true);
    
    // LEDs and lenses
    for (i = [1:led_count]) {
      translate([(-length/2) + (length/(led_count+1))*i, 0, thickness/2 + pcb_thickness + led_height/2 - overlap])
        cube([led_size_x, led_size_y, led_height], center=true);
      translate([(-length/2) + (length/(led_count+1))*i, 0, thickness/2 + pcb_thickness + led_height + led_lens_height/2 - overlap])
        cylinder(r=led_lens_diameter/2, h=led_lens_height, center=true, $fn=32);
    }
    
    // Solder pads
    translate([(-length/2) + solder_pad_length/2, 0, thickness/2 + pcb_thickness + solder_pad_thickness/2 - overlap])
      cube([solder_pad_length, solder_pad_width, solder_pad_thickness], center=true);
    translate([(length/2) - solder_pad_length/2, 0, thickness/2 + pcb_thickness + solder_pad_thickness/2 - overlap])
      cube([solder_pad_length, solder_pad_width, solder_pad_thickness], center=true);
    
    // Segment markings
    for (i = [1:segment_count]) {
      translate([(-length/2) + (length/segment_count)*i, 0, thickness/2 + pcb_thickness + segment_mark_height/2 - overlap])
        cube([segment_mark_width, width - 2*overlap, segment_mark_height], center=true);
    }
  }
  
  // Mounting holes
  color("Black") {
    for (i = [0:mounting_hole_count-1]) {
      translate([(-length/2) + hole_edge_margin + i*mounting_hole_spacing, 0, thickness/2 + (pcb_thickness + led_height + led_lens_height)/2 - overlap])
        cylinder(r=mounting_hole_diameter/2, h=thickness + pcb_thickness + led_height + led_lens_height + 2*overlap, center=true, $fn=32);
    }
  }
}

// Light Strip Clip - complete geometry
module light_strip_clip() {
  color([0.15, 0.15, 0.17]) {
    // Outer block
    difference() {
      translate([0, 0, thickness/2 + pcb_thickness + led_height + led_lens_height + clip_depth/2 - overlap])
        cube([clip_length, width + 2*clip_wall + 2*clip_overhang, clip_depth], center=true);
      
      // Slot cut
      translate([0, 0, thickness/2 + pcb_thickness + led_height + led_lens_height + clip_depth/2 - overlap])
        cube([clip_length - 2*clip_wall, width + 2*clip_clearance, clip_depth + 2*overlap], center=true);
      
      // Aperture cut
      translate([0, 0, thickness/2 + pcb_thickness + led_height + led_lens_height + clip_depth/2 - overlap])
        cube([clip_length + 2*overlap, width - 2*clip_overhang, clip_depth + 2*overlap], center=true);
    }
  }
}

// Assembly
module assembly() {
  light_strip();
  light_strip_clip();
}

assembly();