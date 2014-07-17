package hud;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.text.FlxText;

/**
 * ...
 * @author Victor Grunn
 */
class ScoreBoard extends FlxGroup
{
	private var score:FlxText;
	private var currentScore:Int = 0;

	public function new() 
	{
		super();
		
		score = new FlxText(5, 5, FlxG.width, "SCORE: " + currentScore, 14);
		add(score);
	}
	
	public function addToScore(_amount:Int):Void
	{
		currentScore += _amount;
		score.text = "SCORE: " + currentScore;
	}
	
}