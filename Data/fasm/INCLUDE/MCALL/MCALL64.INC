include 'macro\struct.inc'
include 'macro\proc64.inc'

 	macro table name, parent{
	 	macro name \{ 
	 		purge name
	 		name name#_@ 
 		\}
		struc name#_@  \{
		if parent eq
		else
			. parent#_@ 
		end if
	}
	endt fix }

	macro AddTable structure, table{
		struc structure a& \{
			. structure a
			.Table equ table
		\}
	}

	macro mcall obj_proc*, [args]{
		define _obj_proc obj_proc
		match [obj:prc], _obj_proc\{
			if args eq
				ccall [obj\#.\#prc], addr obj
			else
				ccall [obj\#.\#prc], addr obj, args
			end if
			rept 0\{
		\}
		match obj:prc, _obj_proc\{
			if args eq
				ccall obj\#.\#prc, addr obj
			else
				ccall obj\#.\#prc, addr obj, args
			end if
			rept 0\{
		\}
		match [obj->prc], _obj_proc\{
			From@Table [obj\#.Table:prc], obj, args
			rept 0\{
		\}
		match obj->prc, _obj_proc\{
			From@Table obj\#.Table:prc, obj, args
		\}
	}
	macro From@Table table_prc, obj, [args]{
		match table:prc, table_prc\{
			if args eq
				ccall table\#.\#prc, addr obj
			else
				ccall table\#.\#prc, addr obj, args
			end if
		\}
	}

	struc override NewVal{
		store qword NewVal at .
	}