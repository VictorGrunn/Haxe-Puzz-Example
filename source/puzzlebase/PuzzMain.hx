package puzzlebase;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.math.FlxPoint;

/**
 * ...
 * @author Victor Grunn
 */
class PuzzMain extends FlxGroup
{
	private var columnArray:Array<PuzzleRow>;
	
	private var mousePoint:FlxPoint;
	
	private var pieceTarget:PuzzlePiece;
	private var columnTarget:PuzzleRow;
	
	private var columnAmount:Int = 10;
	private var rowAmount:Int = 10;
	
	private var spaceBuffer:Int;
	private var startpoint:FlxPoint;
	
	private var orderQueue:Int = 0;
	
	private var rowCheckTween:FlxTween;

	
	// Generates the initial puzzle size, including space between each symbol, where the puzzle starts at, and so on.
	public function new() 
	{
		super();
		
		columnArray = new Array();
		
		startpoint = new FlxPoint(100, 100);
		
		spaceBuffer = 2;
		
		for (i in 0...columnAmount)
		{
			var puzzlrow:PuzzleRow = new PuzzleRow(new FlxPoint(startpoint.x + (i * PuzzlePiece.pieceSize) + (i * spaceBuffer), startpoint.y), rowAmount, spaceBuffer, this);
			columnArray.push(puzzlrow);
			add(puzzlrow);
		}
		
		//checkRows();
		//initializeFirstPuzzle();
		//initializeRows();
		initialPuzzle();
		
		FlxG.watch.add(this, "orderQueue", "OQ: ");
	}
	
	private function initialPuzzle():Void
	{
		var vName:String = "";
		var hName:String = "";
		
		for (i in 0...columnArray.length)
		{
			for (o in 0...rowAmount)
			{				
				var piece:PuzzlePiece = columnArray[i].puzzleGroup.recycle(PuzzlePiece);
				piece.launch(null, columnArray[i]);
				
				if (columnArray[i].mainArray[o - 1] != null && columnArray[i].mainArray[o - 2] != null)
				{
					//if (columnArray[i].mainArray[o].name == columnArray[i].mainArray[o - 1].name && columnArray[i].mainArray[o - 1].name == columnArray[i].mainArray[o - 2].name)
					if (columnArray[i].mainArray[o - 1].name == columnArray[i].mainArray[o - 2].name)
					{
						vName = columnArray[i].mainArray[o - 1].name;
					}
				}
				
				if (columnArray[i - 1] != null && columnArray[i - 2] != null)
				{
					//if (columnArray[i].mainArray[o] == columnArray[i - 1].mainArray[o] && columnArray[i - 1].mainArray[o] == columnArray[i - 2].mainArray[o])
					if (columnArray[i - 1].mainArray[o].name == columnArray[i - 1].mainArray[o].name)
					{
						hName = columnArray[i - 1].mainArray[o].name;
					}
				}
				
				while (piece.name == vName || piece.name == hName)
				{
					piece.launch(null, columnArray[i]);
				}								
				
				piece.startingPoint.x = piece.x;
				piece.startingPoint.y = piece.y;
		
				piece.destinationPoint.x = columnArray[i].location.x;
				piece.destinationPoint.y = columnArray[i].location.y + piece.height * o + spaceBuffer * o;	
				orderQueue += 1;
				columnArray[i].addPiece(piece, o);
			}
		}
		
		for (i in 0...columnArray.length)
		{			
			columnArray[i].initAnimation();
		}
		
		//trace("All done.");
	}
	
