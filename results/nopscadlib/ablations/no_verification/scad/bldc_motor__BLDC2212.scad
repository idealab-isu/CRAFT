// Brushless DC motor (single connected solid)
// Target: 28.0mm stator diameter, 27.0mm motor height

$fn = 128;

// -------------------- Parameters --------------------
stator_diameter_mm = 28.0;                 //[14.0:56.0:0.5]
motor_height_mm = 27.0;                   //[13.5:54.0:0.5]

body_outer_diameter_mm = 30.0;            //[20.0:60.0:0.5]  // outer can slightly larger than stator
body_wall_thickness_mm = 1.0;             //[0.5:2.0:0.1]
endcap_thickness_mm = 1.5;                //[0.75:3.0:0.1]

stator_inner_bore_diameter_mm = 10.0;     //[5.0:20.0:0.5]
stator_height_mm = 20.0;                  //[10.0:40.0:0.5]
stator_radial_clearance_mm = 0.4;         //[0.2:1.5:0.1]

num_stator_teeth = 12;                    //[6:24]
tooth_depth_mm = 2.2;                     //[1.0:4.0:0.1]
tooth_width_mm = 3.0;                     //[1.0:6.0:0.1]

rotor_clearance_mm = 0.35;                //[0.2:1.0:0.05]
magnet_thickness_mm = 1.2;                //[0.6:2.5:0.1]
num_magnets = 14;                         //[8:20]

shaft_diameter_mm = 3.0;                  //[1.5:6.0:0.1]
shaft_length_mm = 10.0;                   //[5.0:20.0:0.5]

mount_hole_diameter_mm = 3.0;             //[1.5:6.0:0.1]
mount_hole_circle_diameter_mm = 16.0;     //[8.0:32.0:0.5]
mount_boss_diameter_mm = 18.0;            //[10.0:30.0:0.5]
mount_boss_height_mm = 2.0;               //[1.0:5.0:0.1]

wire_grommet_diameter_mm = 6.0;           //[3.0:12.0:0.5]
wire_grommet_length_mm = 4.0;             //[2.0:10.0:0.5]

vent_slot_count = 10;                     //[0:24]
vent_slot_w_mm = 2.2;                     //[1.0:5.0:0.1]
vent_slot_h_mm = 6.0;                     //[2.0:12.0:0.1]
vent_slot_depth_mm = 1.2;                 //[0.6:3.0:0.1]

overlap_mm = 0.6;                         //[0.2:2.0:0.1]

// -------------------- Derived --------------------
body_r = body_outer_diameter_mm/2;
stator_r = stator_diameter_mm/2;
stator_r_eff = stator_r - stator_radial_clearance_mm;

bore_r = stator_inner_bore_diameter_mm/2;

can_inner_r = body_r - body_wall_thickness_mm;
rotor_outer_r = can_inner_r - rotor_clearance_mm;
rotor_inner_r = max(bore_r + 1.2, rotor_outer_r - (magnet_thickness_mm + 1.2)); // keep sane

// Z layout (centered motor body)
z_top = motor_height_mm/2;
z_bot = -motor_height_mm/2;

// Keep internals within the can cavity (between endcaps)
cavity_h = motor_height_mm - 2*endcap_thickness_mm;
stator_h_eff = min(stator_height_mm, cavity_h - 2*overlap_mm);
rotor_h_eff  = min(stator_h_eff*0.90, cavity_h - 2*overlap_mm);

// -------------------- Helpers --------------------
module ring(r_out, r_in, h, center=true) {
  difference() {
    cylinder(r=r_out, h=h, center=center);
    cylinder(r=r_in, h=h + 2*overlap_mm, center=center);
  }
}

module stator_teeth(h) {
  // Teeth protrude inward from stator outer radius
  for (i = [0:num_stator_teeth-1]) {
    rotate([0,0,i*360/num_stator_teeth])
      translate([stator_r_eff - tooth_depth_mm/2, 0, 0])
        cube([tooth_depth_mm, tooth_width_mm, h], center=true);
  }
}

