// Highlight.js language definition for Xojo.
// Adapted from jedt3d/xojo-syntax-highlight-for-web highlightjs/xojo.highlight.js.
export default function xojo(hljs) {
  const KEYWORDS = [
    "Var", "Dim",
    "Sub", "Function",
    "Class", "Module", "Interface", "Enum",
    "If", "Then", "Else", "ElseIf", "End",
    "For", "Each", "Next", "While", "Wend", "Do", "Loop", "Until",
    "Select", "Case", "Break", "Continue",
    "Try", "Catch", "Finally", "Raise", "RaiseEvent", "Return", "Exit",
    "New", "Inherits", "Implements", "Extends",
    "AddHandler", "RemoveHandler",
    "Public", "Private", "Protected", "Static", "Shared", "Global",
    "Override", "Virtual", "Final", "Abstract",
    "Property", "Event", "Delegate", "ParamArray", "Optional",
    "As", "ByRef", "ByVal", "Of",
    "Call", "Using", "Namespace",
  ];

  const LITERALS = ["True", "False", "Nil"];
  const TYPES = [
    "Integer", "Int8", "Int16", "Int32", "Int64",
    "UInt8", "UInt16", "UInt32", "UInt64",
    "Single", "Double", "Boolean", "String", "Variant",
    "Object", "Color", "Ptr", "Auto", "CString", "WString",
    "DateTime", "Dictionary", "FolderItem", "RowSet", "Database", "SQLiteDatabase",
  ];
  const OPERATORS = [
    "And", "Or", "Not", "Xor", "Mod", "In", "Is", "IsA", "Isa",
    "AddressOf", "WeakAddressOf",
  ];
  const BUILTINS = ["Self", "Super", "Me", "App", "SpecialFolder"];

  return {
    name: "Xojo",
    aliases: ["xojo", "xojo_code", "xojo_project", "xojo_window"],
    case_insensitive: true,
    keywords: {
      keyword: [...KEYWORDS, ...OPERATORS],
      literal: LITERALS,
      type: TYPES,
      built_in: BUILTINS,
    },
    contains: [
      hljs.COMMENT("//", "$"),
      hljs.COMMENT("'", "$"),
      {
        scope: "string",
        begin: "\"",
        end: "\"",
        illegal: "\\n",
      },
      {
        scope: "number",
        match: /&[hH][0-9a-fA-F]+\b|&[bB][01]+\b|\b\d+(?:\.\d+)?(?:[eE][+-]?\d+)?\b/,
        relevance: 0,
      },
      {
        scope: "meta",
        match: /#(tag|pragma|if|else|elseif|endif|region|endregion)\b/i,
      },
    ],
  };
}
