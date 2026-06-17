// Parameters
variant_screwfix = 1; //[0:1:1]
switched = 1; //[0:1:1]
faceplate_width = 86; //[60:120:1]
faceplate_height = 86; //[60:120:1]
faceplate_thickness = 8; //[4:16:1]
top_width = 80; //[60:110:1]
top_height = 80; //[60:110:1]
wall_thickness = 2.5; //[1.5:6:0.5]
overall_depth = 25; //[15:50:1]
rear_cavity_depth = 6; //[3:14:1]
rear_cavity_margin = 8; //[4:20:1]
pin_live_neutral_slot_spacing_x = 22.2; //[18:28:0.1]
pin_live_neutral_slot_offset_y = -11.1; //[-20:-5:0.1]
pin_earth_slot_offset_y = 11.1; //[5:20:0.1]
pin_slot_depth = 10; //[6:20:1]
ln_slot_width_x = 7; //[5:10:0.1]
ln_slot_width_y = 4.5; //[3:7:0.1]
earth_slot_width_x = 4.5; //[3:7:0.1]
earth_slot_width_y = 8.5; //[6:12:0.1]
mount_screw_spacing_y = 60.3; //[45:80:0.1]
mount_screw_offset_x = 0; //[-10:10:0.1]
mount_screw_clear_diameter = 4.2; //[3:6:0.1]
mount_counterbore_diameter = 8.5; //[6:14:0.1]
mount_counterbore_depth = 3; //[1:6:0.1]
switch_offset_x = 0; //[-20:20:0.1]
switch_offset_y = 22; //[0:35:0.1]
switch_cutout_width = 30; //[15:45:0.5]
switch_cutout_height = 14; //[8:25:0.5]
switch_cutout_depth = 2; //[1:5:0.1]
overlap = 1; //[0.5:2:0.1]

// Added (derived/extra) parameters for a switched socket body + rocker
corner_r = 3;
backbox_margin = 6;                 // smaller than faceplate to create a rear housing
backbox_depth = max(overall_depth - faceplate_thickness, 10);
backbox_wall = max(wall_thickness, 2);
backbox_front_overlap = overlap;    // overlap into faceplate to ensure one connected solid

switch_bezel_margin = 2.0;
switch_bezel_depth = 1.2;
switch_rocker_depth = 2.2;
switch_rocker_gap = 0.4;

// Helpers
module rounded_plate(w,h,t,r){
  linear_extrude(height=t, center=true)
    offset(r=r)
      square([max(w-2*r,0.01), max(h-2*r,0.01)], center=true);
}

module mains_socket_solid(){
  union(){
    // Faceplate
    rounded_plate(faceplate_width, faceplate_height, faceplate_thickness, corner_r);

    // Slight raised inner "top" area on the front face (connected with overlap)
    translate([0,0, faceplate_thickness/2 - overlap/2])
      rounded_plate(top_width, top_height, overlap, max(corner_r-1,1));

    // Rear housing/backbox (adds depth; connected to faceplate with overlap)
    translate([0,0, -faceplate_thickness/2 - backbox_depth/2 + backbox_front_overlap])
      rounded_plate(faceplate_width - 2*backbox_margin,
                    faceplate_height - 2*backbox_margin,
                    backbox_depth,
                    max(corner_r-1,1));

    // Switch bezel + rocker (switched feature) - protrudes from front and is connected
    if (switched){
      // Bezel frame around switch opening (a raised frame, not a cutout)
      translate([switch_offset_x, switch_offset_y,
                 faceplate_thickness/2 + switch_bezel_depth/2 - overlap/2])
        difference(){
          rounded_plate(switch_cutout_width + 2*switch_bezel_margin,
                        switch_cutout_height + 2*switch_bezel_margin,
                        switch_bezel_depth + overlap,
                        1.5);
          // inner opening
          rounded_plate(switch_cutout_width,
                        switch_cutout_height,
                        switch_bezel_depth + 2*overlap,
                        1.0);
        }

      // Rocker (simple wedge-like rocker using hull between two thin plates)
      translate([switch_offset_x, switch_offset_y,
                 faceplate_thickness/2 + switch_bezel_depth + switch_rocker_depth/2 - overlap/2])
        hull(){
          translate([0,  (switch_cutout_height/2 - 1.0),  0.4])
            rounded_plate(switch_cutout_width - 2*switch_rocker_gap,
                          2.0,
                          0.8,
                          1.0);
          translate([0, -(switch_cutout_height/2 - 1.0), -0.4])
            rounded_plate(switch_cutout_width - 2*switch_rocker_gap,
                          2.0,
                          0.8,
                          1.0);
        }
    }
  }
}

module mains_socket_voids(){
  union(){
    // Pin apertures (cut fully through faceplate thickness)
    // Ensure correct UK arrangement: Earth (top, vertical), Live/Neutral (bottom, vertical)
    translate([-pin_live_neutral_slot_spacing_x/2, pin_live_neutral_slot_offset_y, 0])
      cube([ln_slot_width_y, ln_slot_width_x, faceplate_thickness + 2*overlap], center=true); // vertical slot
    translate([ pin_live_neutral_slot_spacing_x/2, pin_live_neutral_slot_offset_y, 0])
      cube([ln_slot_width_y, ln_slot_width_x, faceplate_thickness + 2*overlap], center=true); // vertical slot
    translate([0, pin_earth_slot_offset_y, 0])
      cube([earth_slot_width_x, earth_slot_width_y, faceplate_thickness + 2*overlap], center=true); // vertical slot

    // Mounting screw holes (through)
    translate([mount_screw_offset_x,  mount_screw_spacing_y/2, 0])
      cylinder(r=mount_screw_clear_diameter/2, h=faceplate_thickness + 2*overlap, center=true, $fn=48);
    translate([mount_screw_offset_x, -mount_screw_spacing_y/2, 0])
      cylinder(r=mount_screw_clear_diameter/2, h=faceplate_thickness + 2*overlap, center=true, $fn=48);

    // Counterbores on front face
    translate([mount_screw_offset_x,  mount_screw_spacing_y/2,
               faceplate_thickness/2 - mount_counterbore_depth/2 + overlap/2])
      cylinder(r=mount_counterbore_diameter/2, h=mount_counterbore_depth + overlap, center=true, $fn=64);
    translate([mount_screw_offset_x, -mount_screw_spacing_y/2,
               faceplate_thickness/2 - mount_counterbore_depth/2 + overlap/2])
      cylinder(r=mount_counterbore_diameter/2, h=mount_counterbore_depth + overlap, center=true, $fn=64);

    // Rear cavity inside backbox (keeps walls; does not break connectivity)
    translate([0,0, -faceplate_thickness/2 - backbox_depth/2 + backbox_front_overlap])
      rounded_plate((faceplate_width - 2*backbox_margin) - 2*backbox_wall,
                    (faceplate_height - 2*backbox_margin) - 2*backbox_wall,
                    min(rear_cavity_depth, backbox_depth - 2),
                    max(corner_r-2,0.8));

    // Switch cutout (only into faceplate, not through rocker)
    if (switched){
      translate([switch_offset_x, switch_offset_y,
                 faceplate_thickness/2 - (switch_cutout_depth + overlap)/2])
        rounded_plate(switch_cutout_width,
                      switch_cutout_height,
                      switch_cutout_depth + overlap,
                      1.0);
    }
  }
}

// Assembly: ONE connected solid
difference(){
  mains_socket_solid();
  mains_socket_voids();
}