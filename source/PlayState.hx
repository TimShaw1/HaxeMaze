package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxExtendedSprite;
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
	var boxes:FlxTypedGroup<FlxSprite>;
	var MAZE_DIM:Int = 16;

	var tileMap:FlxTilemap;

	var spr:FlxExtendedSprite;

	var pressedFlag:Bool;

	override public function create()
	{
		add(boxes = new FlxTypedGroup<FlxSprite>());
		super.create();

		spr = new FlxExtendedSprite(0, 0,
			FlxGraphic.fromRectangle(Math.round((FlxG.width / MAZE_DIM) / 2), Math.round((FlxG.height / MAZE_DIM) / 2), FlxColor.BLUE));
		spr.allowCollisions = ANY;

		var rand = new Random();
		game_maze = DepthFirst.make(MAZE_DIM, MAZE_DIM, Std.string(rand.int));
		tileMap = new FlxTilemap();
		var redRect = FlxGraphic.fromRectangle(Math.round(FlxG.width / MAZE_DIM), Math.round(FlxG.height / MAZE_DIM) * 4, FlxColor.GRAY);

		var startPos:FlxPoint;

		for (i in 0...game_maze.length)
		{
			for (j in 0...game_maze.length)
			{
				if (game_maze[i][j] == 1)
					game_maze[i][j] += 1;
			}
		}

		tileMap.loadMapFrom2DArray(game_maze, redRect, Math.round(FlxG.width / MAZE_DIM), Math.round(FlxG.height / MAZE_DIM));
		tileMap.screenCenter();

		var coords = tileMap.getTileCoords(0);
		var index = rand.int(coords.length);
		startPos = new FlxPoint(coords[index].x + 2, coords[index].y + 2);

		spr.setPosition(startPos.x - Math.round((FlxG.width / MAZE_DIM) / 2), startPos.y - Math.round((FlxG.height / MAZE_DIM) / 2));
		spr.updateHitbox();

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

		if (FlxG.mouse.released)
			pressedFlag = false;

		// Custom collision
		var coords = tileMap.getTileCoords(2);
		var rect:FlxRect;

		var sprRectTL = new FlxRect(spr.getMidpoint().x - Math.round(spr.width / 2), spr.getMidpoint().y - Math.round(spr.height / 2), spr.width, spr.height);

		var sprRectTR = new FlxRect(spr.getMidpoint().x + Math.round(spr.width / 2), spr.getMidpoint().y - Math.round(spr.height / 2), spr.width, spr.height);

		var sprRectBL = new FlxRect(spr.getMidpoint().x - Math.round(spr.width / 2), spr.getMidpoint().y + Math.round(spr.height / 2), spr.width, spr.height);

		var sprRectBR = new FlxRect(spr.getMidpoint().x + Math.round(spr.width / 2), spr.getMidpoint().y + Math.round(spr.height / 2), spr.width, spr.height);

		for (coord in coords)
		{
			rect = new FlxRect(coord.x, coord.y, Math.round((FlxG.width / MAZE_DIM) / 2), Math.round((FlxG.height / MAZE_DIM) / 2));

			if (rect.overlaps(sprRectTL) || rect.overlaps(sprRectTR) || rect.overlaps(sprRectBL) || rect.overlaps(sprRectBR))
			{
				pressedFlag = false;
				text.visible = true;
				tileMap.alpha = 0.5;
				spr.alpha = 0.5;
			}
		}

		if (pressedFlag)
		{
			spr.x = FlxG.mouse.x - spr.width / 2;
			spr.y = FlxG.mouse.y - spr.height / 2;
		}
	}
}