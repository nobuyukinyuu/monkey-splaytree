#THRESHOLD = True
 
Class SplayTree<K, V>
 	Field findCompares:Int = 0
	Field splayThreshold:Int = 0

	'This method MUST be implemented by subclasses of SplayTree...
	Method Compare( lhs:K,rhs:K ) Abstract
 
	Method Clear:Void()
		root = Null
		elementCount = 0
	End
	
	Method IsEmpty:Bool()
		Return root=Null
	End
 
	Method Contains:Bool(key:K)
		Return (Get(key) <> null)
	End
 		
	' return value associated with the given key
	' If no such value, return null
	Method Get:V(key:K)
		Local node:Node<K, V> = Find(key)
		
		If (node <> Null)
			#IF THRESHOLD
				If (findCompares > splayThreshold)
					Splay(node)
				End
			#ELSE
				Splay(node)
			#ENDIF
			Return node.value
		End	
	End
 
	Method Set:Bool(key:K, value:V, splay:Bool = True)
		Local insertNode:Node<K, V> = New Node<K, V>(key, value)
		
		If (root = Null)
			root = insertNode
			Return True
		End If
		
		Local inserted:Bool = False
		Local currNode:Node<K, V> = root
		
		While ( Not inserted)
			Local cmp:Int = Compare(key, currNode.key)
			
			If (cmp < 0)
				If (currNode.left = Null)
					currNode.left = insertNode
					insertNode.parent = currNode
					inserted = True
					elementCount += 1
				Else
					currNode = currNode.left
				End
			ElseIf(cmp > 0)
				If (currNode.right = Null)
					currNode.right = insertNode
					insertNode.parent = currNode
					inserted = True
					elementCount += 1
				Else
					currNode = currNode.right
				End
			Else  'Update the key.
				currNode.value = value
				inserted = True
				Return False
			End
		Wend
		
		#IF THRESHOLD
			splayThreshold = Min(3, Int(Log(elementCount) * 1.442695 * 0.25))
		#ENDIF

		If (splay)
			Splay(insertNode)
		End

		Return True
	End

	Method Remove( key:K )
		Local z:Node<K,V> = Find( key )
	
		If( z = Null ) 
			Return
		End
 
		Splay( z )
 
		If( z.left = Null )
			Replace( z, z.right )
		ElseIf( z.right = Null ) 
			Replace( z, z.left )
		Else 
			Local y:Node<K,V> = FindMinimum( z.right )
			If( y.parent <> z ) 
				Replace( y, y.right )
				y.right = z.right
				y.right.parent = y
			End
			
			Replace( z, y )
			y.left = z.left
			y.left.parent = y
		End
 
 		elementCount -= 1

		#IF THRESHOLD
			splayThreshold = Min(3, Int(Log(elementCount) * 1.442695 * 0.25))
		#ENDIF
	End
		
	'   **************************************************************************
	'	*  helper functions
	'	**************************************************************************
 
	' height of tree (1-node tree has height 0)
	Method Height:Int()
		Return Height(root)
	End
	
	Method Size:Int()
		Return Size(root)
	End 

