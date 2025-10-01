const char *colorname[] = {

  /* 8 normal colors */
  [0] = "#100907", /* black   */
  [1] = "#9B2407", /* red     */
  [2] = "#B72104", /* green   */
  [3] = "#CE1902", /* yellow  */
  [4] = "#E41E02", /* blue    */
  [5] = "#D52303", /* magenta */
  [6] = "#EA2603", /* cyan    */
  [7] = "#c3c1c1", /* white   */

  /* 8 bright colors */
  [8]  = "#695c56",  /* black   */
  [9]  = "#9B2407",  /* red     */
  [10] = "#B72104", /* green   */
  [11] = "#CE1902", /* yellow  */
  [12] = "#E41E02", /* blue    */
  [13] = "#D52303", /* magenta */
  [14] = "#EA2603", /* cyan    */
  [15] = "#c3c1c1", /* white   */

  /* special colors */
  [256] = "#100907", /* background */
  [257] = "#c3c1c1", /* foreground */
  [258] = "#c3c1c1",     /* cursor */
};

/* Default colors (colorname index)
 * foreground, background, cursor */
 unsigned int defaultbg = 0;
 unsigned int defaultfg = 257;
 unsigned int defaultcs = 258;
 unsigned int defaultrcs= 258;