	private function areThereSolutions():Bool
	{		
		var solutionCheck:Bool = false;
		
		for (i in 0...columnArray.length)
		{
			for (o in 0...columnArray[i].mainArray.length)
			{
				//This makes a check based on the initial presence of two vertically matched pieces side by side
				if (columnArray[i].mainArray[o + 1] != null && columnArray[i].mainArray[o].name == columnArray[i].mainArray[o + 1].name)
				{
					//Checking to the left side, top and bottom
					if (columnArray[i - 1] != null)
					{
						if (columnArray[i - 1].mainArray[o - 1] != null && columnArray[i - 1].mainArray[o - 1].name == columnArray[i].mainArray[o].name)
						{							
							columnArray[i - 1].mainArray[o - 1].alpha = .5;
							columnArray[i].mainArray[o].alpha = .5;
							columnArray[i].mainArray[o + 1].alpha = .5;
							
							solutionCheck = true;
						}
						
						if (columnArray[i - 1].mainArray[o + 2] != null && columnArray[i - 1].mainArray[o + 2].name == columnArray[i].mainArray[o].name)
						{
							columnArray[i - 1].mainArray[o + 2].alpha = .5;
							columnArray[i].mainArray[o].alpha = .5;
							columnArray[i].mainArray[o + 1].alpha = .5;
							solutionCheck = true;
						}
					}
					
					//Checking to the right side, top and bottom
					if (columnArray[i + 1] != null)
					{
						if (columnArray[i + 1].mainArray[o - 1] != null && columnArray[i + 1].mainArray[o - 1].name == columnArray[i].mainArray[o].name)
						{
							columnArray[i + 1].mainArray[o - 1].alpha = .5;
							columnArray[i].mainArray[o].alpha = .5;
							columnArray[i].mainArray[o + 1].alpha = .5;
							solutionCheck = true;
						}
						
						if (columnArray[i + 1].mainArray[o + 2] != null && columnArray[i + 1].mainArray[o + 2].name == columnArray[i].mainArray[o].name)
						{
							columnArray[i + 1].mainArray[o + 2].alpha = .5;
							columnArray[i].mainArray[o].alpha = .5;
							columnArray[i].mainArray[o + 1].alpha = .5;
							solutionCheck = true;
						}
					}
					
					//Checking behind two spaces
					if (columnArray[i].mainArray[o - 2] != null && columnArray[i].mainArray[o - 2].name == columnArray[i].mainArray[o].name)
					{
						columnArray[i].mainArray[o - 2].alpha = .5;
						columnArray[i].mainArray[o].alpha = .5;
						columnArray[i].mainArray[o + 1].alpha = .5;
						solutionCheck = true;
					}
					
					//Checking ahead 2 spaces from the second partner
					if (columnArray[i].mainArray[o + 3] != null && columnArray[i].mainArray[o + 3].name == columnArray[i].mainArray[o].name)
					{
						columnArray[i].mainArray[o + 3].alpha = .5;
						columnArray[i].mainArray[o].alpha = .5;
						columnArray[i].mainArray[o + 1].alpha = .5;
						solutionCheck = true;
					}
					
				}
				
				//This makes a check based on the initial presence of two horizontally matched pieces side by side
				if (columnArray[i + 1] != null && columnArray[i + 1].mainArray[o] != null && columnArray[i + 1].mainArray[o].name == columnArray[i].mainArray[o].name)
				{				
					//Checking top and bottom, left side
					if (columnArray[i - 1] != null)
					{
						if (columnArray[i - 1].mainArray[o - 1] != null && columnArray[i - 1].mainArray[o - 1].name == columnArray[i].mainArray[o].name)
						{
							columnArray[i - 1].mainArray[o - 1].alpha = .5;
							columnArray[i].mainArray[o].alpha = .5;
							columnArray[i + 1].mainArray[o].alpha = .5;
							solutionCheck = true;
						}
						
						if (columnArray[i - 1].mainArray[o + 1] != null && columnArray[i - 1].mainArray[o + 1].name == columnArray[i].mainArray[o].name)
						{
							
							columnArray[i - 1].mainArray[o + 1].alpha = .5;
							columnArray[i].mainArray[o].alpha = .5;
							columnArray[i + 1].mainArray[o].alpha = .5;
							solutionCheck = true;
						}
					}
					
					//checking top and bottom, right side
					if (columnArray[i + 2] != null)
					{
						if (columnArray[i + 2].mainArray[o - 1] != null && columnArray[i + 2].mainArray[o - 1].name == columnArray[i].mainArray[o].name)
						{
							columnArray[i + 2].mainArray[o - 1].alpha = .5;
							columnArray[i].mainArray[o].alpha = .5;
							columnArray[i + 1].mainArray[o].alpha = .5;
							solutionCheck = true;
						}
						
						if (columnArray[i + 2].mainArray[o + 1] != null && columnArray[i + 2].mainArray[o + 1].name == columnArray[i].mainArray[o].name)
						{
							columnArray[i + 2].mainArray[o + 1].alpha = .5;
							columnArray[i].mainArray[o].alpha = .5;
							columnArray[i + 1].mainArray[o].alpha = .5;
							solutionCheck = true;
						}
					}
					
					//Checking behind two spaces
					if (columnArray[i - 2] != null && columnArray[i - 2].mainArray[o] != null && columnArray[i - 2].mainArray[o].name == columnArray[i].mainArray[o].name)
					{
						columnArray[i - 2].mainArray[o].alpha = .5;
						columnArray[i].mainArray[o].alpha = .5;
						columnArray[i + 1].mainArray[o].alpha = .5;
						solutionCheck = true;
					}
					
					//Checking ahead 2 spaces from the second partner
					if (columnArray[i + 3] != null && columnArray[i + 3].mainArray[o] != null && columnArray[i + 3].mainArray[o].name == columnArray[i].mainArray[o].name)
					{
						columnArray[i + 3].mainArray[o].alpha = .5;
						columnArray[i].mainArray[o].alpha = .5;
						columnArray[i + 1].mainArray[o].alpha = .5;
						solutionCheck = true;
					}
				}
				
				//This makes a check based on the initial presence two vertically matching tiles, 1 space apart
				if (columnArray[i].mainArray[o + 2] != null && columnArray[i].mainArray[o + 2].name == columnArray[i].mainArray[o].name)
				{
					//Checking to the left
					if (columnArray[i - 1] != null && columnArray[i - 1].mainArray[o + 1] != null && columnArray[i - 1].mainArray[o + 1].name == columnArray[i].mainArray[o].name)
					{												
						columnArray[i - 1].mainArray[o + 1].alpha = .5;
						columnArray[i].mainArray[o].alpha = .5;
						columnArray[i].mainArray[o + 2].alpha = .5;
						solutionCheck = true;
					}
					
					//Checking to the right
					if (columnArray[i + 1] != null && columnArray[i + 1].mainArray[o + 1] != null && columnArray[i + 1].mainArray[o + 1].name == columnArray[i].mainArray[o].name)
					{
						columnArray[i + 1].mainArray[o + 1].alpha = .5;
						columnArray[i].mainArray[o].alpha = .5;
						columnArray[i].mainArray[o + 2].alpha = .5;
						solutionCheck = true;
					}
				}
				
				//This makes a check based on the initial presence of two horizontally matched tiles, 1 space apart
				if (columnArray[i + 2] != null && columnArray[i + 2].mainArray[o] != null && columnArray[i + 2].mainArray[o].name == columnArray[i].mainArray[o].name)
				{
					//Checking up
					if (columnArray[i + 1] != null && columnArray[i + 1].mainArray[o - 1] != null && columnArray[i + 1].mainArray[o - 1].name == columnArray[i].mainArray[o].name)
					{
						columnArray[i + 1].mainArray[o - 1].alpha = .5;
						columnArray[i].mainArray[o].alpha = .5;
						columnArray[i + 2].mainArray[o].alpha = .5;
						solutionCheck = true;
					}
					
					//Checking down
					if (columnArray[i + 1] != null && columnArray[i + 1].mainArray[o + 1] != null && columnArray[i + 1].mainArray[o + 1].name == columnArray[i].mainArray[o].name)
					{
						columnArray[i + 1].mainArray[o + 1].alpha = .5;
						columnArray[i].mainArray[o].alpha = .5;
						columnArray[i + 2].mainArray[o].alpha = .5;
						solutionCheck = true;
					}
				}				
			}						
		}
		
		if (solutionCheck == false)
		{
			//trace("No possible solutions found.");
		}		
		else
		{
			//trace("Possible solutions found.");
		}
		return solutionCheck;
	}
	
	
	
