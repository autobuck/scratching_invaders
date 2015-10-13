/* Stage.java
 * Scratching  -- Scratch for Processing
 *
 * This file seeks to implement Scratch blocks and sprites in
 * Processing, in order to facilitate a transition from Scratch
 * into p.
 * See: http://wiki.scratch.mit.edu/wiki/Blocks
 *
 * This Stage class has just a few simple functions for handling
 * the background. 
 *
 * switchToBackdrop(#); can replace the background(#);
 * command at the top of your draw() loop.
 *
 * The backdrop size should match your stage size.
 * Who knows what might happen if it does not?!
 *
 */

import processing.core.PApplet;
import processing.core.PImage;
import processing.core.PFont;
import java.util.ArrayList;

public class Stage {

  // without this, built-in functions are broken. use p.whatever to access functionality
  PApplet p;

  // listing our backgrounds here lets us access them by name instead of number in our main program
  // ie, switchToBackdrop(bg_title); instead of switchToBackdrop(1).
  //
  // You may use your own art for your own project by adding PNG or JPG art to the file folder,
  // and changing the "addDefaultBackdrops()" function below.
  // 
  // Backdrop 0 should always the X/Y grid, for debugging movement
  public static final int bg_grid=0;
  public static final int bg_title=1;
  public static final int bg_highway=2;
  public static final int bg_gameover=3;

  public int startTime;
  public int backdropNumber, numberOfBackdrops;
  public ArrayList<PImage> backdrops = new ArrayList<PImage>();
  int scrollX, scrollY;
  
  Stage (PApplet parent) {
    p = parent;
    backdropNumber=0;
    numberOfBackdrops=0;
    startTime=0;
    resetTimer();
    scrollX = 0; scrollY = 0;
  }
  
  // the timer returns seconds, in whole numbers (integer)
  public int timer() {
    int temp = p.millis()/1000;
    return temp-startTime;
  } 
  
  // reset the stage timer
  public void resetTimer() {
    startTime = p.millis()/1000;
  }


  public void update() {
    draw();    
  }

  public void draw() {    
    int scrollXmod = scrollX % p.width;
    int scrollYmod = scrollY % p.height;
    // current logic doesn't check direction of scroll & draws unnecessary off-screen backdrops!
      if ( (scrollXmod) != 0 && (scrollYmod) == 0) {
        // scrolling X only. draw stages Y center
        p.image(backdrops.get(backdropNumber), (p.width/2)+scrollXmod, (p.height/2), backdrops.get(backdropNumber).width,
        backdrops.get(backdropNumber).height);
        // for scrolling right, draw to the left of stage
        p.image(backdrops.get(backdropNumber), 0-(p.width/2)+scrollXmod, (p.height/2), backdrops.get(backdropNumber).width,
        backdrops.get(backdropNumber).height);
        // for scrolling left, draw to the right of stage
        p.image(backdrops.get(backdropNumber), p.width+(p.width/2)+scrollXmod, (p.height/2), backdrops.get(backdropNumber).width,
        backdrops.get(backdropNumber).height);
      } else if ( (scrollXmod) == 0 && (scrollYmod) != 0) {
        // scrolling Y only. draw center stage
        p.image(backdrops.get(backdropNumber), (p.width/2), (p.height/2)-scrollYmod, backdrops.get(backdropNumber).width,
        backdrops.get(backdropNumber).height);
        // for scrolling right, draw to the left of stage
        p.image(backdrops.get(backdropNumber), (p.width/2), 0-(p.height/2)-scrollYmod, backdrops.get(backdropNumber).width,
        backdrops.get(backdropNumber).height);
        // for scrolling left, draw to the right of stage
        p.image(backdrops.get(backdropNumber), (p.width/2), p.height+(p.height/2)-scrollYmod, backdrops.get(backdropNumber).width,
        backdrops.get(backdropNumber).height);
      } else if ( (scrollXmod) != 0 && (scrollYmod) != 0) {
        //*************** scrolling X and Y. draw stage Y top
        p.image(backdrops.get(backdropNumber), (p.width/2)+scrollXmod, (p.height/2)-scrollYmod, backdrops.get(backdropNumber).width,
        backdrops.get(backdropNumber).height);
        // for scrolling right, draw to the left of stage
        p.image(backdrops.get(backdropNumber), 0-(p.width/2)+scrollXmod, (p.height/2)-scrollYmod, backdrops.get(backdropNumber).width,
        backdrops.get(backdropNumber).height);
        // for scrolling left, draw to the right of stage
        p.image(backdrops.get(backdropNumber), p.width+(p.width/2)+scrollXmod, (p.height/2)-scrollYmod, backdrops.get(backdropNumber).width,
        backdrops.get(backdropNumber).height);
        //********** scrolling X and Y. draw center stages, 
        p.image(backdrops.get(backdropNumber), (p.width/2)+scrollXmod, 0-(p.height/2)-scrollYmod, backdrops.get(backdropNumber).width,
        backdrops.get(backdropNumber).height);
        // for scrolling right, draw to the left of stage
        p.image(backdrops.get(backdropNumber), 0-(p.width/2)+scrollXmod, 0-(p.height/2)-scrollYmod, backdrops.get(backdropNumber).width,
        backdrops.get(backdropNumber).height);
        // for scrolling left, draw to the right of stage
        p.image(backdrops.get(backdropNumber), p.width+(p.width/2)+scrollXmod, 0-(p.height/2)-scrollYmod, backdrops.get(backdropNumber).width,
        backdrops.get(backdropNumber).height);
        //********** scrolling X and Y. draw bottom stages 
        p.image(backdrops.get(backdropNumber), (p.width/2)+scrollXmod, p.height+(p.height/2)-scrollYmod, backdrops.get(backdropNumber).width,
        backdrops.get(backdropNumber).height);
        // for scrolling right, draw to the left of stage
        p.image(backdrops.get(backdropNumber), 0-(p.width/2)+scrollXmod, p.height+(p.height/2)-scrollYmod, backdrops.get(backdropNumber).width,
        backdrops.get(backdropNumber).height);
        // for scrolling left, draw to the right of stage
        p.image(backdrops.get(backdropNumber), p.width+(p.width/2)+scrollXmod, p.height+(p.height/2)-scrollYmod, backdrops.get(backdropNumber).width,
        backdrops.get(backdropNumber).height);
      } else {
        p.image(backdrops.get(backdropNumber), (p.width/2), (p.height/2), backdrops.get(backdropNumber).width,
        backdrops.get(backdropNumber).height);
      }
  }

  // load xy grid as backdrop 0
  public void loadDefaultBackdrop() {
    addBackdrop("images/xy-grid.png");
  }
    

  // add costume from bitmap image file
  public void addBackdrop(String filePath) {
    numberOfBackdrops++;
    backdrops.add(p.loadImage(filePath));
  }

  // change to next backdrop
  public void nextBackdrop() { 
    backdropNumber++;
    if (backdropNumber > numberOfBackdrops + 1) backdropNumber=0;
    draw();
  }

  // change to previous backdrop
  public void previousCostume() {
    backdropNumber--;
    if (backdropNumber < 0) backdropNumber=backdropNumber;
    draw();
  }

  // switch to specific costume
  public void setBackdrop(int newBackdropNumber) {
    backdropNumber=newBackdropNumber;
    draw();
  }
  
  public void scrollBackdrop(float x, float y) {
    scrollX += x;
    scrollY += y;
  }

  }
