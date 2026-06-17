$fn=96;

// Sellotape-like tape sheet (a thin rectangular strip)
tape_length = 120;
tape_width  = 24;
tape_thick  = 0.06;

// Slightly translucent amber color typical of clear tape
color([1.0, 0.85, 0.45, 0.35])
cube([tape_length, tape_width, tape_thick], center=false);