	//A public function which the PuzzlePiece class uses to set itself as the reference for movement match checks.
	public function setPieceTarget(_targetPiece:PuzzlePiece, _targetRow:PuzzleRow):Void
	{
		pieceTarget = _targetPiece;
	}
	
	public function changeQueue(_amount:Int):Void
	{	
		if (orderQueue != 0)
		{
			orderQueue += _amount;					
			
			if (orderQueue == 0)
			{
				checkMatches();				
			}
		}
		else
		{
			orderQueue += _amount;
		}		
		
		if (orderQueue < 0)
		{
			throw "This should never be less than zero.";
		}
	}
	
	/*
	 * This function handles selecting and moving puzzle pieces onscreen. The actual puzzlePiece waits for an overlap and mousepress check, assigning pieceTarget
	 * the relevant targets. When the mouse moves far enough way from its origin, it checks to see if there's a relevant row or column to the left/right/up/down, and if so, if
	 * there is a valid match there.
	 */
	private function movePiece():Void
	{
		if (FlxG.mouse.justPressed)
		{
			mousePoint = FlxG.mouse.getScreenPosition();
		}
		
		if (FlxG.mouse.justReleased)
		{
			pieceTarget = null;
		}
		
		if (FlxG.mouse.pressed && pieceTarget != null && mousePoint != null)
		{
			var shiftAmount:Int = 30;
			
			if (FlxG.mouse.screenX > mousePoint.x + shiftAmount)
			{
				checkPiece(RIGHT);
				mousePoint = null;
			}
			else if (FlxG.mouse.screenX < mousePoint.x - shiftAmount)
			{
				checkPiece(LEFT);
				mousePoint = null;
			}
			else if (FlxG.mouse.screenY > mousePoint.y + shiftAmount)
			{
				checkPiece(DOWN);
				mousePoint = null;
			}
			else if (FlxG.mouse.screenY < mousePoint.y - shiftAmount)
			{
				checkPiece(UP);
				mousePoint = null;
			}			
		}
	}
	
