require('../index');

describe('new CUI.Icon()', () => {
    test("With font-awesome icon.", () => {
        let icon = new CUI.Icon({"class": "fa-building"});

        expect(icon).toBeDefined();

        let elementClass = icon.getElementClass();
        let dom = icon.DOM;
        let hasFontAwesomeClass = CUI.dom.hasClass(dom, "fa");
        let hasIconClass = CUI.dom.hasClass(dom, "fa-building");

        expect(elementClass).toBe("Icon");
        expect(dom).toBeInstanceOf(HTMLElement);
        expect(dom.tagName).toBe("I");
        expect(hasFontAwesomeClass).toBeTruthy();
        expect(hasIconClass).toBeTruthy();
    });

    test("With svg icon.", () => {
        let icon = new CUI.Icon({icon: "svg-multiple"});

        expect(icon).toBeDefined();

        let elementClass = icon.getElementClass();
        let dom = icon.DOM;
        let hasCuiIconSvgClass = CUI.dom.hasClass(dom, "cui-icon-svg");
        let hasIconClass = CUI.dom.hasClass(dom, "svg-multiple");

        expect(elementClass).toBe("Icon");
        expect(dom).toBeInstanceOf(HTMLElement);
        expect(dom.tagName).toBe("svg");
        expect(hasCuiIconSvgClass).toBeTruthy();
        expect(hasIconClass).toBeTruthy();
    });

    test("Copy", () => {
        let icon = new CUI.Icon({"class": "fa-building"});

        let iconCopied = icon.copy();

        expect(icon).not.toBe(iconCopied);
        expect(icon.getElementClass()).toBe(iconCopied.getElementClass());
        expect(icon.DOM.innerHTML).toBe(iconCopied.DOM.innerHTML);
    });
});