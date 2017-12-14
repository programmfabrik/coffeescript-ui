require("../../src/base/util.coffee");
require("../../src/base/dom.coffee");

let genericDiv;

beforeEach(() => {
    document.body.innerHTML = "";
    genericDiv = CUI.dom.div();
});

describe('CUI.dom.data(node, key, value)', () => {
    test("Set a string value in 'id' attribute.", () => {
        let expectedValue = "idValue";
        let idKey = "id";
        CUI.dom.data(genericDiv, idKey, expectedValue);

        let setValue = CUI.dom.data(genericDiv, idKey);
        expect(setValue).toBe(expectedValue);
    });

    test("Set an object of attributes.", () => {
        let expectedObject = {keyOne: "valueOne", keyTwo: "valueTwo"};
        CUI.dom.data(genericDiv, expectedObject);

        let setObject = CUI.dom.data(genericDiv);
        expect(setObject).toEqual(expectedObject);
    });
});

describe('CUI.dom.setElement(node, element)', () => {
    test("Set element value", () => {
        let expectedValue = "someValue";
        CUI.dom.setElement(genericDiv, expectedValue);

        let setValue = CUI.dom.data(genericDiv, "element");
        expect(setValue).toBe(expectedValue);
    });
});

describe('CUI.dom.removeData(node, key)', () => {
    test("Remove value from data", () => {
        let expectedValue = "idValue";
        let idKey = "id";
        CUI.dom.data(genericDiv, idKey, expectedValue);
        let setValue = CUI.dom.data(genericDiv, idKey);
        expect(setValue).toBe(expectedValue);

        CUI.dom.removeData(genericDiv, idKey);
        let undefinedValue = CUI.dom.data(genericDiv, idKey);
        expect(undefinedValue).toBeUndefined();
    });
});

describe('CUI.dom.findElements(node, selector, nodeFilter, maxEls, forward, siblingOnly, elements)', () => {

    let appendHtml = () => {
        document.body.innerHTML = `<div class="sibling previous-sibling">
                                        <div class="child child-previous-sibling"></div>
                                    </div>
                                    <div id="div">
                                        <div class="child first-element">
                                            <div class="child child-first-element"></div>
                                        </div>
                                        <div class="child second-element"></div>
                                        <div class="child last-element"></div>
                                        <div class="child child-last-element"></div>
                                    </div>
                                    <div class="sibling next-sibling">
                                        <div class="child child-next-sibling"></div>
                                    </div>`;
    };

    test("Using selector parameter.", () => {
        appendHtml();
        let className = "child";
        let selector = "." + className;

        let elementsFound = CUI.dom.findElements(div, selector);

        expect(elementsFound.length).toBe(6);
        for (let elementFound of elementsFound) {
            let hasClass = CUI.dom.hasClass(elementFound, className);
            expect(hasClass).toBeTruthy();
        }

        let lastElement = elementsFound.pop();
        let isNextSibling = CUI.dom.hasClass(lastElement, "child-next-sibling");
        expect(isNextSibling).toBeTruthy();
    });

    test("Using selector and maxEls parameter.", () => {
        appendHtml();
        let maxEls = 2;
        let className = "child";
        let selector = "." + className;

        let elementsFound = CUI.dom.findElements(div, selector, null, maxEls);

        expect(elementsFound.length).toBe(2);
        for (let elementFound of elementsFound) {
            let hasClass = CUI.dom.hasClass(elementFound, className);
            expect(hasClass).toBeTruthy();
        }
    });

    test("Using selector and maxEls parameter, with forward false.", () => {
        appendHtml();
        let maxEls = 10;
        let className = "child";
        let selector = "." + className;
        let forward = false;

        let elementsFound = CUI.dom.findElements(div, selector, null, maxEls, forward);

        expect(elementsFound.length).toBe(6);
        for (let elementFound of elementsFound) {
            let hasClass = CUI.dom.hasClass(elementFound, className);
            expect(hasClass).toBeTruthy();
        }
        let lastElement = elementsFound.pop();
        let isPreviousSibling = CUI.dom.hasClass(lastElement, "child-previous-sibling");
        expect(isPreviousSibling).toBeTruthy();
    });

    test("Using selector and maxEls parameter, with forward and siblingOnly true.", () => {
        appendHtml();
        let maxEls = null;
        let className = "next-sibling";
        let selector = "." + className;
        let forward = true;
        let siblingOnly = true;

        let elementsFound = CUI.dom.findElements(div, selector, null, maxEls, forward, siblingOnly);

        expect(elementsFound.length).toBe(1);
        let hasClass = CUI.dom.hasClass(elementsFound[0], className);
        expect(hasClass).toBeTruthy();
    });
});