'	Method ObjectEnumerator:NodeEnumerator<K, V>()
'		Return New NodeEnumerator<K, V>(root)
'	End
		
		
	Private
 	
	Method Height(x:Node<K, V>)
		If x = Null Then Return - 1
		Return 1 + Max(Height(x.left), Height(x.right))
	End
	
	Method Size:Int(x:Node<K, V>)
		Local count:Int = 0
		Local parentStack:Stack<Node<K, V>> = New Stack<Node<K, V>>()
		Local currNode:Node<K, V> = x
		
		While ( Not parentStack.IsEmpty() Or currNode <> Null)
			If (currNode <> Null)
				parentStack.Push(currNode)
				currNode = currNode.left
			Else
				currNode = parentStack.Pop()
				count += 1
				currNode = currNode.right
			End
		End
		Return count
	End
		
	
	Method Splay:Void(x:Node<K, V>)
		While (x.parent <> Null)
			If (x.parent.parent = Null)
				If (x.parent.left = x)
					rotateRight(x.parent)
				Else
					rotateLeft(x.parent)
				End
			ElseIf(x.parent.left = x And x.parent.parent.left = x.parent)
				rotateRight(x.parent.parent)
				rotateRight(x.parent)
			ElseIf(x.parent.right = x And x.parent.parent.right = x.parent)
				rotateLeft(x.parent.parent)
				rotateLeft(x.parent)
			ElseIf(x.parent.left = x And x.parent.parent.right = x.parent)
				rotateRight(x.parent)
				rotateLeft(x.parent)
			Else
				rotateLeft(x.parent)
				rotateRight(x.parent)
			End
		End
	End

	
	Method rotateRight:Node<K, V>(h:Node<K, V>)
		Local x:Node<K, V> = h.left
		
		If (x <> Null)
			h.left = x.right
			x.right = h
			x.parent = h.parent
		End
		
		If (h.left <> Null)
			h.left.parent = h
		End
		
		h.parent = x
		
		If (x.parent = Null)
			root = x
		ElseIf(x.parent.left = h)
			x.parent.left = x
		Else
			x.parent.right = x
		End
		Return x
	End
 
	Method rotateLeft:Node<K, V>(h:Node<K, V>)
		Local x:Node<K, V> = h.right
		
		If (x <> Null)
			h.right = x.left
			x.left = h
			x.parent = h.parent
		End
		
		If (h.right <> Null)
			h.right.parent = h
		End
		
		h.parent = x
		
		If (x.parent = Null)
			root = x
		ElseIf(x.parent.left = h)
			x.parent.left = x
		Else
			x.parent.right = x
		End
		
		Return x
	End

	
	Method Find:Node<K, V>(key:K)
		findCompares = 0
		Local found:Bool = False
		Local currNode:Node<K, V> = root
		
		While ( Not found)
			Local cmp:Int = Compare(key, currNode.key)
			findCompares += 1
			If (cmp < 0)
				If (currNode.left = Null)
					Return Null
				Else
					currNode = currNode.left
				End
			ElseIf(cmp > 0)
				If (currNode.right = Null)
					Return Null
				Else
					currNode = currNode.right
				End
			Else
				found = True
			End
		End
		
		Return currNode
	End	 

	Method Replace:Void(u:Node<K, V>, v:Node<K, V>)
		If( u.parent = Null ) 
			root = v
		ElseIf( u = u.parent.left ) 
			u.parent.left = v
		Else 
			u.parent.right = v
		End
		
		If( v <> Null ) 
			v.parent = u.parent
		End
	End
	
	Method FindMinimum:Node<K,V>( root:Node<K,V> )
		Local currNode:Node<K,V> = root
		
		While currNode.left <> Null
			currNode = currNode.left
		End
		
		Return currNode
	End	
		
	Field root:Node<K, V>
	Field elementCount:Int	
End
 
 
'Private
 
Class Node<K, V> 
	Method New(key:K, value:V)
		Self.key   = key
		Self.value = value
	End

  Private
	Field key:K				   ' key
	Field value:V				 ' associated data
	Field left:Node, right:Node   ' left and right subtrees
	Field parent:Node		
End
 
 
'Helper versions...
 
Class IntSplayTree<V> Extends SplayTree<Int, V>
	Method Compare(lhs:Int, rhs:Int)
		Return lhs-rhs
	End
End
 
Class FloatSplayTree<V> Extends SplayTree<Float,V>
	Method Compare(lhs:Float, rhs:Float)
		If lhs<rhs Return -1
		Return lhs>rhs
	End
End
 
Class StringSplayTree<V> Extends SplayTree<String,V>
	Method Compare(lhs:String, rhs:String)
		Return lhs.Compare( rhs )
	End
End