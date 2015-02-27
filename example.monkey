Import mojo
Import splaytree
'#CPP_GC_MODE=0
 
Function Main:Int()
	New Game()
End Function
 
Class Game Extends App
	Const NUM_VALUES = 100000  'Number of values each tree will contain in this test.
	Const FETCH_AMT = 10     'Amount of gets done each fetch cycle.
	Const REPEATS = 10000	'number of times to repeat the fetch group
		
	Field a:= New IntMap<String>
	Field b:= New IntSplayTree<String>
 
	Field fetchVals:Int[]
	Field mapFetchTime:Float
	Field splayFetchTime:Float
	Field numTests:Int = 1
	
	Const NUM_SAMPLES:Int = 600 
	Field sampleStartIndex = 0
	Field mapSamples:Float[] = New Float[NUM_SAMPLES]
	Field splaySamples:Float[] = New Float[NUM_SAMPLES]
	Const GRAPH_Y_HEIGHT:Int = 300
	Field yScale:Float
	
	Method OnCreate:Int()
		SetUpdateRate 10
				
		'Load up the trees with some values.
		Local time = Millisecs()
		For Local i:Int = 0 Until NUM_VALUES
			a.Set(i, "KeyValue " + i)
		End
		time = Millisecs() - time
		Print("Map insert time: " + time)
		
		time = Millisecs()
		For Local i:Int = 0 Until NUM_VALUES
			b.Set(i, "KeyValue " + i)
		End
		time = Millisecs() - time
		Print("Splay insert time: " + time)
		
		'Validate that the inserts succeeded.
		Print("Map size: " + a.Count())
		Print("Splay size: " + b.Size())
		'Print b.Height()
		
		'Prepare a set of values to fetch.
		fetchVals = fetchVals.Resize(FETCH_AMT)
		For Local i:Int = 0 Until FETCH_AMT
			fetchVals[i] = Int(Rnd(NUM_VALUES)) '"KeyValue " + Int(Rnd(NUM_VALUES))
		End
		
		'Now, let's fetch these values a few times from our trees.
		time = Millisecs()
		For Local j:Int = 0 Until REPEATS
			For Local i:Int = 0 Until FETCH_AMT
				Local val:= a.Get(fetchVals[i])
			End
		End
		time = Millisecs() - time
		mapFetchTime += time
		Print("Initial Map fetch time: " + time)
 
		time = Millisecs()
		For Local j:Int = 0 Until REPEATS
			For Local i:Int = 0 Until FETCH_AMT
				Local val:= b.Get(fetchVals[i])
				'Print val
				'If (val.Compare("KeyValue " + fetchVals[i]) <> 0)
				'	Error val
				'End
			End
		End
		time = Millisecs() - time
		splayFetchTime += time
		Print("Initial Splay fetch time: " + time)
		
		mapSamples[0] = mapFetchTime
		splaySamples[0] = splayFetchTime
		yScale = Float(GRAPH_Y_HEIGHT)/Max(mapFetchTime,splayFetchTime)
	End
	
	Method OnUpdate:Int()
		
		numTests += 1
		
		'Fetch a couple of values from the trees and display how long it took to do this.  As time progresses, the splay tree should become more efficient.
		Local time = Millisecs()
		For Local j:Int = 0 Until REPEATS
			For Local i:Int = 0 Until FETCH_AMT
				Local val:= a.Get(fetchVals[i])
			End
		End
		time = Millisecs() - time
		mapFetchTime += time
		mapSamples[numTests] = time
		
		time = Millisecs()
		For Local j:Int = 0 Until REPEATS
			For Local i:Int = 0 Until FETCH_AMT
				Local val:= b.Get(fetchVals[i])
				'If (val.Compare("KeyValue " + fetchVals[i]) <> 0)
				'	Error val
				'End
			End
		End
		time = Millisecs() - time
		splaySamples[numTests] = time
		splayFetchTime += time
				
	End
	
	Method OnRender:Int()
		Cls()
		
		DrawText("Mean Map fetch time:   " + FloatToString(mapFetchTime/numTests,2), 8, 8)
		DrawText("Mean Splay fetch time: " + FloatToString(splayFetchTime/numTests,2), 8, 32)
				
		Local xBase:Int = 20
		Local yBase:Int = 400
		
		For Local i:Int = 0 Until NUM_SAMPLES 
			SetColor(48,48,248)
			DrawPoint(xBase + i, yBase - Int(mapSamples[ Wrap(sampleStartIndex+i,0,NUM_SAMPLES) ] * yScale))
			SetColor(16,248,16)
			DrawPoint(xBase + i, yBase - Int(splaySamples[ Wrap(sampleStartIndex+i,0,NUM_SAMPLES) ] * yScale))
		End
		
		SetColor(255,255,255)
		DrawLine(xBase-1,yBase+1,xBase-1,yBase-GRAPH_Y_HEIGHT-1)
		DrawLine(xBase-1,yBase+1,xBase+NUM_SAMPLES+1,yBase+1)
		 
	End
	
	Function FloatToString:String( f:Float, decimals:Int)
		Local retString:String = String(f)
		Local dp:Int = retString.FindLast(".")
    
		If dp = -1
			dp = retString.Length
		End
    
		dp += decimals+1
    
		If dp > retString.Length
			dp = retString.Length
		End
    
		retString = retString[0..dp]
    
		Return retString

	End
	
	Function Wrap:Int( value:Int, low:Int, high:Int )
		Local range:Int = 1+high-low
			
		If value > high
			Return low + (value-low) Mod range
		ElseIf value < low
			Return high - (high-value) Mod range
		End
			
		Return value
	End
End