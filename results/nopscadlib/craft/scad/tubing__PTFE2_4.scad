// Parameters
length = 15; //[8:30:1]
od = 4; //[2:8:0.1]
id = 2; //[1:6:0.1]
center = true; //[0:1:1]
forced_id = 0; //[0:6:0.1]
eps = 0.8; //[0.5:2:0.1]
bore_d = 2; //[1:6:0.1]
z_offset = 0; //[-30:30:1]

// Smoothness
$fn = 128;

// Tubing - circular PTFE tube with circular bore
module tubing() {
  // Choose bore diameter: forced_id overrides, else use id, else bore_d
  bore = (forced_id > 0) ? forced_id : ((id > 0) ? id : bore_d);

  // Ensure valid tube wall thickness
  bore_clamped = min(bore, max(od - 0.2, 0.01));

  // Place inner cutter so it always fully spans the outer cylinder regardless of centering
  inner_h = length + 2*eps;
  inner_z = center ? 0 : (length/2);

  color([0.85, 0.85, 0.8])
  difference() {
    cylinder(h=length, r=od/2, center=center);
    translate([0, 0, inner_z])
      cylinder(h=inner_h, r=bore_clamped/2, center=true);
  }
}

// Assembly
module assembly() {
  translate([0, 0, z_offset]) tubing();
}

assembly();