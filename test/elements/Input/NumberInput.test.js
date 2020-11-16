require('../../index');

describe('CUI.NumberInput.parse', () => {
    test("Decimals: 0 | Number: 1000", () => {
        const input = "1000";

        const output = CUI.NumberInput.parse(input)

        expect(output).toBe(1000)
    });

    test("Decimals: 0 | Number: NotANumber", () => {
        const input = "NotANumber";
        const decimals = 0;

        const output = CUI.NumberInput.parse(input, decimals)

        expect(output).toBe(null)
    });

    test("Decimals: 0 | Number: 1.000.000", () => {
        const input = "1.000.000";
        const decimals = 0;

        const output = CUI.NumberInput.parse(input, decimals)

        expect(output).toBe(1000000)
    });

    test("Decimals: 0 | Number: 1.000", () => {
        const input = "1.000";
        const decimals = 0;

        const output = CUI.NumberInput.parse(input, decimals)

        expect(output).toBe(1000)
    });

    test("Decimals: 0 | Number: 1,000,000", () => {
        const input = "1,000,000";
        const decimals = 0;

        const output = CUI.NumberInput.parse(input, decimals)

        expect(output).toBe(1000000)
    });

    test("Decimals: 0 | Number: 1.000.000,50", () => {
        const input = "1.000.000,50";
        const decimals = 0;

        const output = CUI.NumberInput.parse(input, decimals)

        expect(output).toBe(1000000)
    });

    test("Decimals: 0 | Number: 1,000,000.50", () => {
        const input = "1,000,000.50";
        const decimals = 0;

        const output = CUI.NumberInput.parse(input, decimals)

        expect(output).toBe(1000000)
    });

    test("Decimals: 0 | Number: 100,000", () => {
        const input = "100,000";
        const decimals = 0;

        const output = CUI.NumberInput.parse(input, decimals)

        expect(output).toBe(100000)
    });

    test("Decimals: 2 | Number: 1000", () => {
        const input = "1000";
        const decimals = 0;

        const output = CUI.NumberInput.parse(input, decimals)

        expect(output).toBe(1000.00)
    });

    test("Decimals: 2 | Number: 1000.20", () => {
        const input = "1000.20";
        const decimals = 2;

        const output = CUI.NumberInput.parse(input, decimals)

        expect(output).toBe(1000.2)
    });

    test("Decimals: 2 | Number: 1,000.20", () => {
        const input = "1,000.20";
        const decimals = 2;

        const output = CUI.NumberInput.parse(input, decimals)

        expect(output).toBe(1000.2)
    });

    test("Decimals: 2 | Number: 1.000,20", () => {
        const input = "1.000,20";
        const decimals = 2;

        const output = CUI.NumberInput.parse(input, decimals)

        expect(output).toBe(1000.2)
    });

    test("Decimals: 2 | Number: 1,000.00", () => {
        const input = "1,000.00";
        const decimals = 2;

        const output = CUI.NumberInput.parse(input, decimals)

        expect(output).toBe(1000)
    });

    test("Decimals: 2 | Number: 1.000,2", () => {
        const input = "1.000,2";
        const decimals = 2;

        const output = CUI.NumberInput.parse(input, decimals)

        expect(output).toBe(1000.2)
    });

    test("Decimals: 2 | Number: 1000,2", () => {
        const input = "1000,2";
        const decimals = 2;

        const output = CUI.NumberInput.parse(input, decimals)

        expect(output).toBe(1000.2)
    });
});