package game 
{
	import starling.display.Sprite;
	import starling.text.TextField;
	
	/**
	 * ...
	 * @author Renaud Bardet
	 */
	public class Sweeper extends Sprite 
	{
		
		private var resW : int ;
		private var resH : int ;
		private var numMines : int ;
		
		private var cells : Vector.<Cell> ;
		
		private var initialized : Boolean = false ;
		
		public function Sweeper( _resW : int, _resH : int, _numMines : int ) 
		{
			
			super() ;
			
			resW = _resW ;
			resH = _resH ;
			numMines = _numMines ;
			if ( numMines > (resH * resW) - 1 )
				throw "invalid setup, you cannot have more mines than the resolution of the grid minus one" ;
			
			cells = new Vector.<Cell>() ;
			
			for ( var i:int = 0 ; i < resH ; ++i )
			{
				for ( var j:int = 0 ; j < resW ; ++j )
				{
					// this makes ii and jj copies of i and j that won't be modified next loop
					// and therefore are safe to use in an inline function
					function f(ii:int, jj:int):void
					{
						var cell:Cell = new Cell() ;
						cell.x = 21* jj ;
						cell.y = 21* ii ;
						addChild(cell) ;
						cell.triggered.add( function():void { onCellTriggered( jj, ii, cell ) ; } ) ;
						cells.push( cell ) ;
					}
					f(i, j) ;
				}
			}
			
		}
		
		// delayed init so the grid is generated at first click
		// to avoid first-click gameover flaw
		public function init( _initCellX : int, _initCellY : int ) : void
		{
			
			// initialize a work grid of resW*resH with 'false'
			var tempGrid : Array = [] ;
			for ( var i : int = 0 ; i < resH ; ++i )
			{
				tempGrid[i] = new Array() ;
				for ( var j : int = 0 ; j < resW ; ++j )
					tempGrid[i][j] = false ;
			}
			
			// pick up random x and y to put a mine to
			// if there is already a mine there or it's the init point, start the loop again and pick new coordinates
			// do this while there are still bombs to place
			// [NOTE] this algorithm should have very poor performances if numBombs is close to resW*resH
			//		but I guess it's ok for a reasonable bomb/resolution ratio
			var placedMines : int = 0 ;
			do {
				
				var mineX:int = Math.floor( Math.random() * resW ) ;
				var mineY:int = Math.floor( Math.random() * resH ) ;
				
				// init point, pick new coordinates
				if ( _initCellX == mineX && _initCellY == mineY )
					continue ;
				
				// there is a mine, pick new coordinates
				if ( tempGrid[mineY][mineX] )
					continue ;
				
				// everything went ok, place the mine
				tempGrid[mineY][mineX] = true ;
				++placedMines ;
				
			} while ( placedMines < numMines )
			
			// initialize the real grid with generated values
			for ( i = 0 ; i < tempGrid.length ; ++i )
			{
				for ( j = 0 ; j < tempGrid[i].length ; ++j )
				{
					
					cells[i * resW + j].init( tempGrid[i][j] ? CellType.BOMB : CellType.EMPTY ) ;
					
				}
			}
			
			initialized = true ;
			
		}
		
		private function onCellTriggered( _x : int, _y : int, _cell : Cell ) : void
		{
			
			if ( !initialized )
			{
				init( _x, _y ) ;
				return ;
			}
			
		}
		
		public function getCell( _x : int, _y : int ) : Cell
		{
			
			if ( _x > resW || _y > resH )
				throw "cell out of bounds" ;
			
			return cells[_y * resW + _x] ;
			
		}
		
	}

}