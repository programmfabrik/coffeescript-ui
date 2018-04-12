require('../index');

describe('CUI.resolvedPromise', () => {
    test("Returns a resolved promise", () => {
        expect.assertions(1);
        let promise = CUI.resolvedPromise();
        promise.done(() => {
            expect(true).toBeTruthy();
        })
    });
});

describe('CUI.rejectedPromise', () => {
    test("Returns a rejected promise", () => {
        expect.assertions(1);
        let promise = CUI.rejectedPromise();
        promise.fail(() => {
            expect(true).toBeTruthy();
        })
    });
});

describe('CUI.chainedCall', () => {
    test("Invoke each function in order.", () => {
        expect.assertions(3);
        let order = 0;

        chainFunction = index => {
            expect(order).toBe(index);
            order++;
        };

        CUI.chainedCall(
            () => chainFunction(0),
            () => chainFunction(1),
            () => chainFunction(2)
        );
    });
});

describe('CUI.chunkWork', () => {
    test("With correct parameters", resolve => {
        expect.assertions(3);
        let items = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        let chunkSize = 5;
        let itemsDone = 0;

        CUI.chunkWork.call(this, {
            items: items,
            chunk_size: chunkSize,
            call: items => {
                expect(items.length).toBe(chunkSize);
                itemsDone += items.length;
            }
        }).done(() => {
            expect(itemsDone).toBe(10);
            resolve()
        })
    });
});

describe('CUI.setTimeout', () => {
    test("With correct parameters", resolve => {
        expect.assertions(1);
        let timeoutSeconds = 1000;
        let startTime = new Date().getTime();
        CUI.setTimeout(() => {
            let milliseconds = (new Date().getTime()) - startTime;
            expect(milliseconds / 1000).toBeCloseTo(timeoutSeconds / 1000);
            resolve()
        }, timeoutSeconds)
    });
});

describe('CUI.scheduleCallback', () => {
    test("With correct parameters", resolve => {
        expect.assertions(1);

        let callItOnce = () => {
            expect(true).toBeTruthy();
            resolve()
        };

        CUI.scheduleCallback({
            call: callItOnce,
            ms: 1000
        });

        CUI.scheduleCallback({
            call: callItOnce,
            ms: 500
        });
    });
});

describe('CUI.scheduleCallbackCancel', () => {
    test("With existing callback", () => {
        expect.assertions(1);

        let aFunction = () => expect(false).toBeTruthy();

        CUI.scheduleCallback({
            call: aFunction,
            ms: 1000
        });

        let wasCancelled = CUI.scheduleCallbackCancel({
            call: aFunction
        });

        expect(wasCancelled).toBeTruthy();
    });

    test("Without existing callback", () => {
        expect.assertions(1);

        let aFunction = () => expect(false).toBeTruthy();

        let wasCancelled = CUI.scheduleCallbackCancel({
            call: aFunction
        });

        expect(wasCancelled).toBeFalsy();
    });
});

// Deprecated. Remove when implementation is removed.
describe('CUI.mergeMap', () => {
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

        CUI.mergeMap(targetMap, map);

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
        let result = CUI.mergeMap(targetMap, "map");
        expect(result).toBe(targetMap);
    });
});

describe('CUI.getParameterByName', () => {
    test("With URL as parameter", () => {
        let expectedValue = "hello";
        let value = CUI.getParameterByName("test", "www.google.com?test=" + expectedValue);
        expect(value).toBe(expectedValue);
    });

    test("Without URL as parameter", () => {
        let parameterValue = CUI.getParameterByName("test");
        expect(parameterValue).toBe("");
    });
});

describe('CUI.encodeUrlData', () => {
    test("With parameters", () => {
        let expectedValue = "parameterOne=hello&parameterTwo=hello2";
        let value = CUI.encodeUrlData({parameterOne: "hello", parameterTwo: "hello2"});
        expect(value).toBe(expectedValue);
    });

    test("With different connectors characters", () => {
        let expectedValue = "parameterOne||hello%parameterTwo||hello2";
        let value = CUI.encodeUrlData({parameterOne: "hello", parameterTwo: "hello2"}, null, "%", "||");
        expect(value).toBe(expectedValue);
    });

    test("Without parameters", () => {
        let value = CUI.encodeUrlData();
        expect(value).toBe("");
    });
});

describe('CUI.decodeUrlData', () => {
    test("With parameters", () => {
        let expectedValue = {parameterOne: "hello", parameterTwo: "hello2"};
        let value = CUI.decodeUrlData("parameterOne=hello&parameterTwo=hello2");
        expect(value.parameterOne).toBe(expectedValue.parameterOne);
        expect(value.parameterTwo).toBe(expectedValue.parameterTwo);
    });

    test("With different connectors characters", () => {
        let expectedValue = {parameterOne: "hello", parameterTwo: "hello2"};
        let value = CUI.decodeUrlData("parameterOne||hello%parameterTwo||hello2", null, "%", "||");
        expect(value.parameterOne).toBe(expectedValue.parameterOne);
        expect(value.parameterTwo).toBe(expectedValue.parameterTwo);
    });

    test("Without parameters", () => {
        let value = CUI.decodeUrlData("");
        expect(CUI.util.isEmpty(value)).toBeTruthy();
    });
});

