# json schema for lazy poeple
Simple parser for shorter json schema gramar
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
