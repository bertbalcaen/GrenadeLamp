import wblut.geom.core.*;
import wblut.hemesh.creators.*;
import wblut.hemesh.tools.*;
import wblut.geom.grid.*;
import wblut.geom.nurbs.*;
import wblut.core.math.*;
import wblut.hemesh.subdividors.*;
import wblut.core.processing.*;
import wblut.hemesh.composite.*;
import wblut.core.random.*;
import wblut.hemesh.core.*;
import wblut.geom.frame.*;
import wblut.core.structures.*;
import wblut.hemesh.modifiers.*;
import wblut.hemesh.simplifiers.*;
import wblut.geom.triangulate.*;
import wblut.geom.tree.*;
import processing.opengl.*;
import peasy.*;
import controlP5.*;

HE_Mesh mesh;
WB_Render render;
WB_Plane P;
WB_Line L;

boolean applyExtrude = true;
boolean applyBend = true;
boolean applyCatmullClark = true;
boolean drawBendDebug = false;

PeasyCam camera;
ControlP5 cp5;

void setup() {

  size(600, 600, OPENGL);

  cp5 = new ControlP5(this);

  float sliderX = 10;
  float sliderY = 10;
  float sliderSpacing = 15;
  float toggleSpacing = 40;

  cp5.addToggle("applyExtrude")
     .setPosition(sliderX, sliderY+=toggleSpacing)
     ;

  cp5.addToggle("applyBend")
     .setPosition(sliderX, sliderY+=toggleSpacing)
     ;

  cp5.addToggle("applyCatmullClark")
     .setPosition(sliderX, sliderY+=toggleSpacing)
     ;

  camera = new PeasyCam(this, 0, 0, 0, 600);
  
  makeMesh();

}
     
void makeMesh(){

  HEC_Sphere creator = new HEC_Sphere();
  creator.setRadius(200); 
  creator.setUFacets(16);
  creator.setVFacets(16);
  mesh = new HE_Mesh(creator); 

  HEM_Extrude extrude = new HEM_Extrude();
  extrude.setDistance(50);
  extrude.setRelative(false);
  extrude.setChamfer(5);
  if(applyExtrude){
    mesh.modify(extrude);
  }

  HEM_Bend bend =  new HEM_Bend();
  P = new WB_Plane(0, 0, 0, 0, 0, 1); 
  bend.setGroundPlane(P); 
  L = new WB_Line(0, 0,400, 0, 0, -400);
  bend.setBendAxis(L);
  bend.setAngleFactor(100.0/400);
  bend.setPosOnly(false);
  if(applyBend){
    mesh.modify(bend);
  }

  HES_CatmullClark catmullClark = new HES_CatmullClark();
  if(applyCatmullClark){
    mesh.subdivide(catmullClark);
  }

  render = new WB_Render(this);
  
  HET_Export.saveToOBJ(mesh, sketchPath("lamp.obj")); 
  
}

void draw() {

  background(100);
  lights();

  fill(200);
  noStroke();
  render.drawFaces(mesh);
  
  noFill();
  stroke(10);
  render.drawEdges(mesh);
  
  if(drawBendDebug){
    render.draw(P, 500);
    render.draw(L, 800);
  }
  
  noLights();
  hint(DISABLE_DEPTH_TEST);
  camera.beginHUD();
  cp5.draw();
  camera.endHUD();
  hint(ENABLE_DEPTH_TEST);
 
}

void keyPressed(){
  makeMesh();
}