	/*If a match check is successful, this tweens the two pieces into each other's place. It's also responsible for making sure they get each other's array assignment in
	 * their respective rows so they can be properly processed.
	 */
	private function tradePlaces(_piece1:PuzzlePiece, _piece2:PuzzlePiece):Void
	{
		var column1:Int = -1;
		var row1:Int = -1;
		var rowassignment1:PuzzleRow = _piece1.rowAssignment;
		
		var column2:Int = -1;
		var row2:Int = -1;
		var rowassignment2:PuzzleRow = _piece2.rowAssignment;
		
		var temp_x:Float;
		var temp_y:Float;
		var temp_rowassignment:PuzzleRow;				
		
		for (i in 0...columnArray.length)
		{
			if (columnArray[i] == _piece1.rowAssignment)
			{
				column1 = i;				
			}
			
			if (columnArray[i] == _piece2.rowAssignment)
			{
				column2 = i;
			}
		}
		
		for (i in 0...rowAmount)
		{
			if (columnArray[column1].mainArray[i] == _piece1)
			{
				row1 = i;
			}
			
			if (columnArray[column2].mainArray[i] == _piece2)
			{
				row2 = i;
			}
		}				
		
		temp_x = _piece1.x;
		temp_y = _piece1.y;
		
		var movespeed:Float = .2;
		
		var tween1:FlxTween = FlxTween.linearMotion(_piece1, _piece1.x, _piece1.y, _piece2.x, _piece2.y, movespeed);
		
		temp_rowassignment = _piece1.rowAssignment;
		
		_piece1.rowAssignment = _piece2.rowAssignment;
		
		_piece2.rowAssignment = temp_rowassignment;
		
		var tween2:FlxTween = FlxTween.linearMotion(_piece2, _piece2.x, _piece2.y, _piece1.x, _piece1.y, movespeed);
		
		columnArray[column1].mainArray[row1] = _piece2;
		columnArray[column2].mainArray[row2] = _piece1;	
		
		
		var endTween:FlxTween = FlxTween.num(1, 10, movespeed + .01, { complete: tradePlacesTween } );				
	}
	
	
	// If a match check fails, this animates to show the failure.
	private function tradePlacesFail(_piece1:PuzzlePiece, _piece2:PuzzlePiece):Void
	{
		var temp_x:Float = _piece1.x;
		var temp_y:Float = _piece1.y;
		
		var temp_x2:Float = _piece2.x;
		var temp_y2:Float = _piece2.y;
		
		var tween1:FlxTween = FlxTween.linearPath(_piece1, [new FlxPoint(_piece1.x, _piece1.y), new FlxPoint(_piece2.x, _piece2.y), new FlxPoint(temp_x, temp_y)], .2);
		var tween2:FlxTween = FlxTween.linearPath(_piece2, [new FlxPoint(_piece2.x, _piece2.y), new FlxPoint(temp_x, temp_y), new FlxPoint(temp_x2, temp_y2)], .2);
	}
	
