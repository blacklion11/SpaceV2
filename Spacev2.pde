
HashMap<Integer,Block> blockTypes = new HashMap<Integer,Block>();

HashMap<Integer,World> worlds = new HashMap<Integer,World>();

HashMap<Integer,Integer> inventory = new HashMap<Integer,Integer>();

ArrayList<Integer> removeItems = new ArrayList<Integer>();



//pixels
public int blockSize = 32;
float movementSpeed = 10;
int playerSize = 32;

float yVelocity = 0;
float xVelocity = 0;
float gravity = 2;

//blocks
public int chunkSize = 32;
public int chunkHeight = 256;
float playerX = 5000;
float playerY = -10;
int verticalRenderDist = 20;

//chunks
int chunkRenderDist = 2;

World w;
int worldCount = -1;
int currentWorld = 0;

int xOffset = 0;

int selectedItem = 0;

//PImage sky;
PImage background;
PImage player;
Gui g;

PVector curBlock = new PVector(-1,-1);
double startBreak = -1;




void setup() {
    player = loadImage("Blocks/Player.png");
    background = loadImage("Blocks/BackGround1.png");
    g = new Gui();
    UIPanel p = new UIPanel(width/2-250,height/2-350,width/2,(int)(height/1.5),color(100,100,100,240),"Main Menu",width/2-100,200,false);
    p.setTextModeCenter(true);
    p.formatText(30,color(0));
    g.addPanel(p);
    p = new UIPanel(width/2-(width/8),height/2-250,width/4,30,color(100,100,100,240),"Play",width/2-100,height/2-600,true);
    p.setTextModeCenter(true);
    p.formatText(30,color(0));
    g.addPanel(p);

    size(1000,1000,P2D);
    //sky = loadImage("Blocks/Sky.png");
    loadFiles();

    w = new World();
    worlds.put(worldCount,w);
}

void loadFiles() {
    String[] temp = loadStrings("Blocks/Blocks.txt");
    
    for(int i = 0; i < temp.length; i++) {
        String[] lines = split(temp[i], ' ');
        Block b = new Block(i,lines[0],Boolean.valueOf(lines[1]),Integer.valueOf(lines[2]));
        blockTypes.put(i,b);
    }
}

void keyPressed() {
     if(key == 'w' && isGrounded()){     
            yVelocity -= 30; 
        }
        if(key == 'a' && xVelocity > -10){  
            xVelocity -= movementSpeed;     
        }
        if(key == 'd' && xVelocity < 10) {  
            xVelocity += movementSpeed; 
        }   
        key = ' ';
}

void mouseWheel(MouseEvent event) {
  selectedItem += event.getCount();
}


