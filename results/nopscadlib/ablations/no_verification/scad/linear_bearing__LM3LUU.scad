// Long linear bearing: 3.0mm bore, 7.0mm OD, 19.0mm length
// Single connected solid (bearing only)

// Parameters
bore_diameter_mm  = 3.0;  //[1.5:6.0:0.1]
outer_diameter_mm = 7.0;  //[3.5:14.0:0.1]
length_mm         = 19.0; //[9.5:38.0:0.1]
chamfer_mm        = 0.2;  //[0.0:1.0:0.05]
overlap_mm        = 0.6;  //[0.2:2.0:0.1]

$fn = 128;

module linear_bearing(bore_d=bore_diameter_mm, od=outer_diameter_mm, L=length_mm, chamfer=chamfer_mm, overlap=overlap_mm) {

  // Ensure valid geometry
  bore_r = bore_d/2;
  od_r   = od/2;
  ch     = max(0, chamfer);
  ov     = max(0.01, overlap);

  difference() {
    // Outer body (OD = 7mm, length = 19mm)
    cylinder(h=L, r=od_r, center=true);

    // Inner bore (ID = 3mm) + lead-in chamfers
    union() {
      // Through bore (extend beyond ends to guarantee a clean cut)
      cylinder(h=L + 2*ov, r=bore_r, center=true);

      // Lead-in at +Z end (connected via overlap)
      if (ch > 0)
        translate([0, 0,  L/2 - (ch + ov)/2])
          cylinder(h=ch + ov, r1=bore_r + ch, r2=bore_r, center=true);

      // Lead-in at -Z end (connected via overlap)
      if (ch > 0)
        translate([0, 0, -L/2 + (ch + ov)/2])
          cylinder(h=ch + ov, r1=bore_r, r2=bore_r + ch, center=true);
    }
  }
}

linear_bearing();