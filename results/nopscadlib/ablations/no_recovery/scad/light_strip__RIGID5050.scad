// Parameters
segments = 5; //[1:20:1]
segment_length_mm = 50; //[25:100:1]
overall_length_mm = 250; //[125:500:1]
width_mm = 12; //[6:24:1]
depth_mm = 4; //[2:8:1]
thickness_mm = 1; //[0.5:2:0.1]
aperture_width_mm = 8; //[4:16:1]
pcb_thickness_mm = 1.6; //[0.8:2.4:0.1]
led_count = 25; //[5:120:1]
led_pitch_mm = 10; //[5:20:0.5]
overlap_mm = 1; //[0.5:2:0.1]
led_body_size_mm = 5; //[3:7:0.5]
led_lens_d_mm = 3.5; //[2:5:0.1]
led_height_mm = 1.6; //[0.8:2.5:0.1]
pad_size_mm = 2.5; //[1.5:4:0.1]
pad_thickness_mm = 0.2; //[0.1:0.6:0.05]
marker_thickness_mm = 0.2; //[0.1:0.6:0.05]
marker_width_mm = 0.4; //[0.2:1:0.05]
resistor_size_x_mm = 3.2; //[2:5:0.1]
resistor_size_y_mm = 1.5; //[1:3:0.1]
resistor_height_mm = 0.55; //[0.3:1.2:0.05]
clip_wall_mm = 1.5; //[0.8:3:0.1]
clip_depth_mm = 10; //[5:25:1]
clip_length_mm = 20; //[10:40:1]
clip_width_mm = 14; //[8:28:1]
clip_slot_mm = 12; //[6:24:1]

// Light Strip - complete geometry
module light_strip() {
  color([0.85, 0.85, 0.8]) {
    // Rigid strip body
    difference() {
      cube([segments * segment_length_mm, width_mm, depth_mm], center=true);
      translate([0, 0, thickness_mm/2])
        cube([segments * segment_length_mm - 2 * thickness_mm, aperture_width_mm, depth_mm - thickness_mm], center=true);
    }
    // PCB core
    translate([0, 0, -depth_mm/2 + thickness_mm + pcb_thickness_mm/2 - overlap_mm])
      cube([segments * segment_length_mm - 2 * thickness_mm, width_mm - 2 * thickness_mm, pcb_thickness_mm], center=true);
    
    // LED array
    for (i = [0:4]) {
      translate([-segments * segment_length_mm/2 + led_pitch_mm * (i + 0.5), 0, -depth_mm/2 + thickness_mm + pcb_thickness_mm + led_height_mm/2 - overlap_mm]) {
        cube([led_body_size_mm, led_body_size_mm, led_height_mm], center=true);
        cylinder(r=led_lens_d_mm/2, h=led_height_mm, center=true);
      }
    }
    
    // Solder pads
    translate([-segments * segment_length_mm/2 + pad_size_mm/2 + overlap_mm, 0, -depth_mm/2 + thickness_mm + pcb_thickness_mm + pad_thickness_mm/2 - overlap_mm])
      cube([pad_size_mm, pad_size_mm, pad_thickness_mm], center=true);
    translate([segments * segment_length_mm/2 - pad_size_mm/2 - overlap_mm, 0, -depth_mm/2 + thickness_mm + pcb_thickness_mm + pad_thickness_mm/2 - overlap_mm])
      cube([pad_size_mm, pad_size_mm, pad_thickness_mm], center=true);
    
    // Segment markers
    for (i = [1:4]) {
      translate([-segments * segment_length_mm/2 + segment_length_mm * i - overlap_mm, 0, -depth_mm/2 + thickness_mm + pcb_thickness_mm + marker_thickness_mm/2 - overlap_mm])
        cube([marker_width_mm, aperture_width_mm, marker_thickness_mm], center=true);
    }
    
    // Resistors
    for (i = [0:4]) {
      translate([-segments * segment_length_mm/2 + segment_length_mm * (i + 0.5), (width_mm - 2 * thickness_mm)/2 - resistor_size_y_mm/2 - overlap_mm, -depth_mm/2 + thickness_mm + pcb_thickness_mm + resistor_height_mm/2 - overlap_mm])
        cube([resistor_size_x_mm, resistor_size_y_mm, resistor_height_mm], center=true);
    }
  }
}

// Light Strip Clip - complete geometry
module light_strip_clip() {
  color([0.15, 0.15, 0.17]) {
    difference() {
      translate([0, width_mm/2 + clip_depth_mm/2 - overlap_mm, 0])
        cube([clip_length_mm, clip_depth_mm, clip_width_mm], center=true);
      translate([0, width_mm/2 + clip_depth_mm/2 - overlap_mm, 0])
        cube([clip_slot_mm, clip_depth_mm - 2 * clip_wall_mm, clip_width_mm - 2 * clip_wall_mm], center=true);
      translate([0, width_mm/2 + clip_depth_mm/2 - overlap_mm, depth_mm/2 - clip_width_mm/2 + overlap_mm])
        cube([aperture_width_mm, clip_depth_mm, clip_width_mm], center=true);
    }
  }
}

// Assembly
module assembly() {
  light_strip();
  light_strip_clip();
}

assembly();