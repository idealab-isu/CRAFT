// Linear bearing: 3.0mm bore, 7.0mm OD, 10.0mm length
// One connected solid (simple cylindrical sleeve with circular bore)

// Parameters
bore_diameter_mm  = 3.0;  //[1.5:6:0.1]
outer_diameter_mm = 7.0;  //[3.5:14:0.1]
length_mm         = 10.0; //[5:20:0.1]
overlap_mm        = 0.2;  //[0.05:1:0.05]

// Derived
bore_r  = bore_diameter_mm / 2;
outer_r = outer_diameter_mm / 2;

$fn = 128;

module linear_bearing() {
  difference() {
    cylinder(r=outer_r, h=length_mm, center=true);
    cylinder(r=bore_r,  h=length_mm + 2*overlap_mm, center=true);
  }
}

linear_bearing();