describe('CUI.dom.children(node, filter)', () => {

    let appendHtml = () => {
        document.body.innerHTML = `<div id="div">
                                        <span class="child"></span>
                                        <div class="child noFilter"></div>
                                   </div>`;
    };

    test("Without filter", () => {
        appendHtml();

        let childrenArray = CUI.dom.children(div);

        expect(childrenArray.length).toBe(2);
    });

    test("With filter as selector", () => {
        appendHtml();
        let className = "noFilter";
        let filterSelector = "." + className;

        let childrenArray = CUI.dom.children(div, filterSelector);

        expect(childrenArray.length).toBe(1);
        let hasClass = CUI.dom.hasClass(childrenArray[0], className);
        expect(hasClass).toBeTruthy();
    });

    test("With filter as function", () => {
        appendHtml();
        let className = "noFilter";
        let filterFunction = (node) => CUI.dom.hasClass(node, className);

        let childrenArray = CUI.dom.children(div, filterFunction);

        expect(childrenArray.length).toBe(1);
        let hasClass = CUI.dom.hasClass(childrenArray[0], className);
        expect(hasClass).toBeTruthy();
    });

});

describe('CUI.dom.firstElementChild(node, selector)', () => {

    let appendHtml = () => {
        document.body.innerHTML = `<div id="div">
                                        <div class="child first-element"></div>
                                        <div class="child element-wanted first"></div>
                                        <div class="child"></div>
                                        <div class="child element-wanted second"></div>
                                        <div class="child"></div>
                                   </div>`;
    };

    test("With selector null, then returns the first child", () => {
        appendHtml();

        let firstChild = CUI.dom.firstElementChild(div);

        expect(firstChild).toBeDefined();
        expect(firstChild).toBeInstanceOf(HTMLElement);
        let hasClass = CUI.dom.hasClass(firstChild, "first-element");
        expect(hasClass).toBeTruthy();
    });

    test("With selector as string", () => {
        appendHtml();
        let className = "element-wanted";
        let selectorWanted = "." + className;

        let elementFound = CUI.dom.firstElementChild(div, selectorWanted);

        expect(elementFound).toBeDefined();
        expect(elementFound).toBeInstanceOf(HTMLElement);
        let hasClass = CUI.dom.hasClass(elementFound, className);
        expect(hasClass).toBeTruthy();
        let isFirst = CUI.dom.hasClass(elementFound, "first");
        expect(isFirst).toBeTruthy();
    });

    test("With selector as string without children, then returns null", () => {
        appendHtml();
        let notFoundSelector = ".not-found-selector";

        let nullValue = CUI.dom.firstElementChild(div, notFoundSelector);

        expect(nullValue).toBeNull();
    });
});

describe('CUI.dom.lastElementChild(node, selector)', () => {

    let appendHtml = () => {
        document.body.innerHTML = `<div id="div">
                                        <div class="child first-element"></div>
                                        <div class="child element-wanted first"></div>
                                        <div class="child"></div>
                                        <div class="child element-wanted second"></div>
                                        <div class="child last-element"></div>
                                   </div>`;
    };

    test("With selector null, then returns the last child", () => {
        appendHtml();

        let firstChild = CUI.dom.lastElementChild(div);

        expect(firstChild).toBeDefined();
        expect(firstChild).toBeInstanceOf(HTMLElement);
        let hasClass = CUI.dom.hasClass(firstChild, "last-element");
        expect(hasClass).toBeTruthy();
    });

    test("With selector as string", () => {
        appendHtml();
        let className = "element-wanted";
        let selectorWanted = "." + className;

        let elementFound = CUI.dom.lastElementChild(div, selectorWanted);

        expect(elementFound).toBeDefined();
        expect(elementFound).toBeInstanceOf(HTMLElement);
        let hasClass = CUI.dom.hasClass(elementFound, className);
        expect(hasClass).toBeTruthy();
        let isFirst = CUI.dom.hasClass(elementFound, "second");
        expect(isFirst).toBeTruthy();
    });

    test("With selector as string without children, then returns null", () => {
        appendHtml();
        let notFoundSelector = ".not-found-selector";

        let nullValue = CUI.dom.lastElementChild(div, notFoundSelector);

        expect(nullValue).toBeNull();
    });

});

