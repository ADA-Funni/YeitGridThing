package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import haxe.Json;
import lime.app.Application;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.ui.Mouse;
import sys.FileSystem;
import sys.io.File;

class PlayState extends FlxState {
    var daGrid:FlxTypedGroup<FlxSprite>;
    static final TILE_SIZE = new FlxPoint(26, 33);
    
    public override function create() {
        super.create();

        FlxG.mouse.useSystemCursor = true;
        FlxG.camera.bgColor = FlxColor.GRAY;

        var grid = FlxGridOverlay.create(Math.round(TILE_SIZE.x), Math.round(TILE_SIZE.y), Math.round(TILE_SIZE.x * 250), Math.round(TILE_SIZE.y * 250), true, 0xffb9b6b6, 0xff998a8a);
        add(grid);

        daGrid = new FlxTypedGroup<FlxSprite>();
        add(daGrid);

        FileSystem.createDirectory('export');

        var bitmapData = Assets.getBitmapData('assets/stupidFile.jpg');
        //add(new FlxSprite(0,0,bitmapData));

        var widthAsIndex = Math.floor(bitmapData.width / TILE_SIZE.x);
        var heightAsIndex = Math.floor(bitmapData.height / TILE_SIZE.y);
        for (xAsIndex in 0... widthAsIndex) {
            for (yAsIndex in 0... heightAsIndex) {
                var x:Int = Math.round(xAsIndex * TILE_SIZE.x);
                var y:Int = Math.round(yAsIndex * TILE_SIZE.y);
                var spr = new FlxSprite(x, y, cropThatMotherfucker(bitmapData, x, y, Math.round(TILE_SIZE.x), Math.round(TILE_SIZE.y)));
                daGrid.add(spr);
            }
        }

        if (FileSystem.exists('project.json')) {
            var js:Array<Array<Int>> = Json.parse(File.getContent('project.json'));
            for (i=>member in daGrid.members) {
                var pos:Array<Int> = js[i];
                member.x = pos[0];
                member.y = pos[1];
            }
        }

        setup = true;
    }

    var setup:Bool = false;
    var draggedObject:FlxSprite;
    var defaultCamZoom:Float = 0.7;
    public override function update(elapsed:Float) {
        super.update(elapsed);

        if (!setup) return;

        if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S) {
            var array:Array<Array<Int>> = [];
            for (member in daGrid) {
                array.push([Math.round(member.x), Math.round(member.y)]);
            }
            File.saveContent('project.json', Json.stringify(array, null, '  '));
        }

        for (object in daGrid) {
            if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(object)) {
                draggedObject = object;
                Mouse.cursor = @:privateAccess __MOVE;
                break;
            }
        }

        if (FlxG.mouse.justReleased) {
            if (draggedObject == null) return;
            draggedObject.x = Math.floor(draggedObject.x / TILE_SIZE.x) * TILE_SIZE.x;
            draggedObject.y = Math.floor(draggedObject.y / TILE_SIZE.y) * TILE_SIZE.y;
            draggedObject = null;

            Mouse.cursor = AUTO;
        }

        if (draggedObject != null) {
            draggedObject.x += FlxG.mouse.deltaViewX;
            draggedObject.y += FlxG.mouse.deltaViewY;
        }

        if (FlxG.mouse.wheel != 0) {
            defaultCamZoom += (FlxG.mouse.wheel / 50);
        }

        if (FlxG.mouse.pressedMiddle || FlxG.keys.pressed.SPACE) {
            FlxG.camera.scroll.x += FlxG.mouse.deltaViewX;
            FlxG.camera.scroll.y += FlxG.mouse.deltaViewY;
        }

        if (FlxG.mouse.justPressedMiddle || FlxG.keys.justPressed.SPACE) {
            Mouse.cursor = HAND;
        }

        if (FlxG.mouse.justReleasedMiddle || FlxG.keys.justReleased.SPACE) {
            Mouse.cursor = AUTO;
        }

        FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, defaultCamZoom, elapsed * 15);
    }

    function cropThatMotherfucker(source:BitmapData, x:Int, y:Int, width:Int, height:Int):BitmapData {
        var bmp = new BitmapData(width, height);
        bmp.copyPixels(source, new Rectangle(x, y, width, height), new Point(0,0));
        #if EXPORT_GRID_PNG
        File.saveBytes('export/x=${Math.round(x / TILE_SIZE.x)}y=${Math.round(y / TILE_SIZE.y)}.png', bmp.encode(bmp.rect, new PNGEncoderOptions()));
        #end
        return bmp;
    }
}