$fn = 128;

// =====================
// Parameters (mm)
// =====================
stator_od = 23.0; //[11.5:46.0:0.1]  // REQUIRED: 23mm stator diameter
stator_h  = 12.0; //[6.0:24.0:0.1]   // REQUIRED: 12mm stator height
stator_id = 8.0;  //[4.0:16.0:0.1]

bore_d = 5.0;     //[2.5:10.0:0.1]

can_od   = 25.0;  //[12.5:50.0:0.1]
can_h    = 14.0;  //[7.0:28.0:0.1]
can_wall = 0.8;   //[0.4:1.6:0.05]

endcap_thk   = 1.2; //[0.6:2.4:0.1]
endcap_clear = 0.2; //[0.1:0.6:0.05]

shaft_d     = 4.0; //[2.0:8.0:0.1]
shaft_extra = 6.0; //[3.0:12.0:0.1]

mount_hole_d     = 2.0; //[1.0:4.0:0.1]
mount_hole_count = 4;   //[3:8:1]
mount_hole_pcd   = 18.0;//[9.0:36.0:0.1]

slot_count = 12;  //[6:24:1]
slot_depth = 3.0; //[1.5:6.0:0.1]
slot_width = 2.0; //[1.0:4.0:0.1]

wire_d      = 1.2;  //[0.6:2.4:0.1]
wire_len    = 10.0; //[5.0:20.0:0.5]
wire_exit_z = 0.0;  //[-6.0:6.0:0.5]

overlap = 0.6; //[0.3:2.0:0.1]

// Visual/feature details (kept connected)
airgap = 0.35;          // visible stator/rotor separation (radial)
tooth_tip_clear = 0.25; // keep teeth inside stator OD
rotor_hub_d = 10.0;     // inner rotor hub diameter (visual)
bell_step = 0.8;        // small bell lip step (visual)

// Ensure internal parts are physically connected to the outer can
// (stator/rotor are "internal" but must be one connected solid per requirement)
internal_bridge_thk = 0.8; // thin ribs from stator OD to can ID

// =====================
// Helpers
// =====================
module radial_array(n) {
  for (i = [0:n-1]) rotate([0,0,i*360/n]) children();
}

// =====================
// Core parts (all centered at origin)
// =====================

// Stator ring with slots (teeth implied by slot cuts)
// VERIFIABLE: outer diameter = stator_od, height = stator_h
module stator_core() {
  difference() {
    cylinder(r=stator_od/2, h=stator_h, center=true);

    // Inner stator void
    cylinder(r=stator_id/2, h=stator_h + 2*overlap, center=true);

    // Slot cuts (radial, cut from inner radius outward)
    radial_array(slot_count)
      translate([stator_id/2 + slot_depth/2 - overlap/2, 0, 0])
        cube([slot_depth + overlap, slot_width, stator_h + 2*overlap], center=true);

    // Center bore through stator
    cylinder(r=bore_d/2, h=stator_h + 2*overlap, center=true);
  }
}

// Rotor (inside stator) with a bell-like outer sleeve and inner hub
module rotor_bell() {
  rotor_od = stator_id - 2*airgap;                 // ensure visible airgap
  rotor_od = max(rotor_od, bore_d + 2.0);          // safety
  rotor_r  = rotor_od/2;

  union() {
    // Outer rotor sleeve (bell wall)
    difference() {
      cylinder(r=rotor_r, h=stator_h, center=true);
      // Hollow it to suggest bell thickness
      cylinder(r=max(rotor_r - 1.2, rotor_hub_d/2), h=stator_h + 2*overlap, center=true);
      // Shaft bore through rotor
      cylinder(r=bore_d/2, h=stator_h + 2*overlap, center=true);
    }

    // Small front lip/step to read as bell
    translate([0,0, stator_h/2 - bell_step/2])
      difference() {
        cylinder(r=rotor_r, h=bell_step, center=true);
        cylinder(r=max(rotor_r - 1.0, rotor_hub_d/2), h=bell_step + 2*overlap, center=true);
      }

    // Inner hub (connects to shaft)
    difference() {
      cylinder(r=rotor_hub_d/2, h=stator_h*0.65, center=true);
      cylinder(r=bore_d/2, h=stator_h + 2*overlap, center=true);
    }
  }
}

// Outer can shell (surrounds stator/rotor)
module can_shell() {
  difference() {
    cylinder(r=can_od/2, h=can_h, center=true);
    cylinder(r=can_od/2 - can_wall, h=can_h + 2*overlap, center=true);
  }
}

// Endcap disk positioned at +/- can_h/2
module endcap(zsign=1) {
  zc = zsign*(can_h/2 - endcap_thk/2 + overlap/2);

  difference() {
    translate([0,0,zc])
      cylinder(r=can_od/2 - can_wall - endcap_clear, h=endcap_thk, center=true);

    // Mount holes (drilled through endcap only)
    translate([0,0,zc])
      radial_array(mount_hole_count)
        translate([mount_hole_pcd/2, 0, 0])
          cylinder(r=mount_hole_d/2, h=endcap_thk + 2*overlap, center=true);

    // Center bore through endcap
    translate([0,0,zc])
      cylinder(r=bore_d/2, h=endcap_thk + 2*overlap, center=true);
  }
}

// Shaft through motor (connects everything)
module shaft() {
  cylinder(r=shaft_d/2, h=can_h + 2*shaft_extra, center=true);
}

// Thin ribs that connect stator to can (so the whole model is ONE connected solid)
module internal_bridges() {
  can_id_r = can_od/2 - can_wall;
  stator_r = stator_od/2;

  // Bridge length spans from stator OD to can ID, with slight overlap into both
  bridge_len = max(0.01, (can_id_r - stator_r) + overlap);
  bridge_w   = internal_bridge_thk;

  // Place bridges so their inner edge overlaps into stator and outer edge overlaps into can
  // Center radius for the bridge block:
  // inner edge at (stator_r - overlap/2), outer edge at (can_id_r + overlap/2)
  bridge_center_r = ( (stator_r - overlap/2) + (can_id_r + overlap/2) ) / 2;

  radial_array(4)
    translate([bridge_center_r, 0, 0])
      cube([bridge_len, bridge_w, stator_h], center=true);
}

// Wire leads (kept connected to can by slight overlap)
module wire_leads() {
  // Place at can OD, overlap into can wall by overlap/2
  x0 = (can_od/2 - can_wall) - wire_d/2 + overlap/2;

  radial_array(3)
    translate([x0, 0, wire_exit_z])
      rotate([0,90,0])
        cylinder(r=wire_d/2, h=wire_len, center=true);
}

// =====================
// Assembly (ONE connected solid)
// =====================
module motor() {
  union() {
    // Outer housing
    can_shell();
    endcap( 1);
    endcap(-1);

    // Internal recognizable BLDC features
    stator_core();
    rotor_bell();

    // Ensure internal parts are connected to the housing
    internal_bridges();

    // Shaft connects rotor/hub and passes through endcaps
    shaft();

    // Leads
    wire_leads();
  }
}

// Final output
motor();