	//When a successful match is finished tweening, this handles all their removals.
	private function tradePlacesTween(t:FlxTween):Void
	{
		checkMatches();
		checkRows();
	}
	
	//Cleans and populates rows.
	public function checkRows():Void
	{
		for (i in 0...columnArray.length)
		{
			columnArray[i].populateColumn();
		}		
	}
	
	public function checkRowTween(_time:Float):Void
	{		
		rowCheckTween = FlxTween.num(0, 10, _time, { complete: onCheckRowsComplete } );
	}
	
	private function onCheckRowsComplete(t:FlxTween):Void
	{
		checkRows();
	}
	
	/* The initial function which checks to see if A) the motion of the mouse/finger is dragging across an actual row, and B) if there's a match between either the moving piece
	 * or the moved piece. Matchverify is used to determine this completely.
	 */
	private function checkPiece(_direction:Direction):Void
	{
		var rowNum:Int = -1;
		var columnNum:Int = -1;		
		var moveable:Bool = false;
		
		var puzzlepiece1:PuzzlePiece;
		var puzzlepiece2:PuzzlePiece;
		
		for (i in 0...columnArray.length)
		{
			for (r in 0...columnArray[i].mainArray.length)
			{
				if (columnArray[i].mainArray[r] == pieceTarget)
				{
					columnNum = i;
					rowNum = r;
				}
			}
		}		
		
		switch (_direction)
		{					
			case UP:
				if (rowNum - 1 < 0)
				{
					return;
				}
				
				puzzlepiece1 = columnArray[columnNum].mainArray[rowNum];
				puzzlepiece2 = columnArray[columnNum].mainArray[rowNum - 1];
				
				if (matchVerify(puzzlepiece1, columnNum, rowNum - 1, UP) || matchVerify(puzzlepiece2, columnNum, rowNum, DOWN))
				{
					moveable = true;
				}
				
				
			case DOWN:
				if (rowNum + 1 == rowAmount)
				{
					return;
				}
				
				puzzlepiece1 = columnArray[columnNum].mainArray[rowNum];
				puzzlepiece2 = columnArray[columnNum].mainArray[rowNum + 1];
				
				if (matchVerify(puzzlepiece1, columnNum, rowNum + 1, DOWN) || matchVerify(puzzlepiece2, columnNum, rowNum, UP))
				{
					moveable = true;
				}
			
				
			case LEFT:
				if (columnNum - 1 < 0)
				{
					return;
				}
				
				puzzlepiece1 = columnArray[columnNum].mainArray[rowNum];
				puzzlepiece2 = columnArray[columnNum - 1].mainArray[rowNum];
				
				if (matchVerify(puzzlepiece1, columnNum - 1, rowNum, LEFT) || matchVerify(puzzlepiece2, columnNum, rowNum, RIGHT))
				{
					moveable = true;
				}
				
			case RIGHT:
				if (columnNum + 1 == columnAmount)
				{
					return;
				}
				
				puzzlepiece1 = columnArray[columnNum].mainArray[rowNum];
				puzzlepiece2 = columnArray[columnNum + 1].mainArray[rowNum];
				
				if (matchVerify(puzzlepiece1, columnNum + 1, rowNum, RIGHT) || matchVerify(puzzlepiece2, columnNum, rowNum, LEFT))
				{
					moveable = true;
				}
				
			case MIDDLEH:
				throw "Don't use this here.";
				
			case MIDDLEV:
				throw "Don't use this here.";
				
		}
		
		if (moveable == true)
		{
			tradePlaces(puzzlepiece1, puzzlepiece2);
		}
		else
		{
			tradePlacesFail(puzzlepiece1, puzzlepiece2);
		}		
	}
	
