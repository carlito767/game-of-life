package;

import ceramic.Scene;
import ceramic.Tilemap;
import ceramic.TilemapData;
import ceramic.TilemapLayerData;
import ceramic.Tileset;

using PatternTools;

class MainScene extends Scene {
    static final CELLMAP_WIDTH = 80;
    static final CELLMAP_HEIGHT = 60;

    var pattern:Pattern;
    var tilemap:Tilemap;
    var generation:Int;

    override function preload() {
        // Add any asset you want to load here

        assets.add(Images.SINGLE_TILE);
        assets.add(Texts.PATTERNS__PULSAR_CELLS);
    }

    override function create() {
        // Called when scene has finished preloading

        // Load Pulsar pattern
        // https://conwaylife.com/wiki/Pulsar
        var text = assets.text(Texts.PATTERNS__PULSAR_CELLS);
        pattern = text.convertPlaintextToPattern();

        // Fit pattern to cellmap
        var cells:Array<Int> = [];
        var dx:Int = Std.int((CELLMAP_WIDTH - pattern.w) * 0.5);
        var dy:Int = Std.int((CELLMAP_HEIGHT - pattern.h) * 0.5);
        for (y in 0...CELLMAP_HEIGHT) {
            for (x in 0...CELLMAP_WIDTH) {
                var px = x - dx;
                var py = y - dy;
                var state = 0;
                if (px >= 0 && px < pattern.w && py >= 0 && py < pattern.h) {
                    state = pattern.cells[px + py * pattern.w];
                }
                cells.push(state);
            }
        }
        pattern = {w: CELLMAP_WIDTH, h: CELLMAP_HEIGHT, cells: cells};
    }

    function createTilemap(p:Pattern) {
        // Create our very simple one-tile tileset
        var tileset = new Tileset();
        // 0 = no tile
        // 1 = our single tile
        tileset.firstGid = 1;
        tileset.tileSize(8, 8);
        tileset.texture = assets.texture(Images.SINGLE_TILE);
        tileset.columns = 1;

        // Create our tile layer
        var layerData = new TilemapLayerData();
        layerData.name = 'main';
        layerData.grid(p.w, p.h);
        layerData.tileSize(8, 8);
        layerData.tiles = p.cells;

        // Create the tilemap data holding our tile layer
        var tilemapData = new TilemapData();
        tilemapData.size(layerData.columns * tileset.tileWidth, layerData.rows * tileset.tileHeight);
        tilemapData.tilesets = [tileset];
        tilemapData.layers = [layerData];

        // Then create the actual tilemap visual and assign it tilemap data
        if (tilemap != null)
            tilemap.destroy();
        tilemap = new Tilemap();
        tilemap.tilemapData = tilemapData;
        tilemap.pos(8, 8);

        add(tilemap);
    }

    override function update(delta:Float) {
        // Here, you can add code that will be executed at every frame

        createTilemap(pattern);
        pattern.nextGeneration();
        generation++;
    }

    override function resize(width:Float, height:Float) {
        // Called everytime the scene size has changed
    }

    override function destroy() {
        // Perform any cleanup before final destroy

        super.destroy();
    }
}
