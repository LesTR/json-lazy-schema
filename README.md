# json schema for lazy poeple
Simple parser for shorter json schema gramar.
I am very lazy man and i don't want write the long mess for http://json-schema.org/ but i need this functionality. For it i wrote a very easy grammar for converting to json-schema.

Its simple, easy, sexy : ) and i don't need write a long mess of json schema code. 

It's first prototype.
Check example folder for examples.

# Licence:
MIT
# Gramar:
```
<class name>[">"extended classes separate by ","]=
        [property modificators]propertieName:[property options]
        
property moficators:
        ? - optional param
        * - readonly param
property options:
        ["type"] - array of 'type'
        {value1,value2} - list of concrete values
        #start comment
        |default value|
Type can be specify in first argument, and this type can be nofify by:
        "string"[0..10] - here can be only strings with lenght betwean 0 and 10, same are posible for another types.
Values can have multiple values:
        attributeName:string{1,10} -  here are allowed multiple values, minimal are 1 and maximal = 10

Modificator can be multiple, for example:
        ?*foo:int[10..20]{1,5}|10| - here we have optional, readonly attribute with values betwean 10 and 20 with default value 10 and this attribute can have multiple value, but minimal are 1 and maximal 5. All of this values must be integer!
Attributes with empty options are represented as required string     
```
# Example:
input:
```
Example=
#note for Example class
        name:
        *readonly:int
Category > ObjectWithId,Example=
#Structure Category extending ObjectWithId and Example

Product>ObjectWithId=
        name:string[10..50]#string with length betwean 10 and 50 characters
        ?description:
        tags:["string"]#Array of string
        ?color:{"black","white"}|"white"|#here are allowed only black or white string with default value white
        categories:[$Category]{1,10}
ObjectWithId=
        id:int[0..100]#integer attribute from range 0..100
```
Output:
```
{
  "Category" : { 
    "attributes" : { 
      "id" : { 
        "description" : "integer attribute from range 0..100",
        "maximum" : "100",
        "minimum" : "0",
        "type" : "int"
      },
      "name" : { "type" : "string" },
      "readonly" : { 
        "readonly" : true,
        "type" : "int"
      }
    },
    "description" : "Structure Category extending ObjectWithId and Example",
    "id" : "Category",
    "name" : "Category"
    },
  "Example" : {
    "attributes" : { 
      "name" : { "type" : "string" },
      "readonly" : { 
        "readonly" : true,
        "type" : "int"
        }
    },
    "description" : "note for Example class",
    "id" : "Example",
    "name" : "Example"
  },
  "ObjectWithId" : {
    "attributes" : {
      "id" : {
        "description" : "integer attribute from range 0..100",
        "maximum" : "100",
        "minimum" : "0",
        "type" : "int"
      }
    },
    "id" : "ObjectWithId",
    "name" : "ObjectWithId"
  },
  "Product" : { 
    "attributes" : {
      "categories" : {
         "type": "Array[@Category]
      },
      "color" : {
        "allowableValues" : {
          "valueTypes" : "LIST",
          "values" : [ "black","white"]
        },
        "default" : "white",
        "description" : "here are allowed only black or white string with default value white",
        "optional" : true,
        "required" : false,
        "type" : "string",
        "uniqueItems" : true
      },
      "description" : { 
        "optional" : true,
        "required" : false,
        "type" : "string"
      },
      "id" : { 
        "description" : "integer attribute from range 0..100",
        "maximum" : "100",
        "minimum" : "0",
        "type" : "int"
      },
      "name" : { 
        "description" : "string with length betwean 10 and 50 characters",
        "maxLength" : "50",
        "minLength" : "10",
        "type" : "string"
      },
      "tags" : { 
        "description" : "Array of string",
        "type" : "string"
      }
    },
    "id" : "Product",
    "name" : "Product"
  }
}
```