	/*
	 * This function uses an initial _direction command to generate an _array with 4 corresponding directions included in it to process throw. The first one to 'succeed' returns true.
	 * Otherwise, it returns false.
	 * 
	 * Use by sending the piece, which column and row you want to check relative to, and what initial direction to use.
	 */
	private function matchVerify(_piece:PuzzlePiece, _column:Int, _row:Int, ?_direction:Direction, ?_array:Array<Direction>):Bool
	{
		var direction:Direction;
		
		var column:Int = _column;
		var row:Int = _row;
		var piece:PuzzlePiece = _piece;
		
		if (_direction != null)
		{
			var directionArray:Array<Direction> = new Array();
			
			switch(_direction)
			{
				case UP:
					directionArray = [UP, LEFT, RIGHT, MIDDLEH];
					
				case DOWN:
					directionArray = [DOWN, LEFT, RIGHT, MIDDLEH];
					
				case LEFT:
					directionArray = [UP, DOWN, LEFT, MIDDLEV];
					
				case RIGHT:	
					directionArray = [UP, DOWN, RIGHT, MIDDLEV];
					
				case MIDDLEH:
					throw "Don't use middleH here.";
					
				case MIDDLEV:					
					throw "Don't use middleV here.";
			}
			
			return matchVerify(_piece, _column, _row, null, directionArray);			
		}		
		
		if (_array != null && _array.length > 0)
		{
			direction = _array.shift();
			var matchArray:Array<PuzzlePiece> = new Array();
			var totalMatch:Int = 1;								
			
			switch (direction)
			{
				case UP:
					for (i in 1...3)
					{
						if (columnArray[column] != null && columnArray[column].mainArray[row - i] != null && columnArray[column].mainArray[row - i].name == piece.name)
						{
							matchArray.push(columnArray[column].mainArray[row - i]);
							totalMatch += 1;								
						}					
					
						if (totalMatch >= 3)
						{
							for (i in 0...matchArray.length)
							{
								matchArray[i].alpha = .2;
							}
							return true;
						}
					}
					
				case DOWN:
					for (i in 1...3)
					{
						if (columnArray[column] != null && columnArray[column].mainArray[row + i] != null && columnArray[column].mainArray[row + i].name == piece.name)
						{
							matchArray.push(columnArray[column].mainArray[row + i]);
							totalMatch += 1;								
						}					
					
						if (totalMatch >= 3)
						{
							for (i in 0...matchArray.length)
							{
								matchArray[i].alpha = .2;
							}
							return true;
						}
					}
					
					
				case LEFT:
					for (i in 1...3)
					{
						if (columnArray[column - i] != null && columnArray[column - i].mainArray[row] != null && columnArray[column - i].mainArray[row].name == piece.name)
						{
							matchArray.push(columnArray[column - i].mainArray[row]);
							totalMatch += 1;
						}
						
						if (totalMatch >= 3)
						{
							for (i in 0...matchArray.length)
							{
								matchArray[i].alpha = .2;
							}
							return true;
						}
					}
					
				case RIGHT:
					for (i in 1...3)
					{
						if (columnArray[column + i] != null && columnArray[column + i].mainArray[row] != null && columnArray[column + i].mainArray[row].name == piece.name)
						{
							matchArray.push(columnArray[column + i].mainArray[row]);
							totalMatch += 1;
						}
						
						if (totalMatch >= 3)
						{
							for (i in 0...matchArray.length)
							{
								matchArray[i].alpha = .2;
							}
							return true;
						}
					}
					
				case MIDDLEH:
					for (i in 0...3)
					{
						if (i == 1)
						{
							continue;
						}
					
						if (columnArray[column - 1 + i] != null && columnArray[column - 1 + i].mainArray[row] != null && columnArray[column - 1 + i].mainArray[row].name == piece.name)
						{
							matchArray.push(columnArray[column - 1 + i].mainArray[row]);
							totalMatch += 1;							
						}
					
						if (totalMatch >= 3)
						{
							for (i in 0...matchArray.length)
							{
								matchArray[i].alpha = .2;
							}							
							return true;
						}										
					}			
					
				case MIDDLEV:													
					for (i in 0...3)
					{
						if (i == 1)
						{
							continue;
						}
					
						if (columnArray[column] != null && columnArray[column].mainArray[row - 1 + i] != null && columnArray[column].mainArray[row - 1 + i].name == piece.name)
						{
							matchArray.push(columnArray[column].mainArray[row - 1 + i]);
							totalMatch += 1;							
						}
					
						if (totalMatch >= 3)
						{
							for (i in 0...matchArray.length)
							{
								matchArray[i].alpha = .2;
							}							
							return true;
						}										
					}	
				}
		}
		
		if (_array != null && _array.length > 0)
		{
			return matchVerify(piece, column, row, null, _array);
		}
		
		return false;
	}
	