describe('CUI.dom.nextElementSibling(node, selector)', () => {
    let appendHtml = () => {
        document.body.innerHTML = `<div class="element-wanted previous-sibling"></div>
                                   <div id="div"></div>
                                   <div class="element-wanted next-sibling"></div>`;
    };

    test("With selector as string and existing sibling", () => {
        appendHtml();
        let className = "element-wanted";
        let selector = "." + className;

        let elementFound = CUI.dom.nextElementSibling(div, selector);

        expect(elementFound).toBeDefined();
        expect(elementFound).toBeInstanceOf(HTMLElement);
        let hasClass = CUI.dom.hasClass(elementFound, className);
        expect(hasClass).toBeTruthy();
        let isNextSibling = CUI.dom.hasClass(elementFound, "next-sibling");
        expect(isNextSibling).toBeTruthy();
    });

    test("With selector as string and non existing sibling", () => {
        appendHtml();
        let notFoundSelector = ".not-found-selector";

        let nullValue = CUI.dom.nextElementSibling(div, notFoundSelector);

        expect(nullValue).toBeNull();
    });
});

describe('CUI.dom.previousElementSibling(node, selector)', () => {
    let appendHtml = () => {
        document.body.innerHTML = `<div class="element-wanted previous-sibling"></div>
                                   <div id="div"></div>
                                   <div class="element-wanted next-sibling"></div>`;
    };

    test("With selector as string and existing sibling", () => {
        appendHtml();
        let className = "element-wanted";
        let selector = "." + className;

        let elementFound = CUI.dom.previousElementSibling(div, selector);

        expect(elementFound).toBeDefined();
        expect(elementFound).toBeInstanceOf(HTMLElement);
        let hasClass = CUI.dom.hasClass(elementFound, className);
        expect(hasClass).toBeTruthy();
        let isNextSibling = CUI.dom.hasClass(elementFound, "previous-sibling");
        expect(isNextSibling).toBeTruthy();
    });

    test("With selector as string and non existing sibling", () => {
        appendHtml();
        let notFoundSelector = ".not-found-selector";

        let nullValue = CUI.dom.nextElementSibling(div, notFoundSelector);

        expect(nullValue).toBeNull();
    });
});

describe('CUI.dom.setAttribute(node, key, value)', () => {
    test("Set attribute with string value", () => {
        let key = "id";
        let valueExpected = "idValue";

        CUI.dom.setAttribute(genericDiv, key, valueExpected)

        let setAttribute = CUI.dom.getAttribute(genericDiv, key)
        expect(setAttribute).toBe(valueExpected);
    });

    test("Set attribute with true value", () => {
        let key = "enabled";

        CUI.dom.setAttribute(genericDiv, key, true);

        let setAttribute = CUI.dom.getAttribute(genericDiv, key)
        expect(setAttribute).toBe(key);
    });

    test("Set attribute with false value", () => {
        let key = "enabled";

        CUI.dom.setAttribute(genericDiv, key, false);

        let hasAttribute = CUI.dom.hasAttribute(genericDiv, key)
        expect(hasAttribute).toBeFalsy();
    });
});

describe('CUI.dom.removeAttribute(node, key)', () => {
    test("With existing attribute", () => {
        document.body.innerHTML = `<div id="div" enabled="enabled"></div>`;
        let attributeToBeRemoved = "enabled";

        let hasAttribute = CUI.dom.hasAttribute(div, attributeToBeRemoved);
        expect(hasAttribute).toBeTruthy();

        CUI.dom.removeAttribute(div, attributeToBeRemoved);

        hasAttribute = CUI.dom.hasAttribute(div, attributeToBeRemoved);
        expect(hasAttribute).toBeFalsy();
    });
});

