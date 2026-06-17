$fn = 128;

// -------------------- Parameters (mm) --------------------
stator_d = 28.0;          // stator OD (key requirement)
stator_h = 17.25;         // stator height (key requirement)

bore_d = 5.0;             // stator center bore (for shaft/bearing region)
slot_count = 12;
slot_depth = 2.6;
slot_width = 2.0;

housing_wall_t = 1.0;
housing_clearance = 0.25;

rotor_clearance = 0.5;    // radial airgap between stator OD and rotor ID
rotor_can_wall_t = 0.6;

endcap_t = 1.5;
endcap_overhang = 0.8;

mount_hole_count = 4;
mount_hole_d = 2.2;
mount_hole_r = 12.0;      // keep within housing OD

shaft_d = 3.0;
shaft_len = 30.0;

wire_lead_d = 1.2;
wire_lead_len = 12.0;
wire_lead_count = 3;

fillet_r = 0.6;

// Use a small, consistent overlap to guarantee watertight unions
overlap = 1.2;

// -------------------- Derived dimensions --------------------
stator_r = stator_d/2;

housing_r_in  = stator_r + housing_clearance;
housing_r_out = housing_r_in + housing_wall_t;

rotor_r_in  = stator_r + rotor_clearance;     // rotor inner radius (around stator)
rotor_r_out = rotor_r_in + rotor_can_wall_t;

housing_h   = stator_h;                        // align housing height to stator height
rotor_can_h = stator_h - 1.0;                  // slightly shorter so endcaps read clearly

// Ensure rotor is inside housing
assert(rotor_r_out <= housing_r_in + 0.01,
       "Rotor OD must fit inside housing ID. Increase housing_clearance or reduce rotor_clearance/rotor_can_wall_t.");

// -------------------- Base shapes --------------------
module stator_core() {
  // Centered at origin; height exactly stator_h
  difference() {
    cylinder(r=stator_r, h=stator_h, center=true);

    // center bore
    cylinder(r=bore_d/2, h=stator_h + 2*overlap, center=true);

    // slots cut from OD inward
    for (i = [0:slot_count-1]) {
      rotate([0,0,i*360/slot_count])
        translate([stator_r - slot_depth/2, 0, 0])
          cube([slot_depth + overlap, slot_width, stator_h + 2*overlap], center=true);
    }
  }
}

module housing_sleeve() {
  // Centered at origin; height exactly housing_h
  difference() {
    cylinder(r=housing_r_out, h=housing_h, center=true);
    cylinder(r=housing_r_in,  h=housing_h + 2*overlap, center=true);
  }
}

module endcaps() {
  // Endcaps overlap into the housing so everything is one connected solid
  union() {
    translate([0,0, housing_h/2 + endcap_t/2 - overlap])
      cylinder(r=housing_r_out + endcap_overhang, h=endcap_t, center=true);

    translate([0,0,-housing_h/2 - endcap_t/2 + overlap])
      cylinder(r=housing_r_out + endcap_overhang, h=endcap_t, center=true);
  }
}

module mounting_holes_cut() {
  // Through-holes across full motor body (endcaps included)
  for (i = [0:mount_hole_count-1]) {
    rotate([0,0,i*360/mount_hole_count])
      translate([mount_hole_r, 0, 0])
        cylinder(r=mount_hole_d/2,
                 h=housing_h + 2*endcap_t + 6*overlap,
                 center=true);
  }
}

module rotor_can() {
  // Rotor can sits inside housing; centered at origin
  difference() {
    cylinder(r=rotor_r_out, h=rotor_can_h, center=true);
    cylinder(r=rotor_r_in,  h=rotor_can_h + 2*overlap, center=true);
  }
}

module shaft() {
  // Shaft passes through motor; centered at origin
  cylinder(r=shaft_d/2, h=shaft_len, center=true);
}

module wire_leads() {
  // Leads must intersect the housing wall and also intersect the bottom endcap region.
  // Place them slightly below the housing mid-plane so they clearly "exit" near the bottom.
  z0 = -housing_h/2 - endcap_t/2 + overlap; // inside bottom endcap by 'overlap'

  for (i = [0:wire_lead_count-1]) {
    rotate([0,0,i*360/wire_lead_count])
      // Ensure connection: start inside housing wall by 'overlap'
      translate([housing_r_out - overlap + wire_lead_len/2, 0, z0])
        rotate([0,90,0])
          cylinder(r=wire_lead_d/2, h=wire_lead_len, center=true);
  }
}

// -------------------- Assembly --------------------
module motor_sharp() {
  // Single connected solid after subtraction of mounting holes
  difference() {
    union() {
      // Main recognizable BLDC silhouette: housing + endcaps + shaft
      housing_sleeve();
      endcaps();

      // Internal recognizable elements (kept, but do NOT remove the outer silhouette)
      // Ensure they are solidly connected to the rest via overlap (they already intersect).
      stator_core();
      rotor_can();

      // Shaft and wire leads for BLDC identity
      shaft();
      wire_leads();
    }
    mounting_holes_cut();
  }
}

// Minkowski can sometimes create degenerate/empty-looking previews in some render pipelines.
// Keep rounding optional and default to the sharp, clearly visible motor.
module rounded_motor() {
  minkowski() {
    motor_sharp();
    sphere(r=fillet_r, $fn=24);
  }
}

// ---- Output ----
// Use the sharp model for robust visibility in orthographic views.
// (Switch to rounded_motor(); if you specifically need fillets.)
motor_sharp();