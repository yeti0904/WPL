# WPL
Interpreted programming language where everything is done with binary operators

## Build
```
dub build
```

## Example (insertionSort.wpl)
```
(sort = ([array] => {
	(n = (array - 0)) ;
	((n > 1) ? {
		(i = 1) ;
		({i < n} @ {
			(key = ((array : i) : 0)) ;
			(j = (i - 1)) ;
			({{j >= 0} && {key < ((array : j) : 0)}} @ {
				((array : (j + 1)) := ((array : j) : 0)) ;
				(j = (j - 1))
			}) ;
			((array : (j + 1)) := key) ;
			(i = (i + 1))
		})
	}) ;
	array
})) ;

(array = (sort ! [[2 3 1 6 5]])) ;
(i = 0) ;
({i < (array - 0)} @ {
	(stderr .d ((array : i) : 0)) ;
	(stderr .s "\n") ;
	(i = (i + 1))
})
```
