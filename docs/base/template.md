# new CUI.Template(Options)

CUI has built-in support for Templates. Templates are preloaded HTML snippets which can be instantiated and later filled with content.

## Options

### name

The **name** of the CUI.Template. This is required. The Template is found by the DOM attribute **data-template** or the class name **cui-tmpl-<name>**.

The Template HTML needs to be loaded before new CUI.Template ins called.

### map_prefix

The **map_prefix** is a string which prefixes the class names search for by the slot-map.

## map

The **map** is a PlainObject to register template slots. A slot has a name. Most methods of CUI.Template can use that name to append content to, replace content to, or empty a template slot.

```json
map:
   slot1: true
   slot2: true
   slot3: ".my-slot-class3"
```

The key of the PlainObject is the name of the slot, the value is either **true** or a CSS selector. If it is set to **true** a DOM element with the attribute **[data-slot]** set to the slot name is searched for. If it set to an CSS selector, that selector is used to find the slot element.

This is how the corresponding template for the above **map** could look like. Notice that the slots are all empty. This is not a requirement but recommended best practice.

```html
<div data-template="mytemplate">
  <div data-slot="slot1"></div>
  <div data-slot="slot2"></div>  
  <div class="my-slot-class3"></div>
</div>
```

## set_template_empty

If set to _true_ (default), the Template maintains a class _cui-template-empty_ on the top level node. This is useful to hide empty content Templates.

## class

An optional String to append **class** names to the top level template node.

## init_flex_handles

Template HTML can contain flex handles. Flex handles are DIVs which allow are a user draggable separator between Layout DIVs.

All flex handles are automatically initialized if this option is set to _true_.

```html
<div data-cui-flex-handle="pane: .cui-horizontal-layout-left;
name: left; direction: horizontal;"></div>
```

The attribute **[data-cui-flex-handle]** is used to initialize a [CUI.FlexHandle](flexHandle.md) using CUI.Element.readOptsFromAttr.


# Template.loadTemplateFile(url)

Load the given Template file (HTML) into the DOM tree. The Template is hidden and loaded using display: none.

# Template.loadFile(url)

Load the given HTML/SVG file into the DOM tree. The content of the file is loaded into a DIV which is set to _display: none_ and then appended to **document.body**.

# Template.nodeByName

This PlainObject is used as registry for the template DOM nodes by name.