describe('CUI.dom.getAttribute(node, key)', () => {
    test("With existing attribute", () => {
        document.body.innerHTML = `<div id="div" someKey="aValue"></div>`;

        let attributeValue = CUI.dom.getAttribute(div, "someKey");
        expect(attributeValue).toBe("aValue")
    });
});

describe('CUI.dom.hasAttribute(node, key)', () => {
    test("With existing attribute", () => {
        document.body.innerHTML = `<div id="div" someKey="aValue"></div>`;

        let hasAttribute = CUI.dom.hasAttribute(div, "someKey");
        expect(hasAttribute).toBeTruthy()
    });

    test("Without existing attribute", () => {
        document.body.innerHTML = `<div id="div"></div>`;

        let hasAttribute = CUI.dom.hasAttribute(div, "someKey");
        expect(hasAttribute).toBeFalsy()
    });
});

describe('CUI.dom.setAttributeMap(node, map)', () => {

    test("With valid plain object", () => {
        let idKey = "id";
        let aKey = "aKey";
        let map = {
            [idKey]: "idValue",
            [aKey]: "aValue"
        };

        CUI.dom.setAttributeMap(genericDiv, map);

        let idValue = CUI.dom.getAttribute(genericDiv, idKey);
        expect(idValue).toBe(map[idKey]);

        let aValue = CUI.dom.getAttribute(genericDiv, aKey);
        expect(aValue).toBe(map[aKey]);
    });
});

describe('CUI.dom.replace(node, content)', () => {

    test("With valid node element", () => {
        document.body.innerHTML = `<div id="div">
                                        <p></p>
                                   </div>`;

        let span = CUI.dom.span();

        CUI.dom.replace(div, span);

        expect(div.children[0]).toBe(span);
    });
});

describe('CUI.dom.prepend(node, content)', () => {

    test("With valid node element", () => {
        document.body.innerHTML = `<div id="div">
                                        <p></p>
                                   </div>`;

        let span = CUI.dom.span();

        CUI.dom.prepend(div, span);

        expect(div.children[0]).toBe(span);
        expect(div.children[1]).toBeDefined();
    });
});

describe('CUI.dom.append(node, content)', () => {

    test("With valid node element", () => {
        document.body.innerHTML = `<div id="div">
                                        <p></p>
                                   </div>`;

        let span = CUI.dom.span();

        CUI.dom.append(div, span);

        expect(div.children[1]).toBe(span);
        expect(div.children[0]).toBeDefined();
    });
});

describe('CUI.dom.getAttribute(node, key)', () => {

    test("With existing attribute", () => {
        document.body.innerHTML = `<div id="div" key="some-value"></div>`;

        let value = CUI.dom.getAttribute(div, "key");

        expect(value).toBe("some-value");
    });
});

describe('CUI.dom.remove(node)', () => {

    test("With valid node element", () => {
        document.body.innerHTML = `<div id="div">
                                        <p></p>
                                   </div>`;

        CUI.dom.remove(div.children[0]);

        expect(div.children.length).toBe(0);
    });
});

describe('CUI.dom.empty(node)', () => {

    test("With valid node element", () => {
        document.body.innerHTML = `<div id="div">
                                        <p></p>
                                   </div>`;

        CUI.dom.empty(div);

        expect(div.children.length).toBe(0);
    });
});

describe('CUI.dom.hasClass(node, className)', () => {

    test("With an existing class", () => {
        document.body.innerHTML = `<div id="div" class="some-class"></div>`;

        let hasClass = CUI.dom.hasClass(div, "some-class");

        expect(hasClass).toBeTruthy();
    });

    test("Without an existing class", () => {
        document.body.innerHTML = `<div id="div"></div>`;

        let hasClass = CUI.dom.hasClass(div, "some-class");

        expect(hasClass).toBeFalsy();
    });
});

