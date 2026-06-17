// Linear bearing (LM12UU-like) with optional side boss (kept connected)
// Target: 12.0mm bore, 21.0mm OD, 30.0mm length

$fn = 128;

// Parameters
bore_diameter_mm = 12.0;          //[6.0:24.0:0.1]
outer_diameter_mm = 21.0;         //[10.5:42.0:0.1]
length_mm = 30.0;                //[15.0:60.0:0.1]

eps_mm = 0.2;                     //[0.05:0.5:0.05]
overlap_mm = 1.0;                 //[0.5:2.0:0.1]

groove_width_mm = 2.0;            //[1.0:4.0:0.1]
groove_depth_mm = 0.6;            //[0.2:1.5:0.1]
groove_offset_from_end_mm = 4.0;  //[2.0:8.0:0.1]

// Optional connected side boss (set to 0 to disable)
boss_diameter_mm = 0.0;           //[0.0:12.0:0.1]
boss_length_mm = 0.0;             //[0.0:20.0:0.5]

// Derived
OD = outer_diameter_mm;
ID = bore_diameter_mm;
L  = length_mm;

module linear_bearing_body() {
  difference() {
    // Outer cylinder
    cylinder(d=OD, h=L, center=true);

    // Through bore (typical linear bearing)
    cylinder(d=ID, h=L + 2*eps_mm, center=true);

    // Two shallow external grooves near ends (cut into OD)
    for (z = [-L/2 + groove_offset_from_end_mm, L/2 - groove_offset_from_end_mm]) {
      translate([0, 0, z])
        difference() {
          cylinder(d=OD + 2*eps_mm, h=groove_width_mm + 2*eps_mm, center=true);
          cylinder(d=OD - 2*groove_depth_mm, h=groove_width_mm + 4*eps_mm, center=true);
        }
    }
  }
}

module connected_boss() {
  if (boss_diameter_mm > 0 && boss_length_mm > 0) {
    // Boss axis along +X, tangent/overlapping into bearing OD so it's one connected solid
    translate([OD/2 + boss_length_mm/2 - overlap_mm, 0, 0])
      rotate([0, 90, 0])
        cylinder(d=boss_diameter_mm, h=boss_length_mm, center=true);
  }
}

union() {
  linear_bearing_body();
  connected_boss();
}