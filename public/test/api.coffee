{api} = sellstome

module "Collections"

test "collections: each", ->
	api.each [1, 2, 3], (num, i) ->
	  equals(num, i + 1, 'each iterators provide value and iteration count')

	answers = []
	api.each [1, 2, 3], (num) -> 
		answers.push(num * @multiplier)
	, multiplier: 5
	equals(answers.join(', '), '5, 10, 15', 'context object property accessed')

	answers = []
	api.forEach [1, 2, 3], (num) -> answers.push(num)
	equals(answers.join(', '), '1, 2, 3', 'aliased as "forEach"')

	answers = []
	obj = one: 1, two: 2, three: 3
	obj.constructor.prototype.four = 4;
	api.each obj, (value, key) -> answers.push(key)
	equals(answers.join(", "), 'one, two, three', 'iterating over objects works, and ignores the object prototype.')
	delete obj.constructor.prototype.four

	# answer = null
	# api.each [1, 2, 3], (num, index, arr) ->
	# 	answer = true if api.include(arr, num)
	# ok(answer, 'can reference the original collection from inside the iterator')

	answers = 0
	api.each null, () -> ++answers
	equals(answers, 0, 'handles a null properly')

module "Functions"

test "functions: bind", ->
	context = name: 'moe'
	func = (arg) ->  "name: " + (this.name or arg)
	bound = api.bind(func, context)
	equals(bound(), 'name: moe', 'can bind a function to a context')

	bound = api.bind(func, null, 'curly')
	equals(bound(), 'name: curly', 'can bind without specifying a context')

	func = (salutation, name) -> salutation + ': ' + name
	func = api.bind(func, this, 'hello')
	equals(func('moe'), 'hello: moe', 'the function was partially applied in advance')

	func = api.bind(func, this, 'curly');
	equals(func(), 'hello: curly', 'the function was completely applied in advance')

	func = (salutation, firstname, lastname) -> "#{salutation}: #{firstname} #{lastname}"
	func = api.bind(func, this, 'hello', 'moe', 'curly')
	equals(func(), 'hello: moe curly', 'the function was partially applied in advance and can accept multiple arguments')

	func = (context, message) -> equals(this, context, message)
	api.bind(func, 0, 0, 'can bind a function to `0`')()
	api.bind(func, '', '', 'can bind a function to an empty string')()
	api.bind(func, false, false, 'can bind a function to `false`')()
	
### SPEED TESTS ###

numbers = []
numbers.push(i) for i in [0...1000]
	
JSLitmus.test 'each()', ->
	timesTwo = []
	api.each numbers, (num) -> timesTwo.push(num * 2)
	return timesTwo