describe('CUI.dom.toggleClass(node, className)', () => {

    test("With existing class", () => {
        document.body.innerHTML = `<div id="div" class="some-class"></div>`;
        let className = "some-class";

        let hasClassBefore = CUI.dom.hasClass(div, className);

        CUI.dom.toggleClass(div, className);

        let hasClassAfter = CUI.dom.hasClass(div, className);

        expect(hasClassBefore).toBeTruthy();
        expect(hasClassAfter).toBeFalsy();
    });

    test("Without existing class", () => {
        document.body.innerHTML = `<div id="div"></div>`;
        let className = "some-class";

        let hasClassBefore = CUI.dom.hasClass(div, className);

        CUI.dom.toggleClass(div, className);

        let hasClassAfter = CUI.dom.hasClass(div, className);

        expect(hasClassBefore).toBeFalsy();
        expect(hasClassAfter).toBeTruthy();
    });
});

describe('CUI.dom.setClass(node, className, on_off)', () => {

    test("With 'off' value, then removes the class", () => {
        document.body.innerHTML = `<div id="div" class="some-class"></div>`;
        let className = "some-class";

        let hasClassBefore = CUI.dom.hasClass(div, className);

        CUI.dom.setClass(div, className, false);

        let hasClassAfter = CUI.dom.hasClass(div, className);

        expect(hasClassBefore).toBeTruthy();
        expect(hasClassAfter).toBeFalsy();
    });

    test("With 'on' value, then adds the class", () => {
        document.body.innerHTML = `<div id="div"></div>`;
        let className = "some-class";

        let hasClassBefore = CUI.dom.hasClass(div, className);

        CUI.dom.setClass(div, className, true);

        let hasClassAfter = CUI.dom.hasClass(div, className);

        expect(hasClassBefore).toBeFalsy();
        expect(hasClassAfter).toBeTruthy();
    });

    test("With 'on' value and existing class, then doesn't add the class", () => {
        document.body.innerHTML = `<div id="div" class="some-class"></div>`;
        let className = "some-class";

        let hasClassBefore = CUI.dom.hasClass(div, className);

        CUI.dom.setClass(div, className, true);

        let hasClassAfter = CUI.dom.hasClass(div, className);

        expect(hasClassBefore).toBeTruthy();
        expect(hasClassAfter).toBeTruthy();
    });
});

describe('CUI.dom.addClass(node, className)', () => {

    test("Without existing class", () => {
        document.body.innerHTML = `<div id="div"></div>`;
        let className = "some-class";

        let hasClassBefore = CUI.dom.hasClass(div, className);

        CUI.dom.addClass(div, className);

        let hasClassAfter = CUI.dom.hasClass(div, className);

        expect(hasClassBefore).toBeFalsy();
        expect(hasClassAfter).toBeTruthy();
    });
});

describe('CUI.dom.removeClass(node, className)', () => {

    test("With existing class", () => {
        document.body.innerHTML = `<div id="div" class="some-class"></div>`;
        let className = "some-class";

        let hasClassBefore = CUI.dom.hasClass(div, className);

        CUI.dom.removeClass(div, className);

        let hasClassAfter = CUI.dom.hasClass(div, className);

        expect(hasClassBefore).toBeTruthy();
        expect(hasClassAfter).toBeFalsy();
    });
});

describe('CUI.dom.isNode(node, level)', () => {

    test("With a div, returns true", () => {
        let div = CUI.dom.div();

        let isNode = CUI.dom.isNode(div);

        expect(isNode).toBeTruthy();
    });

    test("With window, returns true", () => {
        let isNode = CUI.dom.isNode(window);

        expect(isNode).toBeTruthy();
    });

    test("With a number, returns false", () => {
        let isNode = CUI.dom.isNode(123456);

        expect(isNode).toBeFalsy();
    });
});