// Deprecated. Remove when implementation is removed.
describe('CUI.revertMap', () => {
    test("With correct map", () => {
        let map = {
            a: "z",
            b: "y",
            c: "x"
        };

        let mapReverted = CUI.revertMap(map);

        expect(mapReverted.z).toBe("a");
        expect(mapReverted.y).toBe("b");
        expect(mapReverted.x).toBe("c");
    });
});

// Deprecated. Remove when implementation is removed.
describe('CUI.isFunction', () => {
    test("True case", () => {
        let aFunction = () => {};
        let isFunction = CUI.isFunction(aFunction);
        expect(isFunction).toBeTruthy();
    });

    test("False case", () => {
        let aFunction = "";
        let isFunction = CUI.isFunction(aFunction);
        expect(isFunction).toBeFalsy();
    });
});

// Deprecated. Remove when implementation is removed.
describe('CUI.isPlainObject', () => {
    test("True case", () => {
        let plainObject = {};
        let isPlainObject = CUI.isPlainObject(plainObject);
        expect(isPlainObject).toBeTruthy();
    });

    test("False case", () => {
        let plainObject = "";
        let isPlainObject = CUI.isPlainObject(plainObject);
        expect(isPlainObject).toBeFalsy();
    });

    test("False case 2", () => {
        let plainObject = CUI;
        let isPlainObject = CUI.isPlainObject(plainObject);
        expect(isPlainObject).toBeFalsy();
    });
});

// Deprecated. Remove when implementation is removed.
describe('CUI.isEmptyObject', () => {
    test("True case", () => {
        let plainObject = {};
        let isEmptyObject = CUI.isEmptyObject(plainObject);
        expect(isEmptyObject).toBeTruthy();
    });

    test("False case", () => {
        let plainObject = {a: 1};
        let isEmptyObject = CUI.isEmptyObject(plainObject);
        expect(isEmptyObject).toBeFalsy();
    });
});

// Deprecated. Remove when implementation is removed.
describe('CUI.inArray', () => {
    test("True case", () => {
        let anArray = [1,2,3,4,5];
        let isInArray = CUI.inArray(1, anArray);
        expect(isInArray).toBe(0);
    });

    test("False case", () => {
        let anArray = [1,2,3,5];
        let isInArray = CUI.inArray(4, anArray);
        expect(isInArray).toBe(-1);
    });
});

// Deprecated. Remove when implementation is removed.
describe('CUI.isString', () => {
    test("True case", () => {
        let aString = "test";
        let isString = CUI.isString(aString);
        expect(isString).toBeTruthy();
    });

    test("False case", () => {
        let aString = {};
        let isString = CUI.isString(aString);
        expect(isString).toBeFalsy();
    });
});

describe('CUI.appendToUrl', () => {
    test("Without parameters", () => {
        let url = "www.google.com";
        let parameters = {parameterOne: "test", parameterTwo: "test2"};
        let urlWithParameters = CUI.appendToUrl(url, parameters);
        expect(urlWithParameters).toBe(url + "?parameterOne=test&parameterTwo=test2");
    });

    test("With existing parameters", () => {
        let url = "www.google.com?parameterOne=test";
        let parameters = {parameterTwo: "test2"};
        let urlWithParameters = CUI.appendToUrl(url, parameters);
        expect(urlWithParameters).toBe(url + "&parameterTwo=test2");
    });
});

describe('CUI.parseLocation', () => {
    test("With a full URL", () => {
        // Example: "http://www.google.com.ar:1000/uri/to/somewhere?parameterOne=test&parameterTwo=test2#someAnchor";
        let url = "www.google.com.ar";
        let port = "1000";
        let protocol = "http";
        let uri = "/uri/to/somewhere";
        let parameters = "?parameterOne=test&parameterTwo=test2";
        let anchor = "#someAnchor";

        let location = protocol + "://" + url + ":" + port + uri + parameters + anchor;
        let resultObject = CUI.parseLocation(location);

        expect(resultObject.origin).toBe(protocol + "://" + url + ":" + port);
        expect(resultObject.path).toBe(uri + parameters + anchor);
        expect(resultObject.protocol).toBe(protocol);
        expect(resultObject.search).toBe(parameters);
        expect(resultObject.href).toBe(location);
        expect(resultObject.hostname).toBe(url);
        expect(resultObject.pathname).toBe(uri);
        expect(resultObject.hash).toBe(anchor);
        expect(resultObject.port).toBe(port);
    });
});