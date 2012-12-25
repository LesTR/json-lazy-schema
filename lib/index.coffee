util = require 'util'
fs   = require 'fs'
	
classes = {}
refs = []
createClass = (name,line,params) =>
	if classes[name]
		throw new Error("Duplicate class #{name}. First declaration are on line: #{classes[name].line}")
	else
		classes[name] = {}
		classes[name].line = line
		classes[name].noteLines = []
		classes[name].attributes = {}
		classes[name].params = params

addAttribute = (className,name,prop) =>
	if classes[className].attributes[name]
		throw new Error("Duplicate attribute #{name} for class #{className}")
	else
		classes[className].attributes[name] = prop

parseAttributeFromLine = (className, line) =>
	attrProps = {}
	n = line.split(":")
	attrName = n[0].trim()
	lineParams = n[1].trim()

	if attrName[0] is "#"
		#commented => skip this line
		return

	if attrName.indexOf('?') isnt -1
		attrProps['required'] = no
		attrProps['optional'] = yes
		attrName = attrName.replace("?","")
	else
		attrProps['required'] = yes
		attrProps['optional'] = no
	
	if attrName.indexOf('*') isnt -1
		attrProps['readonly'] = yes
		attrName = attrName.replace("*","")
		
	commentPos = lineParams.indexOf("#")
	if commentPos isnt -1
		attrProps['comment'] = lineParams.substr(commentPos+1)
		lineParams = lineParams.substr(0,commentPos)

	if lineParams.length is 0
		attrProps['type'] = "string"
	else
		type = lineParams.match(/^([^[{]+)?/i)
		if type[1]
			attrProps['type'] = type[1].trim()
	
	range = lineParams.match(/\[(\d+)..(\d+)\]/i)
	if range
		attrProps['range'] = {min:range[1],max:range[2]}

	arrayParam = lineParams.match(/^\[(.+)\]/i)
	if arrayParam
		#param are array
		attrProps['array'] = yes
		attrProps['type'] = arrayParam[1].toString().replace(/['"]/g,'')
	else
		attrProps['array'] = no
	
	listParam = lineParams.match(/\{(.*)\}/i)
	if listParam
		attrProps['values'] = []
		for v in listParam[1].split(',')
			v = v.replace(/["']/g,'')
			if lastType isnt typeof v
				lastType = v 
			if attrProps['values'].indexOf(v) isnt -1
				throw new Error("Duplicate value '#{v} 'in list for attribute '#{attrName}' in class '#{className}'")
			attrProps['values'].push v

		if attrProps['values'].length is 0
			throw new Error("List for attribute '#{attrName}' in class '#{className}' are empty")

		typesInList = {}
		for t in attrProps['values']
			typesInList[typeof t] = ++typesInList[typeof t] || 1
		first = yes
		prevType = null
		multipeTypes = no
		for type,cnt of typesInList
			if first is no
				if prevType isnt type
					multipeTypes = yes
			prevType = type	
			first = no
		if multipeTypes is yes
			attrProps['type'] = 'any'
		else
			attrProps['type'] = prevType.replace(/["']/g,'')

	defaultValue = lineParams.match(/\|(.+)\|/i)
	if defaultValue
		attrProps['defaultValue'] = defaultValue[1].replace(/["']/g,'')

	if attrProps['type']?[0] is "$"
		refs.push(attrProps['type'][1..])
	
	addAttribute(className,attrName,attrProps)

addNoteForClass = (className, noteLine) =>
	if !classes[className]
		throw new Error("Can't add note '#{noteLine}' for non exists class #{className}")
	else
		classes[className].noteLines.push(noteLine)

parseFromString = (input,cb) =>
	classes = {}
	lastClass = null
	line = 0
	for data in input.toString().split("\n")
		line++
		classLine = data.match(/^([^>\s]+)(\s?)(>)?(\s?)(.*)=/i)
		if classLine
			lastClass = classLine[1]
			classParam = {}
			if classLine[5]
				classParam['extends'] = classLine[5].split(",")
			try
				createClass(lastClass,line,classParam)
			catch err
				return cb({error:yes,message: err.message})
		classCommentLine = data.match(/^#(.*)/i)
		attributeLine = data.match(/^\s+(.*):/i)

		if classCommentLine
			addNoteForClass(lastClass,data[1..])
		if attributeLine
			try
				parseAttributeFromLine(lastClass,data)
			catch err
				return cb({error:yes,message: err.message})

	return convertToJsonSchema(classes,cb)

convertToJsonSchema = (data,cb) =>
	schema = {}
	for className,definition of data
		object = {}
		object['name'] = className
		object['id']   = className
		if definition.noteLines.length > 0
			object['description'] = definition.noteLines.join("\n")
		
		convertAttribute = (opt)=>
			attr = {}
			attr['type'] = opt.type
			attr['required'] = opt.required if opt.required is no
			attr['optional'] = opt.optional if opt.optional is yes
			attr['description'] = opt.comment if opt.comment?.length > 0
			attr['readonly'] = opt.readonly if opt.readonly? is yes
			if opt.type is "string" && opt.range
				attr['minLength'] = opt.range.min
				attr['maxLength'] = opt.range.max
			else if opt.range
				attr['minimum'] = opt.range.min
				attr['maximum'] = opt.range.max
			if opt.defaultValue
				attr['default'] = opt.defaultValue
			if opt.values
				attr['allowableValues'] = {}
				attr['allowableValues'].valueTypes = "LIST"
				attr['allowableValues'].values = opt.values
				attr['uniqueItems'] = yes
			return attr

		attrs = {}

		if definition.params.extends
			for ext in definition.params.extends
				for attrName,opt of data[ext].attributes
					attrs[attrName] = convertAttribute(opt)

		for attrName,opt of definition.attributes
			attrs[attrName] = convertAttribute(opt)

		object['attributes'] = attrs
		schema[object['name']] = object
	cb(0,schema)

parseFromFile = (file,cb) =>
	return parseFromString(fs.readFileSync(file),cb)

module.exports.compile = (input,output)=>
	schema = parseFromFile(input)
	fs.writeFileSync(output,schema)

module.exports.parseFromFile = parseFromFile
module.exports.parseFromString = parseFromString