describe('CUI.dom.insertChildAtPosition(node, nodeToInsert, position)', () => {

    test("With a valid position", () => {
        document.body.innerHTML = `<div id="div">
                                        <p></p>
                                        <p></p>
                                        <p></p>
                                   </div>`;

        let position = 1;
        let span = CUI.dom.span();

        CUI.dom.insertChildAtPosition(div, span, position);

        expect(div.children[position]).toBe(span);
        expect(div.children.length).toBe(4);
    });

    test("Without a valid position", () => {
        document.body.innerHTML = `<div id="div">
                                        <p></p>
                                   </div>`;
        try {
            let position = 999;
            let span = CUI.dom.span();

            CUI.dom.insertChildAtPosition(div, span, position);
            expect(true).toBeFalsy();
        } catch (error) {
            expect(true).toBeTruthy();
        }
    });
});

describe('CUI.dom.insertBefore(node, nodeToInsert)', () => {

    test("With a valid node", () => {
        document.body.innerHTML = `<div id="div">
                                        <p></p>
                                   </div>`;

        let span = CUI.dom.span();

        CUI.dom.insertBefore(div.children[0], span);

        expect(div.children[0]).toBe(span);
        expect(div.children[1]).toBeDefined();
        expect(div.children.length).toBe(2);
    });
});

describe('CUI.dom.insertAfter(node, nodeToInsert)', () => {

    test("With a valid node", () => {
        document.body.innerHTML = `<div id="div">
                                        <p></p>
                                   </div>`;

        let span = CUI.dom.span();

        CUI.dom.insertAfter(div.children[0], span);

        expect(div.children[0]).toBeDefined();
        expect(div.children[1]).toBe(span);
        expect(div.children.length).toBe(2);
    });
});

describe('CUI.dom.is(node, selector)', () => {

    test("With the same node as selector", () => {
        document.body.innerHTML = `<div id="div" class="a-class"></div>`;

        let is = CUI.dom.is(div, div);

        expect(is).toBeTruthy();
    });

    test("With an existing class as selector", () => {
        document.body.innerHTML = `<div id="div" class="a-class"></div>`;

        let is = CUI.dom.is(div, ".a-class");

        expect(is).toBeTruthy();
    });

    test("Without an existing class as selector", () => {
        document.body.innerHTML = `<div id="div"></div>`;

        let is = CUI.dom.is(div, ".a-class");

        expect(is).toBeFalsy();
    });

    test("With a function as selector", () => {
        document.body.innerHTML = `<div id="div" class="a-class"></div>`;

        let is = CUI.dom.is(div, node => CUI.dom.hasClass(node, "a-class"));

        expect(is).toBeTruthy();
    });
});

describe('CUI.dom.matchSelector(node, selector, trySelf)', () => {
    test("With one existing element with the selector", () => {
        document.body.innerHTML = `<div id="div" class="a-class">
                                       <span></span>
                                       <div>
                                           <span class="a-class"></span>
                                       </div>
                                   </div>`;

        let elementsFound = CUI.dom.matchSelector(div, ".a-class");

        expect(elementsFound.length).toBe(1);
        let hasClass = CUI.dom.hasClass(elementsFound[0], "a-class");
        expect(hasClass).toBeTruthy();
    });

    test("Without one existing element with the selector and try self true", () => {
        document.body.innerHTML = `<div id="div" class="a-class">
                                       <span></span>
                                       <div>
                                           <span></span>
                                       </div>
                                   </div>`;

        let elementsFound = CUI.dom.matchSelector(div, ".a-class", true);

        expect(elementsFound.length).toBe(1);
        let hasClass = CUI.dom.hasClass(elementsFound[0], "a-class");
        expect(hasClass).toBeTruthy();
    });

    test("Without one existing element with the selector and try self false", () => {
        document.body.innerHTML = `<div id="div">
                                       <span></span>
                                       <div>
                                           <span></span>
                                       </div>
                                   </div>`;

        let elementsFound = CUI.dom.matchSelector(div, ".a-class", false);

        expect(elementsFound.length).toBe(0);
    });
});

describe('CUI.dom.find(selector)', () => {
    test("With one existing element with the selector", () => {
        document.body.innerHTML = `<div id="div" class="a-class">
                                       <span></span>
                                       <div>
                                           <span class="a-class"></span>
                                       </div>
                                   </div>`;

        let elementsFound = CUI.dom.find(".a-class");

        expect(elementsFound.length).toBe(2);
        let hasClass = CUI.dom.hasClass(elementsFound[0], "a-class");
        expect(hasClass).toBeTruthy();
        hasClass = CUI.dom.hasClass(elementsFound[1], "a-class");
        expect(hasClass).toBeTruthy();
    });
});

