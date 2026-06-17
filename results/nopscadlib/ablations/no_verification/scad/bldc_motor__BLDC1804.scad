// Brushless DC motor (ONE connected solid)
// Target: stator_outer_diameter_mm = 23.0mm, stator_height_mm = 12.0mm

// -------------------- Parameters --------------------
stator_outer_diameter_mm = 23; //[12:46:0.1]
stator_height_mm         = 12; //[6:24:0.1]
stator_inner_diameter_mm = 8;  //[4:18:0.1]

shaft_diameter_mm        = 3;  //[1:8:0.1]

// Keep can slightly larger than stator (typical BLDC)
overall_motor_diameter_mm = 27; //[14:54:0.1]
overall_motor_height_mm   = 18; //[9:36:0.1]

tolerance_mm        = 0.2; //[0.05:0.6:0.05]
connect_overlap_mm  = 1;   //[0.5:2:0.1]

$fn = 128;

// -------------------- Derived --------------------
stator_r = stator_outer_diameter_mm/2;
stator_h = stator_height_mm;

motor_r = overall_motor_diameter_mm/2;
motor_h = overall_motor_height_mm;

shaft_r = shaft_diameter_mm/2;

// Ensure can fits stator
can_r = max(motor_r, stator_r + 1.0);

// Endbells
endbell_h   = max(1.4, motor_h*0.14);
can_shell_h = max(0.1, motor_h - 2*endbell_h);

// Rotor (visual) - slightly smaller than stator ID
rotor_r = max( (stator_inner_diameter_mm/2) - 0.6, shaft_r + 0.8 );
rotor_h = stator_h - 0.6;

// Shaft + boss
shaft_front_len = max(7, motor_h*0.40);
shaft_back_len  = max(3, motor_h*0.18);
shaft_total_h   = motor_h + shaft_front_len + shaft_back_len;

boss_r = max(shaft_r + 2.2, stator_inner_diameter_mm/2 + 1.2);
boss_h = max(2.2, endbell_h + 0.9);

// Back mounting flange + holes (dimples)
flange_r = can_r + 1.6;
flange_h = max(1.6, endbell_h*0.9);

lug_count = 4;
lug_pcd_r = flange_r - 2.6;
hole_r    = 1.1;
hole_depth = min(1.0, flange_h - 0.3);

// Stator teeth (visual, inward)
tooth_count = 12;
tooth_w = 1.2;
tooth_h = stator_h;
tooth_radial_len = max(1.8, (stator_r - (stator_inner_diameter_mm/2 + 1.0)) * 0.65);

// Wire exit bump (connected)
wire_bump_r = 2.0;
wire_bump_h = 2.4;
wire_bump_offset = can_r - wire_bump_r + connect_overlap_mm;

// Front face details (vents + rim)
front_rim_h = max(0.8, endbell_h*0.55);
front_rim_r = can_r - 0.7;

vent_count = 6;
vent_r = 1.2;
vent_pcd_r = max(shaft_r + 3.0, can_r*0.45);
vent_depth = min(0.9, endbell_h - 0.3);

// -------------------- Helpers --------------------
module radial_hole_dimples(z_center, pcd_r, count, r, depth) {
  for (i = [0:count-1]) {
    rotate([0,0,i*360/count])
      translate([pcd_r, 0, z_center])
        cylinder(r=r, h=depth, center=true, $fn=48);
  }
}

module stator_with_teeth() {
  union() {
    // Stator ring (23mm OD, 12mm height)
    difference() {
      cylinder(r=stator_r, h=stator_h, center=true);
      cylinder(r=stator_inner_diameter_mm/2 + tolerance_mm,
               h=stator_h + 2*tolerance_mm, center=true);
    }

    // Teeth protruding inward from stator ID region (visual)
    for (i = [0:tooth_count-1]) {
      rotate([0,0,i*360/tooth_count])
        translate([ (stator_inner_diameter_mm/2 + 0.8) + tooth_radial_len/2, 0, 0 ])
          cube([tooth_radial_len, tooth_w, tooth_h], center=true);
    }
  }
}

module rotor_core() {
  // Rotor cylinder inside stator (connected to shaft)
  // Slight overlap into stator to guarantee connectivity in union
  translate([0,0,0])
    cylinder(r=rotor_r, h=rotor_h + 2*connect_overlap_mm, center=true, $fn=96);
}

module motor_can_with_endbells() {
  union() {
    // Main can shell
    cylinder(r=can_r, h=can_shell_h, center=true);

    // Front endbell (z+)
    translate([0,0, can_shell_h/2 + endbell_h/2 - connect_overlap_mm])
      cylinder(r=can_r, h=endbell_h, center=true);

    // Back endbell (z-)
    translate([0,0,-(can_shell_h/2 + endbell_h/2 - connect_overlap_mm)])
      cylinder(r=can_r, h=endbell_h, center=true);

    // Front rim/lip (step)
    translate([0,0, motor_h/2 - front_rim_h/2])
      cylinder(r=front_rim_r, h=front_rim_h, center=true);

    // Back mounting flange (typical BLDC base)
    translate([0,0, -motor_h/2 + flange_h/2 - connect_overlap_mm])
      cylinder(r=flange_r, h=flange_h, center=true, $fn=128);
  }
}

module shaft_and_boss() {
  union() {
    // Shaft passes through motor and protrudes both sides
    cylinder(r=shaft_r, h=shaft_total_h, center=true, $fn=72);

    // Front boss around shaft (connected to front endbell)
    translate([0,0, motor_h/2 - boss_h/2 + connect_overlap_mm])
      cylinder(r=boss_r, h=boss_h, center=true, $fn=96);

    // Back boss (smaller) to suggest bearing seat, connected to back endbell
    back_boss_r = max(shaft_r + 1.6, boss_r*0.75);
    back_boss_h = max(1.8, endbell_h*0.75);
    translate([0,0, -motor_h/2 + back_boss_h/2 - connect_overlap_mm])
      cylinder(r=back_boss_r, h=back_boss_h, center=true, $fn=96);
  }
}

module wire_exit_bump() {
  // Small bump on side of can (connected)
  translate([wire_bump_offset, 0, -motor_h/2 + wire_bump_h/2 + endbell_h*0.25])
    cylinder(r=wire_bump_r, h=wire_bump_h, center=true, $fn=48);
}

module bldc_motor() {
  // ONE connected solid: union of all features, with only shallow dimples subtracted
  difference() {
    union() {
      // Can + endbells + flange
      motor_can_with_endbells();

      // Stator inside can (centered)
      // Ensure it intersects can slightly to guarantee connectivity
      stator_with_teeth();

      // Rotor core (connected to shaft)
      rotor_core();

      // Shaft + bosses
      shaft_and_boss();

      // Wire exit bump
      wire_exit_bump();
    }

    // Back flange mounting hole dimples (do not cut through)
    radial_hole_dimples(
      z_center = -motor_h/2 + flange_h/2 + 0.05,
      pcd_r    = lug_pcd_r,
      count    = lug_count,
      r        = hole_r,
      depth    = hole_depth
    );

    // Front face vent dimples (visual)
    radial_hole_dimples(
      z_center = motor_h/2 - endbell_h/2,
      pcd_r    = vent_pcd_r,
      count    = vent_count,
      r        = vent_r,
      depth    = vent_depth
    );
  }
}

// Final
bldc_motor();