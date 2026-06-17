// Dimension-calibrated (target: 0.15 x 0.13 x 0.08 mm)
scale([0.828057, 1.221154, 0.950000])
{
// Parameters
bbox_L = 0.15; //[0.075:0.3:0.001]
bbox_W = 0.13; //[0.065:0.26:0.001]
bbox_H = 0.08; //[0.04:0.16:0.001]
base_L = 0.085; //[0.0425:0.17:0.001]
base_W = 0.11; //[0.055:0.22:0.001]
base_H = 0.08; //[0.04:0.16:0.001]
base_corner_r = 0.018; //[0.009:0.036:0.001]
arm_thk = 0.06; //[0.03:0.12:0.001]
arm_w = 0.032; //[0.016:0.064:0.001]
arm_neck_w = 0.022; //[0.011:0.044:0.001]
arm_len_from_base = 0.065; //[0.0325:0.13:0.001]
arm_elbow_offset_y = 0.02; //[0.01:0.04:0.001]
arm_tip_L = 0.03; //[0.015:0.06:0.001]
arm_tip_W = 0.038; //[0.019:0.076:0.001]
arm_tip_r = 0.019; //[0.0095:0.038:0.001]
boss_L = 0.012; //[0.006:0.024:0.001]
boss_W = 0.01; //[0.005:0.02:0.001]
boss_H = 0.02; //[0.01:0.04:0.001]
boss_offset_from_base_face = 0.01; //[0.005:0.02:0.001]
blend_r = 0.008; //[0.004:0.016:0.001]
overlap = 0.001; //[0.0005:0.002:0.0005]
chamfer_cut = 0.004; //[0.002:0.008:0.001]
relief_step_depth = 0.006; //[0.003:0.012:0.001]
relief_step_L = 0.03; //[0.015:0.06:0.001]
relief_step_W = 0.04; //[0.02:0.08:0.001]

// Base rounded rectangle
module base_block_rounded_rectangle() {
  hull() {
    translate([(-base_L/2 + base_corner_r), (-base_W/2 + base_corner_r), 0])
      cylinder(r=base_corner_r, h=base_H, center=true);
    translate([(base_L/2 - base_corner_r), (-base_W/2 + base_corner_r), 0])
      cylinder(r=base_corner_r, h=base_H, center=true);
    translate([(base_L/2 - base_corner_r), (base_W/2 - base_corner_r), 0])
      cylinder(r=base_corner_r, h=base_H, center=true);
    translate([(-base_L/2 + base_corner_r), (base_W/2 - base_corner_r), 0])
      cylinder(r=base_corner_r, h=base_H, center=true);
  }
}

// Arm with curved planform
module arm_curved_planform() {
  hull() {
    translate([(base_L/2 + (arm_len_from_base*0.35)/2 - overlap), 0, 0])
      cube([(arm_len_from_base*0.35), arm_neck_w, arm_thk], center=true);
    translate([(base_L/2 + (arm_len_from_base*0.45)/2 + arm_len_from_base*0.25 - overlap), (arm_elbow_offset_y*0.35), 0])
      cube([(arm_len_from_base*0.45), arm_w, arm_thk], center=true);
    translate([(base_L/2 + arm_len_from_base - (arm_len_from_base*0.35)/2 - overlap), arm_elbow_offset_y, 0])
      cube([(arm_len_from_base*0.35), arm_w, arm_thk], center=true);
  }
}

// Arm tip with obround end
module arm_tip_obround_end() {
  union() {
    translate([(base_L/2 + arm_len_from_base + arm_tip_L/2 - overlap), arm_elbow_offset_y, 0])
      cube([(arm_tip_L - 2*arm_tip_r), arm_tip_W, arm_thk], center=true);
    translate([(base_L/2 + arm_len_from_base + arm_tip_L - arm_tip_r - overlap), arm_elbow_offset_y, 0])
      rotate([90, 0, 0])
      cylinder(r=arm_tip_r, h=arm_thk, center=true);
    translate([(base_L/2 + arm_len_from_base + arm_tip_r - overlap), arm_elbow_offset_y, 0])
      rotate([90, 0, 0])
      cylinder(r=arm_tip_r, h=arm_thk, center=true);
  }
}

// Arm with tip
module arm_with_tip() {
  union() {
    arm_curved_planform();
    arm_tip_obround_end();
  }
}

// Arm to base blend fillet approx
module arm_to_base_blend_fillet_approx() {
  hull() {
    translate([(base_L/2 - overlap), 0, 0])
      sphere(r=blend_r);
    translate([(base_L/2 + blend_r - overlap), 0, 0])
      sphere(r=blend_r);
  }
}

// Cosmetic rounding on bosses
module cosmetic_rounding_on_bosses() {
  hull() {
    translate([(base_L/2 + boss_offset_from_base_face + boss_L/2 - overlap), (arm_neck_w/2 + boss_W/2 - overlap), 0])
      cube([boss_L, boss_W, boss_H], center=true);
    translate([(base_L/2 + boss_offset_from_base_face + boss_L - overlap), (arm_neck_w/2 + boss_W - overlap), 0])
      sphere(r=(boss_W/2));
  }
}

// Cosmetic rounding on bosses right
module cosmetic_rounding_on_bosses_right() {
  hull() {
    translate([(base_L/2 + boss_offset_from_base_face + boss_L/2 - overlap), (-arm_neck_w/2 - boss_W/2 + overlap), 0])
      cube([boss_L, boss_W, boss_H], center=true);
    translate([(base_L/2 + boss_offset_from_base_face + boss_L - overlap), (-arm_neck_w/2 - boss_W + overlap), 0])
      sphere(r=(boss_W/2));
  }
}

// Bracket union pre cuts
module bracket_union_pre_cuts() {
  union() {
    base_block_rounded_rectangle();
    arm_with_tip();
    cosmetic_rounding_on_bosses();
    cosmetic_rounding_on_bosses_right();
    arm_to_base_blend_fillet_approx();
  }
}

// Small top relief steps
module small_top_relief_steps() {
  union() {
    translate([(-base_L/2 + relief_step_L/2), 0, (base_H/2 - relief_step_depth/2 + overlap)])
      cube([relief_step_L, relief_step_W, relief_step_depth], center=true);
    translate([(-base_L/2 + relief_step_L*0.65), 0, (base_H/2 - (relief_step_depth*0.7)/2 + overlap)])
      cube([(relief_step_L*0.7), (relief_step_W*0.6), (relief_step_depth*0.7)], center=true);
  }
}

// Edge chamfers
module edge_chamfers() {
  union() {
    translate([(base_L/2 - chamfer_cut/2 + overlap), 0, 0])
      cube([chamfer_cut, base_W, base_H], center=true);
    translate([(-base_L/2 + chamfer_cut/2 - overlap), 0, 0])
      cube([chamfer_cut, base_W, base_H], center=true);
    translate([0, (base_W/2 - chamfer_cut/2 + overlap), 0])
      cube([base_L, chamfer_cut, base_H], center=true);
    translate([0, (-base_W/2 + chamfer_cut/2 - overlap), 0])
      cube([base_L, chamfer_cut, base_H], center=true);
  }
}

// Complete model
difference() {
  bracket_union_pre_cuts();
  small_top_relief_steps();
  edge_chamfers();
}
}