describe('CUI.dom.elementsUntil(element, selector, untilElement)', () => {
    let appendHtml = () => {
        document.body.innerHTML = `<div id="divNode" class="node">
                                       <div></div>
                                       <div></div>
                                       <div id="divParent3" class="parent-3">
                                           <div id="divChild3" class="child-3"></div>
                                       </div>
                                   </div>`
    };

    test("Case 1", () => {
        appendHtml();

        let elements = CUI.dom.elementsUntil(divChild3, ".parent-3", divNode);

        expect(elements.length).toBe(2);
    });

    test("Case 2", () => {
        appendHtml();

        let elements = CUI.dom.elementsUntil(divChild3, ".child-3", divNode);

        expect(elements.length).toBe(1);
    });

    test("Case 3", () => {
        appendHtml();

        let elements = CUI.dom.elementsUntil(divChild3, ".node", divNode);

        expect(elements.length).toBe(3);
    });

    test("Case 4", () => {
        appendHtml();

        let elements = CUI.dom.elementsUntil(divParent3, ".node", divNode);

        expect(elements.length).toBe(2);
    });
});

describe('CUI.dom.parent(node)', () => {

    test("With parent", () => {
        document.body.innerHTML = `<div class="parent">
                                      <div id="div"></div>
                                   </div>`;

        let parent = CUI.dom.parent(div);

        let isParent = CUI.dom.hasClass(parent, "parent");
        expect(isParent).toBeTruthy();
    });

    test("When node is document", () => {
        let parent = CUI.dom.parent(document);

        expect(parent).toBe(window);
    });

    test("When node is window", () => {
        let parent = CUI.dom.parent(window);

        expect(parent).toBeNull();
    });
});

describe('CUI.dom.closest(node, selector)', () => {

    let appendHtml = () => {
        document.body.innerHTML = `<div id="divParent" class="node">
                                       <div></div>
                                       <div></div>
                                       <div class="a-selector found-element">
                                           <div id="div""></div>
                                       </div>
                                   </div>`
    };

    test("With existing element", () => {
        appendHtml();

        let elementFound = CUI.dom.closest(div, "a-selector");

        let isCorrectElement = CUI.dom.hasClass(elementFound, "found-element");
        expect(isCorrectElement).toBeDefined()
    });

    test("Without closest element", () => {
        appendHtml();

        let elementFound = CUI.dom.closest(divParent, "a-selector");

        expect(elementFound).toBeNull();
    });
});

describe('CUI.dom.replaceWith(node, newNode)', () => {

    test("With existing node", () => {
        document.body.innerHTML = `<div id="div">
                                       <div id="divToReplace"></div>
                                   </div>`;

        let classNewDiv = "new-div";
        let newDiv = CUI.dom.div(classNewDiv);

        CUI.dom.replaceWith(divToReplace, newDiv)

        let childrenReplaced = div.children[0];
        let isChildrenReplaced = CUI.dom.hasClass(childrenReplaced, classNewDiv);
        expect(isChildrenReplaced).toBeTruthy();
    });
});

describe('CUI.dom.setStyle(element, style, append)', () => {

    test("All types of styles", () => {
        let style = {
            "padding-bottom": 10,
            "display": "none",
            "margin": null
        };

        CUI.dom.setStyle(genericDiv, style);

        let divStyle = genericDiv.style;
        expect(divStyle["padding-bottom"]).toBe("10px");
        expect(divStyle["display"]).toBe("none");
        expect(divStyle["margin"]).toBe("");
    });

    test("With different 'append' parameter", () => {
        let append = "em";
        let style = {
            "padding-bottom": 1,
        };

        CUI.dom.setStyle(genericDiv, style, append);

        let divStyle = genericDiv.style;
        expect(divStyle["padding-bottom"]).toBe("1em");
    });
});

