Import mojo
Import splaytree
'#CPP_GC_MODE=0
 
Function Main:Int()
	New Game()
End Function

#STRING_KEY = True
 
Class Game Extends App
	Const NUM_VALUES = 20000  'Number of values each tree will contain in this test.
	Const FETCH_AMT = 100     'Amount of gets done each fetch cycle.
	Const REPEATS = 200	'number of times to repeat the fetch group
	
	Const DELETES_AND_INSERTS:Int = 200
		
#if STRING_KEY
	Field testMap:= New StringMap<String>
	Field testSplay:= New StringSplayTree<String>
 
	Field fetchKeys:String[]
	Field deletes:String[]
#else
	Field testMap:= New IntMap<String>
	Field testSplay:= New IntSplayTree<String>
 
	Field fetchKeys:Int[]
	Field deletes:Int[]
#end
	
	Field fetchVals:String[]
		
	Field mapFetchTime:Float
	Field splayFetchTime:Float
	Field numTests:Int = 1
	
	Const NUM_SAMPLES:Int = 500
	Field sampleStartIndex = 0
	Field mapSamples:Float[] = New Float[NUM_SAMPLES]
	Field splaySamples:Float[] = New Float[NUM_SAMPLES]
	Const GRAPH_Y_HEIGHT:Int = 300
	Field maxTime:Float
	Field yScale:Float
	
	Method OnCreate:Int()
		SetUpdateRate 3
		
		'Load up the trees with some values.
		Local time = Millisecs()
		For Local i:Int = 0 Until NUM_VALUES
			testMap.Set(i, "KeyValue " + i)
		End
		time = Millisecs() - time
		Print("Map insert time: " + time)
		
		time = Millisecs()
		For Local i:Int = 0 Until NUM_VALUES
			testSplay.Set(i, "KeyValue " + i)
		End
		time = Millisecs() - time
		Print("Splay insert time: " + time)
		
		'Validate that the inserts succeeded.
		Print("Map size: " + testMap.Count())
		Print("Splay size: " + testSplay.Size())
		'Print testSplay.Height()
		
		deletes = deletes.Resize(DELETES_AND_INSERTS)
		
		'Prepare testMap set of values to fetch.
		fetchKeys = fetchKeys.Resize(FETCH_AMT)
		
		For Local i:Int = 0 Until FETCH_AMT
#if STRING_KEY
			fetchKeys[i] = "KeyValue " + Int(Rnd(NUM_VALUES))
#else
			fetchKeys[i] = Int(Rnd(NUM_VALUES))
#end
		End
		
		'Now, let's fetch these values testMap few times from our trees.
		time = Millisecs()
		For Local j:Int = 0 Until REPEATS
			For Local i:Int = 0 Until FETCH_AMT
				Local val:= testMap.Get(fetchKeys[i])
			End
		End
		time = Millisecs() - time
		mapFetchTime += time
		Print("Initial Map fetch time: " + time)
 
		time = Millisecs()
		For Local j:Int = 0 Until REPEATS
			For Local i:Int = 0 Until FETCH_AMT
				Local val:= testSplay.Get(fetchKeys[i])
				'Print val
				'If (val.Compare("KeyValue " + fetchKeys[i]) <> 0)
				'	Error val
				'End
			End
		End
		time = Millisecs() - time
		splayFetchTime += time
		Print("Initial Splay fetch time: " + time)
		
		mapSamples[0] = mapFetchTime
		splaySamples[0] = splayFetchTime
		maxTime = Max(mapFetchTime,splayFetchTime)
		yScale = Float(GRAPH_Y_HEIGHT)/maxTime
	End
	
	Method OnUpdate:Int()
		
		numTests += 1
		
		For Local i:Int = 0 Until DELETES_AND_INSERTS
			Local index:Int = Int(Rnd(NUM_VALUES))
#if STRING_KEY
			deletes[i] = "KeyValue " + index 
#else
			deletes[i] = index
#end
		End
		
		'Fetch testMap couple of values from the trees and display how long it took to do this.  As time progresses, the splay tree should become more efficient.
		Local time = Millisecs()
		For Local i:Int = 0 Until DELETES_AND_INSERTS
			Local key := deletes[i]
			testMap.Remove(key)
			testMap.Insert(key, "KeyValue " + key)
		End
		For Local j:Int = 0 Until REPEATS			
			For Local i:Int = 0 Until FETCH_AMT
				Local val:= testMap.Get(fetchKeys[i])
			End
		End
		time = Millisecs() - time
		mapFetchTime += time
		mapSamples[numTests mod NUM_SAMPLES] = time
		
		time = Millisecs()
		For Local i:Int = 0 Until DELETES_AND_INSERTS
			Local key := deletes[i]
			testSplay.Remove(key)
			testSplay.Set(key, "KeyValue " + key, False)
		End
		
		For Local j:Int = 0 Until REPEATS
			For Local i:Int = 0 Until FETCH_AMT
				Local val:= testSplay.Get(fetchKeys[i])
				'If (val.Compare("KeyValue " + fetchKeys[i]) <> 0)
				'	Error val
				'End
			End
		End
		time = Millisecs() - time
		splaySamples[numTests mod NUM_SAMPLES] = time
		splayFetchTime += time
		
		If( numTests / NUM_SAMPLES >= 1 )
			sampleStartIndex = (sampleStartIndex + 1) Mod NUM_SAMPLES
		End
				
		maxTime = Max(maxTime,(Max(mapSamples[numTests mod NUM_SAMPLES],splaySamples[numTests mod NUM_SAMPLES])))
		yScale = Float(GRAPH_Y_HEIGHT)/maxTime
		If( testMap.Count() <> testSplay.Size() )
			Error "Datasets out of sync"
		End
	End
	
	Method OnRender:Int()
		Cls()
		
		DrawText("Mean Map fetch time:   " + FloatToString(mapFetchTime/numTests,2), 8, 8)
		DrawText("Mean Splay fetch time: " + FloatToString(splayFetchTime/numTests,2), 8, 32)
				
		Local xBase:Int = 20
		Local yBase:Int = 400
		
		For Local i:Int = 0 Until NUM_SAMPLES
			SetColor(48,48,248)
			DrawPoint(xBase + i, yBase - Int(mapSamples[ (sampleStartIndex+i) mod NUM_SAMPLES ] * yScale))
			SetColor(16,248,16)
			DrawPoint(xBase + i, yBase - Int(splaySamples[ (sampleStartIndex+i) mod NUM_SAMPLES ] * yScale))
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
