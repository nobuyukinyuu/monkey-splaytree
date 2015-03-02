'This example shows the usage of enumerators, and sanity tests node removal and insertion.

Import mojo
Import splaytree

Function Main:Int()
	New Game()
End Function

Class Game Extends App
	Field a:= New IntSplayTree<String>
	Field time
	Const NUM_VALUES = 20  'Number of values each tree will contain in this test.
	
	Method OnCreate:Int()
		SetUpdateRate 60

		time = Millisecs()
		For Local i:Int = 0 Until NUM_VALUES
			a.Set(i, "KeyValue " + i)
		End
		time = Millisecs() - time
		Print("Splay insert time: " + time)


		Local i:Int
		For Local k:= EachIn a
			i += 1
		Next
	End Method
	
	Method OnUpdate:Int()
		If KeyHit(KEY_ENTER)
			Local pick = Rnd(20)
			Print "Removing element " + pick
			a.Remove(pick)
		End If

		If KeyHit(KEY_SPACE)
			Local pick = Rnd(20)
			Print "Setting element " + pick
			a.Set(pick, "NewValue " + pick + ": " + Rnd(100))
		End If

	End Method
	
	Method OnRender:Int()
		Cls()
		
		Local i:Int
		For Local v:= EachIn a.Values
			DrawText(v, 8, 8 + (i * 14))
			i += 1
		Next
		
	End Method
End Class