describe('CUI.dom.setStyleOne(element, styleName, styleValue)', () => {

    test("With number as value", () => {
        let value = 10;

        CUI.dom.setStyleOne(genericDiv, "width", value);

        expect(genericDiv.style["width"]).toBe("10px");
    });

    test("With string as value", () => {
        let value = "none";

        CUI.dom.setStyleOne(genericDiv, "display", value);

        expect(genericDiv.style["display"]).toBe(value);
    });
});

describe('CUI.dom.htmlToNodes(html)', () => {
    test("With valid html", () => {
        let html = `<div><span></span></div><div><p></p><p></p></div>`;

        let nodes = CUI.dom.htmlToNodes(html);

        expect(nodes[0].children.length).toBe(1);
        expect(nodes[1].children.length).toBe(2);
    });
});

describe('CUI.dom.findTextInNodes(nodes, callback, texts)', () => {
    test("With existing texts, without callback parameter", () => {
        document.body.innerHTML = `<div id="div">
                                       <span>Text node 1</span>
                                       <div>
                                           <div>
                                               <h1>Text node 2</h1>
                                           </div>
                                           <div>Text node 3</div>
                                       </div>
                                   </div>`;

        let texts = CUI.dom.findTextInNodes([div]);

        expect(texts.length).toBe(3);
        expect(texts[0]).toBe("Text node 1");
        expect(texts[1]).toBe("Text node 2");
        expect(texts[2]).toBe("Text node 3");
    });

    test("With existing texts, with callback parameter", () => {
        document.body.innerHTML = `<div id="div">
                                       <span>Text node 1</span>
                                       <div>
                                           <div>
                                               <h1>Text node 2</h1>
                                           </div>
                                           <div>Text node 3</div>
                                       </div>
                                   </div>`;

        let callbackTextArray = [];

        let toUpperCase = (textNode, textContent) => {
            callbackTextArray.push(textContent.toUpperCase())
        };

        let texts = CUI.dom.findTextInNodes([div], toUpperCase);

        expect(callbackTextArray.length).toBe(3);
        expect(callbackTextArray[0]).toBe("TEXT NODE 1");
        expect(callbackTextArray[1]).toBe("TEXT NODE 2");
        expect(callbackTextArray[2]).toBe("TEXT NODE 3");
    });
});

describe('CUI.dom.getCSSFloatValue(value)', () => {
    test("With value with px, then returns the number value", () => {
        let value = "10px";

        let floatValue = CUI.dom.getCSSFloatValue(value);

        expect(floatValue).toBe(10.0);
    });

    test("With a number, then returns 0", () => {
        let value = "10";

        let floatValue = CUI.dom.getCSSFloatValue(value);

        expect(floatValue).toBe(0);
    });
});

describe('CUI.dom.isVisible(element)', () => {
    test("When element is visible", () => {
        document.body.innerHTML = `<div id="div" style="display: block;"></div>`;

        let isVisible = CUI.dom.isVisible(div);

        expect(isVisible).toBeTruthy();
    });

    test("When element is not visible, first case", () => {
        document.body.innerHTML = `<div id="div" style="display: block; visibility: hidden;"></div>`;

        let isVisible = CUI.dom.isVisible(div);

        expect(isVisible).toBeFalsy();
    });

    test("When element is not visible, second case", () => {
        document.body.innerHTML = `<div id="div" style="display: none;"></div>`;

        let isVisible = CUI.dom.isVisible(div);

        expect(isVisible).toBeFalsy();
    });
});

describe('CUI.dom.hideElement(element)', () => {
    test("When element is visible", () => {
        document.body.innerHTML = `<div id="div"></div>`;

        let isVisibleBefore = div.style["display"];

        CUI.dom.hideElement(div)

        let isVisibleAfter = div.style["display"];

        expect(isVisibleBefore).toBe("");
        expect(isVisibleAfter).toBe("none");
    });
});

describe('CUI.dom.showElement(element)', () => {
    test("When element is not visible", () => {
        document.body.innerHTML = `<div id="div" style="display: none;"></div>`;

        let isVisibleBefore = div.style["display"];

        CUI.dom.showElement(div);

        let isVisibleAfter = div.style["display"];

        expect(isVisibleBefore).toBe("none");
        expect(isVisibleAfter).toBe("");
    });
});