void draw() {
    
    if(mouseButton == LEFT) {
        int blockId = worlds.get(currentWorld).getBlock(mouseX+playerX-width/2,mouseY+playerY-height/2);
        println(millis() - startBreak);
        if(blockTypes.get(blockId).isSolid() && (millis() - startBreak > (blockTypes.get(blockId).hardness() * 100)) && startBreak != -1 && curBlock.x == (int)(mouseX+playerX-width/2)/blockSize && curBlock.y == (int)(mouseY+playerY-height/2)/blockSize) {     
            worlds.get(currentWorld).changeBlock(mouseX+playerX-width/2,mouseY+playerY-height/2,0);
            
            if(!inventory.containsKey(blockId)) {            
                inventory.put(blockId,0);
            }
            inventory.put(blockId,inventory.get(blockId)+1);
            curBlock = new PVector(-1,-1);
            startBreak = -1;
        }else {
            curBlock.x = (int)(mouseX+playerX-width/2)/blockSize;
            curBlock.y = (int)(mouseY+playerY-height/2)/blockSize;
            if(startBreak == -1 || !blockTypes.get(blockId).isSolid())startBreak = millis();

        }

    }else {
        curBlock.x = (int)(mouseX+playerX-width/2)/blockSize;
        curBlock.y = (int)(mouseY+playerY-height/2)/blockSize;
        startBreak = -1;
    }



    //clear();
    if(selectedItem > inventory.size()-1) selectedItem = 0;
    if(selectedItem < 0)selectedItem = inventory.size()-1;
    if(inventory.size() == 0) selectedItem = 0;
    
    
    background(0, 0,255);

    if(keyPressed) {
       
    }else{
        xVelocity = 0;
    }

        if(yVelocity < 0 && !doCollision("up")) playerY += yVelocity;
        else if(yVelocity > 0 && !doCollision("down")) playerY += yVelocity;

        if(xVelocity < 0 && !doCollision("left")) playerX += xVelocity;
        else if(xVelocity > 0 && !doCollision("right")) playerX += xVelocity;

        if(yVelocity < movementSpeed) yVelocity+= gravity;
    

    translate(-playerX+(width/2.0), -playerY+(height/2.0));
    
    playerX = (int) playerX;
    playerY = (int) playerY;
    worlds.get(currentWorld).render();
    fill(255);
    //rect(playerX-(playerSize/2),playerY-(playerSize/2),playerSize,playerSize);
    image(player, playerX-(playerSize/2), playerY-(playerSize/2), playerSize, playerSize);
    translate(-(-playerX+(width/2.0)), -(-playerY+(height/2.0)));
    //g.drawUI();
   
   
   //inventory
    

    xOffset = -(int)((inventory.size()*blockSize)/2)-blockSize;

    stroke(0);
    for(Integer entry : inventory.keySet()) {
    if(inventory.get(entry) <= 0) removeItems.add(entry);
    else {
        xOffset+=blockSize;
        blockTypes.get(entry).draw((width/2)+xOffset,height-blockSize);
        noFill();
        rect((width/2)+xOffset,height-blockSize,blockSize,height-blockSize);
        fill(255);
        text(inventory.get(entry),(width/2)+xOffset+blockSize-textWidth(inventory.get(entry).toString()),height);
    }
   
    }
    for(Integer i: removeItems) {
        inventory.remove(i);
    }
    if(inventory.size() > 0) {
        stroke(255);
        noFill();
        xOffset = -(int)((inventory.size()*blockSize)/2);
        rect((width/2)+xOffset+selectedItem*blockSize,height-blockSize,blockSize,height-blockSize);
    }
}

