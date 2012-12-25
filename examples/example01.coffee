jsonLazyffee = require '../lib/'
colors       = require 'colors'
util			 = require 'util'
require 'coffee-trace'


#some helpers
fn = util.inspect
util.inspect = (a,b,c) -> fn a,b,c,yes

#cmon! parse file
jsonLazyffee.parseFromFile "./example01.input",(err,jsonSchema) ->
	if err
		util.log "ERROR:"
		util.log util.inspect err
	for object,def of jsonSchema
		util.log "Object: #{object} in json-schema:"
		util.log JSON.stringify(def)