module magnets_ring(h) {
  // Magnet blocks on inner wall of rotor can (visual cue)
  magnet_len = h * 0.92;
  magnet_w = (2*PI*(rotor_outer_r - magnet_thickness_mm/2))/num_magnets * 0.55;
  for (i = [0:num_magnets-1]) {
    rotate([0,0,i*360/num_magnets])
      translate([rotor_outer_r - magnet_thickness_mm/2, 0, 0])
        cube([magnet_thickness_mm, magnet_w, magnet_len], center=true);
  }
}

module vent_slots() {
  // Shallow slots cut into the can wall near the top half (visual cue)
  // Slots are subtracted from the outer can only (do not affect connectivity).
  if (vent_slot_count > 0) {
    slot_r_center = body_r - vent_slot_depth_mm/2;
    slot_z = z_top - endcap_thickness_mm - vent_slot_h_mm/2 - 0.8; // formula-based, near top
    for (i = [0:vent_slot_count-1]) {
      rotate([0,0,i*360/vent_slot_count])
        translate([slot_r_center, 0, slot_z])
          cube([vent_slot_depth_mm, vent_slot_w_mm, vent_slot_h_mm], center=true);
    }
  }
}

// -------------------- Motor (single connected solid) --------------------
module bldc_motor() {
  union() {

    // Outer can with cavity + vent slots
    difference() {
      cylinder(r=body_r, h=motor_height_mm, center=true);

      // Hollow interior (leave endcaps thickness)
      cylinder(r=can_inner_r,
               h=cavity_h + 2*overlap_mm,
               center=true);

      // Ventilation slots (shallow)
      vent_slots();
    }

    // Front endcap + mounting boss (connected to can)
    translate([0,0, z_top - endcap_thickness_mm/2])
      difference() {
        union() {
          cylinder(r=body_r, h=endcap_thickness_mm, center=true);

          // Boss protrudes outward from front face
          translate([0,0, endcap_thickness_mm/2 + mount_boss_height_mm/2 - overlap_mm])
            cylinder(r=mount_boss_diameter_mm/2, h=mount_boss_height_mm, center=true);
        }

        // Mount holes through endcap + boss
        for (i = [0:3]) {
          rotate([0,0,i*90])
            translate([mount_hole_circle_diameter_mm/2, 0, 0])
              cylinder(r=mount_hole_diameter_mm/2,
                       h=endcap_thickness_mm + mount_boss_height_mm + 4*overlap_mm,
                       center=true, $fn=48);
        }
      }

    // Rear endcap (connected to can)
    translate([0,0, z_bot + endcap_thickness_mm/2])
      cylinder(r=body_r, h=endcap_thickness_mm, center=true);

    // Stator core ring + teeth (kept inside cavity)
    translate([0,0,0])
      difference() {
        union() {
          ring(stator_r_eff, bore_r, stator_h_eff, center=true);
          stator_teeth(stator_h_eff);
        }
        cylinder(r=bore_r, h=stator_h_eff + 2*overlap_mm, center=true);
      }

    // Rotor ring + magnets (kept inside cavity)
    translate([0,0,0])
      union() {
        ring(rotor_outer_r, rotor_inner_r, rotor_h_eff, center=true);
        magnets_ring(rotor_h_eff);
      }

    // Shaft (connected to front boss with overlap)
    translate([0,0, z_top + mount_boss_height_mm + shaft_length_mm/2 - overlap_mm])
      cylinder(r=shaft_diameter_mm/2,
               h=shaft_length_mm + 2*overlap_mm,
               center=true, $fn=64);

    // Wire exit grommet (connected to can side)
    grommet_z = z_bot + endcap_thickness_mm + wire_grommet_diameter_mm/2;
    translate([body_r + wire_grommet_length_mm/2 - overlap_mm, 0, grommet_z])
      rotate([0,90,0])
        cylinder(r=wire_grommet_diameter_mm/2,
                 h=wire_grommet_length_mm,
                 center=true, $fn=64);
  }
}

bldc_motor();