// Dimension-calibrated (target: 0.01 x 0.01 x 0.03 mm)
scale([1.428899, 1.428899, 0.847527])
{
// Rotationally symmetric knob with scalloped rim, faceted barrel, rounded shoulder,
// coaxial boss, and a CENTRAL SQUARE THROUGH-HOLE (true through-cut).

// ---------------- Parameters ----------------
main_d = 0.01;          //[0.005:0.02:0.0001]
main_h = 0.022;         //[0.011:0.044:0.0001]
boss_d = 0.006;         //[0.003:0.012:0.0001]
boss_h = 0.008;         //[0.004:0.016:0.0001]
square_hole_w = 0.003;  //[0.0015:0.006:0.0001]

shoulder_h = 0.002;     //[0.001:0.004:0.0001]
facet_count = 8;        //[4:24:1]

scallop_count = 24;     //[8:64:1]
scallop_depth = 0.0008; //[0.0002:0.0012:0.00005]

overlap = 0.001;        //[0.0002:0.002:0.00005]  // ~1mm overlap for robust connectivity
micro_fillet_r = 0.00025; //[0.0001:0.0006:0.00005]

// ---------------- Derived ----------------
main_r  = main_d/2;
boss_r  = boss_d/2;

// Total height of the *outer* solid (used for through-hole length)
outer_total_h = main_h + boss_h;

$fn = 128;

// ---------------- Base geometry ----------------
module faceted_main_barrel() {
  // Faceted sides (polygonal cylinder), centered at origin
  rotate([0,0,180/facet_count])
    cylinder(h=main_h, r=main_r, center=true, $fn=facet_count);
}

module scalloped_band_cutters(rim_h, rim_z) {
  // Subtractive "bites" to form scallops around the circumference
  bite_r = scallop_depth * 1.6;
  bite_center_r = main_r + bite_r * 0.65;

  for (i = [0:scallop_count-1]) {
    rotate([0,0,i*360/scallop_count])
      translate([bite_center_r, 0, rim_z])
        cylinder(h=rim_h + 2*overlap, r=bite_r, center=true, $fn=48);
  }
}

module scalloped_main_barrel() {
  // Scalloped/serrated band near the bottom of the main barrel
  rim_h = main_h * 0.28;
  rim_z = -main_h/2 + rim_h/2;

  difference() {
    faceted_main_barrel();
    scalloped_band_cutters(rim_h, rim_z);
  }
}

module rounded_shoulder() {
  // Rounded transition from main barrel to boss via hull.
  // Recalculated to guarantee overlap into BOTH parts.
  // Main barrel spans: z = [-main_h/2, +main_h/2]
  // Boss spans (with overlap): centered at z = main_h/2 + boss_h/2 - overlap
  // so its bottom is at z = main_h/2 - overlap.
  z_main =  main_h/2 - shoulder_h/2;                 // inside main barrel top
  z_boss =  main_h/2 - overlap + shoulder_h/2;       // inside boss bottom

  hull() {
    translate([0,0,z_main])
      cylinder(h=shoulder_h, r=main_r, center=true, $fn=96);
    translate([0,0,z_boss])
      cylinder(h=shoulder_h, r=boss_r, center=true, $fn=96);
  }
}

module coaxial_boss() {
  // Boss on top end, overlapped into shoulder/main
  translate([0,0, main_h/2 + boss_h/2 - overlap])
    cylinder(h=boss_h, r=boss_r, center=true, $fn=96);
}

module outer_body() {
  union() {
    scalloped_main_barrel();
    rounded_shoulder();
    coaxial_boss();
  }
}

// ---------------- Subtractions ----------------
module square_through_hole() {
  // True square through-hole along Z, long enough to cut through filleted outer body.
  // Keep axis-aligned so it reads as a square in orthographic end views.
  hole_h = outer_total_h + 12*overlap + 2*micro_fillet_r;
  cube([square_hole_w, square_hole_w, hole_h], center=true);
}

// ---------------- Final ----------------
difference() {
  // Fillet outer body only, then cut the square hole through everything.
  minkowski() {
    outer_body();
    sphere(r=micro_fillet_r, $fn=32);
  }
  square_through_hole();
}
}
