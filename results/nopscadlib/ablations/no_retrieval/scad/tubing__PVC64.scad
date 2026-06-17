// PVC aquarium tubing (hollow tube)
// Fix: ensure non-zero wall thickness and avoid self-canceling geometry.
// Also orient tube along X so orthographic views show a recognizable long tube.

$fn = 128;

// Parameters
tube_length     = 1000; //[500:2000:10]
outer_diameter  = 6;    //[3:12:0.5]
inner_diameter  = 4;    //[2:10:0.5]
wall_thickness  = 1;    //[0.5:3:0.1]  // fallback if inner_diameter invalid
end_face_square = 1;    //[0:1:1]      // 1 = square ends, 0 = chamfered ends
chamfer_length  = 1;    //[0.5:5:0.1]
chamfer_radial  = 0.5;  //[0.2:2:0.1]
bore_overlap    = 2;    //[0.5:10:0.5]
eps             = 0.02;

// Derived (robust radii)
outer_r = max(0.05, outer_diameter/2);
inner_r_limit = max(0.01, outer_r - max(0.05, wall_thickness));
inner_r_raw   = inner_diameter/2;
inner_r       = (inner_r_raw > 0 && inner_r_raw < inner_r_limit) ? inner_r_raw : inner_r_limit;

// Chamfer cutter placed at an end (along X axis)
module end_chamfer_cutter(sign=1) {
  // sign = +1 for +X end, -1 for -X end
  translate([sign*(tube_length/2 - chamfer_length/2), 0, 0])
    rotate([0, 90, 0])  // make cylinder axis along X
      cylinder(
        h  = chamfer_length + 2*eps,
        r1 = outer_r + chamfer_radial,
        r2 = max(0.01, outer_r - chamfer_radial),
        center = true
      );
}

// Final tube (ONE connected solid)
module pvc_tube() {
  difference() {
    // Outer body (optionally chamfered)
    difference() {
      rotate([0, 90, 0]) cylinder(h=tube_length, r=outer_r, center=true); // axis along X
      if (end_face_square == 0) {
        end_chamfer_cutter(+1);
        mirror([1,0,0]) end_chamfer_cutter(+1);
      }
    }

    // Inner bore (slightly longer for clean subtraction)
    rotate([0, 90, 0]) cylinder(h=tube_length + 2*bore_overlap, r=inner_r, center=true);
  }
}

color([0.85, 0.85, 0.8]) pvc_tube();