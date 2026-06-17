$fn = 96;

// 6R8 3W vitreous enamel resistor (axial)
// Oriented along X so orthographic front/back/left/right show the full part.

// Parameters
body_length = 26;            //[12:40:0.5]  // 3W typically larger than 1/4W
body_diameter = 9.5;         //[5:14:0.1]
lead_diameter = 0.9;         //[0.4:1.6:0.05]
lead_length_each = 32;       //[15:70:1]
end_cap_length = 2.2;        //[1:4:0.1]
end_cap_diameter = 10.0;     //[5:14:0.1]
band_width = 2.4;            //[1:5:0.1]
band_thickness = 0.25;       //[0.05:0.6:0.01]
gloss_thickness = 0.12;      //[0.02:0.35:0.01]
overlap = 0.6;               //[0.2:2:0.1]

// Derived
body_r = body_diameter/2;
cap_r  = end_cap_diameter/2;
lead_r = lead_diameter/2;

half_body = body_length/2;
half_cap  = end_cap_length/2;

// Positions along X (axial)
cap_x = half_body + half_cap - overlap; // cap centers
lead_h = lead_length_each + end_cap_length + 2*overlap;
lead_x = half_body + end_cap_length + lead_h/2 - overlap; // lead centers

// Modules
module resistor_body() {
  // Slightly rounded cylinder (vitreous enamel look)
  color([0.86, 0.86, 0.82])
  rotate([0,90,0])
    hull() {
      translate([0,0,-half_body + 0.6]) sphere(r=body_r);
      translate([0,0, half_body - 0.6]) sphere(r=body_r);
    }
}

module end_cap(sign=1) {
  color("Silver")
  translate([sign*cap_x, 0, 0])
    rotate([0,90,0])
      cylinder(h=end_cap_length, r=cap_r, center=true);
}

module lead(sign=1) {
  color("DimGray")
  translate([sign*lead_x, 0, 0])
    rotate([0,90,0])
      cylinder(h=lead_h, r=lead_r, center=true);
}

module color_band() {
  // Single dark band (generic marking)
  color([0.18, 0.18, 0.2])
  rotate([0,90,0])
    cylinder(h=band_width, r=body_r + band_thickness, center=true);
}

module surface_gloss() {
  // Subtle gloss sleeve, kept within body length
  gloss_h = max(0.1, body_length - 2*band_width);
  color([0.95, 0.95, 0.95, 0.25])
  rotate([0,90,0])
    cylinder(h=gloss_h, r=body_r + gloss_thickness, center=true);
}

// Assemble as ONE connected solid (slight overlaps everywhere)
module resistor_complete() {
  union() {
    resistor_body();
    end_cap(-1);
    end_cap( 1);
    lead(-1);
    lead( 1);
    color_band();
    surface_gloss();
  }
}

resistor_complete();