	override public function update():Void
	{
		super.update();
		
		movePiece();		
		
		if (FlxG.keys.justPressed.F)
		{
			areThereSolutions();
		}
	}
	
	/*
	 * This function checks the entirety of the puzzle map. If any matches are found static on the map, they are eliminated. Also calls the row population function to
	 * fill in whatever blanks exist.
	 */
	private function checkMatches():Void
	{		
		var removeArray:Array<PuzzlePiece> = new Array();
		
		//We loop throw the PuzzleRows in columnArray
		for (i in 0...columnArray.length)
		{			
			//And now we check through the puzzlepieces, in each PuzzleRow
			for (o in 0...columnArray[i].mainArray.length)
			{
				//If what's present is a puzzlePiece...
				if (Std.is(columnArray[i].mainArray[o], PuzzlePiece))
				{			
					var pieceName:String = columnArray[i].mainArray[o].name;
					var pieceFlagged:Bool = false;
					var pieceArray:Array<PuzzlePiece> = new Array();					
					
					//Loop through from left to right. Check to see if the puzzlepiece names match the initial puzzlepiece name. If they do, add them to an array.
					//For 3 or more, flush them. Except for the first one! We need THAT one for the horizontal check, which is coming next.
					for (r in 0...columnArray.length)
					{
						if (columnArray[i + r] == null || (columnArray[i + r].mainArray[o] == null || columnArray[i + r].mainArray[o] != null && columnArray[i + r].mainArray[o].name != pieceName))
						{
							if (pieceArray.length >= 3)
							{
								pieceFlagged = true;
								
								for (i in 1...pieceArray.length)
								{
									removeArray.push(pieceArray[i]);
								}
							}							
							pieceArray = null;							
							break;
						}
						else if (columnArray[i + r] != null && columnArray[i + r].mainArray[o] != null && columnArray[i + r].mainArray[o].name == pieceName)
						{
							pieceArray.push(columnArray[i + r].mainArray[o]);
						}						
					}
					
					pieceArray = new Array();
						
					//Loop through from top to bottom, looking for matches.
					for (r in 0...columnArray[i].mainArray.length)
					{
						if (columnArray[i].mainArray[o + r] == null || columnArray[i].mainArray[o + r].name != pieceName)
						{
							if (pieceArray.length >= 3)
							{
								pieceFlagged = true;								
								
								for (i in 1...pieceArray.length)
								{
									removeArray.push(pieceArray[i]);
								}
							}														
							
							if (pieceFlagged == true)
							{								
								removeArray.push(pieceArray[0]);
							}						
							pieceArray = null;
							break;
						}
						else if (columnArray[i].mainArray[o + r].name != null && columnArray[i].mainArray[o + r].name == pieceName)
						{
							pieceArray.push(columnArray[i].mainArray[o + r]);										
						}
					}					
				}				
			}
		}
		for (i in 0...removeArray.length)
		{
			//removeArray[i].removeMeFast();
			removeArray[i].rowAssignment.removePiece(removeArray[i]);
		}
		
		removeArray = null;
		checkRows();		
	}		
}

enum Direction
{
	LEFT;
	RIGHT;
	UP;
	DOWN;
	MIDDLEH;
	MIDDLEV;
}