package puzzlebase;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup;
import flixel.math.FlxRandom;

/**
 * ...
 * @author Victor Grunn
 */
class PuzzleRow extends FlxGroup
{	
	public var mainArray:Array<PuzzlePiece>;
	private var rowSize:Int;
	public var location:FlxPoint;
	private var refillSpeed:Int = 400;
	
	public var puzzleGroup:FlxTypedGroup<PuzzlePiece>;
	
	private var spaceBuffer:Int;
	
	private var mainClass:PuzzMain;	

	//Sets everything up for row generation. Actual row generation is called from the PuzzMain class.
	public function new(_location:FlxPoint, _rowSize:Int, _spaceBuffer:Int, _mainClass:PuzzMain) 
	{
		super();			
		
		spaceBuffer = _spaceBuffer;
		
		puzzleGroup = new FlxTypedGroup<PuzzlePiece>();
		add(puzzleGroup);
		
		rowSize = _rowSize;
		
		location = _location;
		
		mainClass = _mainClass;
		
		mainArray = new Array<PuzzlePiece>();					
	}
	
	public function addPiece(_piece:PuzzlePiece, _slot:Int):Void
	{
		if (_slot > rowSize -1)
		{
			throw "Bigger than the row.";
		}
		
		if (mainArray[_slot] != null)
		{
			removePiece(mainArray[_slot], true);
		}
		
		mainArray[_slot] = _piece;
	}
	
	public function initAnimation():Void
	{
		animatePieces(mainArray);
	}	
	
	//Checks how many spaces in the row are 'null', and populates them as necessary, moving old puzzle pieces into empty spaces, and generating new ones as required.
	public function populateColumn():Void
	{		
		var rowMembers:Array<PuzzlePiece> = new Array();
		var takeRowMembers:Bool = false;
		var rowFillStart:Int = 0;
		var animationArray:Array<PuzzlePiece> = new Array();
		
		/* Check the Mainarray in reverse order for the first instance of a null. If one is found, then takeRowMembers is set to true,	
		and we know from what point we need to start accounting for any and all remaining puzzle pieces to shift ahead.
		*/
		for (i in 0...rowSize)
		{
			if (mainArray[(rowSize - 1) - i] == null)
			{
				//trace("We just checked " + ((rowSize - 1) - i) + " and found " + mainArray[(rowSize - 1) - i]);
				takeRowMembers = true;
				rowFillStart = rowSize - 1 - i;
				//trace("rowFillStart initializing at: " + rowFillStart);
				break;
			}
		}
		
		/* If takeRowMembers is false, that means no empty/null member of mainArray was found, so we don't need to populate anything after all. Ergo, return out of this function.
		 * Let's trace our result just for the hell of it.
		 */
		if (takeRowMembers == false)
		{
			//trace("Nothing found to do in populateRow in PuzzleRow.");
			return;
		}
		
		/* If, however, takeRowMembers was triggered, that means we have some work to do.
		 * In particular, we're going to check the mainArray in order. Any PuzzlePieces we find will be added to the end of rowMembers in the order found. So, pieces occupying spaces
		 * 7 5 and 3 would ultimately be added as 7, 5, and 3. That way we can move everything in order when we move them downwards. We also remove them from the mainArray, so they can be
		 * re-added in order after moving.
		 */
		if (takeRowMembers == true)
		{
			
			for (i in 0...rowFillStart)
			{
				if (mainArray[i] != null)
				{
					rowMembers.unshift(mainArray[i]);
					mainArray[i] = null;
				}
			}
		}				
		
		/*
		 * Now, we tween each of the members of rowMembers into position, starting from rowFillStart and working backwards. What's more, we add the pieces to their new position in the row.
		 * This may still leave some empty row spaces left over.
		 */
		if (rowMembers.length > 0)		
		{
			for (i in 0...rowMembers.length)
			{
				var puzzlePiece:PuzzlePiece = rowMembers.shift();
				mainClass.changeQueue(1);
				mainArray[rowFillStart] = puzzlePiece;
				puzzlePiece.startingPoint.x = puzzlePiece.x;
				puzzlePiece.startingPoint.y = puzzlePiece.y;
				puzzlePiece.destinationPoint.x = puzzlePiece.x;
				puzzlePiece.destinationPoint.y = location.y + (puzzlePiece.height * rowFillStart) + (rowFillStart * spaceBuffer);
				animationArray.push(puzzlePiece);				
				
				rowFillStart -= 1;
				
			}
		}
		
		/*
		 * Naturally we now have to update rowFillStart to make sure it's working from the right location and number.
		 */		
		for (i in 0...rowSize)
		{
			if (mainArray[(rowSize - 1) - i] == null)
			{
				takeRowMembers = true;
				rowFillStart = rowSize - 1 - i;
				//trace("Second rowFillStart at " + rowFillStart);
				break;
			}
		}
		
		
		var newPieceCount:Int = 1;
		
		/*
		 * Now, we deal with any remaining empty spaces, adding in new puzzle pieces, and counting down rowFillStart. At -1, this should stop.
		 */
		while (rowFillStart >= 0)
		{
			var puzzlePiece:PuzzlePiece = puzzleGroup.recycle(PuzzlePiece);
			chooseColor(puzzlePiece);			
			mainArray[rowFillStart] = puzzlePiece;
			mainClass.changeQueue(1);
			newPieceCount += 1;
			puzzlePiece.startingPoint.x = location.x;
			puzzlePiece.startingPoint.y = location.y;
			puzzlePiece.destinationPoint.x = location.x;
			puzzlePiece.destinationPoint.y = location.y + (puzzlePiece.height * rowFillStart) + (rowFillStart * spaceBuffer);
			animationArray.push(puzzlePiece);
			
			rowFillStart -= 1;
		}		
		
		rowMembers = null;
		
		animatePieces(animationArray);
		animationArray = null;
	}	
	
