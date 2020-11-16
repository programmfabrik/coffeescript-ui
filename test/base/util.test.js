require('../index');

describe('CUI.util.isFunction', () => {
    test("True case", () => {
        let aFunction = () => {};
        let isFunction = CUI.util.isFunction(aFunction);
        expect(isFunction).toBeTruthy();
    });

    test("False case", () => {
        let aFunction = "";
        let isFunction = CUI.util.isFunction(aFunction);
        expect(isFunction).toBeFalsy();
    });
});

describe('CUI.util.isArray', () => {
    test("True case", () => {
        let anArray = [];
        let isArray = CUI.util.isArray(anArray);
        expect(isArray).toBeTruthy();
    });

    test("False case", () => {
        let anArray = "";
        let isArray = CUI.util.isArray(anArray);
        expect(isArray).toBeFalsy();
    });
});

describe('CUI.util.isPlainObject', () => {
    test("True case", () => {
        let plainObject = {};
        let isPlainObject = CUI.util.isPlainObject(plainObject);
        expect(isPlainObject).toBeTruthy();
    });

    test("False case", () => {
        let plainObject = "";
        let isPlainObject = CUI.util.isPlainObject(plainObject);
        expect(isPlainObject).toBeFalsy();
    });

    test("False case 2", () => {
        let plainObject = CUI;
        let isPlainObject = CUI.util.isPlainObject(plainObject);
        expect(isPlainObject).toBeFalsy();
    });
});

describe('CUI.util.isEmptyObject', () => {
    test("True case", () => {
        let plainObject = {};
        let isEmptyObject = CUI.util.isEmptyObject(plainObject);
        expect(isEmptyObject).toBeTruthy();
    });

    test("False case", () => {
        let plainObject = {a: 1};
        let isEmptyObject = CUI.util.isEmptyObject(plainObject);
        expect(isEmptyObject).toBeFalsy();
    });
});

describe('CUI.util.inArray', () => {
    test("True case", () => {
        let anArray = [1,2,3,4,5];
        let isInArray = CUI.util.inArray(1, anArray);
        expect(isInArray).toBe(0);
    });

    test("False case", () => {
        let anArray = [1,2,3,5];
        let isInArray = CUI.util.inArray(4, anArray);
        expect(isInArray).toBe(-1);
    });
});

describe('CUI.util.isString', () => {
    test("True case", () => {
        let aString = "test";
        let isString = CUI.util.isString(aString);
        expect(isString).toBeTruthy();
    });

    test("False case", () => {
        let aString = {};
        let isString = CUI.util.isString(aString);
        expect(isString).toBeFalsy();
    });
});

describe('CUI.util.revertMap', () => {
    test("With correct map", () => {
        let map = {
            a: "z",
            b: "y",
            c: "x"
        };

        let mapReverted = CUI.util.revertMap(map);

        expect(mapReverted.z).toBe("a");
        expect(mapReverted.y).toBe("b");
        expect(mapReverted.x).toBe("c");
    });
});

describe('CUI.util.mergeMap', () => {
    test("With valid maps", () => {
        let targetMap = {
            a: 1,
            b: 2,
            d: {
                z: 100,
                y: 200
            }
        };
        let map = {
            a: 100,
            c: 3,
            d: {
                z: 200,
                x: 300
            },
            e: {
                a: 1
            }
        };

        CUI.util.mergeMap(targetMap, map);

        expect(targetMap.a).toBe(1);
        expect(targetMap.b).toBe(2);
        expect(targetMap.c).toBe(3);
        expect(targetMap.d.z).toBe(100);
        expect(targetMap.d.y).toBe(200);
        expect(targetMap.d.x).toBe(300);
        expect(targetMap.e.a).toBe(1);
    });

    test("With arguments as strings", () => {
        let targetMap = "target map";
        let result = CUI.util.mergeMap(targetMap, "map");
        expect(result).toBe(targetMap);
    });
});