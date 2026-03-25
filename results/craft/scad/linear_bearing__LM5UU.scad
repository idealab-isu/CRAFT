// Linear bearing: 5.0mm bore, 10.0mm OD, 15.0mm length
// One connected solid (single sleeve with through bore)

// Parameters
bore_diameter_mm  = 5.0;   // bore
outer_diameter_mm = 10.0;  // OD
length_mm         = 15.0;  // length

eps_mm = 0.2;              // clearance / robustness for boolean ops

$fn = 128;

module linear_bearing_5x10x15() {
    difference() {
        // Outer sleeve
        cylinder(d=outer_diameter_mm, h=length_mm, center=true);

        // Through bore (slightly oversized for clean subtraction)
        cylinder(d=bore_diameter_mm + 2*eps_mm, h=length_mm + 2*eps_mm, center=true);
    }
}

linear_bearing_5x10x15();