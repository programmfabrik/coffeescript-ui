const CUI = require('../../public/cui');
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

