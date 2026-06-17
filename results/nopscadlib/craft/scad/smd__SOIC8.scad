// Simple SMD block: exact overall dimensions [4.90, 3.90, 1.25]
// One connected solid, no extra protrusions/steps, no text.

body_length = 4.90;
body_width  = 3.90;
body_height = 1.25;

union() {
    cube([body_length, body_width, body_height], center=false);
}