boolean doCollision(String dir) {


    if(dir.equals("up")) {
        if((blockTypes.get(worlds.get(currentWorld).getBlock(playerX-(0.5*playerSize),playerY-abs(yVelocity)-(0.5*playerSize))).isSolid()) ||
        (blockTypes.get(worlds.get(currentWorld).getBlock(playerX+(0.5*playerSize),playerY-abs(yVelocity)-(0.5*playerSize))).isSolid())) {
             
            if(((((int)((playerX+(0.5*playerSize))/blockSize))*blockSize) == playerX+0.5*blockSize) && !blockTypes.get(worlds.get(currentWorld).getBlock(playerX,playerY-abs(yVelocity)-(0.5*playerSize))).isSolid()) return false;
            if(((((int)((playerX-(0.5*playerSize))/blockSize))*blockSize) == playerX-0.5*blockSize) && !blockTypes.get(worlds.get(currentWorld).getBlock(playerX,playerY-abs(yVelocity)-(0.5*playerSize))).isSolid()) return false;

            if((playerY-0.5*blockSize)-(((int)((playerY-(0.5*playerSize))/blockSize))*blockSize) != 0) {
                playerY+=(((int)((playerY+(0.5*playerSize))/blockSize))*blockSize)-(playerY+0.5*blockSize);
            }
            
            return true;
        }
    }
    if(dir.equals("down")) {
        if((blockTypes.get(worlds.get(currentWorld).getBlock(playerX-(0.5*playerSize),playerY+movementSpeed+(0.5*playerSize))).isSolid()) ||
        (blockTypes.get(worlds.get(currentWorld).getBlock(playerX+(0.5*playerSize),playerY+movementSpeed+(0.5*playerSize))).isSolid())) {
            
            if(((((int)((playerX+(0.5*playerSize))/blockSize))*blockSize) == playerX+0.5*blockSize) && !blockTypes.get(worlds.get(currentWorld).getBlock(playerX,playerY+movementSpeed+(0.5*playerSize))).isSolid()) return false;
            if(((((int)((playerX-(0.5*playerSize))/blockSize))*blockSize) == playerX-0.5*blockSize) && !blockTypes.get(worlds.get(currentWorld).getBlock(playerX,playerY+movementSpeed+(0.5*playerSize))).isSolid()) return false;

            if((playerY+0.5*blockSize)-(((int)((playerY+(0.5*playerSize))/blockSize))*blockSize) != 0) {
                playerY-=(playerY+0.5*blockSize)-(((int)((playerY+(0.5*playerSize))/blockSize))*blockSize)-blockSize;
            }
            
            return true;
        }

    }
    if(dir.equals("left")) {

        //if(blockTypes.get(worlds.get(currentWorld).getBlock(playerX-movementSpeed-(0.5*playerSize),playerY)).isSolid()) return true;

        if((blockTypes.get(worlds.get(currentWorld).getBlock(playerX-movementSpeed-(0.5*playerSize),playerY-(0.5*playerSize))).isSolid()) ||
        (blockTypes.get(worlds.get(currentWorld).getBlock(playerX-movementSpeed-(0.5*playerSize),playerY+(0.5*playerSize))).isSolid()) 
        ) {
            
            if(((((int)((playerY+(0.5*playerSize))/blockSize))*blockSize) == playerY+0.5*blockSize) && !blockTypes.get(worlds.get(currentWorld).getBlock(playerX-movementSpeed-(0.5*playerSize),playerY)).isSolid()) return false;
            if(((((int)((playerY-(0.5*playerSize))/blockSize))*blockSize) == playerY-0.5*blockSize) && !blockTypes.get(worlds.get(currentWorld).getBlock(playerX-movementSpeed-(0.5*playerSize),playerY)).isSolid()) return false;

            if((playerX+0.5*blockSize)-(((int)((playerX+(0.5*playerSize))/blockSize))*blockSize) != 0) {
                playerX+=(((int)((playerX+(0.5*playerSize))/blockSize))*blockSize)-(playerX+0.5*blockSize);
            }
            

            
            return true;
        }
    }
    if(dir.equals("right")) {
        if((blockTypes.get(worlds.get(currentWorld).getBlock(playerX+movementSpeed+(0.5*playerSize),playerY+(0.5*playerSize))).isSolid()) ||
        (blockTypes.get(worlds.get(currentWorld).getBlock(playerX+movementSpeed+(0.5*playerSize),playerY-(0.5*playerSize))).isSolid())) {
           
            if(((((int)((playerY+(0.5*playerSize))/blockSize))*blockSize) == playerY+0.5*blockSize) && !blockTypes.get(worlds.get(currentWorld).getBlock(playerX+movementSpeed+(0.5*playerSize),playerY)).isSolid()) return false;
            if(((((int)((playerY-(0.5*playerSize))/blockSize))*blockSize) == playerY-0.5*blockSize) && !blockTypes.get(worlds.get(currentWorld).getBlock(playerX+movementSpeed+(0.5*playerSize),playerY)).isSolid()) return false;


           if((playerX+0.5*blockSize)-(((int)((playerX+(0.5*playerSize))/blockSize))*blockSize) != 0) {
                playerX+=(((int)((playerX+(0.5*playerSize))/blockSize))*blockSize)-(playerX+0.5*blockSize)+blockSize;
            }
            
            return true;
        }
    }
    
    return false;
}

boolean isGrounded() {
    return(doCollision("down"));
}

void mousePressed() {
    int blockId = worlds.get(currentWorld).getBlock(mouseX+playerX-width/2,mouseY+playerY-height/2);
    
    if(mouseButton == RIGHT) {
        if(inventory.size() > 0 && !blockTypes.get(blockId).isSolid()) {          
            worlds.get(currentWorld).changeBlock(mouseX+playerX-width/2,mouseY+playerY-height/2,(int)inventory.keySet().toArray()[selectedItem]);
            inventory.put((int)inventory.keySet().toArray()[selectedItem],inventory.get((int)inventory.keySet().toArray()[selectedItem])-1);
        }
    }
}
