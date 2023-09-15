package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import maze.DepthFirst;
import neko.Random;

class PlayState extends FlxState
{
	var text:FlxText;
	var game_maze:Array<Array<Int>>;
	var MAZE_DIM:Int = 16;

	var tileMap:FlxTilemap;

	var spr:FlxSprite;
	var sprRect:FlxRect;

	var pressedFlag:Bool;

	override public function create()
	{
		super.create();

		// Draggable box
		spr = new FlxSprite(0, 0, FlxGraphic.fromRectangle(Math.round((FlxG.width / MAZE_DIM) / 2), Math.round((FlxG.height / MAZE_DIM) / 2), FlxColor.BLUE));
		spr.allowCollisions = ANY;

		// Generate maze
		var rand = new Random();
		game_maze = DepthFirst.make(MAZE_DIM, MAZE_DIM, Std.string(rand.int));

		// Generate tile texture
		var grayRect = FlxGraphic.fromRectangle(Math.round(FlxG.width / MAZE_DIM), Math.round(FlxG.height / MAZE_DIM) * 4, FlxColor.GRAY);

		// Fixes tiles not rendering
		for (i in 0...game_maze.length)
		{
			for (j in 0...game_maze.length)
			{
				if (game_maze[i][j] == 1)
					game_maze[i][j] += 1;
			}
		}

		// Generate the tile map
		tileMap = new FlxTilemap();
		tileMap.loadMapFrom2DArray(game_maze, grayRect, Math.round(FlxG.width / MAZE_DIM), Math.round(FlxG.height / MAZE_DIM));
		tileMap.screenCenter();

		// Get random valid starting position
		var coords = tileMap.getTileCoords(0);
		var index = rand.int(coords.length);
		var startPos:FlxPoint;
		startPos = new FlxPoint(coords[index].x + 4, coords[index].y + 4);

		// set sprite start position
		spr.setPosition(startPos.x - Math.round((FlxG.width / MAZE_DIM) / 2), startPos.y - Math.round((FlxG.height / MAZE_DIM) / 2));
		spr.updateHitbox();

		sprRect = new FlxRect(spr.getMidpoint().x - Math.round(spr.width / 2), spr.getMidpoint().y - Math.round(spr.height / 2), spr.width * 2,
			spr.height * 2); // no idea why I need to multiply w and h by 2

		// Game over text
		text = new FlxText(0, 0, FlxG.width, "You Lose", 64);
		text.setFormat(null, 64, FlxColor.RED, FlxTextAlign.CENTER);
		text.screenCenter();
		text.visible = false;

		add(tileMap);
		add(spr);
		add(text);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// Drag tile
		if (FlxG.mouse.overlaps(spr))
		{
			if (FlxG.mouse.pressed)
			{
				pressedFlag = true;
			}
		}

		// Stop dragging
		if (FlxG.mouse.released)
			pressedFlag = false;

		// Custom collision - hitboxes were being weird
		var coords = tileMap.getTileCoords(2);
		var rect:FlxRect = new FlxRect(0, 0, Math.round((FlxG.width / MAZE_DIM) / 2), Math.round((FlxG.height / MAZE_DIM) / 2));
		sprRect.x = spr.getMidpoint().x - Math.round(spr.width / 2);
		sprRect.y = spr.getMidpoint().y - Math.round(spr.height / 2);

		for (coord in coords)
		{
			// Garbage collector is now happy
			rect.x = coord.x;
			rect.y = coord.y;

			// See if the current wall overlaps (collides) with the player
			if (rect.overlaps(sprRect))
			{
				pressedFlag = false;
				text.visible = true;
				tileMap.alpha = 0.5;
				spr.alpha = 0.5;
			}
		}

		// Drag properly
		if (pressedFlag)
		{
			spr.x = FlxG.mouse.x - spr.width / 2;
			spr.y = FlxG.mouse.y - spr.height / 2;
		}
	}
}