	private function animatePieces(_array:Array<PuzzlePiece>):Void
	{
		for (i in 0..._array.length)
		{
			var tween:FlxTween = FlxTween.cubicMotion(_array[i], _array[i].startingPoint.x, _array[i].startingPoint.y, FlxRandom.float(0, FlxG.width), FlxRandom.float(0, FlxG.height), FlxRandom.float(0, FlxG.width), FlxRandom.float(0, FlxG.height), _array[i].destinationPoint.x, _array[i].destinationPoint.y, .5, { complete: onComplete });
		}
	}
	
	private function onComplete(t:FlxTween):Void
	{
		mainClass.changeQueue( -1);
	}	
		
	public function initializeFirstRow(_animate:Bool = false):Void
	{
		var rowMembers:Array<PuzzlePiece> = new Array();
		var takeRowMembers:Bool = false;
		var rowFillStart:Int = 0;
		var animationArray:Array<PuzzlePiece> = new Array();
		
		/* Check the Mainarray in reverse order for the first instance of a null. If one is found, then takeRowMembers is set to true,	
		and we know from what point we need to start accounting for any and all remaining puzzle pieces to shift ahead.
		*/
		for (i in 0...rowSize)
		{
			if (mainArray[(rowSize - 1) - i] == null)
			{
				takeRowMembers = true;
				rowFillStart = rowSize - 1 - i;
				break;
			}
		}
		
		/* If takeRowMembers is false, that means no empty/null member of mainArray was found, so we don't need to populate anything after all. Ergo, return out of this function.
		 * Let's trace our result just for the hell of it.
		 */
		if (takeRowMembers == false && _animate == false)
		{
			return;
		}
		
		/* If, however, takeRowMembers was triggered, that means we have some work to do.
		 * In particular, we're going to check the mainArray in order. Any PuzzlePieces we find will be added to the end of rowMembers in the order found. So, pieces occupying spaces
		 * 7 5 and 3 would ultimately be added as 7, 5, and 3. That way we can move everything in order when we move them downwards. We also remove them from the mainArray, so they can be
		 * re-added in order after moving.
		 */
		if (takeRowMembers == true)
		{			
			for (i in 0...rowFillStart)
			{
				if (mainArray[i] != null)
				{
					rowMembers.unshift(mainArray[i]);
					mainArray[i] = null;
				}				
			}
		}				
		
		/*
		 * Now, we tween each of the members of rowMembers into position, starting from rowFillStart and working backwards. What's more, we add the pieces to their new position in the row.
		 * This may still leave some empty row spaces left over.
		 */
		if (rowMembers.length > 0)		
		{
			for (i in 0...rowMembers.length)
			{
				/*if (_animate)
				{
					mainClass.changeQueue(1);
				}*/
				
				var puzzlePiece:PuzzlePiece = rowMembers.shift();				
				mainArray[rowFillStart] = puzzlePiece;
				puzzlePiece.startingPoint.x = puzzlePiece.x;
				puzzlePiece.startingPoint.y = puzzlePiece.y;
				//puzzlePiece.destinationPoint.x = puzzlePiece.x;
				puzzlePiece.destinationPoint.x = location.x;
				puzzlePiece.destinationPoint.y = location.y + (puzzlePiece.height * rowFillStart) + (rowFillStart * spaceBuffer);
				
				rowFillStart -= 1;							
			}
		}
		
		/*
		 * Naturally we now have to update rowFillStart to make sure it's working from the right location and number.
		 */		
		for (i in 0...rowSize)
		{
			if (mainArray[(rowSize - 1) - i] == null)
			{
				takeRowMembers = true;
				rowFillStart = rowSize - 1 - i;
				//trace("Second rowFillStart at " + rowFillStart);
				break;
			}
		}
		
		var newPieceCount:Int = 1;
		
		/*
		 * Now, we deal with any remaining empty spaces, adding in new puzzle pieces, and counting down rowFillStart. At -1, this should stop.
		 */
		while (rowFillStart >= 0)
		{			
			/*if (_animate)
			{
				mainClass.changeQueue(1);
			}*/
			
			var puzzlePiece:PuzzlePiece = puzzleGroup.recycle(PuzzlePiece);
			chooseColor(puzzlePiece);			
			mainArray[rowFillStart] = puzzlePiece;			
			newPieceCount += 1;
			puzzlePiece.startingPoint.x = location.x;
			puzzlePiece.startingPoint.y = location.y;
			puzzlePiece.destinationPoint.x = location.x;			
			puzzlePiece.destinationPoint.y = location.y + (puzzlePiece.height * rowFillStart) + (rowFillStart * spaceBuffer);

			rowFillStart -= 1;
		}		
		
		rowMembers = null;						
		
		if (_animate == true)
		{						
			for (i in 0...mainArray.length)
			{
				mainClass.changeQueue(1);
			}
			animatePieces(mainArray);
		}				
		animationArray = null;
	}
	
		
	//Use to generate the initial colors/types of puzzle pieces.
	private function chooseColor(t:PuzzlePiece):Void
	{
		var lucknum:Int = Math.floor(Math.random() * 6);
		
		switch (lucknum)
		{
			case 0:
				t.launch(Red, this);
				
			case 1:
				t.launch(Green, this);
				
			case 2:
				t.launch(Blue, this);			
				
			case 3:
				t.launch(Purple, this);
				
			case 4:
				t.launch(Yellow, this);
				
			case 5:
				t.launch(Black, this);
				
		}
	}
	
	
	//Remove a piece from the row. Keeps the slot in the array as 'null' so the class knows where to move pieces to.
	public function removePiece(t:PuzzlePiece, _fast:Bool = false):Void
	{
		if (_fast)
		{
			t.x = -100;
			t.exists = false;
			for (i in 0...mainArray.length)
			{
				if (mainArray[i] == t)
				{
					mainArray[i] = null;				
					break;
				}
			}
			
			mainClass.checkRowTween(.001);
			return;
		}
		
		//Userdata is no longer used in the latest versions of HaxeFlixel, but that doesn't mean I can't go in there and modify the class myself! This worked too well.
		var tween:FlxTween = FlxTween.tween(t.scale, { x: .1, y: .1 }, .25, { complete: removePieceTween } );		
		tween.userData = t;		
		
		mainClass.checkRowTween(.3);
	}
	
	private function removePieceTween(t:FlxTween):Void
	{
		t.userData.x = -100;
		t.userData.x = 0;
		t.userData.exists = false;		
		
		for (i in 0...mainArray.length)
		{
			if (mainArray[i] == t.userData)
			{
				mainArray[i] = null;				
				break;
			}
		}		
	}		
	
	override public function update():Void
	{
		super.update();								
	}
	
}